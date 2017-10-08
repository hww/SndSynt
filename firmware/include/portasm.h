; File: port.asm

	include "asmdef.h"

;/*******************************************************
;* Conditional assembly
;*******************************************************/

;/* Change the following defines to '0' to eliminate asserts */
	define  ASSERT_ON_INVALID_PARAMETER   '1' 

;/* Temporary to exclude V2 workarounds in common files */
	define V2_WORKAROUND '0'

;/*******************************************************
;* Constants
;*******************************************************/

;/* Function Result Values */
PASS      equ     0
FAIL      equ     -1

true      equ     1
false     equ     0

;/*******************************************************
;* Implementation Limits 
;*******************************************************/

PORT_MAX_VECTOR_LEN  equ 32767

;/*******************************************************
;* Directly addressable registers in memory for temp storage
;*******************************************************/

 DEFINE DMR0 'x:<$30'
 DEFINE DMR1 'x:<$31'
 DEFINE DMR2 'x:<$32'
 DEFINE DMR3 'x:<$33'
 DEFINE DMR4 'x:<$34'
 DEFINE DMR5 'x:<$35'
 DEFINE DMR6 'x:<$36'
 DEFINE DMR7 'x:<$37'
