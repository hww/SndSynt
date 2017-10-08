/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2001 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name:         spidrv.h
*
* Description:       Header file for the DSP56826 SPI device driver.      
*
* 
*****************************************************************************/
#ifndef __SPIDRV_H
#define __SPIDRV_H

#ifndef SDK_LIBRARY
	#include "configdefines.h"

	#ifndef INCLUDE_SPI
		#error INCLUDE_SPI must be defined in appconfig.h to initialize the SPI Library
	#endif
#endif

#include "port.h"
#include "io.h"
#include "periph.h"
#include "spi.h"

#ifdef __cplusplus
extern "C" {
#endif


#define SPI_HANDLE_0  0
#define SPI_HANDLE_1  1

typedef enum
{
	EightBitChars,
	Raw
} eDataFormat;

typedef struct
{
	bool        bInitialized;
	bool        bMaster;
	bool        bBlocking;
	UWord16     ReadData;
	void        (* pSlaveSelect)(void);
	void        (* pSlaveDeselect)(void);
	eDataFormat DataFormat;
	UWord16     Handle;
} sSpi;

/* SPI FLAGS */
#define SPI_INT_COMPLETE                 0x2000 /* poll bit 9 in SPSCR */
#define SPI_NUM_BITS_PER_WORD            0x000F /* sets bits in SPDSR  */
#define SPI_PORT_B_PIN_5                 0x0010 
#define SPI_SET_BAUD_TO_2                0x00C0

/* PORT B FLAGS */
#define SPI_SPI0_SLAVE_SELECT            0x0004 /* slave select pin 3 port B          */
#define SPI_SPI0_PERIPHERAL_ENABLE       0x0003 /* sets spi pins as peripherals       */

/* PORT F FLAGS */
#define SPI_SPI1_SLAVE_SELECT            0x0080 /* slave select pin 7 port F          */
#define SPI_SPI1_PERIPHERAL_ENABLE       0x0070 /* sets spi pins as peripherals       */


/**********************************************************************
* Redefine ioctl calls to map to standard driver 
***********************************************************************/

#define spiIoctl(FD, Cmd, pParams, spiDeviceName)  spiIoctl##Cmd(FD,pParams)

#define spiIoctlSPI_ENABLE(fd, Mask)                \
			periphBitSet (SPI_ENABLE, (UWord16 *)(&ArchIO.Spi0.ControlReg + ((((sSpi *)fd) -> Handle)*16)))
#define spiIoctlSPI_DISABLE(fd, Mask)                \
			periphBitClear (SPI_DISABLE, (UWord16 *)(&ArchIO.Spi0.ControlReg + ((((sSpi *)fd) -> Handle)*16)))

#define spiIoctlSPI_TX_INTERRUPT_ENABLE(fd, Mask)                \
			periphBitSet (SPI_TX_INTERRUPT_ENABLE, (UWord16 *)(&ArchIO.Spi0.ControlReg + ((((sSpi *)fd) -> Handle)*16)))
#define spiIoctlSPI_TX_INTERRUPT_DISABLED(fd, Mask)                \
			periphBitClear (SPI_TX_INTERRUPT_DISABLED, (UWord16 *)(&ArchIO.Spi0.ControlReg + ((((sSpi *)fd) -> Handle)*16)))

#define spiIoctlSPI_RX_INTERRUPT_ENABLE(fd, Mask)                \
			periphBitSet (SPI_RX_INTERRUPT_ENABLE, (UWord16 *)(&ArchIO.Spi0.ControlReg + ((((sSpi *)fd) -> Handle)*16)))
#define spiIoctlSPI_RX_INTERRUPT_DISABLE(fd, Mask)                \
			periphBitClear (SPI_RX_INTERRUPT_DISABLE, (UWord16 *)(&ArchIO.Spi0.ControlReg + ((((sSpi *)fd) -> Handle)*16)))

#define spiIoctlSPI_DATA_SHIFT_MSB_FIRST(fd, Mask)                \
			periphBitClear (SPI_DATA_SHIFT_MSB_FIRST, (UWord16 *)(&ArchIO.Spi0.ControlReg + ((((sSpi *)fd) -> Handle)*16)))
#define spiIoctlSPI_DATA_SHIFT_LSB_FIRST(fd, Mask)                \
			periphBitSet (SPI_DATA_SHIFT_LSB_FIRST, (UWord16 *)(&ArchIO.Spi0.ControlReg + ((((sSpi *)fd) -> Handle)*16)))

#define spiIoctlSPI_ERROR_INTERRUPT_ENABLE(fd, Mask)                \
			periphBitSet (SPI_ERROR_INTERRUPT_ENABLE, (UWord16 *)(&ArchIO.Spi0.ControlReg + ((((sSpi *)fd) -> Handle)*16)))
#define spiIoctlSPI_ERROR_INTERRUPT_DISABLE(fd, Mask)                \
			periphBitClear (SPI_ERROR_INTERRUPT_DISABLE, (UWord16 *)(&ArchIO.Spi0.ControlReg + ((((sSpi *)fd) -> Handle)*16)))

#define spiIoctlSPI_MODE_FAULT_ENABLE(fd, Mask)                \
			periphBitSet (SPI_MODE_FAULT_ENABLE, (UWord16 *)(&ArchIO.Spi0.ControlReg + ((((sSpi *)fd) -> Handle)*16)))
#define spiIoctlSPI_MODE_FAULT_DISABLE(fd, Mask)                \
			periphBitClear (SPI_MODE_FAULT_DISABLE, (UWord16 *)(&ArchIO.Spi0.ControlReg + ((((sSpi *)fd) -> Handle)*16)))

#define spiIoctlSPI_CLEAR_MODE_FAULT(fd, Mask)                \
			periphBitSet (SPI_CLEAR_MODE_FAULT, (UWord16 *)(&ArchIO.Spi0.ControlReg + ((((sSpi *)fd) -> Handle)*16)))

#define spiIoctlSPI_MODE_MASTER(fd, Mask)                \
			periphBitSet (SPI_MODE_MASTER, (UWord16 *)(&ArchIO.Spi0.ControlReg + ((((sSpi *)fd) -> Handle)*16)))
#define spiIoctlSPI_MODE_SLAVE(fd, Mask)                \
			periphBitClear (SPI_MODE_SLAVE, (UWord16 *)(&ArchIO.Spi0.ControlReg + ((((sSpi *)fd) -> Handle)*16)))

#define spiIoctlSPI_CLOCK_PHASE_SET(fd, Mask)                \
			periphBitSet (SPI_CLOCK_PHASE_SET, (UWord16 *)(&ArchIO.Spi0.ControlReg + ((((sSpi *)fd) -> Handle)*16)))
#define spiIoctlSPI_CLOCK_PHASE_NOTSET(fd, Mask)                \
			periphBitClear (SPI_CLOCK_PHASE_NOTSET, (UWord16 *)(&ArchIO.Spi0.ControlReg + ((((sSpi *)fd) -> Handle)*16)))

#define spiIoctlSPI_CLK_POL_RISING_EDGE(fd, Mask)                \
			periphBitSet (SPI_CLK_POL_RISING_EDGE, (UWord16 *)(&ArchIO.Spi0.ControlReg + ((((sSpi *)fd) -> Handle)*16)))
#define spiIoctlSPI_CLK_POL_FALLING_EDGE(fd, Mask)                \
			periphBitClear (SPI_CLK_POL_FALLING_EDGE, (UWord16 *)(&ArchIO.Spi0.ControlReg + ((((sSpi *)fd) -> Handle)*16)))

#define spiIoctlSPI_BAUDRATE_DIVIDER_2(fd, Mask)                \
			periphBitClear (SPI_SET_BAUD_TO_2, (UWord16 *)(&ArchIO.Spi0.ControlReg + ((((sSpi *)fd) -> Handle)*16)))

#define spiIoctlSPI_BAUDRATE_DIVIDER_8(fd, Mask)                \
			periphBitSet (SPI_BAUDRATE_DIVIDER_8, (UWord16 *)(&ArchIO.Spi0.ControlReg + ((((sSpi *)fd) -> Handle)*16)));  \
			periphBitClear(SPI_BAUDRATE_DIVIDER_16,(UWord16 *)(&ArchIO.Spi0.ControlReg + ((((sSpi *)fd) -> Handle)*16))) 

#define spiIoctlSPI_BAUDRATE_DIVIDER_16(fd, Mask)                \
			periphBitSet (SPI_BAUDRATE_DIVIDER_16, (UWord16 *)(&ArchIO.Spi0.ControlReg + ((((sSpi *)fd) -> Handle)*16))); \
			periphBitClear(SPI_BAUDRATE_DIVIDER_8,(UWord16 *)(&ArchIO.Spi0.ControlReg + ((((sSpi *)fd) -> Handle)*16)))

#define spiIoctlSPI_BAUDRATE_DIVIDER_32(fd, Mask)                \
			periphBitSet (SPI_BAUDRATE_DIVIDER_32, (UWord16 *)(&ArchIO.Spi0.ControlReg + ((((sSpi *)fd) -> Handle)*16)))

#define spiIoctlSPI_TRANSMISSION_DATA_SIZE(fd, Mask)                \
			periphMemWrite (Mask-1, (UWord16 *)(&ArchIO.Spi0.DataSizeReg + ((((sSpi *)fd) -> Handle)*16)))

#define spiIoctlSPI_DATAFORMAT_RAW(fd, Mask)                \
			((sSpi *)fd) -> DataFormat = Raw

#define spiIoctlSPI_DATAFORMAT_EIGHTBITCHARS(fd, Mask)                \
			((sSpi *)fd) -> DataFormat = EightBitChars


/*****************************************************************************
* Prototypes - See source file for functional descriptions
******************************************************************************/
EXPORT int          spiOpen  (const char * pName, spi_sParams * pParams);
EXPORT int          spiClose (int FileDesc);
EXPORT ssize_t      spiRead  (int FileDesc, void * pBuffer, size_t NWords);
EXPORT ssize_t      spiWrite (int FileDesc, UWord16 * pBuffer, size_t Size);

/* EXPORT Result spiCreate(const char * pName) */
#define spiCreate(name) (PASS)


#ifdef __cplusplus
}
#endif

#endif
