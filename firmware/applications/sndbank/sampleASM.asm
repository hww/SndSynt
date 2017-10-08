	SECTION rtlib
	
	include "portasm.h"
	
	GLOBAL  FsampleASM

; void sampleASM (void)
; {
; }

FsampleASM:

	move  #$1234,A	; dummy moves to illustrate ASM coding
	move  #$4321,B
		
	rts
	
	ENDSEC
