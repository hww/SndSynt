

;**********************************
;*   X:MDMCONFIG Bit pattern
;**********************************

CALLANS         equ          $0001
GTEN            equ          $0002
GTTYPE          equ          $0004
RET_EN          equ          $0008
V22bisEN        equ          $0100
V23EN           equ          $0200
LOOPBACK        equ          $8000

;End MDMCONFIG Bit pattern

;**********************************
;*   X:MDMSTATUS Bit pattern
;**********************************
DISCON          equ          $0001
TXERR           equ          $0002
RXERR           equ          $0004
NOISY           equ          $0008

V23Con          equ          $0100
V22Con          equ          $0200
V22BisCon       equ          $0400

CDBIT           equ          $1000
RREQ            equ          $2000
LREQ            equ          $4000
DABIT           equ          $0010

;End MDMSTATUS Bit pattern


;**********************************
;*   X:mode_flg Bit pattern
;**********************************
hndshk          equ          $0001        ;Check flag for handshake mode
datamd          equ          $0002        ;Check flag for data mode
retrn           equ          $0004        ;Check flag for retrain mode

;End mode_flg Bit pattern

CALLING         equ          $0000        ;Bit position in flag tx_ans_flg
ANSWERING       equ          $0001        ; which indicates cal/ans modes

V22             equ          $0000
V22Bis          equ          $0001
 
CABIT           equ          $0001 

PI              set          2.0*@asn(1.0) ;Constants used
SFREQ           set          7200
N0              equ          24
N1              equ          256
