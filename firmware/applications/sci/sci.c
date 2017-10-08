/*******************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
********************************************************************************
*
* FILE NAME: sci.c
*
*******************************************************************************/

#include "bsp.h"
#include "io.h"
#include "fcntl.h"
#include "mempx.h"

#include "assert.h"

#include "sci.h"


#define X_MEMORY 'X'
#define P_MEMORY 'P'

#define MEMORY_SIZE 0x101

#define BUFFER_SIZE 10

UWord16 Buffer[MEMORY_SIZE];

/******************************************************************************/
int main()
{
   UWord16        StartLoc;
   UWord16        OneWord;
   UWord16     *  pData;
   UWord16        MemoryType;
   UWord16        I;
   int            SciFD;
   sci_sConfig    SciConfig;

   for ( I = 0; I < MEMORY_SIZE; I++)
   {
      Buffer[I] = I;
   }

   SciConfig.SciCntl    =  SCI_CNTL_WORD_8BIT | SCI_CNTL_PARITY_NONE;
   SciConfig.SciHiBit   =  SCI_HIBIT_0;
   SciConfig.BaudRate   =  SCI_BAUD_28800;

   SciFD = open(BSP_DEVICE_NAME_SCI_0, O_RDWR, &(SciConfig)); /* open device in Blocking mode */

   if ( SciFD  == -1 )
   {
      assert(!" Open /sci0 device failed.");
   }
   
   while(true)
   {
      ioctl( SciFD, SCI_DATAFORMAT_EIGHTBITCHARS, NULL );
         
      read(SciFD, &MemoryType, sizeof(UWord16));

      ioctl( SciFD, SCI_DATAFORMAT_RAW, NULL );

      read(SciFD, &StartLoc, sizeof(StartLoc));

      if(MemoryType == X_MEMORY)
      {
         write( SciFD, (UWord16 *)StartLoc, MEMORY_SIZE);
      }
      else if(MemoryType == P_MEMORY)
      {
         pData = (UWord16 *)StartLoc; 

         for(I = 0; I < MEMORY_SIZE; I++, pData++)
         {
            OneWord = memReadP16(pData);
            write(SciFD, &OneWord, sizeof(OneWord));
         }
      }
   }
}
