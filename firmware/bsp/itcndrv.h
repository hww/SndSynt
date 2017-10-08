/* File: itcndrv.h */

#ifndef __ITCNDRV_H
#define __ITCNDRV_H

#include "port.h"
#include "arch.h"
#include "periph.h"

#ifdef __cplusplus
extern "C" {
#endif


/*****************************************************************************/
/* EXPORT void itcndrvInitialize (   UWord16 GPR0, 
									 UWord16 GPR1,
									 UWord16 GPR2,
									 UWord16 GPR3,
									 UWord16 GPR4,
									 UWord16 GPR5,
									 UWord16 GPR6,
									 UWord16 GPR7,
									 UWord16 GPR8,
									 UWord16 GPR9,
									 UWord16 GPR10,
									 UWord16 GPR11,
									 UWord16 GPR12,
									 UWord16 GPR13,
									 UWord16 GPR14,
									 UWord16 GPR15); */
#define itcndrvInitialize(G0,G1,G2,G3,G4,G5,G6,G7,G8,G9,G10,G11,G12,G13,G14,G15) \
{                                                                           \
	periphMemWrite(G0, &ArchIO.IntController.GroupPriorityReg[0]);          \
	periphMemWrite(G1, &ArchIO.IntController.GroupPriorityReg[1]);          \
	periphMemWrite(G2, &ArchIO.IntController.GroupPriorityReg[2]);          \
	periphMemWrite(G3, &ArchIO.IntController.GroupPriorityReg[3]);          \
	periphMemWrite(G4, &ArchIO.IntController.GroupPriorityReg[4]);          \
	periphMemWrite(G5, &ArchIO.IntController.GroupPriorityReg[5]);          \
	periphMemWrite(G6, &ArchIO.IntController.GroupPriorityReg[6]);          \
	periphMemWrite(G7, &ArchIO.IntController.GroupPriorityReg[7]);          \
	periphMemWrite(G8, &ArchIO.IntController.GroupPriorityReg[8]);          \
	periphMemWrite(G9, &ArchIO.IntController.GroupPriorityReg[9]);          \
	periphMemWrite(G10, &ArchIO.IntController.GroupPriorityReg[10]);        \
	periphMemWrite(G11, &ArchIO.IntController.GroupPriorityReg[11]);        \
	periphMemWrite(G12, &ArchIO.IntController.GroupPriorityReg[12]);        \
	periphMemWrite(G13, &ArchIO.IntController.GroupPriorityReg[13]);        \
	periphMemWrite(G14, &ArchIO.IntController.GroupPriorityReg[14]);        \
	periphMemWrite(G15, &ArchIO.IntController.GroupPriorityReg[15]);        \
	                                                                                                                     \
}


#ifdef __cplusplus
}
#endif

#endif
