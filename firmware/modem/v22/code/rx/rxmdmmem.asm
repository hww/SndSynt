

       include 'rxmdmequ.asm'

       SECTION RX_MEM

       GLOBAL       RXMEMB
       GLOBAL       rx_st_chg
       GLOBAL       rx_ans_flg
       GLOBAL       RX_LAPM_EN
       GLOBAL       TX_LAPM_EN
       GLOBAL       retctr
       GLOBAL       rx_ctr
       GLOBAL       err_ctr
       GLOBAL       rx_toutctr
       GLOBAL       RXTH
       GLOBAL       DEL_2100
       GLOBAL       TON2100
       GLOBAL       TON150
       GLOBAL       TONS1
       GLOBAL       SPEED
       GLOBAL       USB1PAT
       GLOBAL       RETRCNT
       GLOBAL       TRN_LNG
       GLOBAL       IB
       GLOBAL       IBPTR
       GLOBAL       IBPTR_IN
       GLOBAL       RXSB
       GLOBAL       RXRB
       GLOBAL       RXFPTR
       GLOBAL       DPHASE
       GLOBAL       CDP
       GLOBAL       DP
       GLOBAL       DPHADJ
       GLOBAL       BPF_OUT
       GLOBAL       BPFOUT_PTR
       GLOBAL       RXMPTR
       GLOBAL       RXCB2A
       GLOBAL       RXCB2A_1
       GLOBAL       RXCB2A_2
       GLOBAL       RXCB2A_3
       GLOBAL       RXCB2A_4
       GLOBAL       RXCB2A_5
       GLOBAL       RXCB2A_6
       GLOBAL       RXCBPTR
       GLOBAL       PREV_ENERGY
       GLOBAL       PRV_ENPTR
       GLOBAL       ENBUF_PTR
       GLOBAL       AGCG
       GLOBAL       AGCC1
       GLOBAL       AGCC2
       GLOBAL       AGCC3
       GLOBAL       AGCC4
       GLOBAL       AGCLP1
       GLOBAL       AGCLP2
       GLOBAL       AGCLG
       GLOBAL       RXSBAG
       GLOBAL       CD1
       GLOBAL       ENERBUF
       GLOBAL       RXCB
       GLOBAL       RXCB_1
       GLOBAL       RXCB_2
       GLOBAL       RXCB_3
       GLOBAL       RXCB_4
       GLOBAL       RXCB_5
       GLOBAL       RXCB_6
       GLOBAL       RXCBIN_PTR
       GLOBAL       RXCBOUT_PTR
       GLOBAL       CD_CNT
       GLOBAL       LPBAGC
       GLOBAL       LPBAGC2
       GLOBAL       HPG1
       GLOBAL       HPG2
       GLOBAL       BLPG1
       GLOBAL       BLPG2
       GLOBAL       BOFF
       GLOBAL       BHPX1
       GLOBAL       BHPY1
       GLOBAL       BHPX3
       GLOBAL       BHPY3 
       GLOBAL       BHPE1
       GLOBAL       BHPE3
       GLOBAL       BACC1
       GLOBAL       BACC2
       GLOBAL       BLP
       GLOBAL       BINTG
       GLOBAL       BINTGA
       GLOBAL       status
       GLOBAL       CARG1
       GLOBAL       CARG2
       GLOBAL       CARG3
       GLOBAL       CARG4
       GLOBAL       COFF
       GLOBAL       CLP
       GLOBAL       RCBUF
       GLOBAL       RCBUF_1
       GLOBAL       RCBUF_2
       GLOBAL       RCBUF_3
       GLOBAL       RCBUF_4
       GLOBAL       RCBUF_5
       GLOBAL       THBUF
       GLOBAL       BBUF
       GLOBAL       JITTER
       GLOBAL       JITG1
       GLOBAL       JITG2
       GLOBAL       WRPFLG
       GLOBAL       ACODE
       GLOBAL       EQRT
       GLOBAL       EQRT_1
       GLOBAL       EQRT_2
       GLOBAL       EQRT_3
       GLOBAL       EQRT_4
       GLOBAL       EQRT_5
       GLOBAL       EQRT_6
       GLOBAL       EQRT_7
       GLOBAL       EQRT_8
       GLOBAL       EQRT_9
       GLOBAL       EQRT_10
       GLOBAL       EQIT
       GLOBAL       EQRSB
       GLOBAL       EQRBIN
       GLOBAL       EQIBIN
       GLOBAL       EQISB
       GLOBAL       EQUDSIZ
       GLOBAL       LUPALP
       GLOBAL       RXSCRD
       GLOBAL       RXODAT
       GLOBAL       RXQ
       GLOBAL       RXQ_1
       GLOBAL       RXQ_2
       GLOBAL       RXQ_3
       GLOBAL       RXQ_4
       GLOBAL       RXQ_5
       GLOBAL       RXQ_6
       GLOBAL       RXQ_7
       GLOBAL       RXQ_8
       GLOBAL       RXQ_9
       GLOBAL       RXQ_10
       GLOBAL       RXQ_11
       GLOBAL       RXQ_12
       GLOBAL       RXQ_13
       GLOBAL       RXQ_14
       GLOBAL       RXQ_15
       GLOBAL       RxQ_ptr
       GLOBAL       Rx_StQC
       GLOBAL       Rx_StQA
       GLOBAL       Rx_StQG22
       GLOBAL       Rx_StQGBis
       GLOBAL       Rx_StQ_ptr
       GLOBAL       RXMASK_MC
       GLOBAL       RXMASK
       GLOBAL       TXMASK_MC
       GLOBAL       TXMASK
       GLOBAL       RN_BITS_BAUD
       GLOBAL       TN_BITS_BAUD
       GLOBAL       T401_VALUE
       GLOBAL       T401B_VALUE
       GLOBAL       T403_VALUE
       GLOBAL       LASTDP
       GLOBAL       WRAP
       GLOBAL       BBUFPTR
       GLOBAL       rx_data
       GLOBAL       Frx_data
       GLOBAL       NOISE
       GLOBAL       RETCNT_RM
       GLOBAL       speed
       GLOBAL       ICOEFF
       GLOBAL       BPF_PTR
       GLOBAL       temp1
       GLOBAL       temp2
       GLOBAL       mod_tbl_offset
       GLOBAL       TRAINING
       GLOBAL       IFBANK
       GLOBAL       IBCNT
       GLOBAL       TXBD_CNT
       GLOBAL       TNSUM
       GLOBAL       TNASUM
       GLOBAL       EQX
       GLOBAL       EQY
       GLOBAL       RXDATA
       GLOBAL       DECX
       GLOBAL       DECY
       GLOBAL       DX
       GLOBAL       DY
       GLOBAL       dscr_mask
       GLOBAL       rx_dscr_buff
       GLOBAL       rx_dscr_buff_1
       GLOBAL       dscr_cntr
       GLOBAL       RXMEMSIZE
       GLOBAL       IBPTR_IN

;-------------------------------------------------


       org x:

rx_st_chg       ds           1   
RXMEMB          equ          rx_st_chg
rx_ans_flg      ds           1   
RX_LAPM_EN      ds           1
TX_LAPM_EN      ds           1

 
retctr          ds           1
rx_ctr          ds           1   
err_ctr         ds           1   
rx_toutctr      ds           1
RXTH            ds           1   
DEL_2100        ds           5
TON2100         ds           1   
TON150          ds           1   
TONS1           ds           1   
SPEED           ds           1   
USB1PAT         ds           1   
RETRCNT         ds           1   
TRN_LNG         ds           1   

  
IB              dsm          IBSIZ
IBPTR           ds           1   
RXSB            ds           12  
RXRB            dsm          RX_FILT_V22

RXFPTR          ds           1   
DPHASE          ds           1   
CDP             ds           1   
DP              ds           1   
DPHADJ          ds           1   
 
BPF_OUT         ds           24  
BPFOUT_PTR      ds           1   
RXMPTR          ds           1   

RXCB2A          ds           24  
RXCB2A_1        equ          RXCB2A+1
RXCB2A_2        equ          RXCB2A+2
RXCB2A_3        equ          RXCB2A+3
RXCB2A_4        equ          RXCB2A+4
RXCB2A_5        equ          RXCB2A+5
RXCB2A_6        equ          RXCB2A+6


RXCBPTR         ds           1   
PREV_ENERGY     ds           12  
PRV_ENPTR       ds           1   
ENBUF_PTR       ds           1   
AGCG            ds           1   
AGCC1           ds           1   
AGCC2           ds           1   
AGCC3           ds           1   
AGCC4           ds           1   
AGCLP1          ds           1   
AGCLP2          ds           1   
AGCLG           ds           1   
RXSBAG          ds           1   
CD1             ds           1   
ENERBUF         dsm          36  

RXCB            dsm          30  
RXCB_1          equ           RXCB+1
RXCB_2          equ           RXCB+2
RXCB_3          equ           RXCB+3
RXCB_4          equ           RXCB+4
RXCB_5          equ           RXCB+5
RXCB_6          equ           RXCB+6


RXCBIN_PTR      ds           1   
RXCBOUT_PTR     ds           1   
 
CD_CNT          ds           1   
LPBAGC          ds           1   
LPBAGC2         ds           1   
 
HPG1            ds           1   
HPG2            ds           1   
BLPG1           ds           1   
BLPG2           ds           1   
BOFF            ds           1   
BHPX1           ds           1   
BHPY1           ds           1   
BHPX3           ds           1   
BHPY3           ds           1   
BHPE1           ds           1   
BHPE3           ds           1   
BACC1           ds           1   
BACC2           ds           1   
BLP             ds           1   
BINTG           ds           1   
BINTGA          ds           1   
status          ds           1   
 
CARG1           ds           1            ;Assign Carrier loop variables
CARG2           ds           1   
CARG3           ds           1   
CARG4           ds           1   
COFF            ds           1   
CLP             ds           1   
 
RCBUF           ds           6            ;Assign Phase jitter module
RCBUF_1         equ          RCBUF+1
RCBUF_2         equ          RCBUF+2
RCBUF_3         equ          RCBUF+3
RCBUF_4         equ          RCBUF+4
RCBUF_5         equ          RCBUF+5


THBUF           ds           6            ;  variables and buffers
BBUF            dsm          13  
JITTER          ds           1   
JITG1           ds           1   
JITG2           ds           1   
WRPFLG          ds           1   
ACODE           ds           1   
 
EQRT            ds           EQTSIZ22     ;Assign Equaliser module
EQRT_1          equ          EQRT+1
EQRT_2          equ          EQRT+2
EQRT_3          equ          EQRT+3
EQRT_4          equ          EQRT+4
EQRT_5          equ          EQRT+5
EQRT_6          equ          EQRT+6
EQRT_7          equ          EQRT+7
EQRT_8          equ          EQRT+8
EQRT_9          equ          EQRT+9
EQRT_10         equ          EQRT+10


EQIT            ds           EQTSIZ22     ;  buffers and variables
EQRSB           dsm          2*EQTSIZ22
EQRBIN          ds           1   
EQIBIN          ds           1   
EQISB           dsm          2*EQTSIZ22
EQUDSIZ         ds           1   
LUPALP          ds           1   
 
RXSCRD          ds           1            ;Assign Descrambler module
RXODAT          ds           1            ;  variables
 
RXQ             ds           25  

RXQ_1           equ          RXQ+1
RXQ_2           equ          RXQ+2
RXQ_3           equ          RXQ+3
RXQ_4           equ          RXQ+4
RXQ_5           equ          RXQ+5
RXQ_6           equ          RXQ+6
RXQ_7           equ          RXQ+7
RXQ_8           equ          RXQ+8
RXQ_9           equ          RXQ+9
RXQ_10          equ          RXQ+10
RXQ_11          equ          RXQ+11
RXQ_12          equ          RXQ+12
RXQ_13          equ          RXQ+13
RXQ_14          equ          RXQ+14
RXQ_15          equ          RXQ+15


RxQ_ptr         ds           1   
Rx_StQC         ds           6   
Rx_StQA         ds           5   
Rx_StQG22       ds           5   
Rx_StQGBis      ds           8   
Rx_StQ_ptr      ds           1   
 
RXMASK_MC       ds           1            ;**** Additions
RXMASK          ds           1   
TXMASK_MC       ds           1   
TXMASK          ds           1   
RN_BITS_BAUD    ds           1   
TN_BITS_BAUD    ds           1   
T401_VALUE      ds           1   
T401B_VALUE     ds           1   
T403_VALUE      ds           1   
LASTDP          ds           1   
WRAP            ds           1   
BBUFPTR         ds           1   
rx_data         ds           1
Frx_data        equ          rx_data   
NOISE           ds           1   
RETCNT_RM       ds           1   
speed           ds           1   
ICOEFF          ds           12  
BPF_PTR         ds           1   
temp1           ds           1   
temp2           ds           1   

mod_tbl_offset  ds           1   
TRAINING        ds           1   
IFBANK          ds           1   
IBCNT           ds           1
TXBD_CNT        ds           1
TNSUM           ds           1   
TNASUM          ds           1   
EQX             ds           1   

EQY             ds           1   
RXDATA          ds           1   
DECX            ds           1   
DECY            ds           1   
DX              ds           1   
DY              ds           1   
dscr_mask       ds           1   
rx_dscr_buff    ds           2
rx_dscr_buff_1  equ          rx_dscr_buff+1
dscr_cntr       ds           1  

RXMEME          equ          *

RXMEMSIZE       dc          RXMEME-RXMEMB
IBPTR_IN        ds           1

       
     ENDSEC
