		SECTION rtlib
	
		include "portasm.h"

		GLOBAL  Fuldiv
		GLOBAL  Ful2mks
		GLOBAL  Ful2str
																
		ORG	P:
	
;**********************************************************************************
;*
;*	       unsigned long uldiv(unsigned long Dividend, umsigned int Divisor)
;*               Division of unsigned long / unsigned int (A1:A0/Y0)
;*
;**********************************************************************************
		
Fuldiv		
		clr     B
		move    A1,B0
												
		bfclr	#$0001,SR
		rep     #17
		div     Y0,B		; Positive quotient in B0
		move	B0,A1		; Save quotient in A1
		
		add     Y0,B		; Restore remainder in B1
		asr     B			; Required for correct integer remainder
		
		move    A0,B0		
		
		bfclr	#$0001,SR
		rep     #17
		div     Y0,B		; Positive quotient in B0

		move	B0,A0		; Save quotient in A0
		
		add     Y0,B		; Restore remainder in B1
		asr     B			; Required for correct integer remainder
		
		rts

;**********************************************************************************
;*
;*        void ul2mks(unsigned long val, char * buff)
;*        Conversion: Unsigned long to string of the microseconds
;*
;* Input paramiters:
;*
;* A1:A0 - unsigned long val
;* R2    - cahr * buff
;*
;* Registers usage:
;*
;* X0 - digits counter
;* B  - dividend
;* Y0 - divisor
;* 
;* Stack usage:
;* 
;* Subrotine uses 10 bytes of the stack maximum (depends from the input digit) 
;* 
;**********************************************************************************
Ful2mks:
		clr     X0			; Reset digits counter
L1:				
		;**************************************************************************
		;* val = val/10, *SP++ = val%10
		;**************************************************************************
		clr     B			; Clear dividend register
		move    A1,B0		; Load high byte of dividend 
		movei	#10,Y0      ; Load divisor        

		bfclr	#$0001,SR
		rep     #17
		div     Y0,B		; Positive quotient in B0
		move	B0,A1		; Save quotient in A1
		
		add     Y0,B		; Restore remainder in B1
		asr     B			; Required for correct integer remainder
		
		move    A0,B0		
		
		bfclr	#$0001,SR
		rep     #17
		div     Y0,B		; Positive quotient in B0
		move	B0,A0		; Save quotient in A0
		
		add     Y0,B		; Restore remainder in B1
		beq     L2			; if 0, then stop cycle of conversion    
		asr     B			; Required for correct integer remainder
		
		add     #48,B		; Convert number to char (add the '0') 
		inc     X0			; Increment cycle counter              
		push    B1			; Store converted symbol to the stack  
		
		jmp     L1			; Continue conversion 

L2:
		;**************************************************************************
		;* Add the '0' to the first three place (if its were empty)
		;**************************************************************************
		cmp     #2,X0		; if number of the digit is > 2 then skip 
		bgt     L4			
		inc     X0			
		move    #48,B1		
		push	B1
		jmp     L2
L3:
		;**************************************************************************
		;* Add the '.' after second digit
		;**************************************************************************
		cmp     #2,X0
		bne     L4
		movei   #46,X:(R2+0)
		lea     (R2)+
L4:
		;**************************************************************************
		;* Copy converted chars from the stack to the memory location,
		;* that was pointered by the second parameter of the function
		;**************************************************************************
		pop     B1
		move    B1,X:(R2)+
		dec     X0
		bne     L3
    
		movei   #0,X:(R2+0)

		rts



;**********************************************************************************
;*
;*        void ul2str(unsigned long val, char * buff)
;*        Conversion: Unsigned long to string
;*
;* Input paramiters:
;*
;* A1:A0 - unsigned long val
;* R2    - cahr * buff
;*
;* Registers usage:
;*
;* X0 - digits counter
;* B  - dividend
;* Y0 - divisor
;* 
;* Stack usage:
;* 
;* Subrotine uses 10 bytes of the stack maximum (depends from the input digit) 
;* 
;**********************************************************************************
Ful2str:
		clr     X0			; Reset digits counter
Ful2str_01:				
		;**************************************************************************
		;* val = val/10, *SP++ = val%10
		;**************************************************************************
		clr     B			; Clear dividend register
		move    A1,B0		; Load high byte of dividend 
		movei	#10,Y0      ; Load divisor        

		bfclr	#$0001,SR
		rep		#17
		div     Y0,B		; Positive quotient in B0
		move	B0,A1		; Save quotient in A1
		
		add     Y0,B		; Restore remainder in B1
		asr     B			; Required for correct integer remainder
		
		move    A0,B0		
		
		bfclr	#$0001,SR
		rep		#17
		div     Y0,B		; Positive quotient in B0
		move	B0,A0		; Save quotient in A0
		
		add     Y0,B		; Restore remainder in B1
		beq     Ful2str_02	; if 0, then stop cycle of conversion    
		asr     B			; Required for correct integer remainder
		
		add     #48,B		; Convert number to char (add the '0') 
		inc     X0			; Increment cycle counter              
		push    B1			; Store converted symbol to the stack  
		
		jmp     Ful2str_01	; Continue conversion 

Ful2str_02:
		;**************************************************************************
		;* Add the '0' to the first place (if its were empty)
		;**************************************************************************
		cmp     #0,X0		; if number of the digit is > 0 then skip 
		bgt     Ful2str_03			
		movei   #48,X:(R2+0)
		lea     (R2)+
		jmp     Ful2str_04

Ful2str_03:
		;**************************************************************************
		;* Copy converted chars from the stack to the memory location,
		;* that was pointered by the second parameter of the function
		;**************************************************************************
		pop     B1
		move    B1,X:(R2)+
		dec     X0
		bne     Ful2str_03

Ful2str_04:    
		;**************************************************************************
		;* Add the 'end of string' to the last place 
		;**************************************************************************
		movei   #0,X:(R2+0)

		rts

		ENDSEC
		END




