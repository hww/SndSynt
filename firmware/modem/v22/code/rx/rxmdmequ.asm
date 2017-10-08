PI              set          2.0*@asn(1.0)
cost            equ          @cos(26.56*PI/180)
sint            equ          @sin(26.56*PI/180)

AGC_SCALE       equ          $0006
FASTAGC         equ          $1000
SLOWAGC         equ          $0400
 
FASTEQUD        equ          $0800
SLOWEQUD        equ          $0200
DPHASEANS       equ          $00ab
DPHASECAL       equ          $0155
 
NOISETHR        equ          $0c00
 
rxCActr         equ          300          ;500ms
rxCBctr         equ          15           ;25ms
rxCCctr         equ          93           ;155ms
rxCCtout        equ          7200         ;7 sec timeout
rxCEerr         equ          1800         ;3sec
rxCFctr         equ          36           ;60ms
rxCFerr         equ          5            ;8.333ms
 
rxAActr         equ          -1           ;wait for tx to effect state
                                          ;  transition
rxACctr         equ          6            ;10ms
rxAC1ctr        equ          4            ;6.67ms
rxADctr         equ          48           ;80ms
 
rxG22Actr       equ          12           ;20ms
rxG22Bctr       equ          125          ;208.33ms
rxG22Cctr       equ          -1           ;Tx to give permission!
 
rxGBisBctr      equ          12           ;20ms
rxGBisCctr      equ          270          ;450ms
rxGBisDctr      equ          8            ;32 consecutive 1
rxGBisDerr      equ         1200          ;(1200) 2sec
rxGBisEctr      equ          -1           ;Wait for trasmitter to effect
                                          ;  state transition
rxGBisFctr      equ          600          ;1sec
 
rxRetAerr       equ          720          ;1.2sec
 
EQTSIZ22        equ          15
RX_FILT_V22     equ          48
RXCB_MOD        equ          30-1
 
IBSIZ           equ          34
ENBUF_SIZ       equ          36
RXCB_SIZ        equ          30           ;56
RXSB_SIZ        equ          12

THRESH1         equ          $00c0        ;Thresholds used in Carrier 
THRESH2         equ          $0048        ;  detection
THRESH3         equ          $005c
THRESH4         equ          $0070


BETA2           equ          $c0c3        ;Bandpass filter coeff. used
BETA3           equ          $7f1e        ;  detecting 2100Hz tone.
ALPHA3          equ          $00e2
