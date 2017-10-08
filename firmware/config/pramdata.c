/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name:         pramdata.c
*
* Description:       Declaration of SDK variables located in Program RAM
*
* Modules Included:  
*                    
* 
*****************************************************************************/

#include "port.h"
#include "arch.h"
#include "config.h"
#include "pramdata.h"

#ifdef __cplusplus
extern "C" {
#endif

EXPORT sUserISR archUserISRTable[sizeof(arch_sInterrupts) / sizeof(UWord32)] =
/*
	archUserISRTable is an array of Normal and Fast ISR addresses;
	Typically, an InterruptNN routine is called from the Interrupt Vector,
	which in turn calls the Dispatcher.  The Dispatcher saves the appropriate
	registers and then indexes through this table to branch to an ISR.
	
	The Superfast ISR bypasses this mechanism completely, and jumps directly
	to an ISR address in the Interrupt Vector.  However, no registers are 
	saved;  all registers must be saved/restored by the Superfast ISR itself.
	
*/
	{
			#if defined (FAST_ISR_0)
				FAST_ISR_0,
			#else
				#if defined (NORMAL_ISR_0)
					NORMAL_ISR_0,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_1)
				FAST_ISR_1,
			#else
				#if defined (NORMAL_ISR_1)
					NORMAL_ISR_1,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_2)
				FAST_ISR_2,
			#else
				#if defined (NORMAL_ISR_2)
					NORMAL_ISR_2,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_3)
				FAST_ISR_3,
			#else
				#if defined (NORMAL_ISR_3)
					NORMAL_ISR_3,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_4)
				FAST_ISR_4,
			#else
				#if defined (NORMAL_ISR_4)
					NORMAL_ISR_4,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_5)
				FAST_ISR_5,
			#else
				#if defined (NORMAL_ISR_5)
					NORMAL_ISR_5,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_6)
				FAST_ISR_6,
			#else
				#if defined (NORMAL_ISR_6)
					NORMAL_ISR_6,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_7)
				FAST_ISR_7,
			#else
				#if defined (NORMAL_ISR_7)
					NORMAL_ISR_7,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_8)
				FAST_ISR_8,
			#else
				#if defined (NORMAL_ISR_8)
					NORMAL_ISR_8,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_9)
				FAST_ISR_9,
			#else
				#if defined (NORMAL_ISR_9)
					NORMAL_ISR_9,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_10)
				FAST_ISR_10,
			#else
				#if defined (NORMAL_ISR_10)
					NORMAL_ISR_10,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_11)
				FAST_ISR_11,
			#else
				#if defined (NORMAL_ISR_11)
					NORMAL_ISR_11,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_12)
				FAST_ISR_12,
			#else
				#if defined (NORMAL_ISR_12)
					NORMAL_ISR_12,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_13)
				FAST_ISR_13,
			#else
				#if defined (NORMAL_ISR_13)
					NORMAL_ISR_13,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_14)
				FAST_ISR_14,
			#else
				#if defined (NORMAL_ISR_14)
					NORMAL_ISR_14,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_15)
				FAST_ISR_15,
			#else
				#if defined (NORMAL_ISR_15)
					NORMAL_ISR_15,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_16)
				FAST_ISR_16,
			#else
				#if defined (NORMAL_ISR_16)
					NORMAL_ISR_16,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_17)
				FAST_ISR_17,
			#else
				#if defined (NORMAL_ISR_17)
					NORMAL_ISR_17,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_18)
				FAST_ISR_18,
			#else
				#if defined (NORMAL_ISR_18)
					NORMAL_ISR_18,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_19)
				FAST_ISR_19,
			#else
				#if defined (NORMAL_ISR_19)
					NORMAL_ISR_19,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_20)
				FAST_ISR_20,
			#else
				#if defined (NORMAL_ISR_20)
					NORMAL_ISR_20,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_21)
				FAST_ISR_21,
			#else
				#if defined (NORMAL_ISR_21)
					NORMAL_ISR_21,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_22)
				FAST_ISR_22,
			#else
				#if defined (NORMAL_ISR_22)
					NORMAL_ISR_22,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_23)
				FAST_ISR_23,
			#else
				#if defined (NORMAL_ISR_23)
					NORMAL_ISR_23,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_24)
				FAST_ISR_24,
			#else
				#if defined (NORMAL_ISR_24)
					NORMAL_ISR_24,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_25)
				FAST_ISR_25,
			#else
				#if defined (NORMAL_ISR_25)
					NORMAL_ISR_25,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_26)
				FAST_ISR_26,
			#else
				#if defined (NORMAL_ISR_26)
					NORMAL_ISR_26,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_27)
				FAST_ISR_27,
			#else
				#if defined (NORMAL_ISR_27)
					NORMAL_ISR_27,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_28)
				FAST_ISR_28,
			#else
				#if defined (NORMAL_ISR_28)
					NORMAL_ISR_28,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_29)
				FAST_ISR_29,
			#else
				#if defined (NORMAL_ISR_29)
					NORMAL_ISR_29,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined(FAST_ISR_30)
				FAST_ISR_30,
			#else
				#if defined(NORMAL_ISR_30)
					NORMAL_ISR_30,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_31)
				FAST_ISR_31,
			#else
				#if defined (NORMAL_ISR_31)
					NORMAL_ISR_31,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_32)
				FAST_ISR_32,
			#else
				#if defined (NORMAL_ISR_32)
					NORMAL_ISR_32,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_33)
				FAST_ISR_33,
			#else
				#if defined (NORMAL_ISR_33)
					NORMAL_ISR_33,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_34)
				FAST_ISR_34,
			#else
				#if defined (NORMAL_ISR_34)
					NORMAL_ISR_34,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_35)
				FAST_ISR_35,
			#else
				#if defined (NORMAL_ISR_35)
					NORMAL_ISR_35,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_36)
				FAST_ISR_36,
			#else
				#if defined (NORMAL_ISR_36)
					NORMAL_ISR_36,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_37)
				FAST_ISR_37,
			#else
				#if defined (NORMAL_ISR_37)
					NORMAL_ISR_37,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_38)
				FAST_ISR_38,
			#else
				#if defined (NORMAL_ISR_38)
					NORMAL_ISR_38,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_39)
				FAST_ISR_39,
			#else
				#if defined (NORMAL_ISR_39)
					NORMAL_ISR_39,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_40)
				FAST_ISR_40,
			#else
				#if defined (NORMAL_ISR_40)
					NORMAL_ISR_40,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_41)
				FAST_ISR_41,
			#else
				#if defined (NORMAL_ISR_41)
					NORMAL_ISR_41,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_42)
				FAST_ISR_42,
			#else
				#if defined (NORMAL_ISR_42)
					NORMAL_ISR_42,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_43)
				FAST_ISR_43,
			#else
				#if defined (NORMAL_ISR_43)
					NORMAL_ISR_43,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_44)
				FAST_ISR_44,
			#else
				#if defined (NORMAL_ISR_44)
					NORMAL_ISR_44,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_45)
				FAST_ISR_45,
			#else
				#if defined (NORMAL_ISR_45)
					NORMAL_ISR_45,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_46)
				FAST_ISR_46,
			#else
				#if defined (NORMAL_ISR_46)
					NORMAL_ISR_46,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_47)
				FAST_ISR_47,
			#else
				#if defined (NORMAL_ISR_47)
					NORMAL_ISR_47,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_48)
				FAST_ISR_48,
			#else
				#if defined (NORMAL_ISR_48)
					NORMAL_ISR_48,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_49)
				FAST_ISR_49,
			#else
				#if defined (NORMAL_ISR_49)
					NORMAL_ISR_49,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_50)
				FAST_ISR_50,
			#else
				#if defined (NORMAL_ISR_50)
					NORMAL_ISR_50,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_51)
				FAST_ISR_51,
			#else
				#if defined (NORMAL_ISR_51)
					NORMAL_ISR_51,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_52)
				FAST_ISR_52,
			#else
				#if defined (NORMAL_ISR_52)
					NORMAL_ISR_52,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_53)
				FAST_ISR_53,
			#else
				#if defined (NORMAL_ISR_53)
					NORMAL_ISR_53,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_54)
				FAST_ISR_54,
			#else
				#if defined (NORMAL_ISR_54)
					NORMAL_ISR_54,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_55)
				FAST_ISR_55,
			#else
				#if defined (NORMAL_ISR_55)
					NORMAL_ISR_55,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_56)
				FAST_ISR_56,
			#else
				#if defined (NORMAL_ISR_56)
					NORMAL_ISR_56,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_57)
				FAST_ISR_57,
			#else
				#if defined (NORMAL_ISR_57)
					NORMAL_ISR_57,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_58)
				FAST_ISR_58,
			#else
				#if defined (NORMAL_ISR_58)
					NORMAL_ISR_58,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_59)
				FAST_ISR_59,
			#else
				#if defined (NORMAL_ISR_59)
					NORMAL_ISR_59,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_60)
				FAST_ISR_60,
			#else
				#if defined (NORMAL_ISR_60)
					NORMAL_ISR_60,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_61)
				FAST_ISR_61,
			#else
				#if defined (NORMAL_ISR_61)
					NORMAL_ISR_61,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_62)
				FAST_ISR_62,
			#else
				#if defined (NORMAL_ISR_62)
					NORMAL_ISR_62,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
			
			#if defined (FAST_ISR_63)
				FAST_ISR_63,
			#else
				#if defined (NORMAL_ISR_63)
					NORMAL_ISR_63,
				#else
					archUnhandledInterrupt,
				#endif
			#endif
	};

/*
	Quadrature Timer Drivers
*/
#ifdef INCLUDE_QUAD_TIMER

	#include "quadraturetimer.h"
	
	qt_tQTContext   qt_ctx_A_0;
	qt_tQTContext   qt_ctx_A_1;
	qt_tQTContext   qt_ctx_A_2;
	qt_tQTContext   qt_ctx_A_3;
	qt_tQTContext   qt_ctx_B_0;
	qt_tQTContext   qt_ctx_B_1;
	qt_tQTContext   qt_ctx_B_2;
	qt_tQTContext   qt_ctx_B_3;
	qt_tQTContext   qt_ctx_C_0;
	qt_tQTContext   qt_ctx_C_1;
	qt_tQTContext   qt_ctx_C_2;
	qt_tQTContext   qt_ctx_C_3;
	qt_tQTContext   qt_ctx_D_0;
	qt_tQTContext   qt_ctx_D_1;
	qt_tQTContext   qt_ctx_D_2;
	qt_tQTContext   qt_ctx_D_3;

#endif


#ifdef __cplusplus
}
#endif