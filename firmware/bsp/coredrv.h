/* File: coredrv.h */

#ifndef __COREDRV_H
#define __COREDRV_H

#include "port.h"

#ifdef __cplusplus
extern "C" {
#endif


/* INTERRUPT PRIORITY REGISTER FLAGS */

#define IPR_ENABLE_CHANNEL_0                     0x8000
#define IPR_ENABLE_CHANNEL_1                     0x4000
#define IPR_ENABLE_CHANNEL_2                     0x2000
#define IPR_ENABLE_CHANNEL_3                     0x1000
#define IPR_ENABLE_CHANNEL_4                     0x0800
#define IPR_ENABLE_CHANNEL_5                     0x0400
#define IPR_ENABLE_CHANNEL_6                     0x0200
#define IPR_ENABLE_IRQA                          0x0002
#define IPR_ENABLE_IRQB                          0x0010

#define IPR_IRQA_TRIGGER_LOW_LEVEL               0x0000
#define IPR_IRQA_TRIGGER_HIGH_LEVEL              0x0001
#define IPR_IRQA_TRIGGER_FALLING_EDGE            0x0004
#define IPR_IRQA_TRIGGER_RISING_EDGE             0x0005

#define IPR_IRQB_TRIGGER_LOW_LEVEL               0x0000
#define IPR_IRQB_TRIGGER_HIGH_LEVEL              0x0008
#define IPR_IRQB_TRIGGER_FALLING_EDGE            0x0020
#define IPR_IRQB_TRIGGER_RISING_EDGE             0x0028


/*****************************************************************************/
/* EXPORT void coredrvInitialize ( UWord16 BusControlReg, UWord16 InterruptPriorityReg ); */
#define coredrvInitialize(BusCtrlReg,IntPriorityReg)                 \
{                                                                    \
	periphMemWrite(BusCtrlReg, &ArchCore.BusControlReg);             \
                                                                     \
	periphMemWrite(IntPriorityReg, &ArchCore.InterruptPriorityReg);  \
}


#ifdef __cplusplus
}
#endif

#endif
