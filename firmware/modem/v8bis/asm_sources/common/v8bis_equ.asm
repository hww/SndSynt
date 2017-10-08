;***********************************************************************
;
; Motorola India Electronics Ltd. (MIEL)
;
; PROJECT ID           : V.8 bis
;
; ASSEMBLER            : ASM56800 version 6.2.0
;
; FILE NAME            : v8bis_equ.asm
;
; PROGRAMMER           : Binuraj K.R.
;
; DATE CREATED         : 1/4/1998
;
;**********************MODULE  DESCRIPTION ******************************
; Description:	This module contains the EQU definitions
;		for V.21 Modem and DTMF detection. 
;
;*************************** Revision History *****************************
;
;  Date         Person             Change
;  ----         ------             ------
;  1/4/1998     Binuraj K.R.       Collated all the EQU files and created this
;                                  file
;  24/4/1998    Minati             Added new EQUs reqd. for V21 Demodulation  
;  
;  14/5/1998    Minati             Changed the EQU SAMPLES_PER_BIT TO 
;                                  SAMPLES_PER_BAUD 
;  04/6/1998    Varadarajan G      Added constants for state machine
;
;  12/6/1998    Varadarajan G      Added constants for Agc and carrier detect
;
;------------------------------------------------------------------------------
;***********************************************************************
;*  
;*  EQU's used for V21 modem
;* 
;***********************************************************************

FS                   equ      7200
BAUD_RATE            equ      300
SAMPLES_PER_BAUD     equ      FS/BAUD_RATE 
V21_L_FC             equ      1080
V21_L_F0             equ      1180 
V21_L_F1             equ      980
V21_H_FC             equ      1750
V21_H_F0             equ      1850
V21_H_F1             equ      1650
SINE_TABLE1_LEN      equ      360
SINE_TABLE2_LEN      equ      144     
V21_L_INDEX0         equ      (V21_L_F0*SINE_TABLE1_LEN)/FS
V21_L_INDEX1         equ      (V21_L_F1*SINE_TABLE1_LEN)/FS
V21_H_INDEX0         equ      (V21_H_F0*SINE_TABLE2_LEN)/FS
V21_H_INDEX1         equ      (V21_H_F1*SINE_TABLE2_LEN)/FS
V21_L_INDEX          equ      (V21_L_FC*SINE_TABLE1_LEN)/FS
V21_H_INDEX          equ      (V21_H_FC*SINE_TABLE2_LEN)/FS
COS_L_INDEX          equ      SINE_TABLE1_LEN/4
COS_H_INDEX          equ      SINE_TABLE2_LEN/4
AVG_LEN              equ      6
AVG_FACTOR           equ      0.166667    ;1/AVG_LEN
C_ZERO_CROSS         equ      0.9
TIMREC_MODULO_LEN    equ      36
DEF_ZERO_CROSS_INDEX equ      6
ONE_IN_Q11           equ      $0800
R1_MODULO            equ      $8000
LPF_ORDER            equ      3 
;**************************************************************************
;
;  EQU used for AGCG and carrier detect modules
;
;*************************************************************************

NEG43DB_THRESH_HI    equ      $0001        ;3.162277660168380e-05
NEG43DB_THRESH_LO    equ      $0945
EIGHT_BY_12          equ      .6666667     ;equ for 8/12
NORM_CNT             equ      16
ROUND_CONST          equ      $8000

;**************************************************************************
;
;  EQU used for CRC Module
;
;*************************************************************************

CRC_CCITT_DIVISOR    equ      $1021
OCTET_LENGTH         equ      8
WORD_LENGTH          equ      16  

;**************************************************************************
;
;  EQU used for state machine
;
;*************************************************************************

CHG_STATE            equ      1     
CDPRESENSE           equ      3        ;Continously carrier should be present
                                       ;  for this many bauds
STAB_FILST           equ      3        ;Stabilise filter states
STATE1               equ      1
STATE2               equ      2
STATE3               equ      3
STATE4               equ      4
STATE5               equ      5
DEFAULT_LOG2AGCG     equ      0        ;Default AGC gain
MAX_AGCLEN           equ      16       ;Maximum number of bauds used in AGCg
DEF_ZERO_CROSS_IDX   equ      6        ;Zero cross index(default)
MAX_CD_DROP_ALLD     equ      9        ;30 ms of carrier drop


; EQU's used for signal modules.

NS                   equ      144      ;No of samples in a frame
M                    equ      1        ;Number of channels

EMIN_L               equ      $0004    ;absolute Thresh value -60dBm
EMIN_H               equ      $0000    ;is multiplied NS/4,taken as 
                                       ;  double precision and stored 
				       ;  by deviding 2^14 sinse 7 is
				       ;  gaurd bits  
N_COMP               equ      0        ;Noise compensator

ANA_BUF_SIZE	     equ      NS       ;size of required analysis buffer

SAMPLE_SHIFT	     equ      7        ;The gaurd bits needed.  

OUT_INDEX            equ      4       ;ptr index for pointing to out 
                                      ;   samples in HPF output.
OUT_PTR              equ     -5       ;index to out samples in HPF.

INP_SCL_FACTOR       equ      2       ;input scaling factor for samples
                                      ;  to avoid saturation.
HPF_MOD_COUNT        equ      8       ;modulo count for 4th order HPF

ZERO_PAD             equ      8       ;The count to be intialised to
                                      ;  zero before filtering.
HPF_XROM_COPY        equ      9       ;No of HPF coefficients to be
                                      ;  copied from X-Rom to X-Ram   
NORM_COUNT           equ      15      ;Normalisation count

NO_HPF_COEFF         equ       9      ;count of hpf coefficients

FIRST_LOC            equ       -8     ;count for pointing to first 
                                      ;  locn. from input_buf+8


;**********************************************************************
;  v.8 bis flags, first word x:Fg_v8bis_flags
;**********************************************************************

SSI_RX_SAMPLES_READY      equ    $0001
SSI_TX_SAMPLES_RQST       equ    $0002
SIGNAL_GEN_ENABLE         equ    $0004
MESSAGE_GEN_ENABLE        equ    $0008
SIGNAL_DETECT_ENABLE      equ    $0010
MESSAGE_RECEPTION_ENABLE  equ    $0020
CDBIT                     equ    $0040 
ES_DETECTED               equ    $0080
ES_GENERATED              equ    $0100
V8BIS_TRANSACTION_ON      equ    $0200
INITIATE_TRANSACTION      equ    $0400
STATION                   equ    $0800
SIGNAL_DETECTED           equ    $1000
MESSAGE_RECEIVED          equ    $2000
DSP_TX_BUSY               equ    $4000
MESSAGE_VALIDITY          equ    $8000

;********************************************************************
; v.8 bis flags, second word x:Fg_v8bis_flags+1
;********************************************************************

PRECEDE_ES                equ    $0001
GENERATE_CL_MS            equ    $0002
CL_RECEIVED               equ    $0004
CL_MS_EXPECTED            equ    $0008
START_MODEM_HANDSHAKE     equ    $0010
HOST_CONFIG_MSG_RXD       equ    $0020
HOST_CAP_MSG_RXD          equ    $0040
HOST_RCAP_MSG_RXD         equ    $0080
HOST_PRIORITY_MSG_RXD     equ    $0100
SEND_NAK1                 equ    $0200
SILENCE_BEFORE_SIGNAL     equ    $0400
FIVE_SECONDS_COUNTER      equ    $0800
HS_SIGNAL_DETECTED        equ    $1000 

CODEC_BUFFER_LENGTH       equ    144*2
SAMPLES_PER_FRAME         equ    144
