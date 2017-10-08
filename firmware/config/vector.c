/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name:         vector.c
*
* Description:       Interrupt vector table declaration
*
* Modules Included:  
*                    
* 
*****************************************************************************/

#include "port.h"
#include "arch.h"
#include "config.h"

#ifdef __cplusplus
extern "C" {
#endif


/*
	The following ISRs are compiled into the sys library.
*/

extern void Interrupt1 (void);
extern void Interrupt2 (void);
extern void Interrupt3 (void);
extern void Interrupt4 (void);
extern void Interrupt5 (void);
extern void Interrupt6 (void);
extern void Interrupt7 (void);
extern void Interrupt8 (void);
extern void Interrupt9 (void);
extern void Interrupt10 (void);
extern void Interrupt11 (void);
extern void Interrupt12 (void);
extern void Interrupt13 (void);
extern void Interrupt14 (void);
extern void Interrupt15 (void);
extern void Interrupt16 (void);
extern void Interrupt17 (void);
extern void Interrupt18 (void);
extern void Interrupt19 (void);
extern void Interrupt20 (void);
extern void Interrupt21 (void);
extern void Interrupt22 (void);
extern void Interrupt23 (void);
extern void Interrupt24 (void);
extern void Interrupt25 (void);
extern void Interrupt26 (void);
extern void Interrupt27 (void);
extern void Interrupt28 (void);
extern void Interrupt29 (void);
extern void Interrupt30 (void);
extern void Interrupt31 (void);
extern void Interrupt32 (void);
extern void Interrupt33 (void);
extern void Interrupt34 (void);
extern void Interrupt35 (void);
extern void Interrupt36 (void);
extern void Interrupt37 (void);
extern void Interrupt38 (void);
extern void Interrupt39 (void);
extern void Interrupt40 (void);
extern void Interrupt41 (void);
extern void Interrupt42 (void);
extern void Interrupt43 (void);
extern void Interrupt44 (void);
extern void Interrupt45 (void);
extern void Interrupt46 (void);
extern void Interrupt47 (void);
extern void Interrupt48 (void);
extern void Interrupt49 (void);
extern void Interrupt50 (void);
extern void Interrupt51 (void);
extern void Interrupt52 (void);
extern void Interrupt53 (void);
extern void Interrupt54 (void);
extern void Interrupt55 (void);
extern void Interrupt56 (void);
extern void Interrupt57 (void);
extern void Interrupt58 (void);
extern void Interrupt59 (void);
extern void Interrupt60 (void);
extern void Interrupt61 (void);
extern void Interrupt62 (void);
extern void Interrupt63 (void);

extern void configUnhandledInterruptISR (void);

/*****************************************************************************
	The following Interrupt Vector MUST be at the beginning of this 
	vector.c file so that it is located at P:0x0000 by the linker.cmd file.
*****************************************************************************/
asm void configInterruptVector(void)
{
		jsr	  archStart
	
	#ifdef INTERRUPT_VECTOR_ADDR_1
		jsr   INTERRUPT_VECTOR_ADDR_1
	#elif GPR_INT_PRIORITY_1 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt1
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_2
		jsr   INTERRUPT_VECTOR_ADDR_2
	#elif GPR_INT_PRIORITY_2 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt2
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_3
		jsr   INTERRUPT_VECTOR_ADDR_3
	#elif GPR_INT_PRIORITY_3 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt3
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_4
		jsr   INTERRUPT_VECTOR_ADDR_4
	#elif GPR_INT_PRIORITY_4 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt4
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_5
		jsr   INTERRUPT_VECTOR_ADDR_5
	#elif GPR_INT_PRIORITY_5 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt5
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_6
		jsr   INTERRUPT_VECTOR_ADDR_6
	#elif GPR_INT_PRIORITY_6 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt6
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_7
		jsr   INTERRUPT_VECTOR_ADDR_7
	#elif GPR_INT_PRIORITY_7 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt7
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_8
		jsr   INTERRUPT_VECTOR_ADDR_8
	#elif GPR_INT_PRIORITY_8 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt8
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_9
		jsr   INTERRUPT_VECTOR_ADDR_9
	#elif GPR_INT_PRIORITY_9 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt9
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_10
		jsr   INTERRUPT_VECTOR_ADDR_10
	#elif GPR_INT_PRIORITY_10 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt10
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_11
		jsr   INTERRUPT_VECTOR_ADDR_11
	#elif GPR_INT_PRIORITY_11 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt11
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_12
		jsr   INTERRUPT_VECTOR_ADDR_12
	#elif GPR_INT_PRIORITY_12 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt12
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_13
		jsr   INTERRUPT_VECTOR_ADDR_13
	#elif GPR_INT_PRIORITY_13 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt13
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_14
		jsr   INTERRUPT_VECTOR_ADDR_14
	#elif GPR_INT_PRIORITY_14 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt14
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_15
		jsr   INTERRUPT_VECTOR_ADDR_15
	#elif GPR_INT_PRIORITY_15 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt15
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_16
		jsr   INTERRUPT_VECTOR_ADDR_16
	#elif GPR_INT_PRIORITY_16 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt16
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_17
		jsr   INTERRUPT_VECTOR_ADDR_17
	#elif GPR_INT_PRIORITY_17 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt17
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_18
		jsr   INTERRUPT_VECTOR_ADDR_18
	#elif GPR_INT_PRIORITY_18 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt18
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_19
		jsr   INTERRUPT_VECTOR_ADDR_19
	#elif GPR_INT_PRIORITY_19 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt19
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_20
		jsr   INTERRUPT_VECTOR_ADDR_20
	#elif GPR_INT_PRIORITY_20 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt20
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_21
		jsr   INTERRUPT_VECTOR_ADDR_21
	#elif GPR_INT_PRIORITY_21 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt21
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_22
		jsr   INTERRUPT_VECTOR_ADDR_22
	#elif GPR_INT_PRIORITY_22 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt22
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_23
		jsr   INTERRUPT_VECTOR_ADDR_23
	#elif GPR_INT_PRIORITY_23 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt23
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_24
		jsr   INTERRUPT_VECTOR_ADDR_24
	#elif GPR_INT_PRIORITY_24 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt24
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_25
		jsr   INTERRUPT_VECTOR_ADDR_25
	#elif GPR_INT_PRIORITY_25 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt25
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_26
		jsr   INTERRUPT_VECTOR_ADDR_26
	#elif GPR_INT_PRIORITY_26 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt26
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_27
		jsr   INTERRUPT_VECTOR_ADDR_27
	#elif GPR_INT_PRIORITY_27 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt27
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_28
		jsr   INTERRUPT_VECTOR_ADDR_28
	#elif GPR_INT_PRIORITY_28 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt28
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_29
		jsr   INTERRUPT_VECTOR_ADDR_29
	#elif GPR_INT_PRIORITY_29 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt29
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_30
		jsr   INTERRUPT_VECTOR_ADDR_30
	#elif GPR_INT_PRIORITY_30 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt30
	#endif
	
	#ifdef INTERRUPT_VECTOR_ADDR_31
		jsr   INTERRUPT_VECTOR_ADDR_31
	#elif GPR_INT_PRIORITY_31 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt31
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_32
		jsr   INTERRUPT_VECTOR_ADDR_32
	#elif GPR_INT_PRIORITY_32 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt32
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_33
		jsr   INTERRUPT_VECTOR_ADDR_33
	#elif GPR_INT_PRIORITY_33 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt33
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_34
		jsr   INTERRUPT_VECTOR_ADDR_34
	#elif GPR_INT_PRIORITY_34 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt34
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_35
		jsr   INTERRUPT_VECTOR_ADDR_35
	#elif GPR_INT_PRIORITY_35 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt35
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_36
		jsr   INTERRUPT_VECTOR_ADDR_36
	#elif GPR_INT_PRIORITY_36 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt36
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_37
		jsr   INTERRUPT_VECTOR_ADDR_37
	#elif GPR_INT_PRIORITY_37 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt37
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_38
		jsr   INTERRUPT_VECTOR_ADDR_38
	#elif GPR_INT_PRIORITY_38 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt38
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_39
		jsr   INTERRUPT_VECTOR_ADDR_39
	#elif GPR_INT_PRIORITY_39 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt39
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_40
		jsr   INTERRUPT_VECTOR_ADDR_40
	#elif GPR_INT_PRIORITY_40 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt40
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_41
		jsr   INTERRUPT_VECTOR_ADDR_41
	#elif GPR_INT_PRIORITY_41 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt41
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_42
		jsr   INTERRUPT_VECTOR_ADDR_42
	#elif GPR_INT_PRIORITY_42 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt42
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_43
		jsr   INTERRUPT_VECTOR_ADDR_43
	#elif GPR_INT_PRIORITY_43 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt43
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_44
		jsr   INTERRUPT_VECTOR_ADDR_44
	#elif GPR_INT_PRIORITY_44 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt44
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_45
		jsr   INTERRUPT_VECTOR_ADDR_45
	#elif GPR_INT_PRIORITY_45 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt45
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_46
		jsr   INTERRUPT_VECTOR_ADDR_46
	#elif GPR_INT_PRIORITY_46 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt46
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_47
		jsr   INTERRUPT_VECTOR_ADDR_47
	#elif GPR_INT_PRIORITY_47 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt47
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_48
		jsr   INTERRUPT_VECTOR_ADDR_48
	#elif GPR_INT_PRIORITY_48 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt48
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_49
		jsr   INTERRUPT_VECTOR_ADDR_49
	#elif GPR_INT_PRIORITY_49 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt49
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_50
		jsr   INTERRUPT_VECTOR_ADDR_50
	#elif GPR_INT_PRIORITY_50 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt50
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_51
		jsr   INTERRUPT_VECTOR_ADDR_51
	#elif GPR_INT_PRIORITY_51 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt51
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_52
		jsr   INTERRUPT_VECTOR_ADDR_52
	#elif GPR_INT_PRIORITY_52 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt52
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_53
		jsr   INTERRUPT_VECTOR_ADDR_53
	#elif GPR_INT_PRIORITY_53 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt53
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_54
		jsr   INTERRUPT_VECTOR_ADDR_54
	#elif GPR_INT_PRIORITY_54 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt54
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_55
		jsr   INTERRUPT_VECTOR_ADDR_55
	#elif GPR_INT_PRIORITY_55 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt55
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_56
		jsr   INTERRUPT_VECTOR_ADDR_56
	#elif GPR_INT_PRIORITY_56 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt56
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_57
		jsr   INTERRUPT_VECTOR_ADDR_57
	#elif GPR_INT_PRIORITY_57 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt57
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_58
		jsr   INTERRUPT_VECTOR_ADDR_58
	#elif GPR_INT_PRIORITY_58 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt58
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_59
		jsr   INTERRUPT_VECTOR_ADDR_59
	#elif GPR_INT_PRIORITY_59 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt59
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_60
		jsr   INTERRUPT_VECTOR_ADDR_60
	#elif GPR_INT_PRIORITY_60 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt60
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_61
		jsr   INTERRUPT_VECTOR_ADDR_61
	#elif GPR_INT_PRIORITY_61 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt61
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_62
		jsr   INTERRUPT_VECTOR_ADDR_62
	#elif GPR_INT_PRIORITY_62 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt62
	#endif

	#ifdef INTERRUPT_VECTOR_ADDR_63
		jsr   INTERRUPT_VECTOR_ADDR_63
	#elif GPR_INT_PRIORITY_63 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt63
	#endif
		
;  /* End of Interrupt Vector */

; /**/
; /* Vector for Boot Loader to start program */
; /**/
		jsr    archStart
		
; /**/
; /* Vector for Boot Loader to start program */
; /**/
	#ifdef INTERRUPT_VECTOR_ADDR_1
		jsr   INTERRUPT_VECTOR_ADDR_1
	#elif GPR_INT_PRIORITY_1 == 0
		jsr   configUnhandledInterruptISR
	#else	
		jsr   Interrupt1
	#endif

; /**/
; /* Reserve two words for Bootloader timeout variable */
; /* 0x00000084  0xF054       movei instruction code */
; /* 0x00000085  0xFE1E       Immediate data (0xfe00 used to prevent optimization of */
; /*                          "move 16bit" instruction into "move 7bit" instruction )*/
; /**/
; /* To manage Bootloder within SDK use BSP_BOOTLOADER_DELAY variable in appconfig.h */
; /* The BSP_BOOTLOADER_DELAY variable defines the delay befor application start in  */
; /* seconds. */
; /* If BSP_BOOTLOADER_DELAY variable does not defined, the default timeout is set */
; /* To disable bootloader set BSP_BOOTLOADER_DELAY variable equal to zero  */
; /**/

		movei BSP_BOOTLOADER_DELAY+0xfe00, x0
		
; /**/
; /* To use bootloader without SDK support comment out movei inctuction and use the  */
; /* following code : */
; /**/	
; /*    nop */
; /*    nop */

; /**/
; /* To disable bootloader without SDK support comment out the above movei inctuction */
; /* and use the following code : */
; /**/	
; /*    movei 0xfe00, x0 */

}

#ifdef __cplusplus
}
#endif