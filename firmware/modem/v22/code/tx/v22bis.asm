;******************************** Module **********************************
;
;  Module Name     : V22BIS
;  Author          : N.G.Pai, Varadarajan
;  Date of origin  : 10 Sept 99
;
;*************************** Module Description ***************************
;
;  This module is executed every baud. This module calls the following 
;  function
;  V22BIS_TX_DLB
;  V22BIS_RX_DLB : For Digital Loopback
;  V22BIS_TX_ALB
;  V22BIS_RX_ALB : For Analog Loopback
;  V22BIS_TX
;  V22BIS_R      : For (normal) end-to-end modem operation
;
;************************** Calling Requirements **************************
;The modem TX and RX modes should be set appropriately (i.e. CALL or ANSWER
;) in the variable MDMCONFIG before calling these functions
;
;
;*************************** Input and Output *****************************
;
;  Input   :  None
;  Output  :  None
;
;******************************* Resources ********************************
;
;                        Cycle Count   :  
;                        Program Words :  
;                        NLOAC         :  
;                                          
; Address Registers used: 
;
; Offset Registers used : 
;                          none
;
; Data Registers used   : 
;
; Registers Changed     : 
;
;      
;
;************************** Environment ***********************************
;
;       Assembler : ASM56800 version 6.0.1.0
;       Machine   : IBM PC
;       OS        : MSDOS 6.0
;
;**************************** Assembly Code *******************************
       
    include "gmdmequ.asm"
    include "txmdmequ.asm"       
       
       
    SECTION V22B_TX
        
    GLOBAL  V22BIS_INIT
    GLOBAL  V22BIS_TX_ALB
    GLOBAL  V22BIS_TX_DLB
    GLOBAL  V22BIS_RX_ALB
    GLOBAL  V22BIS_RX_DLB
    GLOBAL  V22BIS_TX
    GLOBAL  V22BIS_RX
 
 
    org     p:

        
V22BIS_INIT
    
    move    x:TXMEMSIZE,x0
    move    #TXMEMB,r0
    clr     a
    rep     x0
    move    a,x:(r0)+

    move    x:RXMEMSIZE,x0
    move    #RXMEMB,r0
    clr     a
    rep     x0
    move    a,x:(r0)+
    move    #0,x:MDMSTATUS
    
    move    #hndshk,x:mode_flg
    move    #V22Bis,x:mdm_flg
    move    #CCITT,x:ccitt_flg
    move    #1,x:flg_104
    move    #0,x:flg_106
    move    #0,x:flg_107
    move    #0,x:flg_109
    move    #0,x:flg_112    
        
    
CopyConfig
    move    x:MDMCONFIG,x0

    bftsth   #CALLANS,x0
    jcc      txcall
 
    move    #ANSWERING,x:rx_ans_flg
    tstw    x:loopback
    beq     _notloopback1                
    move    #CALLING,x:tx_ans_flg
    bra     tstgtone
        
_notloopback1      
    move    #ANSWERING,x:tx_ans_flg

    bra     tstgtone

txcall

    move    #CALLING,x:rx_ans_flg
    tstw    x:loopback
    beq     _notloopback2                                 
    move    #ANSWERING,x:tx_ans_flg
    bra     tstgtone
 
_notloopback2     
    move    #CALLING,x:tx_ans_flg

tstgtone
    move    #0,x:gt_flg

    bftsth  #GTEN,x0
    jcc     tstret

    move    #1,x:gt_flg

    bftsth  #GTTYPE,x0
    jcc     tstret

    move    #3,x:gt_flg

tstret

End_CopyConfig
    
	jsr     TX_MDM_INIT
	jsr     INIT_SP_COMMON
	jsr     RX_MDM_INIT
		
	rts


;***************************************************************************
; Thre will be 3 different calls to V22bis modem depending upon the mode
; 
; 1. V22BIS_TX_DLB
;    V22BIS_RX_DLB: These calls will be for V22bis modem digital loopback
;
; 2. V22BIS_TX_ALB: 
;    V22BIS_RX_ALB: This call will be for V22bis modem analog loopback
;
; 3. V22BIS_TX    : 
;    V22BIS_RX    : This call will be for V22BIS BER testing or for end-to-end
;                   connection
;***************************************************************************
        

V22BIS_TX_ALB
V22BIS_TX_DLB
V22BIS_TX
        
    jsr     TXBAUD
    rts
        
        
V22BIS_RX_ALB
V22BIS_RX_DLB
V22BIS_RX

    jsr     RXBAUDPROC                ;Call the Baud processing routine
		
    rts

        
    ENDSEC
		

