/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name:         bootstart.c
*
* Description:       Startup for Bootloader application
*
* Modules Included:  bootArchStart()
*                    
* 
*****************************************************************************/

#include "arch.h"
#include "bootloader.h"

/****************************************************************************/
#define mr15	      $3F

/* Define registers and bits to work with COP */

#define CEN          $0002
#define CWP          $0001

extern void * archStartDelayAddress;
extern void archStart(void);  /* Defined in linker.cmd file */
extern int  * _StackAddr;     /* Defined in linker.cmd file */
extern void main(void);

/*****************************************************************************
*
* Module:         bootArchStart()
*
* Description:    Startup subroutine for bootloader. 
*                 
* Returns:        Never return.
*
* Arguments:      None
*
* Range Issues:   None
*
* Special Issues: Reset processor via COP if loaded application return 
*                 control to the bootloader.
*
* Test Method:    boottest.mcp
*
*****************************************************************************/

asm void bootArchStart(void)
{
Start:
	move	#_StackAddr,r0    //; Get Stack start address
   move  #archStartDelayAddress,r1     //; Get address of timeout variable 
	move	r0,sp             //; Set stack pointer to known location
	   
   move  P:(r1)+,A         
   cmp   #$fe00,A          //; Determine will bootloader start or not
   beq   StartUserApplication
  	
  	bfclr #CEN,ArchIO.Cop.ControlReg     //; Disable COP

  	bfset #$0100,OMR        //; Set CC bit for 32-bit compares

	move	#-1,x0            //; Set the m register to linear addressing
	move	x0,m01            
				
	move	hws,la            //; Clear the hardware stack
	move	hws,la
 #if defined(DSP56801EVM)	  /*801 has different memory map  */
	move  #$0400,y0         //; Clear internal ram to initialize all 
    move  #0,r2             //; bootloader global variables to 0
    move  #0,x0
	rep   y0
	move  x0,x:(r2)+
 #else /*For 803/805 DSPs */
 	move  #$0800,y0         //; Clear internal ram to initialize all 
    move  #0,r2             //; bootloader global variables to 0
    move  #0,x0
	rep   y0
	move  x0,x:(r2)+
 #endif	
	jsr	main              //; Call the bootloader application
	
#if defined(DSP56801EVM)	  /*801 has different memory map  */     
   	move  #$0400,y0         //; Clear internal ram before start user
   	move  #0,r2             //; application
   	move  #$0,x0
	rep   y0
	move  x0,x:(r2)+	
 #else /*For 803/805 DSPs */ 
	move  #$0800,y0         //; Clear internal ram before start user
   	move  #0,r2             //; application
   	move  #$0,x0
	rep   y0
	move  x0,x:(r2)+
 #endif
 
StartUserApplication:   
   jsr   archStart         //; Call user application
   
   jmp   Start             //; Jump to bootloader start without processor reset, 
                           //; if exit from user application occurred. 
                           //; NB:
                           //; 1. usually applicattion switchs the stack 
                           //; and can not return here.
                           //; 2. after this instruction correct bootloader work 
                           //; can not be guaranteed without processor reset
                                                           
}
