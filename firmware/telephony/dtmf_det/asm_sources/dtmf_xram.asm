
        
        include "tone_api.inc"

		section dtmf_xram GLOBAL



;******************************************************************************
; Declaring XRAM variables for external reference
;******************************************************************************
      	org    x:

        GLOBAL     max_val
		GLOBAL     result_ptr
		GLOBAL     frame_info
		GLOBAL     sig_en_hi1
		GLOBAL     dtmf_r1
		GLOBAL     sil_r1

		GLOBAL     ANA_BUF
		GLOBAL     LAST_BUF

		GLOBAL     shift_count
		GLOBAL     sig_energy

		GLOBAL     dtmf_on_timer
		GLOBAL     dtmf_off_timer
		GLOBAL     dtmf_state
		GLOBAL     previous_dtmf
		GLOBAL     dtmf_status
		GLOBAL     dtmf_level
		GLOBAL     n_e

		GLOBAL     loop_cntr
		GLOBAL     sik
		GLOBAL     mg_energy
		
        GLOBAL     Thresh5c
		GLOBAL     Thresh4a
		GLOBAL     Thresh4b

		GLOBAL     pk_add
		GLOBAL     alfa
		GLOBAL     Fspeech_flag


;******************************************************************************
; Defining XRAM variables
;******************************************************************************
        org     x:

;Modulo Buffer definitions
sik     dsm     (2*NO_FIL*M)            ;Buffer for MG filter states 
                                        ;and the delayed states for M 
                                        ;channels 2*NO_FIL locations 
										;per channel 
sig_energy      dsm     2*M             ;Signal energies for M channel

;Analysis Buffer and overlap buffer definitions
ANA_BUF         ds  ANA_BUF_SIZE        ;analysis buffer
LAST_BUF        ds  LAST_BUF_SIZE       ;buffer to store the last part 
                                        ;of the previous frame
;Variables used by API function
max_val         ds  1                   ; maximum value for 10ms frame
result_ptr      ds  1                   ; pointer into frame_info
frame_info      ds  4                   ; frame information structure
sig_en_hi1      equ frame_info+0        ; sig_en high word for 1st 10ms
sig_en_lo1      equ frame_info+1        ; sig_en low word for 1st 10ms
dtmf_r1         equ frame_info+2        ; dtmf detection for 1st 10ms
sil_r1          equ frame_info+3        ; sil detection for 1st 10ms

shift_count     ds      1               ;Sample normalising count
 
mg_energy       ds    NO_FIL            ;Buffer for energy of MG filters

;DTMF FSM variables
dtmf_on_timer   ds      1               ; timer for tone ON 
dtmf_off_timer  ds      1               ; timer for tone OFF 
dtmf_state      ds      1               ; holds dtmf debounce state
previous_dtmf   ds      1               ; history variable for detection
dtmf_status     ds      1               ; status of the detection
dtmf_level      ds      2               ; absolute detection threshold
  


;DTMF MG filter variables & Noise energy variables
loop_cntr       ds      1
n_e             ds      2               ; Adaptive Noise level


;Thresholds for DTMF tests
;These below defined locations should appear in the same order 
Thresh5c        EQU     sik+2           ;holds Thresh5c for CAS/DTMF and is
	                                    ;an input to REL_EN ()
Thresh4a        EQU     sik+3
										;Forward twist
Thresh4b        EQU     sik+4
										;Reverse twist
pk_add          EQU     sik+13

alfa            ds      1               ;Energy updation factor
Fspeech_flag    ds      1               ;Detection in the presence of 
                                        ;  speech																											 
         endsec
