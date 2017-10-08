/**********************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
***********************************************************************
*
* File Name: V22bisAPI.c
*
* Description: This module is an API for V22bis data pump and to be
*              used by the user Application routines
*
* Modules Included:
*                   v22bisCreate ()
*                   v22bisInit ()
*                   v22bisTXDataInit ()
*                   v22bisTX ()
*                   v22bisTransmit ()
*                   v22bisRX ()
*                   v22bisDestroy()
*                   v22bisControl()
*                   TransmitV14 ()
*                   ReceiveV14 ()
*
* Author : Sanjay Karpoor
*
**************************** Change History **************************
*
*    DD/MM/YY     Code Ver    Description           Author
*    --------     --------    -----------           ------
*    13-09-2000   0.0.1       Created               Sanjay Karpoor
*    05-03-2001   1.0.0       Removed create,       Sanjay Karpoor
*                             destroy and control
*                             functions 
*    21-05-2001   1.0.1       Added create,         Prasad & Mahesh
*                             destroy and control
*                             functions
*
**********************************************************************/

#include "v22bis.h"
#include "stdlib.h"
#include "port.h"
#include "mem.h"

#define  NIBBLE_RECEIVED             0x0001
#define  ERROR_IN_HANDSHAKE          0x0002
#define  TRANSMIT_DATA_READY         0x0004
#define  HANDSHAKE_COMPLETE          0x0008
#define  RETRAINING_MODE             0x0010
#define  NUMRXBITS                   8
#define  NUMSAMPLES                  12
#define  STARTBIT_DETECTED           1
#define  STARTBIT_NOT_DETECTED       0
#define  START_BIT                   0
#define  STOP_BIT                    1
#define  STARTBIT_POSITION_V22BIS    0x8
#define  STARTBIT_POSITION_V22       0x2
#define  MSBIT_BYTE                  0x80
#define  LASTBYTE                    0x1
#define  NOT_LASTBYTE                0

/* #defines to be used for checking whether the modem is connected
   in V22 1200bps mode or v22bis 2400 bps mode. These #defines
   should be same as "V22Con" and "V22BisCon" defined in "gmdmequ.asm" 
   file
 */

#define  V22_MODE                    0x0200   
#define  V22BIS_MODE                 0x0400   

extern   Result    INITIALIZE_V22BIS (UWord16);
extern   void      V42_V22DRV_INIT (UWord16 *);
extern   void      V22BIS_TRANSMIT (void);
extern   Result    V22BIS_RECEIVE_SAMPLE (Word16);
extern   char      rx_data;
extern   UWord16   MDMCONFIG;  /*  To check sync / async mode */
extern   UWord16   MDMSTATUS;  /*  To check for V22 or V22bis mode */
extern   Word16    tx_out[12];
Result   v22bisTransmit  ( v22bis_sHandle * pV22bis, UWord16 * pNibble);
void     TransmitV14 (char InputByte, UWord16 ByteCount, UWord16 lastbyte);
Result   ReceiveV14 ( char *RxByte);

v22bis_sTXCallback  TXCallback;  /* Transmit callback structure */
v22bis_sRXCallback  RXCallback;  /* Receive callback structure */

Int16     messageover;
UWord16   ByteCount;
char      *BytePtr;
UWord16   NumberBytes;
UWord16   NibbleCount;
UWord16   Nibbles[3];
char      PartialRxByte;
Int16     startbit;
UWord16   rxbitcounter;  
Int16     v22dibittxcount;


/*********************************************************************
*
* Module: v22bisCreate ()
*
* Description: This module creates an instance of V22bis.
*              It calls the V22bis init routine, so that the 
*              user need not call init again. But even if user calls
*              init again after a call to this routine, the init is
*              done once again.
*
*              One word (16-bits) get allocated per instance
*
* Returns: Pointer to v22bis instance.
*
* Arguments: pConfig -> pointer to the structure of type 
*            v22bis_sConfigure. 
*            For more details on the elements of the structure, 
*            refer to "v22bis.h" file in the include directory.
*
* Range Issues:  None
*
* Special Issues:  This should be the first routine to be called
*                  before calling any of the V22bis tx, rx related
*                  routines
*
* Test Method:  Tested through loopback tests and demo.
*
**************************** Change History **************************
*
*    DD/MM/YY     Code Ver    Description       Author
*    --------     --------    -----------       ------
*    12-04-2000   0.0.1       Created           Sanjay Karpoor
*    13-09-2000   1.0.0       Reviewed and      Sanjay Karpoor
*                             Baselined 
*
**********************************************************************/

v22bis_sHandle *  v22bisCreate ( v22bis_sConfigure * pConfig)

{

    Result  result;
    v22bis_sHandle   *pV22bis;
    
    pV22bis = (v22bis_sHandle *) memMallocEM (sizeof(v22bis_sHandle));
    
    if ( pV22bis == NULL)
    {
        return (NULL);
    }    
	
	result = v22bisInit ( pV22bis, pConfig);

	return (pV22bis);
}

     
/**********************************************************************
*
* Module: v22bisInit ()
*
* Description: Initializes V22bis algorithm
*
* Returns: PASS or FAIL
*
* Arguments: pV22bis -> pointer to the structure of type v22bis_sHandle
*            pConfig -> pointer to the structure of type 
*                       v22bis_sConfigure 
*                       For more details on the elements of the 
*                       structure, refer to "v22bis.h" file in the
*                       include directory.
*
* Range Issues: None
*
* Special Issues: None
*
* Test Method: loopback_test.mcp - for loopback testing
*              interopans.mcp - for answer modem testing and 
*              interopcall.mcp - for call modem testing
*
**************************** Change History **************************
*
*    DD/MM/YY     Code Ver    Description       Author
*    --------     --------    -----------       ------
*    12-04-2000   0.0.1       Created           Sanjay Karpoor
*    13-09-2000   1.0.0       Reviewed and      Sanjay Karpoor
*                             Baselined 
*    06-03-2001   1.0.1       Removed handle    Sanjay Karpoor
*                             argument
*    21-05-2001   1.0.2       Added handle
*                             argument          Prasad & Mahesh
**********************************************************************/

Result v22bisInit ( v22bis_sHandle * pV22bis,
                    v22bis_sConfigure * pConfig)
{
   
    Result   result;
    UWord16  Flags, i;
    
    Flags      = pConfig-> Flags;          /* modem config bits */
    TXCallback = pConfig -> TXCallback; 
    RXCallback = pConfig -> RXCallback;

    messageover = true;                    /* Init for data tx */
    ByteCount = 0;
    NibbleCount = 0;
    NumberBytes = 0;
    
    startbit = STARTBIT_NOT_DETECTED;
    rxbitcounter = 0;
    PartialRxByte = 0;
    v22dibittxcount = 0;
    
    result = INITIALIZE_V22BIS ( Flags );  /* Configures MDMCONFIG */
    
    return (result);
    
}    


/**********************************************************************
*
* Module: v22bisTXDataInit ()
*
* Description: This module should be called by the user once the
*              modem enters into the data mode. User can call this
*              module whenever he/she has the data to transmit. After
*              calling this module once, user need to wait till 
*              modem transmits all the data. Upon successful 
*              transmission of the data, user can call this routine
*              again to initialize V22bis with the new data.
*              This module should not be called when the modem is
*              re-training.
*
* Returns: PASS or FAIL
*
* Arguments:   pV22bis -> pointer to the structure of type v22bis_sHandle
*              pBits -> pointer to the buffer containing the characters
*                       to be transmitted
*              NumBytes - Number of bytes in the character buffer
*
* Range Issues: None
*
* Special Issues: None
*
* Test Method: loopback_test.mcp - for loopback testing
*              interopans.mcp - for answer modem testing and 
*              interopcall.mcp - for call modem testing
*
**************************** Change History **************************
*
*    DD/MM/YY     Code Ver    Description       Author
*    --------     --------    -----------       ------
*    12-04-2000   0.0.1       Created           Sanjay Karpoor
*    13-09-2000   1.0.0       Reviewed and      Sanjay Karpoor
*                             Baselined 
*    06-03-2001   1.0.1       Removed handle    Sanjay Karpoor
*                             argument
*    21-05-2001   1.0.2       Added handle
*                             argument          Prasad & Mahesh
**********************************************************************/

Result v22bisTXDataInit ( v22bis_sHandle * pV22bis, char  * pBits,
                          UWord16 NumBytes)
{

    NumberBytes = NumBytes;
    BytePtr = pBits;
    
    messageover = false;
    ByteCount = 0;
    NibbleCount = 0;
    v22dibittxcount = 0;
        
    return (PASS);
}
    

/**********************************************************************
*
* Module: v22bisTX ()
*
* Description: This module generates samples at 7200 Hz for the user
*              to transmit through the codec. It generates 12 samples
*              per call and makes a call to the user callback routine.
*              This module should be called when the modem enters
*              into the data mode and modem is not doing re-training.
*              Before calling this module, user should initialize the
*              modem with the data to be transmitted by calling the
*              routine v22bisTXDataInit mentioned above. If this 
*              module is called without data init, it generates 
*              samples corresponding to the stop bits. This module
*              takes care of padding start and stop bits to the user
*              data in the async mode of operation.
*
* Returns:  PASS - If samples are generated for the user data.
*
*           FAIL - If user supplied data has been transmitted.
*                  If the user calls this module after the status is
*                  FAIL and the v22bis is not supplied with any data,
*                  it generates samples corresponding to the stop bits 
*
* Arguments: pV22bis -> pointer to V22bis instance
*
* Range Issues: None
*
* Special Issues:  1. Generates 12 samples per call.
*                  2. Should not be called when the modem is in
*                     the handshake or in the re-training mode.
*                  3. In the async mode, it should always be called
*                     irrespective of whether data is available for
*                     transmission or not. This is necessary to keep
*                     the carrier on the line so that the remote
*                     modem doesn't hang-up.
*
* Test Method: loopback_test.mcp - for loopback testing
*              interopans.mcp - for answer modem testing and 
*              interopcall.mcp - for call modem testing
*
**************************** Change History **************************
*
*    DD/MM/YY     Code Ver    Description       Author
*    --------     --------    -----------       ------
*    12-04-2000   0.0.1       Created           Sanjay Karpoor
*    13-09-2000   1.0.0       Reviewed and      Sanjay Karpoor
*                             Baselined 
*    06-03-2001   1.0.1       Removed handle    Sanjay Karpoor
*                             argument
*    21-05-2001   1.0.2       Added handle
*                             argument          Prasad & Mahesh
**********************************************************************/
    
Result v22bisTX (v22bis_sHandle * pV22bis)
{
    
    UWord16  Nibble, lastbyte;
    char     InputByte;
    Result   result;
    

    if ( messageover == true)
    {
        Nibbles[0] = 0x000f;
        v22bisTransmit  ( pV22bis, Nibbles);   
    }
    
    else if ( NibbleCount == 0)
    {
        if ( NumberBytes > 0)
        {
        
            lastbyte = NOT_LASTBYTE;
        
            if ( NumberBytes == 1)
            {
                lastbyte = LASTBYTE;
            }
                
            InputByte =  BytePtr[ByteCount];
            TransmitV14 ( InputByte, ByteCount, lastbyte);
            NumberBytes--;
            ByteCount++;
        }
    }
        
    if ( messageover == false)
    {
        
        if ((MDMSTATUS & V22_MODE) == V22_MODE)
        {
             if (v22dibittxcount == 0)
             {
                 NibbleCount--;
             }
        
             else
             {
                 Nibbles[NibbleCount] = Nibbles[NibbleCount] >> 2;
             }
        
            v22dibittxcount = v22dibittxcount ^ 0x0001;
        }
        
        else if ((MDMSTATUS & V22BIS_MODE) == V22BIS_MODE)
        {
             NibbleCount--;
        }
          
        v22bisTransmit  ( pV22bis, &Nibbles[NibbleCount]);   
    }        

    if ((MDMSTATUS & V22_MODE) == V22_MODE)
    {
        if ( ( NibbleCount == 0) && ( NumberBytes == 0) && (v22dibittxcount == 0))
        {
             messageover = true;        
        }
    }
    
    else if ((MDMSTATUS & V22BIS_MODE) == V22BIS_MODE)
    {
       if ( ( NibbleCount == 0) && ( NumberBytes == 0) )
       {
            messageover = true;        
       }
    }
    
    
    if ( messageover == true)
    {
        result = FAIL;
    }
    else
    {
        result = PASS;
    }    
    return ( result );
}
         
   
/**********************************************************************
*
* Module: v22bisTransmit ()
*
* Description: This module generates samples at 7200 Hz for the user
*              to transmit through the codec. It generates 12 samples
*              per call and makes a call to the user callback routine.
*
* Returns:  PASS - Always
*
* Arguments:  pV22bis -> pointer to the structure of type v22bis_sHandle
*             pNibble -> pointer to the word containing either 2 or
*                        4 valid bits.
*
* Range Issues: None
*
* Special Issues:  User should not call this module. This module
*                  is called by v22bisTX routine described above.
*
* Test Method: loopback_test.mcp - for loopback testing
*              interopans.mcp - for answer modem testing and 
*              interopcall.mcp - for call modem testing
*
**************************** Change History **************************
*
*    DD/MM/YY     Code Ver    Description       Author
*    --------     --------    -----------       ------
*    12-04-2000   0.0.1       Created           Sanjay Karpoor
*    13-09-2000   1.0.0       Reviewed and      Sanjay Karpoor
*                             Baselined 
*    06-03-2001   1.0.1       Removed handle    Sanjay Karpoor
*                             argument
*    21-05-2001   1.0.2       Added handle
*                             argument          Prasad & Mahesh
**********************************************************************/
    
Result v22bisTransmit ( v22bis_sHandle * pV22bis, UWord16 *pNibble)
{
       
    V42_V22DRV_INIT (pNibble);           /* Call for a packet of input
                                            bits. The bits are assumed
                                            to be packed in bytes
                                          */                                      
    V22BIS_TRANSMIT();
            
            
    /* Call back proc to indicate that data is ready in tx_out,
       status is always data available
     */  
            
    TXCallback.pCallback(                     
    				TXCallback.pCallbackArg,
					V22BIS_DATA_AVAILABLE,
					tx_out,
					NUMSAMPLES
				    );
                                        
    return (PASS);
    
}


/**********************************************************************
*
* Module: v22bisRX ()
*
* Description: This module should be called when the user collects
*              a few samples from the codec. The recommended number
*              is 12 though it can be called with any number of
*              samples. During power-up, only this module should
*              be called. When the connection is established
*              (handshake is complete) with the remote modem, this
*              module make a callback to the user transmit callback
*              function. During handshake and re-training mode, the
*              receiver itself calls the transmitter appropriately
*              and calls the user transmit callback routine to supply
*              the samples generated. It returns received bytes to
*              the user through the receive callback function.
*
* Returns:  PASS - Always
*
* Arguments: pV22bis -> pointer to V22bis instance
*            pSamples -> pointer to a buffer containing 16-bit linear
*                        samples to be processed
*            NumberSamples - Number of samples to be processed
*
* Range Issues: None
*
* Special Issues:   1. Returns one byte per receive callback.
*                   2. should be called always whether the modem is
*                      in handshake or data or re-training mode.
*
* Test Method: loopback_test.mcp - for loopback testing
*              interopans.mcp - for answer modem testing and 
*              interopcall.mcp - for call modem testing
*
**************************** Change History **************************
*
*    DD/MM/YY     Code Ver    Description       Author
*    --------     --------    -----------       ------
*    12-04-2000   0.0.1       Created           Sanjay Karpoor
*    13-09-2000   1.0.0       Reviewed and      Sanjay Karpoor
*                             Baselined 
*    06-03-2001   1.0.1       Removed handle    Sanjay Karpoor
*                             argument
*    21-05-2001   1.0.2       Added handle
*                             argument          Prasad & Mahesh
**********************************************************************/

Result v22bisRX  ( v22bis_sHandle * pV22bis, Word16 * pSamples, 
                   UWord16 NumberSamples)
{

    Word16  i, sample;
    Result  result, v14result;
    Int16   connection_rate;
     
    for ( i = 0; i < NumberSamples; i++)
    {
     
        sample = * pSamples++;                /* Get new sample */
         
        result = V22BIS_RECEIVE_SAMPLE (sample);
         

        if ( (result & RETRAINING_MODE) == RETRAINING_MODE)
        {  
              /* Return status = RETRAINING IN PROGRESS */
         
              TXCallback.pCallback(                     
					TXCallback.pCallbackArg,
					V22BIS_RETRAINING,
					NULL,
					0
				    );
        }      


        if ( (result & TRANSMIT_DATA_READY) == TRANSMIT_DATA_READY)
        {
         
          /* Return pointer to tx_data, status available */
          
              TXCallback.pCallback(                     
					TXCallback.pCallbackArg,
					V22BIS_DATA_AVAILABLE,
					tx_out,
					NUMSAMPLES
				    );
         
        }
               
        if ( (result & HANDSHAKE_COMPLETE) == HANDSHAKE_COMPLETE)
        { 
              /* Set the status to connection established */
             
              if ( (MDMSTATUS & V22_MODE) == V22_MODE)
              {
                  connection_rate = V22BIS_1200BPS_CONNECTION_ESTABLISHED;
              }
              
              else if ( (MDMSTATUS & V22BIS_MODE) == V22BIS_MODE)  
              {
                  connection_rate = V22BIS_2400BPS_CONNECTION_ESTABLISHED;
              }

              TXCallback.pCallback(                     
					TXCallback.pCallbackArg,
					connection_rate,
					NULL,
					0
				    );
        }
              
        if ( (result & NIBBLE_RECEIVED) == NIBBLE_RECEIVED)
        {
              /* Return x:rx_data and status = DATA AVAILABLE */
            
              v14result =  ReceiveV14 ( &rx_data);
              if (v14result == PASS)
              {
                                          
                  RXCallback.pCallback(                     
				    	RXCallback.pCallbackArg,
					    V22BIS_DATA_AVAILABLE,
				        &rx_data,
					    NUMRXBITS
				       );
			  }	       
        }
        
        if ( (result & ERROR_IN_HANDSHAKE) == ERROR_IN_HANDSHAKE)
        {  
              /* Return status = CONNECTION LOST */
         
              RXCallback.pCallback(                     
					RXCallback.pCallbackArg,
					V22BIS_CONNECTION_LOST,
					NULL,
					0
				    );
        }      
    }         
    
    return (PASS);
    
}


/**********************************************************************
*
* Module: v22bisDestroy ()
*
* Description: Destroys the instance of V22bis
*
* Returns:  PASS - Always
*
* Arguments: pV22bis -> pointer to V22bis instance
*
* Range Issues: None
*
* Special Issues: None
*
* Test Method: loopback_test.mcp - for loopback testing
*              interopans.mcp - for answer modem testing and 
*              interopcall.mcp - for call modem testing
*
**************************** Change History **************************
*
*    DD/MM/YY     Code Ver    Description       Author
*    --------     --------    -----------       ------
*    12-04-2000   0.0.1       Created           Sanjay Karpoor
*    13-09-2000   1.0.0       Reviewed and      Sanjay Karpoor
*                             Baselined 
*
**********************************************************************/

Result  v22bisDestroy( v22bis_sHandle * pV22bis)

{
     if (pV22bis != NULL)
     {
         memFreeEM (pV22bis);
     }    
     return (PASS);
}     



/*********************************************************************
* Module:  v22bisControl()
*
* Description: Not used as of now
*
* Returns:  PASS always
*
* Arguments: Type of command. Refer to the v22bis.h file
*
* Range Issues:  None
*
* Special Issues: None
*
* Test Method: Not required.
*
**************************** Change History **************************
*
*    DD/MM/YY     Code Ver    Description       Author
*    --------     --------    -----------       ------
*    12-04-2000   0.0.1       Created           Sanjay Karpoor
*    13-09-2000   1.0.0       Reviewed and      Sanjay Karpoor
*                             Baselined 
*
**********************************************************************/
Result  v22bisControl (UWord16  Command)

{

     return (PASS);
     
}     


/**********************************************************************
*
* Module: TransmitV14 ()
*
* Description: This module is called by v22bisTX module to append
*              start and stop bits in the async mode. In the sync,
*              mode it returns the nibbles without adding start and
*              stop bits. The first nibble to be transmitted is put
*              at the end of the buffer so that the transmit routine
*              can access from the bottom of the buffer. This is to
*              ease the implementation.
*
* Formula implemented -
*       For even bytes 3 nibbles will be generated in the following
*       format -
*                first nibble =  0, 1, b5, b6 ; 
*                second nibble = b7, b8, b1, b2
*                third nibble =  b3, b4, 0, 1
*
*       following assumption is made on the bit pattern within a byte 
*                b1, b2, b3, b4, b5, b6, b7, b8
*
*       for the last byte in a packet of data, 
*                first nibble =  1, 1, b5, b6.
*       This is because, the last byte should not have start bit for
*       the next byte.
*
*       Third nibble is stored at the bottom of the buffer and this is
*       the first nibble to be transmitted. Then the second nibble and
*       the first nibble should be transmitted.
*
* Returns:  Updates the globals - Number of bytes packed
*                               - The transmit nibble buffer
*                               - Number of nibbles generated 
*
* Arguments:  InputByte - A byte which is to be packed
*             ByteCount - The byte count in a packet of data.
*             lastbyte - flag to indicate the last byte in a packet
*
* Range Issues: None
*
* Special Issues: This is to be called only by v22bisTX and this
*                 routine should not be made visible to the user.
*                 This is not a generic V14 tx routine.
*
* Test Method: loopback_test.mcp - for loopback testing
*              interopans.mcp - for answer modem testing and 
*              interopcall.mcp - for call modem testing
*
**************************** Change History **************************
*
*    DD/MM/YY     Code Ver    Description       Author
*    --------     --------    -----------       ------
*    12-04-2000   0.0.1       Created           Sanjay Karpoor
*    13-09-2000   1.0.0       Reviewed and      Sanjay Karpoor
*                             Baselined 
*
**********************************************************************/

void TransmitV14 (char InputByte, UWord16 ByteCount, UWord16 lastbyte)
{

    UWord16  read_byte;
    Int16    op_byte;

    
    /* Reverse the nibble order in the byte */

    read_byte = ( InputByte >> 4 ) | ( (InputByte & 0xf) << 4 ); 

    /* To support synchronous operation */
    if (((ByteCount % 2) != 0) ||
         ((MDMCONFIG & V22BIS_V14_ENABLE_ASYNC_MODE) == 0))
    {
        Nibbles[NibbleCount++] = ( read_byte & 0xf ); 
        Nibbles[NibbleCount++] = ( read_byte >> 4 );
        
        /* In the sync mode it always returns from here */
    }
    
    else if ((ByteCount % 2) == 0)
    {

        if ( lastbyte == LASTBYTE)
        {
            op_byte = ( 0xc ) | ( (read_byte & 0xc ) >> 2 );
        }
        
        else
        {    
            op_byte = ( 0x4 ) | ( (read_byte & 0xc ) >> 2 );
        }
            
        Nibbles[NibbleCount++] = op_byte;

        op_byte = ((read_byte >> 6) | ((read_byte & 0x3) << 2 ));
        Nibbles[NibbleCount++] = op_byte;

        op_byte = ( (0x01) | ((read_byte & 0x30) >> 2) );
        Nibbles[NibbleCount++] = op_byte;

    }

    return;
            
}


/**********************************************************************
*
* Module: ReceiveV14 ()
*
* Description: This module packs the received nibble / 2 bits in
*              bytes.
*
* Returns:  None
*
* Arguments:  RxByte -> Pointer to a character location
*
* Range Issues: None
*
* Special Issues: This is to be called only by v22bisRX and this
*                 routine should not be made visible to the user.
*                 This is not a generic V14 rx routine.
*
* Test Method: loopback_test.mcp - for loopback testing
*              interopans.mcp - for answer modem testing and 
*              interopcall.mcp - for call modem testing
*
**************************** Change History **************************
*
*    DD/MM/YY     Code Ver    Description       Author
*    --------     --------    -----------       ------
*    12-04-2000   0.0.1       Created           Sanjay Karpoor
*    13-09-2000   1.0.0       Reviewed and      Sanjay Karpoor
*                             Baselined 
*
**********************************************************************/

Result ReceiveV14 ( char *RxByte)
{

     Result  result = FAIL;
     Int16   i, j, numbits, msbit_position;
     char    InputData, tempdata;
     char    InputBit;
     
     InputData = 0;
     tempdata = *RxByte;
     
     if ((MDMSTATUS & V22_MODE) == V22_MODE)
     {
         numbits = 2;
         msbit_position = STARTBIT_POSITION_V22;
     }
     
     else if ((MDMSTATUS & V22BIS_MODE) == V22BIS_MODE)
     {
         numbits = 4;
         msbit_position = STARTBIT_POSITION_V22BIS;
     }     
         
     
     for ( i = 0; i <numbits ; i++)
     {
         if ((( tempdata >> i) & STOP_BIT) == STOP_BIT)
         {
             InputData = InputData | (msbit_position >> i);
         }
     }    
          
     for ( i = 0; i < numbits; i++)
     {

         /* This will enable the sync mode */
         if ((MDMCONFIG & V22BIS_V14_ENABLE_ASYNC_MODE) == 0)
         {
              startbit =  STARTBIT_DETECTED;
         }
                 
         InputBit = InputData & msbit_position;
         InputBit = InputBit >> (numbits - 1);
         InputData = InputData << 1;
         
         if ( startbit == STARTBIT_NOT_DETECTED)
         {
              if ( InputBit == 0)
              {
                  startbit = STARTBIT_DETECTED;
              }
         }
         
         else
         {
              PartialRxByte = (PartialRxByte << 1) | InputBit;
              rxbitcounter++;
              
              if ( rxbitcounter == NUMRXBITS)
              {   
                  tempdata = 0;
                  PartialRxByte = PartialRxByte & 0xff;
                  
                  for ( j = 0; j < 8; j++)
                  {
                      if ((( PartialRxByte >> j) & STOP_BIT) == STOP_BIT)
                      {
                         tempdata  = tempdata | (MSBIT_BYTE >> j);
                      }
                  }    
                  
                  *RxByte = tempdata;

                  result = PASS;
                    
                  startbit = STARTBIT_NOT_DETECTED;
                  rxbitcounter = 0;
                  PartialRxByte = 0;
              }   
         }
         
      }
      
      return (result);      
}         

