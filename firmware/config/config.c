/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name:         config.c
*
* Description:       Main to generate configuration of SDK application
*
* Modules Included:  
*                    
* 
*****************************************************************************/
#include "port.h"
#include "arch.h"
#include "string.h" /* to be removed, used in PC Master */
#include "config.h"

#ifdef __cplusplus
extern "C" {
#endif

EXPORT void UserPreMain(void);
EXPORT void UserPostMain(void);
EXPORT void configInitialize(void);
EXPORT void configFinalize(void);



extern void configUnhandledInterruptISR (void);
 

asm void configUnhandledInterruptISR (void)
{
	/* 
		No interrupt handler had been specified for the interrupt vector,
		so the interrupt vector defaulted to this routine which is
		a wait forever loop.
	*/
	UnhandledInt:
		debug
		bra    UnhandledInt
}


EXPORT UWord16 archISRType[(sizeof(arch_sInterrupts) / sizeof(UWord32) + 15) / 16] =
/* 
	archISRType is an array of bits for each interrupt
		0 => Normal interrupt
		1 => Fast interrupt
*/
	{   0
			#ifdef FAST_ISR_0
				| 0x0001
			#endif
			#ifdef FAST_ISR_1
				| 0x0002
			#endif
			#ifdef FAST_ISR_2
				| 0x0004
			#endif
			#ifdef FAST_ISR_3
				| 0x0008
			#endif
			#ifdef FAST_ISR_4
				| 0x0010
			#endif
			#ifdef FAST_ISR_5
				| 0x0020
			#endif
			#ifdef FAST_ISR_6
				| 0x0040
			#endif
			#ifdef FAST_ISR_7
				| 0x0080
			#endif
			#ifdef FAST_ISR_8
				| 0x0100
			#endif
			#ifdef FAST_ISR_9
				| 0x0200
			#endif
			#ifdef FAST_ISR_10
				| 0x0400
			#endif
			#ifdef FAST_ISR_11
				| 0x0800
			#endif
			#ifdef FAST_ISR_12
				| 0x1000
			#endif
			#ifdef FAST_ISR_13
				| 0x2000
			#endif
			#ifdef FAST_ISR_14
				| 0x4000
			#endif
			#ifdef FAST_ISR_15
				| 0x8000
			#endif
		,0
			#ifdef FAST_ISR_16
				| 0x0001
			#endif
			#ifdef FAST_ISR_17
				| 0x0002
			#endif
			#ifdef FAST_ISR_18
				| 0x0004
			#endif
			#ifdef FAST_ISR_19
				| 0x0008
			#endif
			#ifdef FAST_ISR_20
				| 0x0010
			#endif
			#ifdef FAST_ISR_21
				| 0x0020
			#endif
			#ifdef FAST_ISR_22
				| 0x0040
			#endif
			#ifdef FAST_ISR_23
				| 0x0080
			#endif
			#ifdef FAST_ISR_24
				| 0x0100
			#endif
			#ifdef FAST_ISR_25
				| 0x0200
			#endif
			#ifdef FAST_ISR_26
				| 0x0400
			#endif
			#ifdef FAST_ISR_27
				| 0x0800
			#endif
			#ifdef FAST_ISR_28
				| 0x1000
			#endif
			#ifdef FAST_ISR_29
				| 0x2000
			#endif
			#ifdef FAST_ISR_30
				| 0x4000
			#endif
			#ifdef FAST_ISR_31
				| 0x8000
			#endif
		,0
			#ifdef FAST_ISR_32
				| 0x0001
			#endif
			#ifdef FAST_ISR_33
				| 0x0002
			#endif
			#ifdef FAST_ISR_34
				| 0x0004
			#endif
			#ifdef FAST_ISR_35
				| 0x0008
			#endif
			#ifdef FAST_ISR_36
				| 0x0010
			#endif
			#ifdef FAST_ISR_37
				| 0x0020
			#endif
			#ifdef FAST_ISR_38
				| 0x0040
			#endif
			#ifdef FAST_ISR_39
				| 0x0080
			#endif
			#ifdef FAST_ISR_40
				| 0x0100
			#endif
			#ifdef FAST_ISR_41
				| 0x0200
			#endif
			#ifdef FAST_ISR_42
				| 0x0400
			#endif
			#ifdef FAST_ISR_43
				| 0x0800
			#endif
			#ifdef FAST_ISR_44
				| 0x1000
			#endif
			#ifdef FAST_ISR_45
				| 0x2000
			#endif
			#ifdef FAST_ISR_46
				| 0x4000
			#endif
			#ifdef FAST_ISR_47
				| 0x8000
			#endif
		,0
			#ifdef FAST_ISR_48
				| 0x0001
			#endif
			#ifdef FAST_ISR_49
				| 0x0002
			#endif
			#ifdef FAST_ISR_50
				| 0x0004
			#endif
			#ifdef FAST_ISR_51
				| 0x0008
			#endif
			#ifdef FAST_ISR_52
				| 0x0010
			#endif
			#ifdef FAST_ISR_53
				| 0x0020
			#endif
			#ifdef FAST_ISR_54
				| 0x0040
			#endif
			#ifdef FAST_ISR_55
				| 0x0080
			#endif
			#ifdef FAST_ISR_56
				| 0x0100
			#endif
			#ifdef FAST_ISR_57
				| 0x0200
			#endif
			#ifdef FAST_ISR_58
				| 0x0400
			#endif
			#ifdef FAST_ISR_59
				| 0x0800
			#endif
			#ifdef FAST_ISR_60
				| 0x1000
			#endif
			#ifdef FAST_ISR_61
				| 0x2000
			#endif
			#ifdef FAST_ISR_62
				| 0x4000
			#endif
			#ifdef FAST_ISR_63
				| 0x8000
			#endif
};


#ifdef INCLUDE_TIMER
	#include "timerdrv.h"

	/* Count number of posix timers */
		
	#if defined(BSP_DEVICE_NAME_QUAD_TIMER_A_0) && (INCLUDE_USER_TIMER_A_0 == 1)
		#define PTA0 1
	#else
		#define PTA0 0
	#endif

	#if defined(BSP_DEVICE_NAME_QUAD_TIMER_A_1) && (INCLUDE_USER_TIMER_A_1 == 1)
		#define PTA1 1
	#else
		#define PTA1 0
	#endif

	#if defined(BSP_DEVICE_NAME_QUAD_TIMER_A_2) && (INCLUDE_USER_TIMER_A_2 == 1)
		#define PTA2 1
	#else
		#define PTA2 0
	#endif

	#if defined(BSP_DEVICE_NAME_QUAD_TIMER_A_3) && (INCLUDE_USER_TIMER_A_3 == 1)
		#define PTA3 1
	#else
		#define PTA3 0
	#endif

	/* Declare posix timer records */
	posix_tDevice POSIXTimerStaticContext[ PTA0 + PTA1 + PTA2 + PTA3 ];
	posix_tDevice * POSIXTimerContext = &POSIXTimerStaticContext[0];
	
	#ifndef INCLUDE_TIME_OF_DAY
		posix_tTod    * POSIXTodContext;
	#endif

#endif

	
#ifdef INCLUDE_TIME_OF_DAY
	#include "timerdrv.h"
	
	posix_tTod POSIXTodStaticContext[1];
	posix_tTod * POSIXTodContext;

	#ifndef INCLUDE_TIMER
		posix_tDevice * POSIXTimerContext;
		const char * POSIXDeviceList[1];
		const int    qtNumberOfDevices;
		const qt_tQTConfig qtDeviceMap[1];
		const UWord16      qtExtAMode[1];
		const UWord16      qtExtAMask[1];
	#endif

#endif


/*****************************************************************************/
#ifdef INCLUDE_TIMER

	#ifdef INCLUDE_UCOS
		
		/* uC/OS version */
		
		/* timerTick and timerSleep are implemented in the uC/OS files */

	#else
		/* No operating system (nos) version */
		
		/* Include OS hooks for Timer ticks */
		static volatile Word32 TimerISRCount = 0;

		void timerSleep(Word32 Ticks)
		{
	    	asm {
	    		bfset #0x0300,SR           /* Disable interrupts to guarantee integrity */
				nop
	
				/* TimerISRCount = 0 */
				clr   B
	    		move  B1,TimerISRCount
	    		move  B1,TimerISRCount+1
	    	
	    		/* while(TimerISRCount < Ticks)
	    	   	{
	              	continue;
	    	   	}
	    		*/
	      	WaitForTicks:
	      
	    		bfset #0x0300,SR           /* Disable interrupts to guarantee integrity */
				nop
			
				move  TimerISRCount+1,B    /* Load TimerISRCount */
				move  TimerISRCount,B0
			
	    		bfclr #0x0200,SR           /* Interrupts must be enabled for timer ISR */

				cmp   A,B
	    		blt   WaitForTicks
	    	
	    		rts
	    	}
		}
	
		void timerTick(void)
		{
			/* Called from timerRealTimeClockISR */
			#undef add  /* to circumvent CW issue */
			asm {
				clr      B
				movei    #1,B0
				move     TimerISRCount+1,A
				move     TimerISRCount,A0
				add      B,A
				move     A1,TimerISRCount+1
				move     A0,TimerISRCount
			
				rts
			}
		}
	#endif
	
#endif


/*****************************************************************************/
EXPORT void configInitialize(void)
{


/*****************************************************************************/
/* INCLUDE_BSP defaults to include the SIM, COP, CORE, PLL, and ITCN 
   initialization;  see configdefines.h for default BSP includes
*/


/*****************************************************************************/
#ifdef INCLUDE_SIM
	{
		simdrvInitialize(SIM_CONTROL_REG);
	}
#endif


/*****************************************************************************/
#ifdef INCLUDE_COP
	{
		copInitialize(COP_CONTROL_REG,COP_TIMEOUT_REG);
	}
#endif


/*****************************************************************************/
#ifdef INCLUDE_CORE
	{
		coredrvInitialize(BUS_CONTROL_REG, INTERRUPT_PRIORITY_REG);
	}
#endif


/*****************************************************************************/
#ifdef INCLUDE_PLL
	{
		plldrvInitialize(PLL_CONTROL_REG, PLL_DIVIDE_BY_REG, PLL_TEST_REG, PLL_SELECT_REG);
	}
#endif


/*****************************************************************************/
#ifdef INCLUDE_ITCN
	{
		itcndrvInitialize ( GPR_REG_0, 
							GPR_REG_1,
							GPR_REG_2,
							GPR_REG_3,
							GPR_REG_4,
							GPR_REG_5,
							GPR_REG_6,
							GPR_REG_7,
							GPR_REG_8,
							GPR_REG_9,
							GPR_REG_10,
							GPR_REG_11,
							GPR_REG_12,
							GPR_REG_13,
							GPR_REG_14,
							GPR_REG_15);
	}
#endif


/*****************************************************************************/
#ifdef INCLUDE_CORE
	{
		if (BSP_ENABLE_INTERRUPTS)
		{			
			archEnableInt();
		}
	}
#endif

/*****************************************************************************/
#ifdef INCLUDE_STACK_CHECK
	{
		stackcheckInitialize ();
	}
#endif	


/*****************************************************************************/
#ifdef INCLUDE_MEMORY
	{
		mem_sState InitialState;
		
		/* These variables are defined in linker.cmd */
		extern UInt16         memEXbit;
		extern UInt16         memNumEMpartitions;
		extern UInt16         memNumIMpartitions;
		extern mem_sPartition memEMpartitionList;
		extern mem_sPartition memIMpartitionList;

		InitialState.EXbit            = memEXbit;
		InitialState.numExtPartitions = memNumEMpartitions;
		InitialState.numIntPartitions = memNumIMpartitions;

		InitialState.extPartitionList = &memEMpartitionList;
		InitialState.intPartitionList = &memIMpartitionList;

		memInitialize(&InitialState);
	}
#endif


/*****************************************************************************/
#ifdef INCLUDE_IO_IO
	{
		static io_sDevice IODeviceTable[IO_MAX_DEVICES];
		
		io_sState IOInitialState;

		IOInitialState.MaxDrivers   = IO_MAX_DRIVERS;
		IOInitialState.MaxDevices   = IO_MAX_DEVICES;
		IOInitialState.pDeviceTable = &IODeviceTable[0];

		ioInitialize(&IOInitialState);
	}
#endif



/*****************************************************************************/

#ifdef INCLUDE_SSI
	{
		arch_sSSI SsiInitialize;

		SsiInitialize.ControlStatusReg = SSI_CONTROL_STATUS_INITIAL_STATE;
		SsiInitialize.Control2Reg      = SSI_CONTROL2_INITIAL_STATE;
		SsiInitialize.TxControlReg     = SSI_RXTX_CONTROL_INITIAL_STATE;
		SsiInitialize.RxControlReg     = SSI_RXTX_CONTROL_INITIAL_STATE;
		SsiInitialize.FifoCntlStatReg  = SSI_FIFO_CNTL_STAT_INITIAL_STATE;
		SsiInitialize.OptionReg        = SSI_OPTION_REGISTER_INITIAL_STATE;
#ifdef INCLUDE_CODEC
		simple_ssiInitialize(&SsiInitialize);
#else
		fsimple_ssiInitialize(&SsiInitialize);
#endif
	}
#endif


/*****************************************************************************/
#ifdef INCLUDE_DSPFUNC
	dspfuncInitialize();
#endif


/*****************************************************************************/
/*
  Modified to comply new SSI driver
*/
#ifdef INCLUDE_CODEC
	{
		static codec_sParams CodecInitialState;
		static UWord16       RxBuffer[CODEC_OPTIMIZATION_BUFFER_SIZE];
		static UWord16       TxBuffer[CODEC_OPTIMIZATION_BUFFER_SIZE];
        
		CodecInitialState.Buffer.Size            = CODEC_FIFO_SIZE;
		CodecInitialState.Buffer.Threshold       = CODEC_FIFO_THRESHOLD;
		CodecInitialState.OptimizationBufferSize = CODEC_OPTIMIZATION_BUFFER_SIZE;
		CodecInitialState.pOptimizationRxBuffer  = &RxBuffer[0];
		CodecInitialState.pOptimizationTxBuffer  = &TxBuffer[0];
		CodecInitialState.RxConfig               = CODEC_RX_CONTROL_WORD;
		CodecInitialState.TxConfig               = CODEC_TX_CONTROL_WORD;
		CodecInitialState.Mode                   = CODEC_MODE;
        
		codecDevCreate(NULL, &CodecInitialState);
	}
#endif

/*****************************************************************************/
/*
  Modified to comply new FAST SSI driver
*/
#ifdef INCLUDE_FCODEC
	{

	}
#endif

/*****************************************************************************/
#ifdef INCLUDE_GPIO
	{
    	#ifdef INCLUDE_IO_GPIO   
			gpiodrvIOCreate(NULL);
	    	ioDrvInstall(gpiodrvIOOpen);
	    #else
	    	gpioCreate(NULL);
    	#endif
	}
#endif


/*****************************************************************************/

#ifdef INCLUDE_LED
	{
		/* Configure the device */

   		#ifdef INCLUDE_IO_LED   
			leddrvIOCreate(BSP_DEVICE_NAME_LED_0);
			ioDrvInstall(leddrvIOOpen);
		#else
			ledCreate(BSP_DEVICE_NAME_LED_0);
   		#endif
	}
#endif


/*****************************************************************************/

#ifdef INCLUDE_SERIAL_DATAFLASH
	serialdataflashDevCreate(NULL, 0);
#endif

/*****************************************************************************/

#ifdef INCLUDE_QUAD_TIMER

	{
		/* Configure the device */

   		#ifdef INCLUDE_IO_QUAD_TIMER   
			qtdrvIOCreate(NULL);
			ioDrvInstall(qtdrvIOOpen);
		#else
			qtCreate(NULL);
   		#endif
	}
	
#endif

        
/*****************************************************************************/
#ifdef INCLUDE_TIMER
	{
		#include "timerdrv.h"
		
		int Index;

		for(Index = 0;  Index < PTA0 + PTA1 + PTA2 + PTA3; Index++)
		{
			POSIXTimerContext[Index].pOpen = qtOpen;
			POSIXTimerContext[Index].pSetTime = timerSetTime;
		}



		timerCreate(POSIXDeviceList[0]);
	}
#endif

/*****************************************************************************/
#ifdef INCLUDE_TIME_OF_DAY
	{
		#include "toddrv.h"

		POSIXTodContext[0].pOpen      = todOpen;
		POSIXTodContext[0].pSetAlarm  = todSetAlarm;
		POSIXTodContext[0].pGetTime   = todGetTime;
		POSIXTodContext[0].pClose     = todClose;	
		POSIXTodContext[0].pCallBacks = todEnableCallBacks;
		POSIXTodContext[0].pMakeTime  = mktime;
	}
#endif

/*****************************************************************************/
#ifdef INCLUDE_FLASH
	{

   #if defined(FLASH_DFIU_PROGRAM_TIME)

      static const UWord16  DfiuInitTime[ FLASH_FIU_TIMER_NUMBER ] = 
      {  
         FLASH_DFIU_CKDIVISOR_VALUE,   
         FLASH_DFIU_TERASEL_VALUE,     
         FLASH_DFIU_TMEL_VALUE,        
         FLASH_DFIU_TNVSL_VALUE,    
         FLASH_DFIU_TPGSL_VALUE,    
         FLASH_DFIU_TPROGL_VALUE,      
         FLASH_DFIU_TNVHL_VALUE,    
         FLASH_DFIU_TNVH1L_VALUE,      
         FLASH_DFIU_TRCVL_VALUE,
      };
   #endif /* defined(FLASH_DFIU_PROGRAM_TIME) */

   #if defined(FLASH_PFIU_PROGRAM_TIME)

      static const UWord16  PfiuInitTime[ FLASH_FIU_TIMER_NUMBER ] = 
      {  
         FLASH_PFIU_CKDIVISOR_VALUE,   
         FLASH_PFIU_TERASEL_VALUE,     
         FLASH_PFIU_TMEL_VALUE,        
         FLASH_PFIU_TNVSL_VALUE,    
         FLASH_PFIU_TPGSL_VALUE,    
         FLASH_PFIU_TPROGL_VALUE,      
         FLASH_PFIU_TNVHL_VALUE,    
         FLASH_PFIU_TNVH1L_VALUE,      
         FLASH_PFIU_TRCVL_VALUE,
      };
   #endif /* defined(FLASH_PFIU_PROGRAM_TIME) */

   #if defined(FLASH_BFIU_PROGRAM_TIME)

      static const UWord16  BfiuInitTime[ FLASH_FIU_TIMER_NUMBER ] = 
      {  
         FLASH_BFIU_CKDIVISOR_VALUE,   
         FLASH_BFIU_TERASEL_VALUE,     
         FLASH_BFIU_TMEL_VALUE,        
         FLASH_BFIU_TNVSL_VALUE,    
         FLASH_BFIU_TPGSL_VALUE,    
         FLASH_BFIU_TPROGL_VALUE,      
         FLASH_BFIU_TNVHL_VALUE,    
         FLASH_BFIU_TNVH1L_VALUE,      
         FLASH_BFIU_TRCVL_VALUE,
      };
   #endif /* defined (FLASH_BFIU_PROGRAM_TIME) */

      static const sFlashInitialize FlashInitialize =
      {
      #if defined (FLASH_DFIU_PROGRAM_TIME) 
         &DfiuInitTime[0],
      #else /* defined (FLASH_DFIU_PROGRAM_TIME)  */
         NULL,
      #endif /* defined (FLASH_DFIU_PROGRAM_TIME)  */
         
      #if defined (FLASH_PFIU_PROGRAM_TIME) 
         &PfiuInitTime[0],
      #else /* defined (FLASH_PFIU_PROGRAM_TIME)  */
         NULL,
      #endif /* defined (FLASH_PFIU_PROGRAM_TIME)  */

      #if defined (FLASH_BFIU_PROGRAM_TIME) 
         &BfiuInitTime[0],
      #else /* defined (FLASH_BFIU_PROGRAM_TIME)  */
         NULL,
      #endif /* defined (FLASH_BFIU_PROGRAM_TIME)  */
      };

      flashDevCreate(&FlashInitialize);
	}
#endif


/*****************************************************************************/
#ifdef INCLUDE_SCI
	{
      static const UWord16 SciBaudRate[SCI_MAX_BAUD_RATE_INDEX] = { 
         SCI_GET_SBR(SCI_230400),
         SCI_GET_SBR(SCI_115200),
         SCI_GET_SBR(SCI_76800),
         SCI_GET_SBR(SCI_57600),
         SCI_GET_SBR(SCI_38400),
         SCI_GET_SBR(SCI_28800),
         SCI_GET_SBR(SCI_19200),
         SCI_GET_SBR(SCI_14400),
         SCI_GET_SBR(SCI_9600),
         SCI_GET_SBR(SCI_7200),
         SCI_GET_SBR(SCI_4800),
         SCI_GET_SBR(SCI_2400),
         SCI_GET_SBR(SCI_1200),
         SCI_GET_SBR(SCI_600),
         SCI_USER_BAUD_RATE_1,
         SCI_USER_BAUD_RATE_2
      };
      
            
   #if defined(SCI_NONBLOCK_MODE)

      static UWord16        Sci0SendBuffer    [ SCI0_SEND_BUFFER_LENGTH     + 1 ];
      static UWord16        Sci0ReceiveBuffer [ SCI0_RECEIVE_BUFFER_LENGTH  + 1 ];
#if defined(BSP_DEVICE_NAME_SCI_1)
      static UWord16        Sci1SendBuffer    [ SCI1_SEND_BUFFER_LENGTH     + 1 ];
      static UWord16        Sci1ReceiveBuffer [ SCI1_RECEIVE_BUFFER_LENGTH  + 1 ];
#endif /* defined(BSP_DEVICE_NAME_SCI_1) */

      static const sSciInitialize SciInitialize =
      {
         (UWord16 *)SciBaudRate,
         {
            SCI0_SEND_BUFFER_LENGTH,
            &Sci0SendBuffer    [0]
         },
         {
            SCI0_RECEIVE_BUFFER_LENGTH,
            &Sci0ReceiveBuffer [0]
         },
#if defined(BSP_DEVICE_NAME_SCI_1)
         {
            SCI1_SEND_BUFFER_LENGTH,
            &Sci1SendBuffer    [0]
         },
         {
            SCI1_RECEIVE_BUFFER_LENGTH,
            &Sci1ReceiveBuffer [0]
         }
#endif /* defined(BSP_DEVICE_NAME_SCI_1) */
      };
      
   #else /* defined(SCI_NONBLOCK_MODE) */
      static const sSciInitialize SciInitialize =
      {
         (UWord16 *)SciBaudRate,
      };      
   #endif /* defined(SCI_NONBLOCK_MODE) */

   sciDevCreate(&SciInitialize);

	}
#endif



/*****************************************************************************/
#ifdef INCLUDE_SPI
	#ifdef INCLUDE_IO_SPI
		spidrvIOCreate(NULL);
		ioDrvInstall(spidrvIOOpen);
	#else
		spiCreate(NULL);
	#endif
#endif



/*****************************************************************************/

#ifdef INCLUDE_BUTTON
	{
		/* Configure the device */

   		#ifdef INCLUDE_IO_BUTTON   
			buttondrvIOCreate(NULL);
			ioDrvInstall(buttondrvIOOpen);
		#else
			buttonCreate(NULL);
   		#endif
	}
#endif


/*****************************************************************************/
#ifdef INCLUDE_FILEIO
	fileioDevCreat(NULL, 0);
#endif


/*****************************************************************************/

#ifdef INCLUDE_PCMASTER
{

	/* if no level is defined set Level1 -> full configuration of PC Master */
	#if !( defined(PCMDRV_LEVEL_1) || defined(PCMDRV_LEVEL_2) || defined(PCMDRV_LEVEL_3) )
		#define PCMDRV_LEVEL_1
	#endif

	#ifdef PCMDRV_LEVEL_1
		#define PCMDRV_BUFFER_SIZE 			37
		#if !defined(PC_MASTER_REC_BUFF_LEN)
			/* Recorder buffer length */
			#define	PC_MASTER_REC_BUFF_LEN	40						
		#endif 
		#if !defined(PC_MASTER_APPCMD_BUFF_LEN)
			/* Application Command buffer length */
			#define PC_MASTER_APPCMD_BUFF_LEN	5					
		#endif 
			
		#undef PCMDRV_LEVEL_2
		#undef PCMDRV_LEVEL_3
	#endif

	#ifdef PCMDRV_LEVEL_2
		#define PCMDRV_BUFFER_SIZE 			30
		#if !defined(PC_MASTER_REC_BUFF_LEN)
			/* Recorder buffer length */
			#define	PC_MASTER_REC_BUFF_LEN	40						
		#endif 
		#if !defined(PC_MASTER_APPCMD_BUFF_LEN)
			/* Application Command buffer length */
			#define PC_MASTER_APPCMD_BUFF_LEN	5					
		#endif 
				
		#undef PCMDRV_LEVEL_1
		#undef PCMDRV_LEVEL_3
	#endif

	#ifdef PCMDRV_LEVEL_3
		#define PCMDRV_BUFFER_SIZE 			20
		#define PC_MASTER_REC_BUFF_LEN		0
		#if !defined(PC_MASTER_APPCMD_BUFF_LEN)
			/* Application Command buffer length */
			#define PC_MASTER_APPCMD_BUFF_LEN	0					
		#endif 
			
		#undef PCMDRV_LEVEL_1
		#undef PCMDRV_LEVEL_2
	#endif

	/* input/output buffer  
		receiving -> contains message without '+' at the beginning 
					and doubled '+' chars are deleted, checksum is in inChar 
		transmitting -> contains a message without '+' at the beginning 
						and without doubled '+' 						*/
	static UWord16 pcmdrvDataBuff[PCMDRV_BUFFER_SIZE + 1];

	static sPCMasterComm PCMSettings;		/* initialization structure */
	static pcmdrv_sScope pcmdrvScope;		/* scope config data */
		
	#if (PC_MASTER_REC_BUFF_LEN != 0)
		/* recorder buffer */
		static UWord16 PCMasterCommRecorderBuffer[PC_MASTER_REC_BUFF_LEN];
		static pcmdrv_sRecorder pcmdrvRecorder;	/* recorder config and temp data */
	#endif

	#if (PC_MASTER_APPCMD_BUFF_LEN != 0)
		/* application command data buffer */
		static UWord16 PCMasterCommApplicationCommandBuffer[PC_MASTER_APPCMD_BUFF_LEN];
	#endif

	#if (PC_MASTER_REC_BUFF_LEN != 0)
		/* address of buffer */
		PCMSettings.p_recBuff   = PCMasterCommRecorderBuffer;						
		PCMSettings.p_recorder	= &pcmdrvRecorder;
	#endif

	/* address of input/output buffer */
	PCMSettings.p_dataBuff 	 = pcmdrvDataBuff;
	PCMSettings.dataBuffSize = PCMDRV_BUFFER_SIZE;
	/* buffer length */
	PCMSettings.recSize      = PC_MASTER_REC_BUFF_LEN;								
	/* recorder time base */
	PCMSettings.timeBase     = PC_MASTER_RECORDER_TIME_BASE ;						
		
	#if (PC_MASTER_APPCMD_BUFF_LEN != 0)
		/* address of buffer */			
		PCMSettings.p_appCmdBuff = PCMasterCommApplicationCommandBuffer;			
	#endif


	PCMSettings.p_scope		= &pcmdrvScope;

	/* buffer length */
	PCMSettings.appCmdSize   = PC_MASTER_APPCMD_BUFF_LEN;							
	/* board firmware version major number */
	PCMSettings.globVerMajor = PC_MASTER_GLOB_VERSION_MAJOR;						
	/* board firmware version minor number */
	PCMSettings.globVerMinor = PC_MASTER_GLOB_VERSION_MINOR;						
	/* device identification string */
		strcpy(PCMSettings.idtString,PC_MASTER_IDT_STRING);								

	/* SCI communication initialization */
	pcmasterdrvInit(&PCMSettings); 													
}
#endif	



/*****************************************************************************/

	UserPreMain();

}


/*****************************************************************************/
EXPORT void configFinalize(void)
{
	UserPostMain();
}

#ifdef __cplusplus
}
#endif