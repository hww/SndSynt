;----- Conditional Assembly/User Configurable Constants  -----;
MODULO_INPUT	set	0		;set 1 for modulo input buffer
					        ;set 0 for linear input buffer
SYS_BUF_LEN	    set	20		;set to total length [ms] of system
					        ;   buffers
SYS_SAMP_FREQ	set	8000    ;set to system sample frequency [Hz]

INPUT_BUF_SIZE  set 80

;----- END ---------------------------------------------------;


MOD_IN_VAL	set	159             ; @cvi(SYS_BUF_LEN/1000.0*SYS_SAMP_FREQ)-1	

Ns              SET     40              ;Number of samples per frame
Nc              SET     52              ;Number of samples which is a 
					;  combination of the present 
					;  frame and some previous samples
zero            SET     0               ;Zero
NO_FIL          SET     10              ;Number of MG filters
NO_DTMF         SET     10              ;Number of filters for DTMF
M               SET     1               ;Number of channels
mul_val         SET     2.0*Nc/128
				                     	;Constant for 2Ns/128*win_fac

;------------ DTMF Parameters --------------------------------
;       comment ~ 
;Thresh4a_dtmf   SET    	0.11941         ;Reverse twist of 6 dB
;Thresh4b_dtmf   SET    	0.09840         ;Forward twist of 8 dB
;      ~

Thresh4a_dtmf   SET    	0.13            ;.13 Reverse twist of 6 dB
Thresh4b_dtmf   SET    	0.13            ;.13 Forward twist of 8 dB

;--- ggw --- changed to allow dynamic threshold
Thresh5cDTMF	SET    0.50000		    ;.557 Thresh5c for DTMF 

THRESH1_DTMF_HI SET    $0000            ;Threshold at -36 dBm
THRESH1_DTMF_LO SET    $7878


NOISE_LEVEL1    SET    $15		        ;Maximum Noise level=-18dB (upper word)
NOISE_LEVEL2    SET    $2c3c		    ;Maximum Noise level (lower word)

Pi              SET     3.141592654     ;Set value of Pi
f0              SET     700.0
f1              SET     771.0
f2              SET     849.0
f3              SET     941.0
f4              SET     1209.0
f5              SET     1337.0
f6              SET     1476.0
f7              SET     1632.0
f8              SET     1011.0
f9              SET     627.0           ;MG filter frequencies in Hz

n_comp          SET     4               ;Noise compensator
TWIST_VAL       SET     2.0             ;set twist to 2dB
					                    ;twist = hi_peak / lo_peak
TWIST_INV       SET     0.63095734448   ; (1.0/@pow(10,TWIST_VAL/10))
					                    ;calculate 1/TWIST

MIN_DTMF_ON     SET     2               ;3 min no. of frame for DTMF ON
MIN_DTMF_OFF    SET     2               ;3 min no. of frame for DTMF OFF


; Equate values for Silence test

al1		SET	0.5		                    ;al1 -> al3 are the noise energy
					                    ;  updation factors
al2		SET	0.03		                ;
al3		SET     0.001		            ;
Thresh6		SET	0.0625		            ;0.25 Threshold value for separating 
	   				                    ;  silence tones
beta		SET	0.125		            ;0.25 Threshold for silence test to
					                    ;  discriminate between silence
					                    ;  and Invalid tones

PASS		SET	1		;passes a tone/silence detect test
FAIL		SET	0		;fails a tone/silence detect test
ON		    SET	    1		;boolean for on
OFF		    SET 	0		;boolean for off
ANA_BUF_SIZE	SET	2*Nc		;size of required analysis buffer
LAST_BUF_SIZE	SET	2*(Nc-Ns)	;size of required history buffer

;--- DTMF/CALL PROGRESS/SILENCE detect status bit defintions ---;
;--- note that lower byte is used for active tone detection value ---;

DETECT		SET	$0100		;set if tone is detected
INVALID2	SET	$0200		;set if 2nd invalid is detected
DEBOUNCED_ON	SET	$0400		;set if tone debounced and on 
DEBOUNCED_OFF	SET	$0800		;set if tone debounced and off 
TONE_MISMATCH	SET	$2000		;set if adjacent tone detects differ

Fs              SET     4000            ; Sampling Rate

PARALLEL_XMOVE	set	1		; set 1 for parallel x-moves, else set 0
TEST_MODE       set     0               ;set 0 for TEST_MODE

SAMPLE_SHIFT	 set	5

SILENCE         set     $17             ;code for silence
INVALID_TONE    set     $FF             ;the code for invalid tone

DIGIT_DETECTED  set     1               ;To indicate that the digit is 
                                        ;  detected
TRUE        set     0
FALSE       set     -1