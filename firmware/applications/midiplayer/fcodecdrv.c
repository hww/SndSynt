//******************************************************************************
// 			     CODEC PCM1717 (not supported by SDK)
//				    (not optimized by performance)
/*******************************************************************************
********************************************************************************
*
* FILE NAME:   fcodecdrv.c
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

#include "mem.h"
#include "bit.h"
#include "periph.h"
#include "portcdrv.h"

//#define __SSIDRV_H //temporary close ssi
#include "ssi.h"

#include "fcodec.h"
#include "iprdrv.h"
#include "audiolib.h"

#define TX_CONTROL_BITS        16

#define CODECDRV_CCS   gpioPin(D,2)
#define CODECDRV_CDIN  gpioPin(D,1)
#define CODECDRV_CCLK  gpioPin(D,0)
#define CODECDRV_ZERO  gpioPin(D,4)

static void EnableFCodec(void);
static void DisableFCodec(void);

 UInt16   dma_pos;
 UInt16   dma_modulo;
 UInt16   dma_buf_1;
 UInt16   dma_buf_2;
 UInt16   dma_frame;

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
UWord16 fsimple_ssiInitialize(arch_sSSI * pSsiInitialState)
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

void fcodecOpen(void)
{
	int  GpioCodec;
	        
	GpioCodec = open (BSP_DEVICE_NAME_GPIO_D, 0);

	/* CONFIGURE PINS CONNECTED TO CCS, CDIN, CCLK, AND RESET AS GPIO */

	ioctl (GpioCodec, GPIO_SETAS_GPIO, CODECDRV_CCS | CODECDRV_CDIN | CODECDRV_CCLK | CODECDRV_ZERO );

	/* CONFIGURE PINS TO BE OUTPUTS */
	
	ioctl (GpioCodec, GPIO_SETAS_OUTPUT, CODECDRV_CCS | CODECDRV_CDIN | CODECDRV_CCLK | CODECDRV_ZERO);

	/* INITIALIZE CCLK TO LOW */
 	
	ioctl (GpioCodec, GPIO_CLEAR, CODECDRV_CCLK); 

	ioctl (GpioCodec, GPIO_SET, CODECDRV_ZERO); 

	/* THE NEXT WRITE TO THE CONTROL SECTION ACTUALLY CONFIGURES
	THE CODEC */

  	fcodecSendCfg(CODEC_ATTEN_LEFT(CODEC_ATTENUATION_DEF));
	fcodecSendCfg(CODEC_ATTEN_RIGHT(CODEC_ATTENUATION_DEF));
	fcodecSendCfg(CODEC_REG2_INI);
	fcodecSendCfg(CODEC_REG3_INI);

	dma_buf_1 = (UInt16) memMallocAlignedEM(FRAME_BUF_SIZE<<1);
	dma_buf_2 = (UInt16) ((UInt16)dma_buf_1+(FRAME_SIZE<<1));
	dma_pos   = dma_buf_1;
	dma_modulo= (FRAME_BUF_SIZE<<1)-1;
	dma_frame = 0;

	memset((void*)dma_buf_1, 0, FRAME_BUF_SIZE<<1 );
	
//	archInstallFastISR(&(pArchInterrupts -> SSITransmitDataException), fcodecStereoISR);
//	archInstallFastISR(&(pArchInterrupts -> SSITransmitData), fcodecStereoISR);	

	EnableFCodec();
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

void fcodecClose(void)
{
	DisableFCodec();
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

void fcodecSendCfg( UWord16 data)
{
	int i;
	int GpioCodec;	

	GpioCodec = open (BSP_DEVICE_NAME_GPIO_D, 0);
	
	/* Initialize clock */
	ioctl (GpioCodec, GPIO_CLEAR, CODECDRV_CCLK);  				/* CLOCK LOW */        
	ioctl (GpioCodec, GPIO_SET, CODECDRV_CCS);     				/* ML HIGHT */
	archDelay(10);

	/* CLOCK IN THE TRANSMIT CONTROL BITS */
	for (i=TX_CONTROL_BITS-1; i>=0; i--)
	{
		ioctl (GpioCodec, GPIO_CLEAR, CODECDRV_CCLK);  			/* CLOCK LOW */

		if (((data >> i) & 0x0001) != 0)
				ioctl (GpioCodec, GPIO_SET, CODECDRV_CDIN);  	/* DATA = 1 */
		else
				ioctl (GpioCodec, GPIO_CLEAR, CODECDRV_CDIN);  	/* DATA = 0 */

		archDelay(10);						/* DELAY FOR TIMING REQUIREMENTS */
		ioctl (GpioCodec, GPIO_SET, CODECDRV_CCLK);  			/* CLOCK HIGH */
		archDelay(10);						/* DELAY FOR TIMING REQUIREMENTS */
	}
	ioctl (GpioCodec, GPIO_CLEAR, CODECDRV_CCS);  				/* ML LOW */
	archDelay(10);							/* DELAY FOR TIMING REQUIREMENTS */
	ioctl (GpioCodec, GPIO_CLEAR, CODECDRV_CCLK);  				/* CLOCK LOW */        
	archDelay(10);							/* DELAY FOR TIMING REQUIREMENTS */
	ioctl (GpioCodec, GPIO_SET, CODECDRV_CCS);    				/* ML HIG */
}



/*****************************************************************************/
static void EnableFCodec(void)
{
	/* Enable SSI device */
	periphBitSet(SSI_ENABLE, &ArchIO.Ssi.Control2Reg);
}

/*****************************************************************************/
static void DisableFCodec(void)
{
	/* Disable SSI device */
	periphBitClear(SSI_ENABLE, &ArchIO.Ssi.Control2Reg);
}

/*****************************************************************************/
Int16 *  fcodecWaitBuf(void)
{
	switch(dma_frame)
	{
	case 0:
		while(dma_pos <  dma_buf_2) asm{nop};
		dma_frame = 1;
		return (Int16*)dma_buf_1;
	case 1:
		while(dma_pos >= dma_buf_2) asm{nop};
		dma_frame = 0;
		return (Int16*)dma_buf_2;
	}
}

/*******************************************************************************
*
* NAME: StereoISR()
*
* PURPOSE: Interrupt Service Routine that is called when configured for
*          Stereo mode.
*
*******************************************************************************/

void fcodecStereoISR(void)
{
	// Called if fifo has 6 or more empty records 
	{
		push	r0
		push	x0
		push	m01
		move	dma_modulo,m01
		move	dma_pos,r0
		move	X:0x1000 + arch_sIO.Ssi.ControlStatusReg,x0
		move	X:(r0)+,x0
		move	x0,X:0x1000 + arch_sIO.Ssi.TransmitReg
		move	X:(r0)+,x0
		move	x0,X:0x1000 + arch_sIO.Ssi.TransmitReg
		move	X:(r0)+,x0
		move	x0,X:0x1000 + arch_sIO.Ssi.TransmitReg
		move	X:(r0)+,x0
		move	x0,X:0x1000 + arch_sIO.Ssi.TransmitReg
//		move	X:(r0)+,x0
//		move	x0,X:0x1000 + arch_sIO.Ssi.TransmitReg
//		move	X:(r0)+,x0
//		move	x0,X:0x1000 + arch_sIO.Ssi.TransmitReg
		move	r0,dma_pos
		pop		m01
		pop		x0
		pop		r0
		rti
	}
}


void	fcodecMute( bool mute )
{
	int  GpioCodec;
	GpioCodec = open (BSP_DEVICE_NAME_GPIO_D, 0);
	if(mute)
		ioctl (GpioCodec, GPIO_SET, CODECDRV_ZERO); 
	else
		ioctl (GpioCodec, GPIO_CLEAR, CODECDRV_ZERO); 
	close(GpioCodec);
}
