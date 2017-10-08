Nc_cpt          SET     80
ANA_BUF_SIZE	SET	    Nc_cpt	        ;size of required analysis buffer
zero            SET     0               ;Zero
NO_FIL_CPT      SET     6               ;Number of CPT MG filters
M               SET     1               ;Number of channels
mul_val_cpt     SET     Nc_cpt/128.0    ;Scale by N/2
					;Constant for 2Ns/128*win_fac

;----------  CPT Group1 Parameters ----------
CPT_THRESH1_HI  SET    $0000            ;threshold for MAG test (-29dBm) with
CPT_THRESH1_LO  SET    $2000            ;  6 guard bits 
Thresh2a1_cpt1  SET    0.22496          ;350 & 280
Thresh2a2_cpt1  SET    0.29251          ;440 & 480
Thresh2a3_cpt1  SET    0.10508          ;440 & 620
Thresh2a4_cpt1  SET    0.02058          ;440 & 700
Thresh4a_cpt1   SET    0.40461          ;Forward twist (440 > 350)
Thresh4b_cpt1   SET    0.38715          ;Reverse twist (350 > 440)
Thresh5a_cpt1   SET    0.61807          ;hi_pk > lo_pk
Thresh5b_cpt1   SET    0.55881          ;lo_pk > hi_pk
ThreshEN1   	SET    0.75512          ;Thresh5c for CPT (a+b)/sig_ener

;----------  CPT Group2 Parameters ----------
CPT_THRESH2_HI  SET    $0000            ;threshold for MAG test (-52dBm) with
CPT_THRESH2_LO  SET    $0245            ;  6 guard bits
Thresh2a1_cpt2  SET    0.03436          ;480 & 280
Thresh2a2_cpt2  SET    0.11774          ;480 & 350
Thresh2a3_cpt2  SET    0.36681          ;480 & 440
Thresh2a4_cpt2  SET    0.19171          ;620 & 700
Thresh4a_cpt2   SET    0.36505          ;Forward twist (620 > 480)
Thresh4b_cpt2   SET    0.44933          ;Reverse twist (480 > 620)
Thresh5a_cpt2   SET    0.55372          ;hi_pk > lo_pk
Thresh5b_cpt2   SET    0.57118          ;lo_pk > hi_pk
ThreshEN2 	SET    0.73230       	;Thresh5c for CPT (a+b)/sig_ener

;----------  CPT Group3 Parameters ----------
CPT_THRESH3_HI  SET    $0000            ;threshold for MAG test (-47dBm) with
CPT_THRESH3_LO  SET    $0673            ;  6 guard bits
Thresh2a1_cpt3  SET    0.14219          ;480 & 620
Thresh2a2_cpt3  SET    0.08498          ;480 & 700
Thresh2a3_cpt3  SET    0.05769          ;440 & 280
Thresh2a4_cpt3  SET    0.38995          ;440 & 350
Thresh4a_cpt3   SET    0.22759          ;Reverse twist (440 > 480)
Thresh4b_cpt3   SET    0.22095          ;Forward twist (480 > 440)
Thresh5a_cpt3   SET    0.62611          ;hi_pk > lo_pk
Thresh5b_cpt3   SET    0.67744          ;lo_pk > hi_pk
ThreshEN3 	SET    0.83158       	;Thresh5c for CPT (a+b)/sig_ener

NOISE_LEVEL1    SET    $15		;Maximum Noise level=-18dB (upper word)
NOISE_LEVEL2    SET    $2c3c		;Maximum Noise level (lower word)

n_comp          SET     4               ;Noise compensator

MIN_CPT_ON	SET     2               ;min no. of frame for call progress on
MIN_CPT_OFF	SET     2               ;min no. of frame for call progress on
MAX_CPT_OFF	SET     250             ;max no. of frame for call progress off
MIN_SIL_ON	SET     2               ;min no. of frame for silence on
MIN_SIL_OFF	SET     2               ;min no. of frame for silence off


; Equate values for Silence test

al1    SET      0.5                 ;al1 -> al3 are the noise energy
                                    ;  updation factors
al2	    SET     0.03
al3		SET     0.001
Thresh6 SET     0.25                ;Threshold value for separating 
                                    ;  silence tones
beta    SET     0.25                ;Threshold for silence test to
                                    ;  discriminate between silence
                                    ;  and Invalid tones

PASS    SET     1                   ;passes a tone/silence detect test
FAIL    SET     0                   ;fails a tone/silence detect test
ON      SET     1                   ;boolean for on
OFF	    SET     0                   ;boolean for off

;--- DTMF/CALL PROGRESS/SILENCE detect status bit defintions ---;
;--- note that lower byte is used for active tone detection value ---;
DETECT          SET  $0100	        ;set if tone is detected
INVALID2        SET  $0200          ;set if 2nd invalid is detected
DEBOUNCED_ON    SET  $0400          ;set if tone debounced and on 
DEBOUNCED_OFF   SET  $0800          ;set if tone debounced and off 
TONE_MISMATCH   SET  $2000          ;set if adjacent tone detects differ

SAMPLE_SHIFT_CPT set	6

;--- CODE VALUES for call progress tone/silence detection ---;
CPT_GROUP_1     set     1           ;code for callprogress group 1 tones
CPT_GROUP_2     set     2           ;code for callprogress group 2 tones
CPT_GROUP_3     set     3           ;code for callprogress group 3 tones
DIAL_TONE       set     $11         ; call progress dial tone 
MSG_WAIT        set     $12         ; call progress message waiting
RECALL          set     $13         ; call progress recall dial tone
BUSY            set     $14         ; call progress line busy
REORDER         set     $15         ; call progress reorder
RING            set     $16         ; call progress audible ringing

SILENCE         set     $17         ;code for silence
INVALID_TONE    set     $FF         ;the code for invalid tone
 


;--- CALL PROGRESS tone detection timing constants ---;
BURST_ON        set     5           ; (0.1sec) / (10msec/frame) = 10
BURST_ON_DEV    set     2           ; +/- 10% of BURST_ON = +/- 1
BURST_OFF       set     5           ; (0.1sec) / (10msec/frame) = 10
BURST_OFF_DEV   set     2           ; +/- 10% of BURST_OFF = +/- 1
MSG_WAIT_BURSTS set     10          ; burst count for message waiting
RECALL_BURSTS   set     3           ; burst count for recall dial tone
BUSY_BURSTS     set     1           ; Minimum burst count for Busy
REORDER_BURSTS  set     1           ; Minimum burst count for Reorder
DIAL_TONE_ON    set     30          ; 600msec 
REORDER_ON      set     12          ; (0.25sec) / (10msec/frame) = 25
REORDER_ON_DEV  set     3           ; +/- 10% of REORDER_ON = +/- 2.5 = 3
REORDER_OFF     set     12          ; (0.25sec) / (10msec/frame) = 25
REORDER_OFF_DEV set     3           ; +/- 10% of REORDER_OFF = +/- 2.5 = 3
BUSY_ON         set     25          ; (0.50sec) / (10msec/frame) = 50
BUSY_ON_DEV     set     4           ; +/- 10% of BUSY_ON = +/- 5
BUSY_OFF        set     25          ; (0.50sec) / (10msec/frame) = 50
BUSY_OFF_DEV    set     4           ; +/- 10% of BUSY_OFF = +/- 5
RING_ON         set     100         ; (2.00sec) / (10msec/frame) = 200
RING_ON_DEV     set     15          ; +/- 10% of RING_ON = +/- 20
RING_OFF        set     200         ; (2.00sec) / (10msec/frame) = 200
RING_OFF_DEV    set     25          ; +/- 10% of RING_OFF = +/- 20

MIN_LAST_ON     set     BURST_ON-BURST_ON_DEV
                                    ; minimum value for cpt_last_on
                                    ; to indicate valid call
                                    ; progress tone
