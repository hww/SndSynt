/******************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000, 2001 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
*******************************************************************************
*
* FILE NAME: spi.h
*
* DESCRIPTION: Public header file for the SPI device driver
*
*******************************************************************************/

#ifndef __SPI_H
#define __SPI_H


#ifndef SDK_LIBRARY
	#include "configdefines.h"

	#ifndef INCLUDE_SPI
		#error INCLUDE_SPI must be defined in appconfig.h to initialize the SPI driver
	#endif
#endif


#include "port.h"

#if defined(SDK_LIBRARY) || defined(INCLUDE_IO_LED)
	#include "io.h"
	#include "fcntl.h"
#endif


#ifdef __cplusplus
extern "C" {
#endif

/******************************************************************************
*
*                      General Interface Description
*
*  The DSP56805 processor has one SPI peripheral, SPI0.  SPI0 is located 
*  on pins [5:8] of Port E. The SPI peripheral provides the following registers:
*
*  SPI Status and Control Register (SPSCR):  SPCR0 is located at memory 
*                                            location: 0x0F20
*                                            
*  This is a read/write register used to configure and control the SPI0
*  peripheral.(See Section 13.9.1 of the DSP 56F801/803/805/807 User's 
*  Manual for more details)
*  
*  SPI Data Size Register (SPDSR): SPDSR is located at memory location: 0x0F21
*
*  This is a read/write	registers that determines the data length for each 
*  transmission.  (See Section 13.9.1.16 of the DSP 56F801/803/805/807  
*  User's Manual for more details) 
*  
*  SPI Data Receive Register (SPDRR): SPDRR is located at memory location: 
*                                     0x0F22
*
*  This is a read only data register.  (See Section 13.9.2 of the DSP 
*  56F801/803/805/807 User's Manual for more details) 
*
*   SPI Data Transmit Register (SPDTR): SPDTR is located at memory location:
*                                       0x0F23
*
*  This is a write only data register.  (See Section 13.9.3 of the DSP 
*  56F801/803/805/807 User's Manual for more details)  
*
*  A port is configured by the following:
*  
*  1)  An "open" call is made to open a particular SPI peripheral.  For 
*      details see "open" call.
*
*  2)  A "write" call is made to write data out of a serial port.
*      For details see "write" call.
* 
*  3)  A "read" call is made to read data from a serial port.
*      For details see "read" call.
*
*  4)  After all port operations are completed, the particular SPI peripheral
*      has to be closed via a "close" call.  For details see "close" call.
*
******************************************************************************/

/*****************************************************************************
* 
*    OPEN
*
*  int open(const char *pName, int OFlags, ...);
*
* Semantics:
*     Open the particular SPI peripheral for operations. Argument pName is the 
*     particular SPI device name. The SPI device is always opened for read
*     and for write calls.
*
* Parameters:
*     pName    - device name. Use   BSP_DEVICE_NAME_SPI_0 for SPI0,
*     OFlags   - open mode flags.   Ignored. 
* 
* Return Value: 
*     SPI device descriptor if open is successful.
*     -1 value if open failed.
*     
* Example:
*     
*     // This example will open SPI0 as a master and return a file descriptor   
*     int SpiFD; 
* 	   spi_sParams * pSpiParams;        // This structure is defined below          
*
*     pSpiParams -> bSetAsMaster = 1;  // This will set SPI1 as a master 
*     SpiFD = open(BSP_DEVICE_NAME_SPI_0, 0, pSpiParams);
*
*****************************************************************************/

/*****************************************************************************
*
* IOCTL
*
*     UWord16 ioctl(int FileDesc, UWord16 Cmd, void * pParams); 
*
* Semantics:
*    Modify port configuration. SPI driver supports the following commands:
*  
*	 SPI_DATA_SHIFT_MSB_FIRST      MSB transmitted first    
*
*	 SPI_DATA_SHIFT_LSB_FIRST      LSB transmitted first
*    
*    SPI_ERROR_INTERRUPT_ENABLE    MODF and OVRF can generate DSP interrupt
*                                  requests
*    
*    SPI_ERROR_INTERRUPT_DISABLE   MODF and OVRF cannot generate DSP interrupt
*                                  requests
* 
*    SPI_MODE_FAULT_ENABLE         Allows MODF to be set 
*    
*    SPI_MODE_FAULT_DISABLE        The level of the SS pin does not affect the
*                                  operation of an enabled SPI sonfigured as 
*                                  a Master
*
*    SPI_CLEAR_MODE_FAULT          Clears Mode Fault Bit after it has been set
*
*    SPI_BAUDRATE_DIVIDER_2        Divides clock by 2
*       
*    SPI_BAUDRATE_DIVIDER_8        Divides clock by 8
*        
*    SPI_BAUDRATE_DIVIDER_16       Divides clock by 16
*      
*    SPI_BAUDRATE_DIVIDER_32       Divides clock by 32
*      
*    SPI_RX_INTERRUPT_ENABLE       SPRF DSP interrupt requests enabled
*
*    SPI_RX_INTERRUPT_DISABLE      SPRF DSP interrupt requests disabled    
*
*    SPI_MODE_MASTER               Puts SPI in Master Mode
*
*    SPI_MODE_SLAVE                Puts SPI in Slave Mode             
*
*    SPI_CLK_POL_RISING_EDGE       Rising edge of SCLK starts transmission    
*
*    SPI_CLK_POL_FALLING_EDGE      Falling edge of SCLK starts transmission
*
*    SPI_CLOCK_PHASE_SET           SS pin of the slave SPI module does not
*                                  have to be set to a logic one between
*                                  full length data transmissions
*
*    SPI_CLOCK_PHASE_NOTSET        SS pin of the slave SPI module does have
*                                  to be set to a logic one between full 
*                                  length data transmissions
*
*    SPI_ENABLE                    SPI module enabled
*          
*    SPI_DISABLE                   SPI module disabled
*                
*    SPI_TX_INTERRUPT_ENABLE       SPTE interrupt requests enabled      
*
*    SPI_TX_INTERRUPT_DISABLED     SPTE interrupt requests disabled  
*
*    SPI_TRANSMISSION_DATA_SIZE    The data transmission size in bits (2-16) 
*
*	 SPI_DATAFORMAT_RAW            Data format will be set to 16 bits.
*                                  
*    SPI_DATAFORMAT_EIGHTBITCHARS  Data format will be set to 8 bits.
*
*    The pParams is used to pass on a particular data transmission size when 
*    using the command SPI_TRANSMISSION_DATA_SIZE.
*
*    Parameters:
*        FileDesc    - Flash Device descriptor returned by "open" call.
*        Cmd         - command for driver 
*        pParam      - Data transmission size in bits when using 
*                      SPI_TRANSMISSION_DATA_SIZE command
*
*    Return Value: Zero 
*                 
*    Example:
*
*    ioctl(SpiFD, SPI_DATA_SHIFT_LSB_FIRST, NULL); // This will make the LSB
*                                                     tx first
*****************************************************************************/

/*****************************************************************************
*
* WRITE
*
*     ssize_t write(int FileDesc, const void * pBuffer, size_t Size);
*
* Semantics:
*     Write user buffer out of SPI device.     
*
* Parameters:
*     FileDesc    - SPI Device descriptor returned by "open" call.
*     pBuffer     - Pointer to user buffer. 
*     Size        - Number of words to be written out of SPI device. 
*
* Return Value: 
*     - Actual number of written words based on transmission size.
*
*****************************************************************************/

/*****************************************************************************
*
* READ
*
*     ssize_t read(int FileDesc, void * pBuffer, size_t Size);
*
* Semantics:
*     Read data from SPI device to user buffer.
*
* Parameters:
*     FileDesc    - SPI Device descriptor returned by "open" call.
*     pBuffer     - Pointer to user buffer. 
*     Size        - Number of words to be read from SPI device. 
*
* Return Value: 
*     - Actual number of read words based on transmission size.
*   
*****************************************************************************/

/*****************************************************************************
*
* CLOSE
*
*     int close(int FileDesc);  
*
* Semantics:
*     Close SPI device.
*
* Parameters:
*     FileDesc - SPI Device descriptor returned by "open" call.
*
* Return Value: 
*     Zero
*
*****************************************************************************/

typedef struct
{
	bool    bSetAsMaster;
	UWord16 TransmissionSize;
	void    (* pSlaveSelect)(void);
	void    (* pSlaveDeselect)(void);
} spi_sParams;

/* SPI IOCTL Commands */
#define SPI_DATA_SHIFT_MSB_FIRST     0x4000
#define SPI_DATA_SHIFT_LSB_FIRST     0x4000 
#define SPI_ERROR_INTERRUPT_ENABLE   0x1000  
#define SPI_ERROR_INTERRUPT_DISABLE  0x1000
#define SPI_MODE_FAULT_ENABLE        0x0100
#define SPI_MODE_FAULT_DISABLE       0x0100 
#define SPI_CLEAR_MODE_FAULT         0x0400
#define SPI_BAUDRATE_DIVIDER_2       0x0000 
#define SPI_BAUDRATE_DIVIDER_8       0x0040 
#define SPI_BAUDRATE_DIVIDER_16      0x0080
#define SPI_BAUDRATE_DIVIDER_32      0x00C0 
#define SPI_RX_INTERRUPT_ENABLE      0x0020
#define SPI_RX_INTERRUPT_DISABLE     0x0020 
#define SPI_MODE_MASTER              0x0010
#define SPI_MODE_SLAVE               0x0010
#define SPI_CLK_POL_RISING_EDGE      0x0008 
#define SPI_CLK_POL_FALLING_EDGE     0x0008 
#define SPI_CLOCK_PHASE_SET          0x0004
#define SPI_CLOCK_PHASE_NOTSET       0x0004
#define SPI_ENABLE                   0x0002
#define SPI_DISABLE                  0x0002
#define SPI_TX_INTERRUPT_ENABLE      0x0001  
#define SPI_TX_INTERRUPT_DISABLED    0x0001 
#define SPI_TRANSMISSION_DATA_SIZE   0x0000
#define SPI_DATAFORMAT_EIGHTBITCHARS 7
#define SPI_DATAFORMAT_RAW           8

#ifdef __cplusplus
}
#endif


/*********************************************************************
* The driver file is included at the end of this public include
* file instead of the beginning to avoid circular dependency problems.
**********************************************************************/ 
#if defined(SDK_LIBRARY) || defined(INCLUDE_IO_SPI)
	#include "spidrvIO.h"
#endif

#include "spidrv.h"

													
#endif
