/* File: simdrv.h */

#ifndef __SIMDRV_H
#define __SIMDRV_H

#include "port.h"
#include "arch.h"
#include "periph.h"

#ifdef __cplusplus
extern "C" {
#endif

/* SYSTEM INTEGRATION MODULE (SIM) REGISTER FLAGS */

#define SIM_SPI_SCI_PULLUP_DISABLE               0x0800
#define SIM_CONTROL_PULLUP_DISABLE               0x0400
#define SIM_SPI_SELECT                           0x0200
#define SIM_DATA_BUS_PULLUP_DISABLE              0x0100
#define SIM_BOOT_MODE_A                          0x0000
#define SIM_BOOT_MODE_B                          0x0010
#define SIM_27V_LOW_VOLTAGE_INT_ENABLE           0x0008
#define SIM_22V_LOW_VOLTAGE_INT_ENABLE           0x0004
#define SIM_PERM_STOP_WAIT_DISABLE               0x0002
#define SIM_PROG_STOP_WAIT_DISABLE               0x0001


/* EXPORT void simdrvInitialize (UWord16 ControlReg); */
#define simdrvInitialize(CtrlReg)            \
	periphMemWrite ( CtrlReg,                \
					 &ArchIO.Sim.ControlReg)

/* Remapping */

#define simControlSIM_SELECT_SCI()                                    \
	(periphBitSet(SIM_SPI_SELECT, (UWord16 *)(&ArchIO.Sim.ControlReg)))

#define simControlSIM_SELECT_SPI()                                    \
	(periphBitClear(SIM_SPI_SELECT, (UWord16 *)(&ArchIO.Sim.ControlReg)))

#ifdef __cplusplus
}
#endif

#endif
