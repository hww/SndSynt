;*****************************************************************************
;*
;* Motorola Inc.
;* (c) Copyright 2000 Motorola, Inc.
;* ALL RIGHTS RESERVED.
;*
;******************************************************************************
;*
;* File Name:         resetvector.asm
;*
;* Description:       Define reset and COP reset interrupt vectors for 
;*                    bootloader
;*
;* Modules Included:  none
;*                    
;* 
;*****************************************************************************

		SECTION resetvec
	
		GLOBAL  FResetVector
		XREF    FbootArchStart
      XREF    FarchCOPVector

			
		ORG	P:
		
FResetVector:

		jmp	FbootArchStart
		jmp	FarchCOPVector
		
		ENDSEC
		END

