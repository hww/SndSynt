/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000-2001 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name:         cop.h
*
* Description:       API header file for DSP5680x COP driver
*
* Modules Included:  copInitialize()
*					 copReload()
*                    copForceReset()
*                    copGetSysStatus()
*                    copClrSysStatus()
*                    
* 
*****************************************************************************/

#ifndef __COP_H
#define __COP_H

#include "port.h"
#include "arch.h"
#include "periph.h"

#ifdef __cplusplus
extern "C" {
#endif


/* COMPUTER OPERATING PROPERLY (COP) REGISTER FLAGS */

#define COP_RUN_IN_STOP                         0x0008
#define COP_RUN_IN_WAIT                         0x0004
#define COP_ENABLE                              0x0002
#define COP_WRITE_PROTECT                       0x0001

/* SYSTEM STATUS (SYS_STS) REGISTER FLAGS           */

#define COP_RESET								0x0010
#define EXT_RESET								0x0008
#define PWR_RESET								0x0004



/*****************************************************************************
* 
* void copInitialize ( UWord16 ControlReg, UWord16 TimeoutReg );  
*
* Semantics:
*     Reload COP timer and initilaize COP Control and Timeout 
*     registers by the specified values.
*
* Parameters:
*     ControlReg - value that shall be written to the Control register
*     TimeoutReg - value that shall be written to the Timeout register
*
* Return Value: None
*     
*****************************************************************************/
#define copInitialize(CtrlReg,TOReg)                      \
{                                                         \
        periphMemWrite(0x5555,  &ArchIO.Cop.ServiceReg);  \
        periphMemWrite(0xAAAA,  &ArchIO.Cop.ServiceReg);  \
      	periphMemWrite(TOReg,   &ArchIO.Cop.TimeoutReg);  \
	    periphMemWrite(CtrlReg, &ArchIO.Cop.ControlReg);  \
}

/*****************************************************************************
* 
* void copReload ( void );                                           
*
* Semantics:
*     Reload COP timer to avoid COP reset.
*
* Parameters:   None
*
* Return Value: None
*     
*****************************************************************************/
#define copReload()                                       \
{                                                         \
        periphMemWrite(0x5555, &ArchIO.Cop.ServiceReg);   \
        periphMemWrite(0xAAAA, &ArchIO.Cop.ServiceReg);   \
}                                                  

/*****************************************************************************
* 
* void copForceReset ( void );                                       
*
* Semantics:
*     Force COP reset event.
*
* Parameters:   None
*
* Return Value: None
*     
*****************************************************************************/
#define copForceReset()                                	  \
{                                                         \
	periphMemWrite(0, &ArchIO.Cop.TimeoutReg);            \
	periphMemWrite(COP_ENABLE, &ArchIO.Cop.ControlReg);   \
}

/*****************************************************************************
* 
* UWord16 copGetSysStatus ( mask );                                       
*
* Semantics:
*     Get reset source from System Status register.
*
* Parameters:   mask - can be one of the following masks:
*                 COP_RESET	- COP reset occurs
*                 EXT_RESET - External reset occurs
*                 PWR_RESET - Power On reset occurs
*
* Return Value: 0 - Reset source specified by the mask was inactive.
*               not zero value - one of the reset source specified
*               by the mask was active.
*     
*****************************************************************************/
#define copGetSysStatus(mask)  										\
(																	\
	periphMemRead(&ArchIO.Sim.StatusReg) & (0x001C & mask)			\
)

/*****************************************************************************
* 
* void copClrSysStatus ( mask );                                       
*
* Semantics:
*     Clear specified reset source bit in the System Status register.
*
* Parameters:   mask - can be one of the following masks:
*                 COP_RESET	- COP reset occurs
*                 EXT_RESET - External reset occurs
*                 PWR_RESET - Power On reset occurs
*
* Return Value: None
*     
*****************************************************************************/
#define copClrSysStatus(mask)  										\
{																	\
	periphMemWrite( ~periphMemRead(&ArchIO.Sim.StatusReg) | 		\
				    (mask & 0x001C), &ArchIO.Sim.StatusReg  );		\
}

#ifdef __cplusplus
}
#endif

#endif /* __COP_H */

