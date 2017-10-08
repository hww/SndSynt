/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name:         com.c
*
* Description:       Bootloader Communication subsystem
*
* Modules Included:  comInit()
*                    comPrintString()
*                    comHex2String()
*                    comMainLoop()
*                    comExit()
*                    comDisable()
*                    comStopReceive()
*                    comResumeReceive()
*                    comRead()
* 
*****************************************************************************/

#include "arch.h"
#include "periph.h"

#include "bootloader.h"
#include "com.h"
#include "sparser.h"
#include "prog.h"

/*****************************************************************************/
/* Calculate SCI baud rate based on PLL after reset state (PLL powered down) */
/* IP bus clock is Oscilator clock divided by default prescaler equal 1 and  */
/* devided by 2                                                              */
#define SCI_GET_SBR(BaudRate) ((UWord16)(((ZCLOCK_FREQUENCY / 16u /  \
                              (unsigned long)(BaudRate)) + 1u) / 2u) & 0x1fffu)

#define SCI_SBR_VALUE         SCI_GET_SBR(SCI_BAUD_RATE)

/*****************************************************************************/
#define  COM_XON           17       /* Ctrl Q  17 */
#define  COM_XOFF          19       /* Ctrl S  19 */

#define  COM_BUFFER_LEN    10

static UWord16  comSciBaudRate = SCI_GET_SBR(SCI_BAUD_RATE);
static UWord16  comBuffer[COM_BUFFER_LEN];
static UWord16  comIndex;
static UWord16  comReadLength = 1;
static bool     comContinue = true;
static bool     comTimerStarted;
static UWord16  comTimerCounter;

static bool     comInitTimerStarted;
static UWord16  comInitTimerCounterLow;
static UWord16  comInitTimerCounterHi;


#define comSetInitTimer(counter)    (comInitTimerCounterHi = counter << 5, \
                                     comInitTimerCounterLow = COM_TIMEOUT_INIT_SECOND, \
                                     comInitTimerStarted = true)
#define comInitTimerIsExpired() ( ((comInitTimerCounterHi == (0x00ff << 5)) || ((comInitTimerCounterHi--)!=0)) ? \
                                    comInitTimerCounterLow = COM_TIMEOUT_INIT_SECOND, false : \
                                    true )
#define comCancelInitTimer() (comInitTimerStarted = false) 
#define comInitTimerIsSet()  (comInitTimerStarted == true) 

/* Pseudo timer functions */
#define comCheckTimers()    ((!comTimerStarted || --comTimerCounter) && \
                              (!comInitTimerStarted || --comInitTimerCounterLow))
#define comCancelTimer()   (comTimerStarted = false)
#define comSetTimer()      (comTimerStarted = true, comTimerCounter = COM_TIMEOUT_VALUE)

/*****************************************************************************/
#define SCI0_GPIO_MASK        0x0003u
#define COM_SELECT_SCI        0x0200u

/* SCICR mode select bits */
#define SCI_SCICR_LOOP        0x8000u
#define SCI_SCICR_SWAI        0x4000u
#define SCI_SCICR_RSRC        0x2000u
#define SCI_SCICR_M           0x1000u
#define SCI_SCICR_WAKE        0x0800u
#define SCI_SCICR_POL         0x0400u
#define SCI_SCICR_PE          0x0200u
#define SCI_SCICR_PT          0x0100u
#define SCI_SCICR_TEIE        0x0080u
#define SCI_SCICR_TIIE        0x0040u
#define SCI_SCICR_RIE         0x0020u
#define SCI_SCICR_REIE        0x0010u
#define SCI_SCICR_TE          0x0008u
#define SCI_SCICR_RE          0x0004u
#define SCI_SCICR_RWU         0x0002u
#define SCI_SCICR_SBK         0x0001u

/* SCI Status Registers bits */
#define SCI_SCISR_TDRE        0x8000u
#define SCI_SCISR_TIDLE       0x4000u
#define SCI_SCISR_RDRF        0x2000u
#define SCI_SCISR_RIDLE       0x1000u
#define SCI_SCISR_OR          0x0800u
#define SCI_SCISR_NF          0x0400u
#define SCI_SCISR_FE          0x0200u
#define SCI_SCISR_PF          0x0100u
#define SCI_SCISR_RAF         0x0001u


/*****************************************************************************
*
* Module:         comInit()
*
* Description:    Initialize communications.
*
* Returns:        None
*
* Arguments:      Timeout befor start application if no SCI activity
*
* Range Issues:   0 > InitTimeout < 0x00ff - timeout in seconds 
*                 InitTimeout == 0x00ff    - wait forever
*
* Special Issues: Set comTimerCounter and comInitTimerCounter variable
*
* Test Method:    boottest.mcp
*
*****************************************************************************/

void comInit          ( UWord16 InitTimeout )
{
   /* all zero initialization is done in archStart() */
   
   /* Initialize SCI0 */
   #if defined(DSP56801EVM)	     
	   periphBitSet(SCI0_GPIO_MASK, &ArchIO.PortB.PeripheralReg);
   #endif
   #if defined(DSP56803EVM) || defined(DSP56805EVM) || defined(DSP56807EVM)
          periphBitSet(SCI0_GPIO_MASK, &ArchIO.PortE.PeripheralReg);   			    
   #endif	   
   #ifdef DSP56826EVM
       periphBitSet(COM_SELECT_SCI, &ArchIO.Sim.ControlReg);
   #endif
   periphMemWrite(comSciBaudRate, &ArchIO.Sci0.BaudRateReg);
   periphMemWrite(SCI_SCICR_TE | SCI_SCICR_RE | SCI_MODE, &ArchIO.Sci0.ControlReg);
   

   

   /* Initialize pseudo timers */
   
   comTimerCounter = COM_TIMEOUT_VALUE;
   
   comCancelTimer();

   comSetInitTimer(InitTimeout);
}

/*****************************************************************************
*
* Module:         comPrintString()
*
* Description:    Output string from X memory to SCI port.
*
* Returns:        None
*
* Arguments:      pStr - pointer to string with 0 in the end.
*
* Range Issues:   None
*
* Special Issues: characters in string are packed as two character in one word
*
* Test Method:    boottest.mcp
*
*****************************************************************************/

void comPrintString  ( UWord16 * pStr )
{
   UWord16 SciStatus;
   UWord16 SciShift = 0x0008u;

   while ( (*pStr >> SciShift) & 0x00ff )
   {
      do
      {
         SciStatus = periphMemRead(&ArchIO.Sci0.StatusReg);
      }
      while ((SciStatus & SCI_SCISR_TDRE) == 0);

      periphMemWrite(*pStr >> SciShift, &ArchIO.Sci0.DataReg);   

      if (SciShift ^= 0x0008u) 
      {
         pStr++;      
      }
   } 

   do
   {
      SciStatus = periphMemRead(&ArchIO.Sci0.StatusReg);
   }
   while ((SciStatus & SCI_SCISR_TIDLE) == 0 );

}

/*****************************************************************************
*
* Module:         comHex2String()
*
* Description:    Convert Data word into hexdecimal string.
*
* Returns:        pStr contains resulting string
*
* Arguments:      Data  - word to be converted
*                 pSrc  - pointer to 3 words buffer.
*
* Range Issues:   None
*
* Special Issues: HexTable[] global table used.
*
* Test Method:    boottest.mcp
*
*****************************************************************************/
 
void comHex2String(UWord16 Data, char * pStr)
{

   pStr[0]  = ( HexTable[ Data >> 12 ] << 8 ) | 
              ( HexTable[ (Data >> 8) & 0x000f] );
   pStr[1]  = ( HexTable[ (Data >> 4) & 0x000f] << 8 ) |
              ( HexTable[ Data & 0x000f] );

   pStr[2]  = 0;
}

/*****************************************************************************
*
* Module:         comMainLoop()
*
* Description:    Main communication loop.
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

void comMainLoop      ( void )
{   
   UWord16 ReadSCIState;
   UWord16 ReadSCIWord;
   
   /* Initialize progress indicator */
   *StringBuffer     = '.' << 8;
   
   while (comContinue)
   {
#if defined(DEBUG_LED)
      USER_OUTPUT_REGISTER   ^= USER_OUTPUT_BIT;   
#endif /* defined(DEBUG_LED) */
   
      /* wait SCI data or while pseudo timers expired, if set */
      do 
      {
         ReadSCIState   = periphMemRead(&ArchIO.Sci0.StatusReg);
      }
      while (((ReadSCIState &  ( SCI_SCISR_RDRF | SCI_SCISR_OR | 
                              SCI_SCISR_NF | SCI_SCISR_FE | SCI_SCISR_PF)) == 0) &&
              comCheckTimers());
      
      if (ReadSCIState & ( SCI_SCISR_RDRF | SCI_SCISR_OR | 
                           SCI_SCISR_NF | SCI_SCISR_FE | SCI_SCISR_PF))
      {  
         
         comCancelInitTimer();
         
         /* Received SCI byte */
         
         periphMemWrite(0, &ArchIO.Sci0.StatusReg);         /* Clear status */
                   
         ReadSCIWord = periphMemRead(&ArchIO.Sci0.DataReg); /* Read data (and clear stutus) */
                   
         if (ReadSCIState & (SCI_SCISR_OR | SCI_SCISR_FE | SCI_SCISR_PF))
         {
            userError(INDICATE_ERROR_RECEIVE);
         }
      
         comTimerCounter = COM_TIMEOUT_VALUE;

         /* remove all control characters */
         if (ReadSCIWord >= ' ')
         {
            comBuffer[comIndex++] =  ReadSCIWord;        /* Save received byte */
            
            if (comIndex >= comReadLength)
            {                                            /* buffer full */
               sprsReady(comBuffer, comReadLength);      /* call S-Record parser */
            }
         }                       
      }
      else  
      {
         if (comInitTimerIsSet())
         {  /* low timeot for init timer */
            if (comInitTimerIsExpired())
            {
               /* exit and start previous application */
               comCancelInitTimer();
               comExit();
            }
         }
         else         
         { /* timeout for X-On/X-Off protocol expired */
            progEnable();     /* Enable Flash programming */
         }
      }
   }  /* while */

   progFlush();    /* Save the latest data, and write Timeout variable into P flash */
}

/*****************************************************************************
*
* Module:         comExit()
*
* Description:    Set flag to exit from comMainLoop(), called from S record 
*                 parser
*
* Returns:        None
*
* Arguments:      None
*
* Range Issues:   None
*
* Special Issues: reset comContinue flag 
*
* Test Method:    boottest.mcp
*
*****************************************************************************/

void comExit ( void )
{
   comContinue = false;
}

/*****************************************************************************
*
* Module:         comResetPeripheralRegisters()
*
* Description:    Resets peripheral registers to reset state
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

void comResetPeripheralRegisters ( void )
{
	/* Reset SCI0 registers to reset state */
	periphMemWrite(0x0000, &ArchIO.Sci0.ControlReg);
	periphMemWrite(0x0004, &ArchIO.Sci0.BaudRateReg);
	periphMemRead (&ArchIO.Sci0.StatusReg); /* Clear Rx Data Reg Full/Rx Idle Line Flags */
	periphMemRead (&ArchIO.Sci0.DataReg);

	/* Reset PLL registers to reset state */
	periphMemWrite(0x0011, &ArchIO.Pll.ControlReg);
	periphMemWrite(0x2013, &ArchIO.Pll.DivideReg);
}

/*****************************************************************************
*
* Module:         comStopReceive()
*
* Description:    Send X-Off symbol, set timer to period while protocol  
*                 continue receive data from host.
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

void comStopReceive   ( void )
{   
   UWord16 State;
   
   do 
   {
      State = periphMemRead(&ArchIO.Sci0.StatusReg);
   }
   while ((State & SCI_SCISR_TDRE) == 0);
   
   periphMemWrite(COM_XOFF, &ArchIO.Sci0.DataReg);         
   
   comSetTimer();
             
}

/*****************************************************************************
*
* Module:         comResumeReceive()
*
* Description:    Send X-On symbol, cancel protocol timer
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

void comResumeReceive ( void )
{   
   UWord16 State;

   do 
   {
      State = periphMemRead(&ArchIO.Sci0.StatusReg);
   }
   while ((State & SCI_SCISR_TDRE) == 0);
   
   periphMemWrite(COM_XON, &ArchIO.Sci0.DataReg);         
             
   comCancelTimer();
}

/*****************************************************************************
*
* Module:         comRead()
*
* Description:    Start reading data from SCI. 
*
* Returns:        None
*
* Arguments:      None
*
* Range Issues:   None
*
* Special Issues: Set two global variables
*
* Test Method:    None
*
*****************************************************************************/

void comRead          ( UWord16 Length )
{
   comReadLength  = Length;
   comIndex       = 0;
}

