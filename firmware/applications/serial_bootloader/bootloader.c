/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name: bootloader.c
*
* Description: Main module for bootloader application
*
* Bootloader application consist of severel files. There are:
*
* com.c        -  Serial Communication.  
*                 Receive data trought SCI, suport Xon/Xoff protocol. 
*                 Input data filtering. Check communication error.
* sparser.c    -  S-Record file parser. 
*                 Read S-Record format fields from com, store address, data, 
*                 and check checksum. Call prog to save received data into 
*                 DSP memory. 
* prog.c       -  Write received data into memory. 
*                 Ask com pause communication with host. When communication 
*                 was paused put data into ram or Flash then ask com resume 
*                 communication.
* bootloader.c -  Main function. 
*                 DSP initialization, and user input processing with error 
*                 indication subroutins.
* bootstart.c  -  Startup for application. 
*                 Clear data memory. Setup stack and call main() subroutine.
* resetvector.asm Reset and COP reset interrupt vectors definition.
* constdata.asm - Defenition of string data located in Boot Flash.
*
* Modules Included: 
*                       main()
*                       userInput()
*                       userLedFlash()
*                       userError()
*                       userToggleLed()
*                       userDelay() 
*                       ConfigureIO()
*                       StopIO()
*                       bootmemCopyXtoX()  
*                       bootmemCopyXtoP() 
*                       bootmemCopyPtoX()  
* 
*****************************************************************************/

#include "arch.h"
#include "periph.h"

#include "bootloader.h"
#include "com.h"
#include "sparser.h"
#include "prog.h"

/****************************************************************************/
   
UWord16 HexTable[HEX_TABLE_LENGTH] = /* Table for Hex to String convertion */
          {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};

char StringBuffer[STRING_BUFFER_LENGTH];

/****************************************************************************
*        Local function prototypes 
****************************************************************************/

static void userDelay         ( UWord16 Counter );
static void pllDelay		  (UWord16 Ticks);


/****************************************************************************
* Variables from linker.cmd file used to copy initialization data into .data
****************************************************************************/
extern void * _Xdata_start_addr_in_RAM;
extern void * _Xdata_ROMtoRAM_length;
extern void * _Xdata_start_addr_in_ROM;

extern void * _bss_start_addr;
extern void * _bss_length;
extern void * archStartDelayAddress;

/*****************************************************************************
*
* Module:         main()
*
* Description:    Initialize used hardware, Start S-Record loading. 
*                 After end disable used hardware and exit.
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

void main ( void )
{
   unsigned int TmpXdataVar;
   unsigned int i;
   unsigned int PLLStatus;
   
   /* The condition of bootloader start was checked in bootArchStart()        */
   /* before enter in main() function ( P:archStartDelayAddress != 0xfe00 )   */

  	
    /* Configure a minimum set of used hardware */
    archDisableInt();  		         
   
   /**************************************************************************/
   /* For DSP56F801EVM use external crystal oscillator */
      
   #if defined(DSP56801EVM)	
		/*disable Extal, Xtal pull up resistors */	
		periphMemWrite(PLL_DISABLE_PULLUP_EXTAL_XTAL, &ArchIO.PortB.PullUpReg);
				
		/* Delay for 40-50 ms for External Oscillator to stabilize */
		for (i=0; i<0x100; i++)
		{
			pllDelay(0x1fff);
		}		
				
   #endif /* defined(DSP56801EVM) */
	
    
       
   /* PLL initialization */  
   /* PRECS bit is reserved (0) for 803,805,807. For 801 it can be 0=Relaxation Osc. and  1 for external */
	 periphMemWrite((PLL_PRESCALER_EXTERNAL_CLK_SELECT |PLL_LOCK_DETECTOR \
												    	  | PLL_ZCLOCK_PRESCALER), &ArchIO.Pll.ControlReg);
												    	  	
   /* Write configuration values into PLL registers */
	periphMemWrite(PLL_TEST_REG,         &ArchIO.Pll.TestReg);
	periphMemWrite(PLL_CLKO_SELECT_ZCLK, &ArchIO.Pll.SelectReg);
	periphMemWrite(PLL_DIVIDE_BY_REG,    &ArchIO.Pll.DivideReg);

   /* Wait for PLL to lock */
	for (i=0; i<0x4000; i++)
	{
		PLLStatus = periphMemRead(&ArchIO.Pll.StatusReg);
		if ((PLLStatus & PLL_STATUS_LOCK_0) == PLL_STATUS_LOCK_0)
		{
			break;  /* PLL locked, so exit now */
		}
	}
   /* PLL did not lock, but proceed anyway */
		
   /* Program PLL to user defined value */
	periphMemWrite((PLL_CONTROL_REG| PLL_PRESCALER_EXTERNAL_CLK_SELECT), &ArchIO.Pll.ControlReg);
	
	/* Copy initialized data section from Boot Flash*/
  	 bootmemCopyPtoX( &_Xdata_start_addr_in_RAM,
		         &_Xdata_start_addr_in_ROM,
		         (UInt16)&_Xdata_ROMtoRAM_length);
   
         
   /* Initialize all bootloader subsystems */
   
   /* Get timeout value */

   bootmemCopyPtoX(&TmpXdataVar, &archStartDelayAddress, sizeof(unsigned int));

   comInit(((TmpXdataVar ^ 0xfe00) & 0xff00) ? 0x00ff : TmpXdataVar & 0x00ff);
   sprsInit();
   
   /* Display copyright */
   comPrintString((UWord16 *)StrCopyright);

   /* Start communication loop. Wait for S-Record file */
   comMainLoop();
   
   if ((progProgCounter != 0) || (progDataCounter != 0)) /* If started after loading file */
   {
      /* Display number of loaded words */
      comPrintString((UWord16 *)StrLoaded_1);
      comHex2String(progProgCounter, StringBuffer);
      comPrintString((UWord16 *)StringBuffer);
      comPrintString((UWord16 *)StrLoaded_2);
      comHex2String(progDataCounter, StringBuffer);
      comPrintString((UWord16 *)StringBuffer);
      comPrintString((UWord16 *)StrLoaded_3);
   }
   
   /* Display application started message */
   comPrintString((UWord16 *)StrStarted_1);

   /* Disable SCI */
   comResetPeripheralRegisters();
   
   userDelay(TERMINAL_OUTPUT_DELAY);

   /* User application will be started from bootArchStart() file after exit from main() */
}


/*****************************************************************************
*
* Module:         userError()
*
* Description:    Indicate number of bootloader error via Serial line.
*                 Perform processor reset.
*
* Returns:        Function does not return control.
*
* Arguments:      ErrorNumber
*
* Range Issues:   None
*
* Special Issues: Function does not return control and perform DSP reset
*
* Test Method:    boottest.mcp
*
*****************************************************************************/

void userError(int ErrorNumber)
{
   /* Display the error number */
   
   comPrintString((UWord16 *)StrError_1);
   comHex2String(ErrorNumber, StringBuffer);
   comPrintString((UWord16 *)StringBuffer);
   comPrintString((UWord16 *)StrError_2);

   /* go to bootloader startup */
   comResetPeripheralRegisters();
   bootArchStart();
}

/*****************************************************************************
*
* Module:         userDelay()
*
* Description:    Delay program execution aproximatly on (Counter * 8191)
*                 instruction clock cycles
*
* Returns:        None
*
* Arguments:      Counter - programmable delay
*
* Range Issues:   Used only 13 least significant bits from Counter
*
* Special Issues: used "rep" instruction 
*
* Test Method:    boottest.mcp
*
*****************************************************************************/

asm void userDelay(UWord16 Counter)
{
   do      y0,userDelay1
   movei   #0xffff, y0
   rep      y0          ;// bootloader does not serve any interrupts 
   nop
userDelay1:
	rts
}

/*****************************************************************************
*
* Module:         bootmemCopyXtoX()
*
* Description:    Copy src words from X:src to X:dest memory location
*                 Register usage:
*                    R2 - dest
*                    R3 - src
*                    Y0 - count, tmp variable 
*
* Returns:        (void *)(dest + count)
*
* Arguments:      dest - data destination
*                 scr  - data source
*                 count - data length in words 
*
* Range Issues:   0 <= count < 8191
*
* Special Issues: inline assembler used, "do" hardware cycle used
*                 No error checking for incorrect counter value.
*
* Test Method:    bootest.mcp
*
*****************************************************************************/

asm 	void *  bootmemCopyXtoX(void *dest, const void *src, size_t count)
{
			tstw    Y0
			beq     EndDo
			do      Y0,EndDo
			move    X:(R3)+,Y0
			move    Y0,X:(R2)+
EndDo:
			/* R2 - Contains *dest return value ??? */
			rts     
}


/*****************************************************************************
*
* Module:         bootmemCopyXtoP()
*
* Description:    Copy src words from X:src to P:dest memory location
*                 Register usage:
*                    R2 - dest
*                    R3 - src
*                    Y0 - count, tmp variable
*
* Returns:        (void *)(dest + count)
*
* Arguments:      dest - data destination
*                 scr  - data source
*                 count - data length in words 
*
* Range Issues:   0 <= count < 8191
*
* Special Issues: Inline assembler used, "do" hardware cycle used
*                 No error checking for incorrect counter value.
*
* Test Method:    bootest.mcp
*
*****************************************************************************/

asm void * bootmemCopyXtoP ( void *dest, const void *src, size_t count )
{
			tstw    Y0
			beq     EndDo
			do      Y0,EndDo
			move    X:(R3)+,Y0
			move    Y0,P:(R2)+
EndDo:
			/* R2 - Contains *dest return value */
			rts     
}


/*****************************************************************************
*
* Module:         bootmemCopyPtoX()
*
* Description:    Copy src words from P:src to X:dest memory location
*                 Register usage:
*                    R2 - dest
*                    R3 - src
*                    Y0 - count, tmp variable
*
* Returns:        (void *)(dest + count)
*
* Arguments:      dest - data destination
*                 scr  - data source
*                 count - data length in words 
*
* Range Issues:   0 <= count < 8191
*
* Special Issues: Inline assembler used, "do" hardware cycle used
*                 No error checking for incorrect counter value.
*
* Test Method:    bootest.mcp
*
*****************************************************************************/

asm void * bootmemCopyPtoX ( void *dest, const void *src, size_t count )
{
			tstw    Y0
			beq     EndDo
			do      Y0,EndDo
			move    P:(R3)+,Y0
			move    Y0,X:(R2)+
EndDo:
			/*  R2 - Contains *dest return value */
			rts     
}

/*****************************************************************************/
asm void pllDelay(UWord16 Ticks)
{
   move    y0,lc
   do      lc,pllDelay1
   nop
pllDelay1:
	rts
}
#define mr15	    $3F