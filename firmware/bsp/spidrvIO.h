/*****************************************************************************
*
* spidrv.h - header file for the Motorola dsp56805 spi device driver.
*
*****************************************************************************/
#ifndef __SPIDRVIO_H
#define __SPIDRVIO_H

#ifndef SDK_LIBRARY
	#include "configdefines.h"

	#ifndef INCLUDE_IO_SPI
		#error INCLUDE_IO_SPI must be defined in appconfig.h to initialize the IO Layer for the SPI Driver
	#endif
#endif

#include "port.h"
#include "io.h"
#include "periph.h"
#include "spi.h"

#ifdef __cplusplus
extern "C" {
#endif

#define ioctlSPI_DATA_SHIFT_MSB_FIRST(fd, Mask)     spiIoctlSPI_DATA_SHIFT_MSB_FIRST(fd, Mask)
#define ioctlSPI_DATA_SHIFT_LSB_FIRST(fd, Mask)     spiIoctlSPI_DATA_SHIFT_LSB_FIRST(fd, Mask)
#define ioctlSPI_ERROR_INTERRUPT_ENABLE(fd, Mask)   spiIoctlSPI_ERROR_INTERRUPT_ENABLE(fd, Mask)
#define ioctlSPI_ERROR_INTERRUPT_DISABLE(fd, Mask)  spiIoctlSPI_ERROR_INTERRUPT_DISABLE(fd, Mask) 
#define ioctlSPI_MODE_FAULT_ENABLE(fd, Mask)        spiIoctlSPI_MODE_FAULT_ENABLE(fd, Mask)
#define ioctlSPI_MODE_FAULT_DISABLE(fd, Mask)       spiIoctlSPI_MODE_FAULT_DISABLE(fd, Mask)
#define ioctlSPI_CLEAR_MODE_FAULT(fd, Mask)         spiIoctlSPI_CLEAR_MODE_FAULT(fd, Mask)
#define ioctlSPI_RX_INTERRUPT_ENABLE(fd, Mask)      spiIoctlSPI_RX_INTERRUPT_ENABLE(fd, Mask)
#define ioctlSPI_RX_INTERRUPT_DISABLE(fd, Mask)     spiIoctlSPI_RX_INTERRUPT_DISABLE(fd, Mask)
#define ioctlSPI_MODE_MASTER(fd, Mask)              spiIoctlSPI_MODE_MASTER(fd, Mask)
#define ioctlSPI_MODE_SLAVE(fd, Mask)               spiIoctlSPI_MODE_SLAVE(fd, Mask)
#define ioctlSPI_CLOCK_PHASE_SET(fd, Mask)          spiIoctlSPI_CLOCK_PHASE_SET(fd, Mask)
#define ioctlSPI_CLOCK_PHASE_NOTSET(fd, Mask)       spiIoctlSPI_CLOCK_PHASE_NOTSET(fd, Mask)
#define ioctlSPI_CLK_POL_RISING_EDGE(fd, Mask)      spiIoctlSPI_CLK_POL_RISING_EDGE(fd, Mask)
#define ioctlSPI_CLK_POL_FALLING_EDGE(fd, Mask)     spiIoctlSPI_CLK_POL_FALLING_EDGE(fd, Mask)
#define ioctlSPI_ENABLE(fd, Mask)                   spiIoctlSPI_ENABLE(fd, Mask) 
#define ioctlSPI_DISABLE(fd, Mask)                  spiIoctlSPI_DISABLE(fd, Mask)
#define ioctlSPI_TX_INTERRUPT_ENABLE(fd, Mask)      spiIoctlSPI_TX_INTERRUPT_ENABLE(fd, Mask)
#define ioctlSPI_TX_INTERRUPT_DISABLED(fd, Mask)    spiIoctlSPI_TX_INTERRUPT_DISABLED(fd, Mask)
#define ioctlSPI_BAUDRATE_DIVIDER_2(fd, Mask)       spiIoctlSPI_BAUDRATE_DIVIDER_2(fd, Mask)
#define ioctlSPI_BAUDRATE_DIVIDER_8(fd, Mask)       spiIoctlSPI_BAUDRATE_DIVIDER_8(fd, Mask)
#define ioctlSPI_BAUDRATE_DIVIDER_16(fd, Mask)      spiIoctlSPI_BAUDRATE_DIVIDER_16(fd, Mask)
#define ioctlSPI_BAUDRATE_DIVIDER_32(fd, Mask)      spiIoctlSPI_BAUDRATE_DIVIDER_32(fd, Mask)
#define ioctlSPI_TRANSMISSION_DATA_SIZE(fd, Mask)   spiIoctlSPI_TRANSMISSION_DATA_SIZE(fd, Mask)
#define ioctlSPI_DATAFORMAT_RAW(fd, Mask)           spiIoctlSPI_DATAFORMAT_RAW(fd, Mask)
#define ioctlSPI_DATAFORMAT_EIGHTBITCHARS(fd, Mask) spiIoctlSPI_DATAFORMAT_EIGHTBITCHARS(fd, Mask)

/*****************************************************************************
* Prototypes - See source file for functional descriptions
******************************************************************************/
EXPORT io_sDriver * spidrvIOOpen(const  char * pName, int OFlags, ...);

/* EXPORT Result spidrvIOCreate(const char * pName) */
#define spidrvIOCreate(name) spiCreate(name)

#ifdef __cplusplus
}
#endif

#endif
