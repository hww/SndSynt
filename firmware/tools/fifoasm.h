; 
; The following symbols can be used to exclude portions (using '0') of 
; the FIFO implementation in order to save program memory;  if you do so,
; however, please make sure that EVERY call to FIFO will satisfy the
; constraints placed upon the limited implementation.
;
	define  FIFO_USE_MODULO_ADDRESSING_OPT     '1'
	define  FIFO_USE_LINEAR_ADDRESSING_OPT     '1'
	
; 
; Define fifo_sFifoPriv offsets
;	
Offset_pCircBuffer       equ 0           
Offset_bIsAligned        equ 1           
Offset_size              equ 2      
Offset_threshold         equ 3 
Offset_origThreshold     equ 4  
Offset_get               equ 5
Offset_put               equ 6
