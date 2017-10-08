/*******************************************************************************
*
* Motorola Inc.
* (c) Copyright 2001 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
********************************************************************************
*
* FILE NAME:   spidrv.c
*
* DESCRIPTION: source file for the SPI device driver
*
*******************************************************************************/

#include "port.h"
#include "arch.h"
#include "assert.h"

#include "bit.h"
#include "periph.h"

#include "bsp.h"
#include "sim.h"
#include "spi.h"
#include "gpio.h"

#ifndef SPI_BAUDRATE_DIVIDER
#define SPI_BAUDRATE_DIVIDER SPI_BAUDRATE_DIVIDER_8
#endif
	
sSpi spidrvDevice[2];
static int  PortB;
static int  PortF;

/*****************************************************************************/
static void SlaveSelect0(void)
{
	ioctl(PortB, GPIO_CLEAR, gpioPin(B,4)); 
}

/*****************************************************************************/
static void SlaveDeselect0(void)
{
 	ioctl(PortB, GPIO_SET, gpioPin(B,4)); 
}

/*****************************************************************************/
static void SlaveSelect1(void)
{
	ioctl(PortF, GPIO_CLEAR, gpioPin(F,7)); 
}

/*****************************************************************************/
static void SlaveDeselect1(void)
{
 	ioctl(PortF, GPIO_SET, gpioPin(F,7)); 
}

/*****************************************************************************/
int spiOpen(const char * pName, spi_sParams * pParams)
{
	sSpi        * pSpi;
	UWord16       Dummy;
	
	if(pName == BSP_DEVICE_NAME_SPI_0) 
	{
		pSpi = &(spidrvDevice[SPI_HANDLE_0]);
		
	    pSpi -> Handle  = SPI_HANDLE_0;

		simControl(SIM_SELECT_SPI);
					
		if(pParams -> bSetAsMaster == true)
 		{
			pSpi -> bMaster = true; 

/* Set GPIO Pin here to chip select slave device */

			gpioIoctl((int)BSP_DEVICE_NAME_GPIO_B, GPIO_SETAS_GPIO,   gpioPin(B,4),
																		 BSP_DEVICE_NAME_GPIO_B);
			gpioIoctl((int)BSP_DEVICE_NAME_GPIO_B, GPIO_SETAS_OUTPUT, gpioPin(B,4),
																		 BSP_DEVICE_NAME_GPIO_B); 

			if(pParams -> pSlaveSelect == NULL)
			{
				pSpi -> pSlaveSelect   = SlaveSelect0;
				pSpi -> pSlaveDeselect = SlaveDeselect0;
			}
			else
			{
				pSpi -> pSlaveSelect   = pParams -> pSlaveSelect;
				pSpi -> pSlaveDeselect = pParams -> pSlaveDeselect;
			}

			bitClear(SPI_ENABLE, ArchIO.Spi0.ControlReg);
			
			pSpi -> pSlaveDeselect(); /* ??? */

			/* THESE TWO LINE NEEDS TO CHANGE */
			
			bitClear(SPI_SPI0_SLAVE_SELECT, ArchIO.PortB.PeripheralReg);
			
			periphMemWrite(SPI_MODE_MASTER | SPI_BAUDRATE_DIVIDER,
														&ArchIO.Spi0.ControlReg);

			periphMemWrite(pParams -> TransmissionSize, &ArchIO.Spi0.DataSizeReg);
			bitSet(SPI_ENABLE, ArchIO.Spi0.ControlReg);
		}
		
		else
		{
			pSpi -> bMaster = false; 
			
			bitClear(SPI_ENABLE, ArchIO.Spi0.ControlReg);
			
			/* THIS LINE NEEDS TO CHANGE */
			bitSet(SPI_SPI0_SLAVE_SELECT, ArchIO.PortB.PeripheralReg);
			
			periphMemWrite(SPI_BAUDRATE_DIVIDER  , &ArchIO.Spi0.ControlReg);
			periphMemWrite(pParams -> TransmissionSize, &ArchIO.Spi0.DataSizeReg);
			
			bitSet(SPI_ENABLE, ArchIO.Spi0.ControlReg);
			Dummy = periphMemRead(&ArchIO.Spi0.DataRxReg);
		}
	}
	
	else if(pName == BSP_DEVICE_NAME_SPI_1)
	{
		pSpi = &(spidrvDevice[SPI_HANDLE_1]);
		
	    pSpi -> Handle  = SPI_HANDLE_1;

		/* GPIO F4-7 */ 
		bitSet(SPI_SPI1_PERIPHERAL_ENABLE, ArchIO.PortF.PeripheralReg);
			
		if(pParams -> bSetAsMaster == true)
 		{
			pSpi -> bMaster = true; 

/* Set GPIO Pin here to chip select slave device */

			gpioIoctl((int)BSP_DEVICE_NAME_GPIO_F, GPIO_SETAS_GPIO,   gpioPin(F,7),
																		BSP_DEVICE_NAME_GPIO_F);
			gpioIoctl((int)BSP_DEVICE_NAME_GPIO_F, GPIO_SETAS_OUTPUT, gpioPin(F,7),
																		BSP_DEVICE_NAME_GPIO_F); 

			if(pParams -> pSlaveSelect == NULL)
			{
				pSpi -> pSlaveSelect   = SlaveSelect1;
				pSpi -> pSlaveDeselect = SlaveDeselect1;
			}
			else
			{
				pSpi -> pSlaveSelect   = pParams -> pSlaveSelect;
				pSpi -> pSlaveDeselect = pParams -> pSlaveDeselect;
			}

			bitClear(SPI_ENABLE, ArchIO.Spi1.ControlReg);
			
			pSpi -> pSlaveDeselect(); /* ??? */

			/* THESE TWO LINE NEEDS TO CHANGE */
			
			bitClear(SPI_SPI1_SLAVE_SELECT, ArchIO.PortF.PeripheralReg);
			
			periphMemWrite(SPI_MODE_MASTER | SPI_BAUDRATE_DIVIDER,
														&ArchIO.Spi1.ControlReg);

			periphMemWrite(pParams -> TransmissionSize, &ArchIO.Spi1.DataSizeReg);
			bitSet(SPI_ENABLE, ArchIO.Spi1.ControlReg);
		}
		
		else
		{
			pSpi -> bMaster = false; 
			
			bitClear(SPI_ENABLE, ArchIO.Spi1.ControlReg);
			
			/* THIS LINE NEEDS TO CHANGE */
			bitSet(SPI_SPI1_SLAVE_SELECT, ArchIO.PortF.PeripheralReg);
			
			periphMemWrite(SPI_BAUDRATE_DIVIDER  , &ArchIO.Spi1.ControlReg);
			periphMemWrite(pParams -> TransmissionSize, &ArchIO.Spi1.DataSizeReg);
			
			bitSet(SPI_ENABLE, ArchIO.Spi1.ControlReg);
			Dummy = periphMemRead(&ArchIO.Spi1.DataRxReg);
		}
	}
	
	else
	{
		return -1;
	}

	pSpi -> DataFormat   = EightBitChars;
	pSpi -> bInitialized = false;
	
	return (int) pSpi;
}

/*****************************************************************************/
int spiClose(int FileDesc)
{
	return 0;
}

/*****************************************************************************/
ssize_t spiRead(int FileDesc, void * pBuffer, size_t NBytes)
{
	sSpi    * pSpi = (sSpi *) FileDesc;
	UWord16   I = 1;

	if(pSpi -> bMaster == true)
	{
		((UWord16 *)pBuffer)[0] = ((sSpi *)FileDesc) -> ReadData;
	}
	else if(((pSpi -> Handle) == SPI_HANDLE_0) && (pSpi -> bMaster == false))
	{
		for(I = 0; I < NBytes; I++)
		{
			CheckSpi0Test:
				bitTestHigh(SPI_INT_COMPLETE, ArchIO.Spi0.ControlReg);
				asm(bcc CheckSpi0Test);
			((UWord16 *)pBuffer)[I] = periphMemRead(&ArchIO.Spi0.DataRxReg);
		}
	}
	else
	{
		for(I = 0; I < NBytes; I++)
		{
			CheckSpi1Test:
				bitTestHigh(SPI_INT_COMPLETE, ArchIO.Spi1.ControlReg);
				asm(bcc CheckSpi1Test);
			((UWord16 *)pBuffer)[I] = periphMemRead(&ArchIO.Spi1.DataRxReg);
		}
	}

	return I;
}

/*****************************************************************************/
static UWord16 SendBits(sSpi * pSpi, UWord16 Data)
{
	UWord16 Dummy = 0;
	
	if(pSpi -> Handle == SPI_HANDLE_0)
	{
	    periphMemWrite(Data, &ArchIO.Spi0.DataTxReg);

	    CheckSpi0:
		    bitTestHigh(SPI_INT_COMPLETE, ArchIO.Spi0.ControlReg);
		    asm(bcc CheckSpi0);

	    Dummy = periphMemRead(&ArchIO.Spi0.DataRxReg);
    }
    else if (pSpi -> Handle == SPI_HANDLE_1)
    {
	    periphMemWrite(Data, &ArchIO.Spi1.DataTxReg);

	    CheckSpi1:
		    bitTestHigh(SPI_INT_COMPLETE, ArchIO.Spi1.ControlReg);
		    asm(bcc CheckSpi1);

	    Dummy = periphMemRead(&ArchIO.Spi1.DataRxReg);    
    }
	return Dummy;
}

/*****************************************************************************/
ssize_t spiWrite(int FileDesc, UWord16 * pBuffer, size_t Size)
{
	sSpi    * pSpi        = (sSpi *)    FileDesc;
	UWord16 * pDataBuffer = (UWord16 *) pBuffer;
	UWord16   Data;
	int I;

	if(pSpi -> bMaster == true)
	{
		pSpi -> pSlaveSelect();
	}

	if(pSpi -> DataFormat == EightBitChars)
	{
		for(; Size; pDataBuffer++, Size--)
		{
			pSpi -> ReadData = SendBits(pSpi, *pDataBuffer);
		}
	}
	else
	{
		for(; Size; pDataBuffer++, Size--)
		{
			Data = (*pDataBuffer) >> 8;
			Data = SendBits(pSpi, Data);
			pSpi -> ReadData = (Data << 8) & 0xFF00;

			Data = *pDataBuffer;
			Data = SendBits(pSpi, Data);
			pSpi -> ReadData = (pSpi -> ReadData) | (Data & 0x00FF);
		}
	}

	if(pSpi -> bMaster == true)
	{
		pSpi -> pSlaveDeselect();
	}

	return Size;
}
