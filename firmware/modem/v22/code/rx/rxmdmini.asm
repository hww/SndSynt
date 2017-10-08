

        include "gmdmequ.asm"

        SECTION V22B_RX 

        GLOBAL   RX_MDM_INIT

        org     p:

RX_MDM_INIT
        jsr     INIT_BEG_AGC
        move    #RXQ,r0
        move    #RXINTP,a
        move    a,x:(r0)+
        move    #RXBPF,a
        move    a,x:(r0)+
        move    #RXDEMOD,a
        move    a,x:(r0)+
        move    #RXDECIM,a
        move    a,x:(r0)+
        move    #RXCDAGC,a
        move    a,x:(r0)+
        move    #RX_NEXT,a
        move    a,x:(r0)+
        move    a,x:(r0)+
        move    #ENDRX,a
        move    a,x:(r0)+
        move    a,x:(r0)+
        move    #RXDEC4,a
        move    a,x:(r0)+
        move    #RXEQERR,a
        move    a,x:(r0)+
        move    #RX_NEXT,a
        move    a,x:(r0)+
        move    #RXDIFDEC,a
        move    a,x:(r0)+
        move    #RXDESCR4,a
        move    a,x:(r0)+
        move    #RX_NEXT,a
        move    a,x:(r0)+
        move    #ENDRX,a
        move    a,x:(r0)+

;StQ initialisation
        move    #Rx_StQC,r0
        move    #rx_CA,a
        move    a,x:(r0)+
        move    #rx_CB,a
        move    a,x:(r0)+
        move    #rx_CC,a
        move    a,x:(r0)+
        move    #rx_CD,a
        move    a,x:(r0)+
        move    #rx_CE,a
        move    a,x:(r0)+
        move    #rx_CF,a
        move    a,x:(r0)+

        move    #Rx_StQA,r0
        move    #rx_AA,a
        move    a,x:(r0)+
        move    #rx_AB,a
        move    a,x:(r0)+
        move    #rx_AC1,a
        move    a,x:(r0)+
        move    #rx_AC,a
        move    a,x:(r0)+
        move    #rx_AD,a
        move    a,x:(r0)+
        
        move    #Rx_StQG22,r0
        move    #rx_G22A,a
        move    a,x:(r0)+
        move    #rx_G22B,a
        move    a,x:(r0)+
        move    #rx_G22C,a
        move    a,x:(r0)+
        move    #rx_G22D,a
        move    a,x:(r0)+

        move    #Rx_StQGBis,r0
        move    #rx_GBisA,a
        move    a,x:(r0)+
        move    #rx_GBisB,a
        move    a,x:(r0)+
        move    #rx_GBisC,a
        move    a,x:(r0)+
        move    #rx_GBisD,a
        move    a,x:(r0)+
        move    #rx_GBisE,a
        move    a,x:(r0)+
        move    #rx_GBisF,a
        move    a,x:(r0)+
        move    #rx_GBisG,a
        move    a,x:(r0)+
        move    #rx_GRetA,a
        move    a,x:(r0)+
        
        move    #Rx_StQC,x0
        bftsth  #CALLANS,x:MDMCONFIG
        bcc     _calling
        move    #Rx_StQA,x0
_calling
        move    x0,x:Rx_StQ_ptr
        move    #1,x:rx_st_chg
        move    #0,x:flg_109
        move    #0,x:flg_112
        rts

        ENDSEC
