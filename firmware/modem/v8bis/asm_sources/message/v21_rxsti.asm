;************************************************************************
;
; Motorola India Electronics Ltd. (MIEL).
;
; PROJECT ID           : V.8 bis
;
; ASSEMBLER            : ASM56800 version 6.2.0
;
; FILE NAME            : v21_rxsti.asm
;
; PROGRAMMER           : Varadarajan G
;
; DATE CREATED         : 02 Jun 1998
; 
; FILE DESCRIPTION     : Contains all the state initialization routines
;
; FUNCTIONS            : V21_Rxcdw_Init, V21_Rxagc_Init, V21_Rxfzc_Init
;                        V21_Rxdat_Init
;
; MACROS               : None
;
;************************************************************************
;
;  Program memory used:  70
;
;**************************** Assembly Code *******************************
        

        include "v8bis_equ.asm"
        
        SECTION V21_Rxsti

        GLOBAL    V21_Rxcdw_Init
        GLOBAL    V21_Rxagc_Init
        GLOBAL    V21_Rxfzc_Init
        GLOBAL    V21_Rxdat_Init
        GLOBAL    V21_Rxagcfzc_Init

              
;****************************** Module ************************************
;
;  Module Name    : V21_Rxcdw_Init
;  Author         : Varadarajan G
;
;************************** Module Description ****************************
;
;  Initialiases for the CD wait state
;
;*************************** Revision History *****************************
;
;  Date         Author             Description 
;  ----         ------             -----------
; 02 Jun 98    Varadarajan G       First Version
; 03 Jul 2000  N R Prasad          Ported on to Metrowerks
;
;******************************** TASK Q **********************************
;
;  V21_RxDemod
;  V21_RxCd
;  V21_Rxcdwait
;
;**************************** Assembly Code *******************************

        ORG     p:

V21_Rxcdw_Init
        move    #STATE1,x:v21_rxstid      ;First state
        move    #CDPRESENSE,x:v21_rxctr   ;Counter = 3
        move    #0,x:v21_cdflag 
        move    #0,x:first_zero_cross     ;This flag should be reset so that
        move    #0,x:Fg_v21_rx_decision_length
                                          ;  while recovering from carrier
                                          ;  drop zerocrossing is det. again
        bfclr   #CDBIT,x:Fg_v8bis_flags
        move    #DEFAULT_LOG2AGCG,x:v21_agcg
                                          ;Default Agcg = 0
        move    #v21_rxq,r3               ;Initialize the RXQ
        move    #V21_RxDemod,x0
        move    x0,x:(r3)+
        move    #V21_RxCd,x0
        move    x0,x:(r3)+
        move    #V21_Rxcdwait,x0
        move    x0,x:(r3)
End_V21_Rxcdw_Init
        rts

;****************************** Module ************************************
;
;  Module Name    : V21_Rxagc_Init
;  Author         : Varadarajan G
;
;************************** Module Description ****************************
;
;  Initialises for stabilising the filter states. This state is needed if
;  v21 state machine is entered in this state. If the filter states are not
;  stabilised before the zerocrossing detection algo is called then false
;  detection is possible
;
;*************************** Revision History *****************************
;
;  Date         Author             Description 
;  ----         ------             -----------
; 02 Jun 98    Varadarajan G       First Version
; 23 Jun 98    Varadarajan G       modified to make it a wait state
;                                  and the next state to agc gain comp stat
; 03 Jul 2000  N R Prasad          Ported on to Metrowerks
;
;******************************** TASK Q **********************************
;
;  V21_RxDemod
;  V21_RxCd
;  V21_Rxwait
;
;**************************** Assembly Code *******************************


V21_Rxagc_Init
        move    #STATE2,x:v21_rxstid
        move    #0,x:v21_acenergy         ;Accumulated energy = 0
        move    #0,x:v21_acenergy+1
        move    #STAB_FILST,x:v21_rxctr   ;STAB_FILST = 3
        move    #DEFAULT_LOG2AGCG,x:v21_agcg
        move    #v21_rxq,r3
        move    #V21_RxDemod,x0
        move    x0,x:(r3)+
        move    #V21_RxCd,x0
        move    x0,x:(r3)+
        move    #V21_Rxwait,x0
        move    x0,x:(r3)
End_V21_Rxagc_Init
        rts

;****************************** Module ************************************
;
;  Module Name    : V21_Rxagcfzc_Init
;  Author         : Varadarajan G
;
;************************** Module Description ****************************
;
;  Initialises for the agc gain computation state
;
;*************************** Revision History *****************************
;
;  Date         Author             Description 
;  ----         ------             -----------
; 23 Jun 98    Varadarajan G       First Version
; 03 Jul 2000  N R Prasad          Ported on to Metrowerks
;
;******************************** TASK Q **********************************
;
;  V21_RxDemod
;  V21_RxCd
;  V21_RxTimejam
;  V21_RxDecode
;  V21_Rxagc
;
;**************************** Assembly Code *******************************
V21_Rxagcfzc_Init
        move    #STATE3,x:v21_rxstid
        move    #(MAX_AGCLEN-STAB_FILST),x:v21_rxctr 
                                          ;MAX_AGCLEN = 16
        move    #DEF_ZERO_CROSS_IDX,x:zero_cross_index
                                          ;DEF_ZERO_CROSS_IDX = 6
        move    #DEFAULT_LOG2AGCG,x:v21_agcg
        move    #0,x:first_zero_cross
        move    #0,x:tau
        move    #0,x:Fg_v21_rx_decision_length
        move    #v21_rxq+2,r3
        move    #V21_RxTimejam,x0
        move    x0,x:(r3)+
        move    #V21_RxDecode,x0
        move    x0,x:(r3)+
        move    #V21_Rxagc,x0
        move    x0,x:(r3)
End_V21_Rxagcfzc_Init
        rts

;****************************** Module ************************************
;
;  Module Name    : V21_Rxfzc_Init
;  Author         : Varadarajan G
;
;************************** Module Description ****************************
;
;  Initialises for first zerocross detection state
;
;*************************** Revision History *****************************
;
;  Date         Author             Description 
;  ----         ------             -----------
; 02 Jun 1998  varadarajan G       First Version
; 03 Jul 2000  N R Prasad          Ported on to Metrowerks
;
;******************************** TASK Q **********************************
;
;  V21_RxDemod
;  V21_RxCd
;  V21_RxTimejam
;  V21_RxDecode
;  V21_RxFirstzc
;
;**************************** Assembly Code *******************************

V21_Rxfzc_Init
        move    #STATE4,x:v21_rxstid
        move    #V21_Rxfirstzc,x:v21_rxq+4
End_V21_Rxfzc_Init
        rts

;****************************** Module ************************************
;
;  Module Name    : V21_Rxdata
;  Author         : Varadarajan G
;
;************************** Module Description ****************************
;
;  Initialises for the data state
;
;*************************** Revision History *****************************
;
;  Date         Author             Description 
;  ----         ------             -----------
; 02 Jun 1998  Varadarajan G       First version
; 03 Jul 2000  N R Prasad          Ported on to Metrowerks
;
;******************************** TASK Q **********************************
;
;  V21_RxDemod
;  V21_RxCd
;  V21_RxTimrec
;  V21_RxDecode
;  V21_Rxdata
;
;**************************** Assembly Code *******************************

V21_Rxdat_Init
        move    #STATE5,x:v21_rxstid
        move    #MAX_CD_DROP_ALLD,x:v21_rxctr
                                          ;MAX_CD_DROP_ALLD = 30ms = 9
        move    #V21_RxTimrec,x:v21_rxq+2
        move    #V21_Rxdata,x:v21_rxq+4
End_V21_Rxdat_Init
        rts

        ENDSEC

;****************************** End of File *******************************
