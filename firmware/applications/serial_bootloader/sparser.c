/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name:         sparser.c
*
* Description:       S-Record parser
*
* Modules Included:  sprsInit()
*                    sprsReady()
*                    sprsHex2Word()
* 
*****************************************************************************/
#include "arch.h"
#include "periph.h"

#include "bootloader.h"
#include "com.h"
#include "sparser.h"
#include "prog.h"

/*****************************************************************************/
#define SPRS_FIELDLEN_ID            1
#define SPRS_FIELDLEN_TYPE          1
#define SPRS_FIELDLEN_LENGTH        2
#define SPRS_FIELDLEN_ADDRESS_4     8
#define SPRS_FIELDLEN_ADDRESS_2     4
#define SPRS_FIELDLEN_CHECKSUM      2

typedef enum { 
   MSB_FIRST = 0,
   LSB_FIRST
} OrderType;

typedef enum { 
   SPRS_STATE_WAIT = 0, 
   SPRS_STATE_TYPE, 
   SPRS_STATE_ADDRESS, 
   SPRS_STATE_LENGTH, 
   SPRS_STATE_DATA, 
   SPRS_STATE_CHECKSUM, 
} StateType;

typedef enum {
   SPRS_TYPE_0 = 0,
   SPRS_TYPE_3 = 0x03,
   SPRS_TYPE_7 = 0x07
} SRecordType;


static UWord16           sprsIndex;

static SRecordType       sprsRecordType;
static UWord16           sprsLength;
static UWord16           sprsAddress;
static mem_eMemoryType   sprsMemoryType;
static UWord16           sprsData[SPRS_BUFFER_LEN];
static UWord16           sprsChecksum;

static bool              sprsBegin;     /* start record resived */
static bool              sprsEnd;       /* end record received */
static StateType         sprsState = SPRS_STATE_WAIT;

/*****************************************************************************/
static UWord16 sprsHex2Word    ( char * Buffer, UWord16 Length, OrderType LSB );



/*****************************************************************************
*
* Module:         sprsInit()
*
* Description:    Initialize S record parser and start communications with 
*                 host
*
* Returns:        None
*
* Arguments:      None
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    boottest.mcp
*
*****************************************************************************/

void sprsInit    ( void )
{
   /* all zero initialization is done in bootArchStart() */

   comRead(SPRS_FIELDLEN_ID);
}

/*****************************************************************************
*
* Module:         sprsInit()
*
* Description:    Convert S-Record data received from SCI into binary form
*                 and place it into memory via progSaveData()
*
* Returns:        None
*
* Arguments:      ReadBuffer - communicatoion data buffer
*                 ReadLength - received data length
*
* Range Issues:   None
*
* Special Issues: None
*
* Test Method:    boottest.mcp
*
*****************************************************************************/

void sprsReady( UWord16 * ReadBuffer, UWord16 ReadLength)
{
   UWord16 i;
   UWord16 NextReadLength = 0;
      
   /* Check all characters */      
   for ( i = 0; i < ReadLength; i++)
   {
      if (!((( ReadBuffer[i] >= '0' ) && ( ReadBuffer[i] <= '9' )) || 
            (((ReadBuffer[i] & ~0x0020) >= 'A') && (( ReadBuffer[i] & ~0x0020 ) <= 'F')) || 
            ((ReadBuffer[i] == 'S') && ( sprsState == SPRS_STATE_WAIT))))
      {
         userError(INDICATE_ERROR_CHARACTER);            
      }   
   }

   /* calculate checksum over all fields */
   for ( i = 0; i < (ReadLength >> 1); i++)
   {
      sprsChecksum += sprsHex2Word((char *)&(ReadBuffer[i << 1]),2,LSB_FIRST);
   }
      
   switch(sprsState)
   {
      case SPRS_STATE_WAIT:
      {
         if(ReadBuffer[0] == 'S' )
         {
            sprsIndex = 0;
            sprsState = SPRS_STATE_TYPE;
            comRead(SPRS_FIELDLEN_TYPE);            
         }
         else
         {
            userError(INDICATE_ERROR_CHARACTER);
         }
      }
      break;
      case SPRS_STATE_TYPE:
      {
         sprsChecksum = 0;
         sprsRecordType  = sprsHex2Word((char *)ReadBuffer, SPRS_FIELDLEN_TYPE, LSB_FIRST);
         sprsState = SPRS_STATE_LENGTH;
         comRead(SPRS_FIELDLEN_LENGTH);            
      }
      break;
      case SPRS_STATE_LENGTH:
      {         
         /* in charactres */
         sprsLength  = sprsHex2Word((char *)ReadBuffer, SPRS_FIELDLEN_LENGTH, LSB_FIRST) << 1; 
         
         switch (sprsRecordType)
         {
            case SPRS_TYPE_0:
            {
               NextReadLength = 4;
            }
            break;
            case SPRS_TYPE_3:
            {
               NextReadLength = 8;
            }
            break;
            case SPRS_TYPE_7:
            {
               NextReadLength = 8;            
            }
            break;
            default:
            {
               /* possible action is ignore */
               userError(INDICATE_ERROR_FORMAT);
            }
         }
         if (sprsLength < (NextReadLength + 2)) /* less then address plus checksum */
         {
               userError(INDICATE_ERROR_FORMAT);         
         }
         
         sprsState = SPRS_STATE_ADDRESS;
         comRead(NextReadLength);
      }
      break;
      case SPRS_STATE_ADDRESS:
      {
         
         if (sprsRecordType == SPRS_TYPE_3)
         {
            sprsAddress       = sprsHex2Word((char *)ReadBuffer, 4, MSB_FIRST);
#if defined(SRECORD_WORD_ADDRESS)
            if (sprsAddress == 0x0020)
            {
               sprsMemoryType  = XData;
            }
            else
            {
               sprsMemoryType  = PData;
            }
            sprsAddress       = sprsHex2Word((char *)&(ReadBuffer[4]), 4, MSB_FIRST);         
#else /* defined(SRECORD_WORD_ADDRESS) */
            if (sprsAddress & 0x0020)
            {
               sprsMemoryType  = XData;
            }
            else
            {
               sprsMemoryType  = PData;
            }
            sprsAddress =  ( sprsAddress << 15 ) | 
                           ( sprsHex2Word(&(ReadBuffer[4]), 4, MSB_FIRST) >> 1 );
#endif defined(SRECORD_WORD_ADDRESS)

         }

         /* sprsPortionTmpLength in characters */
         sprsLength -= ReadLength;

         if (sprsLength <= 2)
         {
            NextReadLength = 2;
         
            sprsState = SPRS_STATE_CHECKSUM;            
         }
         else
         {
            NextReadLength = ((sprsLength - 2) > 4) ? 4: (sprsLength - 2);
         
            sprsState = SPRS_STATE_DATA;
         }
         comRead(NextReadLength);         
         
      }
      break;
      case SPRS_STATE_DATA:
      {

         if (sprsRecordType == SPRS_TYPE_3)
         {
            asm (nop);
         }         
         sprsData[sprsIndex++] = sprsHex2Word((char *)ReadBuffer, ReadLength, LSB_FIRST);

         sprsLength -= ReadLength;

         if (sprsLength == 2) 
         {
            NextReadLength = 2;
            sprsState = SPRS_STATE_CHECKSUM;            
         }
         else
         {
            NextReadLength = ((sprsLength - 2) > 4) ? 4: (sprsLength - 2);         
         }
         comRead(NextReadLength);         
      }
      break;
      case SPRS_STATE_CHECKSUM:
      {
         if (( sprsChecksum & 0x00ff ) == 0x00ff)
         {
            switch (sprsRecordType)
            {
               case SPRS_TYPE_0:
               {
                  sprsBegin = true;
                  sprsState = SPRS_STATE_WAIT;
                  comRead(SPRS_FIELDLEN_ID);         
               }
               break;
               case SPRS_TYPE_3:
               {
                  sprsState = SPRS_STATE_WAIT;
                  comRead(SPRS_FIELDLEN_ID);
                  if (sprsBegin)
                  {   
                     progSaveData ( sprsData, sprsIndex, sprsAddress,  sprsMemoryType);
                  }
                  else
                  {
                     userError(INDICATE_ERROR_FORMAT);
                  }
               }
               break;
               case SPRS_TYPE_7:
               {
                  if (sprsBegin)
                  {
                     sprsEnd  = true;
                     sprsState = SPRS_STATE_WAIT;
                     comExit();
                  }
                  else
                  {
                     userError(INDICATE_ERROR_FORMAT);
                  }
               }
               break;
               default:
               {
                  userError(INDICATE_ERROR_FORMAT);
               }
            }
         }
         else
         {
            userError(INDICATE_ERROR_CHECKSUM);
         }
      }
      break;
      default:
      {
         userError(INDICATE_ERROR_INTERNAL);
      }            
   } /* switch */

}

/*****************************************************************************
*
* Module:         sprsHex2Word()
*
* Description:    Convert Hexdecimal string into UWord16
*
* Returns:        resulting word
*
* Arguments:      Buffer - pointer to source string. One character in one word
*                 Length - string length in characters 
*                 LSB    - byte location type
*                          LSB == SPRS_LSB_FIRST   - LSB first
*                          LSB == SPRS_MSB_FIRST   - MSB
*
* Range Issues:   All hex digits are correct: 
*                             0 1 2 3 4 5 6 7 8 9 Aa Bb Cc Dd Ee Ff
*                 Length = 1,2,4
*
* Special Issues: None
*
* Test Method:    boottest.mcp
*
*****************************************************************************/
static UWord16 sprsHex2Word    ( char * Buffer, UWord16 Length, OrderType LSB )
{
   UWord16 i;
   UWord16 TmpDigit;
   UWord16 TmpByte   = 0;
   UWord16 ResWord   = 0;   
   
   for ( i = 0; i < Length; i++)
   {
      TmpDigit = Buffer[i];

      if ( TmpDigit > '9')
      {
         TmpDigit  =  (TmpDigit & 0x07u)  + 0x09u;
      }
    
      TmpByte |= ( TmpDigit & 0x0fu ) << ( ((i ^ 0x0001u) & 0x0001u) << 2u );

      if (i & 0x0001u)
      {
         if (LSB == LSB_FIRST)
         {
            ResWord |= TmpByte << ((i >> 1) << 3);
         }
         else
         {
            ResWord |= (TmpByte << 8u) >> ((i >> 1) << 3);      
         }
         TmpByte = 0;
      }
   }   
   if ( Length & 0x0001u )
   {
      if (LSB == LSB_FIRST)
      {
         ResWord |= (TmpByte >> 4u) << ((i >> 1) << 3);
      }
      else
      {
         ResWord |= (TmpByte << 4u) >> ((i >> 1) << 3);      
      }      
   }
   if (( LSB == false ) && ( Length < 4 ))
   {
      ResWord >>= ((UWord16)(4u  - Length ) << 2);
   }
   
   return ResWord;
}


