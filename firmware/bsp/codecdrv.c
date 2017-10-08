//******************************************************************************
//******************************************************************************
// 			Рабочий CODEC на PCM1717 но совместимый с SDK по вызовам
//******************************************************************************
//******************************************************************************
/*******************************************************************************
*
* Motorola Inc.
* (c) Copyright 2001 Motorola, Inc.
* ALL RIGHTS RESERVED.
* 
********************************************************************************
*
* FILE NAME:   codecdrv.c
*
* DESCRIPTION: source file for the Crystal CS4218 16-bit Stereo Audio
*              Codec device driver
*
*******************************************************************************/

#include "bsp.h"
#include "port.h"
#include "arch.h"
#include "types.h"

#include "io.h"
#include "fifo.h"
#include "fcntl.h"

#include "stdlib.h"
#include "string.h"
#include "stdarg.h"

#include "mem.h"
#include "bit.h"
#include "periph.h"
#include "portcdrv.h"

//#define __SSIDRV_H //temporary close ssi
#include "ssi.h"


#include "codec.h"
#include "iprdrv.h"

#define TX_CONTROL_BITS        16

#define CODECDRV_CCS   gpioPin(D,2)
#define CODECDRV_CDIN  gpioPin(D,1)
#define CODECDRV_CCLK  gpioPin(D,0)


static void EnableCodec(void);
static void DisableCodec(void);
static void StereoISR(void);
static void MonoISR(void);
static void codec_send_cfg(UWord16 data);

static io_sInterface InterfaceVT = {
	codecClose,
	codecRead,
	codecWrite,
	codecIoctl,
};

typedef struct
{
	UWord16      InitialFifoSize;
	UWord16      InitialFifoThreshold;
	UWord16    * pRxBuffer;
	UWord16    * pTxBuffer;
	UWord16      BufferSize;
	UWord16      Mode;
	UWord16      RxConfig;
	UWord16      TxConfig;
	bool         bInitialized;
	bool         bBlocking;
	UWord16      BufferIndex;
	fifo_sFifo * pRxSamples;
	fifo_sFifo * pTxSamples;
} sCodec;

static sCodec Codec;

const io_sDriver codecdrvDriver = {&InterfaceVT, (int)&Codec};


/*****************************************************************************
*
* SSIINITIALIZE
*
* Semantics:
*     The ssiInitialize() function initializes the SSI device.
*
* Return Value: 
*     Upon successful completion, the function will return a value of zero.
*     Otherwise, a value of -1 will be returned and errno will be set to
*     indicate the error.
*
*****************************************************************************/
UWord16 simple_ssiInitialize(arch_sSSI * pSsiInitialState)
{
	periphBitSet(PORT_C_SSI_ENABLE, &ArchIO.PortC.PeripheralReg);
	periphBitSet(PORT_C_SSI_ENABLE, &ArchIO.PortC.DataDirectionReg);
	
	periphMemWrite(pSsiInitialState->RxControlReg, &ArchIO.Ssi.RxControlReg);

	periphMemWrite(pSsiInitialState->TxControlReg, &ArchIO.Ssi.TxControlReg);

	periphMemWrite(pSsiInitialState->ControlStatusReg, &ArchIO.Ssi.ControlStatusReg);

	periphMemWrite(pSsiInitialState -> Control2Reg, &ArchIO.Ssi.Control2Reg);
	
	periphMemWrite(pSsiInitialState -> FifoCntlStatReg, &ArchIO.Ssi.FifoCntlStatReg);
	
	periphMemWrite(pSsiInitialState -> OptionReg, &ArchIO.Ssi.OptionReg);
}

/*******************************************************************************
*
* NAME: codecDevCreate()
*
* PURPOSE: Create the codec device.
*
* DESCRIPTION: This function creates Codec device by registering it with the
*              ioLib library. Once the driver is registered, the Codec driver
*              services are available for use by application via ioLib and 
*              POSIX calls.
*
*              This function also stores the default configuration of the Codec
*              which will be used by the "open" function to configure the Codec.
*
********************************************************************************
* PARAMETERS:	pName - Name of the codec device
*               pConfig - Pointer to configuration data for the Codec
*
* RETURN:		0
*
* SIDE EFFECTS:   
*
* DESIGNER NOTES:
*
* DEPENDENCIES: This function must be called prior to calling any of the codec
*               I/O functions.  The call to this function is conditionally compiled
*               in config.c when you INCLUDE_CODEC is defined appconfig.h
*******************************************************************************/

UWord16 codecDevCreate(const char * pName, codec_sParams * pParams)
{
	Codec.InitialFifoSize      = pParams -> Buffer.Size;
	Codec.InitialFifoThreshold = pParams -> Buffer.Threshold;
	Codec.pRxBuffer            = pParams -> pOptimizationRxBuffer;
	Codec.pTxBuffer            = pParams -> pOptimizationTxBuffer;
	Codec.BufferSize           = pParams -> OptimizationBufferSize;
	Codec.RxConfig             = pParams -> RxConfig;
	Codec.TxConfig             = pParams -> TxConfig;
	Codec.Mode                 = pParams -> Mode;
    
	ioDrvInstall(codecOpen);

	return 0;
}

/*******************************************************************************
*
* NAME: codecOpen()
*
* PURPOSE: Open and initialize a codec device.
*
* DESCRIPTION: This function opens the desired codec device and initializes
*              it based on the parameters passed in.  This function also sets
*              up the GPIO to communicate with the Codec and configures the
*              codec with the default configuration that was stored in the
*              codecDevCreate() function.
*
********************************************************************************
* PARAMETERS:	pName - Name of device
*               OFlags - Information used for configuring the device
*               pParams - Open parameters for the codec device (codec_sParams type)
*
* RETURN:		CODEC device descriptor if open is successful.
*               -1 value if open failed.
*
* SIDE EFFECTS:   This function assumes the parameters passed in are
*                 initialized.  Unexpected behavior will result if they
*                 are not initialized.
*
* DESIGNER NOTES:   The codec must be configured twice after a reset.  The first
*                   write is considered a dummy write.  The second write is
*                   the one that will actually configure the codec.
*
* DEPENDENCIES: codecDevCreate() must be called first
*******************************************************************************/

io_sDriver * codecOpen(const char * pName, int OFlags, ...)
{
	int  GpioCodec;
	void (*pISR)(void);

	if((int)pName != (int)BSP_DEVICE_NAME_CODEC_0)
	{
		return (io_sDriver *) -1;
	}

	Codec.bInitialized = false;
	Codec.BufferIndex  = 0;
	Codec.bBlocking    = (((UWord16)OFlags & O_NONBLOCK) ? false : true);
	Codec.pRxSamples   = fifoCreate(Codec.InitialFifoSize, Codec.InitialFifoThreshold);
	Codec.pTxSamples   = fifoCreate(Codec.InitialFifoSize, Codec.InitialFifoThreshold);

//	pISR = (Codec.Mode == CODEC_STEREO ? StereoISR : MonoISR);

//	archInstallISR(&(pArchInterrupts -> SSIReceiveDataException), pISR);
//	archInstallISR(&(pArchInterrupts -> SSIReceiveData), pISR);	
	        
	GpioCodec = open (BSP_DEVICE_NAME_GPIO_D, 0);

	/* CONFIGURE PINS CONNECTED TO CCS, CDIN, CCLK, AND RESET AS GPIO */

	ioctl (GpioCodec, GPIO_SETAS_GPIO, CODECDRV_CCS | CODECDRV_CDIN | CODECDRV_CCLK );

	/* CONFIGURE PINS TO BE OUTPUTS */
	
	ioctl (GpioCodec, GPIO_SETAS_OUTPUT, CODECDRV_CCS | CODECDRV_CDIN | CODECDRV_CCLK );

	/* INITIALIZE CCLK TO LOW */
 	
	ioctl (GpioCodec, GPIO_CLEAR, CODECDRV_CCLK); 

	/* THE PCM1717 REQUIRES ONE DUMMY WRITE TO THE CONTROL SECTION.
	THE FOLLOWING FUNCTION CALL DOES THIS */

	/* THE NEXT WRITE TO THE CONTROL SECTION ACTUALLY CONFIGURES
	THE CODEC */
  
  	codec_send_cfg(CODEC_ATTEN_LEFT(CODEC_ATTENUATION_MAX));
	codec_send_cfg(CODEC_ATTEN_RIGHT(CODEC_ATTENUATION_MAX));
	codec_send_cfg(CODEC_REG2_INI);
	codec_send_cfg(CODEC_REG3_INI);

	//EnableCodec();
	
	return (io_sDriver *)&codecdrvDriver;
}


/*******************************************************************************
*
* NAME: codecClose()
*
* PURPOSE: Close the codec device.
*
* DESCRIPTION: This function does nothing.
*
********************************************************************************
* PARAMETERS:	FileDesc - Handle assigned to the codec device
*
* RETURN:		0
*
* SIDE EFFECTS:   
*
* DESIGNER NOTES:   
*
* DEPENDENCIES: codecOpen must be called first
*******************************************************************************/

int codecClose(int FileDesc)
{
	DisableCodec();

//	archRemoveISR(&(pArchInterrupts -> SSIReceiveDataException));
//	archRemoveISR(&(pArchInterrupts -> SSIReceiveData));	

	fifoDestroy(Codec.pRxSamples);
	fifoDestroy(Codec.pTxSamples);
	
	return 0;
}

/*******************************************************************************
*
* NAME: codecRead()
*
* PURPOSE: Read from the codec device.
*
* DESCRIPTION: This function reads data from the fifo interface to the
*              Codec ISR.  If configured for Blocking mode, this function
*              will not return until the requested number of samples have
*              been read.  If configured for Non-Blocking mode, this
*              function will read upto the requested number of samples
*              and return immediately.
*
*              If the codec has not been enabled, then this function will
*              enable it.
*
********************************************************************************
* PARAMETERS:	FileDesc - Handle assigned to the codec device
*               pBuffer - Array to store the received samples in
*               nBytes - Requested number of samples to read
*
* RETURN:		Number of samples read
*
* SIDE EFFECTS:   
*
* DESIGNER NOTES:   
*
* DEPENDENCIES: codecOpen must be called first
*******************************************************************************/

ssize_t codecRead(int FileDesc, void * pBuffer, size_t NBytes)
{
	sCodec * pCodec = (sCodec *) FileDesc;
	UWord16           BytesRead = 0;

	if(pCodec -> bInitialized == false)
	{
		EnableCodec();
		pCodec -> bInitialized = true;
	}

	if(pCodec -> bBlocking) /* BLOCKING MODE */
	{
		do {
			BytesRead = fifoExtract(pCodec -> pRxSamples, pBuffer, NBytes);
		} while(BytesRead == 0);
	}
	else /* NON-BLOCKING MODE */
	{
	    BytesRead = fifoExtract(pCodec -> pRxSamples, pBuffer, NBytes);
	}

	return BytesRead;
}

/*******************************************************************************
*
* NAME: codecWrite()
*
* PURPOSE: Write to the codec device.
*
* DESCRIPTION: This function writes data from the fifo interface to the
*              Codec ISR.  If configured for Blocking mode, this function
*              will not return until the requested number of samples have
*              been written.  If configured for Non-Blocking mode, this
*              function will write the requested number of samples to the
*              fifo and return or will write samples to the fifo until the
*              fifo is full and return, whichever occurs first.
*
*              If the codec has not been enabled, then this function will
*              enable it.
*
********************************************************************************
* PARAMETERS:	FileDesc - Handle assigned to the codec device
*               pBuffer - Array containing the samples to be transmitted
*               nBytes - Requested number of samples to write
*
* RETURN:		Number of samples written
*
* SIDE EFFECTS:   
*
* DESIGNER NOTES:   
*
* DEPENDENCIES: codecOpen() must be called first
*******************************************************************************/

ssize_t codecWrite(int FileDesc, const void * pBuffer, size_t Size)
{
	UWord16           BytesWritten = 0;
	Word16          * pSamplesBuffer = (Word16 *) pBuffer;
	sCodec * pCodec = (sCodec *) FileDesc;

	if(pCodec -> bInitialized == false)
	{
		EnableCodec();
		pCodec -> bInitialized = true;
	}

	if(pCodec -> bBlocking) /* BLOCKING MODE */
	{
		do {
			BytesWritten += fifoInsert(pCodec -> pTxSamples,
			                           pSamplesBuffer + BytesWritten,
			                           Size - BytesWritten);
		} while(BytesWritten < Size);
	}
	else /* NON-BLOCKING MODE */
	{
	    BytesWritten = fifoInsert(pCodec -> pTxSamples, pSamplesBuffer, Size);
	}

	return BytesWritten;
}

/*****************************************************************************
* 
* Module: void codec_send_cfg( UWord16 data)
* 
* Description: Send control data to PCM1717E 
* 
* Returns: 
* 
* Global Data: 
* 
* Arguments: 
* 
* Range Issues:  
* 
* Special Issues:  
* 
*****************************************************************************/

void codec_send_cfg( UWord16 data)
{
	int i;
	int GpioCodec;	

	GpioCodec = open (BSP_DEVICE_NAME_GPIO_D, 0);
	
	/* Initialize clock */
	ioctl (GpioCodec, GPIO_CLEAR, CODECDRV_CCLK);  				/* CLOCK LOW */        
	ioctl (GpioCodec, GPIO_SET, CODECDRV_CCS);     				/* ML HIGHT */

	/* CLOCK IN THE TRANSMIT CONTROL BITS */
	for (i=TX_CONTROL_BITS-1; i>=0; i--)
	{
		ioctl (GpioCodec, GPIO_CLEAR, CODECDRV_CCLK);  			/* CLOCK LOW */

		if (((data >> i) & 0x0001) != 0)
				ioctl (GpioCodec, GPIO_SET, CODECDRV_CDIN);  	/* DATA = 1 */
		else
				ioctl (GpioCodec, GPIO_CLEAR, CODECDRV_CDIN);  	/* DATA = 0 */

		ioctl (GpioCodec, GPIO_SET, CODECDRV_CCLK);  			/* CLOCK HIGH */
		asm(nop); 							/* DELAY FOR TIMING REQUIREMENTS */
	}
	ioctl (GpioCodec, GPIO_CLEAR, CODECDRV_CCS);  				/* ML LOW */
	asm(nop); 								/* DELAY FOR TIMING REQUIREMENTS */
	ioctl (GpioCodec, GPIO_SET, CODECDRV_CCS);    				/* ML HIG */
}

/*******************************************************************************
*
* NAME: codecIoctl()
*
* PURPOSE: Control the codec device.
*
* DESCRIPTION: This function configures the codec device. 
*
*              The CODEC_RESET_DEVICE command disables the codec, resets the fifo
*              interface, and re-enables the codec if it had previously been
*              enabled.
*
*              The CODEC_CONFIG command configures the codec.  32 bits of
*              control data are written to the codec.  The control data is
*              composed of information from the parameters passed in.
*
********************************************************************************
* PARAMETERS:	FileDesc - Handle assigned to the codec device
*               Cmd - Configuration Command
*               pParams - pointer to structure containing configuration data
*
* RETURN:		0
*
* SIDE EFFECTS:   
*
* DESIGNER NOTES:   
*
* DEPENDENCIES: codecDevCreat() must be called first
*******************************************************************************/

UWord16 codecIoctl(int FileDesc, UWord16 Cmd, void * pParams, ...)
{
	sCodec        * pCodec       = (sCodec *) FileDesc;
	codec_sParams * pCodecParams = (codec_sParams *)pParams;

	switch(Cmd)
	{
		case CODEC_DEVICE_RESET:
		{
			DisableCodec();

			fifoDestroy(pCodec -> pRxSamples);
			fifoDestroy(pCodec -> pTxSamples);

			pCodec -> pRxSamples = fifoCreate((pCodecParams -> Buffer).Size,
														(pCodecParams -> Buffer).Threshold);
			pCodec -> pTxSamples = fifoCreate((pCodecParams -> Buffer).Size,
														(pCodecParams -> Buffer).Threshold);
			
			pCodec -> BufferIndex = 0;

			if(pCodec -> bInitialized)
			{
				EnableCodec();
			}

			break;
		}
		
		case CODEC_CONFIG:
		{
			codec_send_cfg(pCodecParams -> TxConfig);
			break;
		}
        
		default:
			break;
	}

	return 0;
}

/*****************************************************************************/
static void EnableCodec(void)
{
	/* Enable SSI device */
	periphBitSet(SSI_ENABLE, &ArchIO.Ssi.Control2Reg);
}

/*****************************************************************************/
static void DisableCodec(void)
{
	/* Disable SSI device */
	periphBitClear(SSI_ENABLE, &ArchIO.Ssi.Control2Reg);
}

/*******************************************************************************
*
* NAME: StereoISR()
*
* PURPOSE: Interrupt Service Routine that is called when configured for
*          Stereo mode.
*
* DESCRIPTION: This function reads and writes codec samples to the fifo
*              interface that communicates to the user's application.
*              Once the desired amount of samples have been collected as
*              defined by codecdrvCodec.BufferSize, the received samples are
*              written to the fifo and the samples to be transmitted are
*              read from the fifo.
*
*              This function reads the ControlStatus register in order to
*              clear out any exception that may have occurred.  This is
*              very useful when debugging because setting a breakpoint in
*              this ISR will cause an exception.  By reading the ControlStatus
*              register, the exception is cleared and you can resume
*              execution without having to reset the DSP.
*
*              In stereo mode, a left and right 16-bit sample is read and
*              written to/from the codec.  This requires two words in the
*              codec receive/transmit buffer.  The samples in the buffer
*              will be interlaced.  Stereo mode generates twice as many
*              samples as mono mode.
*
********************************************************************************
* PARAMETERS:	None
*
* RETURN:		None
*
* SIDE EFFECTS: codecdrvCodec.BufferSize should be an even number.
*
* DESIGNER NOTES: The ISR will take less MIPS as you increase the size of
*                 codecdrvCodec.BufferSize, however, you will not be able to read/
*                 write the samples from the application until the buffer
*                 is full.  Basically, a bigger buffer requires less MIPs, but
*                 it introduces extra delay to the system.  
*
* DEPENDENCIES: None
*******************************************************************************/

static void StereoISR(void)
{
#ifdef CODEC_FAST_ISR
#else
	UWord16 status;
    
	ioctl (GpioCodec, GPIO_SET, CODECDRV_CCLK);  /* DEBUG */

	if(Codec.BufferIndex == Codec.BufferSize)
	{
		Codec.BufferIndex = 0;

		if(Codec.bInitialized)
		{
			fifoInsert(Codec.pRxSamples, (Word16 *) Codec.pRxBuffer, 
															Codec.BufferSize * sizeof(Word16));
			fifoExtract(Codec.pTxSamples, (Word16 *) Codec.pTxBuffer, 
															Codec.BufferSize * sizeof(Word16));
		}
	}

	/* Read the Control/Status Register to clear any exception */
	status = periphMemRead(&ArchIO.Ssi.ControlStatusReg);

	/* Read Left A/D sample */
	Codec.pRxBuffer[Codec.BufferIndex] = periphMemRead(&ArchIO.Ssi.ReceiveReg);

	/* Write Left D/A sample */
	periphMemWrite(Codec.pTxBuffer[Codec.BufferIndex], &ArchIO.Ssi.TransmitReg); 
	
	Codec.BufferIndex += 1;

	/* Read Right A/D sample */
	Codec.pRxBuffer[Codec.BufferIndex] = periphMemRead(&ArchIO.Ssi.ReceiveReg);

	/* Write Right D/A sample */
	periphMemWrite(Codec.pTxBuffer[Codec.BufferIndex], &ArchIO.Ssi.TransmitReg); 
	
	Codec.BufferIndex += 1;
					    
	ioctl (GpioCodec, GPIO_CLEAR, CODECDRV_CCLK);  /* DEBUG */
#endif
}

/*******************************************************************************
*
* NAME: MonoISR()
*
* PURPOSE: Interrupt Service Routine that is called when configured for
*          Mono mode.
*
* DESCRIPTION: This function reads and writes codec samples to the fifo
*              interface that communicates to the user's application.
*              Once the desired amount of samples have been collected as
*              defined by codecdrvCodec.BufferSize, the received samples are
*              written to the fifo and the samples to be transmitted are
*              read from the fifo.
*
*              This function reads the ControlStatus register in order to
*              clear out any exception that may have occurred.  This is
*              very useful when debugging because setting a breakpoint in
*              this ISR will cause an exception.  By reading the ControlStatus
*              register, the exception is cleared and you can resume
*              execution without having to reset the DSP.
*
*              In mono mode, a left and right 16-bit sample is read from the
*              codec and added to form one single sample.  Also, one sample
*              is read from the transmit buffer and written as both the left
*              and right samples.  This requires only one word in the
*              codec receive/transmit buffer.  Mono mode generates half as many
*              samples as stereo mode.
*
********************************************************************************
* PARAMETERS:	None
*
* RETURN:		None
*
* SIDE EFFECTS: 
*
* DESIGNER NOTES: The ISR will take less MIPS as you increase the size of
*                 codecdrvCodec.BufferSize, however, you will not be able to read/
*                 write the samples from the application until the buffer
*                 is full.  Basically, a bigger buffer requires less MIPs, but
*                 it introduces extra delay to the system.  
*
* DEPENDENCIES: None
*******************************************************************************/

static void MonoISR(void)
{
	UWord16 status;
    
	ioctl (GpioCodec, GPIO_SET, CODECDRV_CCLK);  /* DEBUG */

	if(Codec.BufferIndex == Codec.BufferSize)
	{
		Codec.BufferIndex = 0;

		if(Codec.bInitialized)
		{
			fifoInsert(Codec.pRxSamples, (Word16 *) Codec.pRxBuffer, 
															Codec.BufferSize * sizeof(Word16));
			fifoExtract(Codec.pTxSamples, (Word16 *) Codec.pTxBuffer, 
															Codec.BufferSize * sizeof(Word16));
		}
	}

	/* Read the Control/Status Register to clear any exception */
	status = periphMemRead(&ArchIO.Ssi.ControlStatusReg);

	/* Read Left A/D sample */
	Codec.pRxBuffer[Codec.BufferIndex] = __shr(periphMemRead(&ArchIO.Ssi.ReceiveReg),1);

	/* Write Left D/A sample */
	periphMemWrite(Codec.pTxBuffer[Codec.BufferIndex], &ArchIO.Ssi.TransmitReg); 

	/* Read Right A/D sample and add to Left A/D Sample */
	Codec.pRxBuffer[Codec.BufferIndex] = Codec.pRxBuffer[Codec.BufferIndex] + __shr(periphMemRead(&ArchIO.Ssi.ReceiveReg),1);

	/* Write Right D/A sample (Same as Left D/A sample) */
	periphMemWrite(Codec.pTxBuffer[Codec.BufferIndex], &ArchIO.Ssi.TransmitReg); 
	
	Codec.BufferIndex += 1;
					    
	ioctl (GpioCodec, GPIO_CLEAR, CODECDRV_CCLK);  /* DEBUG */
}
