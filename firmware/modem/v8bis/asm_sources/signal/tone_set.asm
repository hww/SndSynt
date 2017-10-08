;********************** Revision History *****************************
; 
; Date               Author                 Comments
; ----               ------                 --------
; 03/07/2000        N R Prasad              Ported on to Mwtrowerks;
;                                           Commented FS line below.
;
;**********************************************************************


;----- Conditional Assembly/User Configurable Constants  -----;

PI              SET    3.1415927       ;set value of Pi
F0              SET    1375.0          ;Initiating tone
F1              SET    2002.0
F2              SET    1529.0          ;Responding tone 
F3              SET    2225.0          ;MG filter frequencies in HZ

; Single Tone Frequencies .
FS0             SET     650.0          ;MRe 
FS1             SET    1150.0          ;MRd
FS2             SET     400.0          ;CRe
FS3             SET    1900.0          ;CRd
FS4             SET     980.0          ;ESi 
FS5             SET    1650.0          ;ESr
NO_DTMF         SET    2               ;No of mg filters for DTMF
NO_STF          SET    6               ;No of mg filters for STF
DTMF_TEST       SET    0               ;if needed down scaling by 2
