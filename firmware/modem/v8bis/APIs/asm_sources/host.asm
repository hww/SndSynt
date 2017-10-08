;***********************************************************************
;
; Motorola India Electronics Ltd. (MIEL)
;
; PROJECT ID           : V.8 bis
;
; ASSEMBLER            : ASM56800 version 6.2.0
;
; FILE NAME            : host.asm
;
; PROGRAMMER           : Binuraj K R
;
; DATE CREATED         : 28:02:98
;
; FILE DESCRIPTION     : This function aids V8bis Init functions to
;                        look for proper initial conditions from the user
;                        or host   
;
; FUNCTIONS            : Fhost
;
; MACROS               : 
;
;************************************************************************ 

;***************************** Module ********************************
;
;  Module Name   :  Fhost 
;  Author        :  Binuraj K R
;
;*************************** Description *******************************
;
;       This module is normalises the input samples and adds gaurd bits
;       according to the DTMF design.
;  Calls:
;       Modules  :  Calc_Sig_En,Find_shift
;       Macro    : 
;
;************************** Revision History ***************************
;
;   Date                 Author              Description 
;  ------              ----------              ---------
;  28:02:98             Binuraj K R         Module Created 
;  04:07:2000           N R Prasad          Ported to Metrowerks 
;
;************************ Calling Requirements *************************


ERROR_MESSAGE                  equ  2
CONFIGURATION_MESSAGE          equ  1
INITIATE_TRANSACTION_MESSAGE   equ  5
NIL_RX_HOST_MESSAGE            equ  0
TX_GAIN_FACTOR_MESSAGE         equ  7
ACK1_BITSET                    equ  $0008

        SECTION HOST GLOBAL
        GLOBAL  Fhost
        GLOBAL  buffer
        GLOBAL  FDetect_ShortV8 
        GLOBAL  FDetect_V8 
        GLOBAL  FDetect_V25 

        org     x:

buffer          ds   64
        
        org     p:

Fhost:

        move    #0,x:Fg_rx_host_msg_type
        tstw    x:flag
        jne     _last
        decw    x:count
        jne     _next3
        move    #1,x:flag
_next3	
        move    x:buf_in_ptr,r0
        nop
        move    x:(r0)+,x0
        move    x0,x:Fg_rx_host_msg_type
        cmp     #NIL_RX_HOST_MESSAGE,x0
        jeq     _end
        cmp     #INITIATE_TRANSACTION_MESSAGE,x0
        jeq     _end
        move    #buffer,r1
        move    x:(r0)+,y0
        move    y0,x:(r1)+
        cmp     #CONFIGURATION_MESSAGE,x0
        jeq     _end
        cmp     #TX_GAIN_FACTOR_MESSAGE,x0
        jeq     _end
        nop
        do      y0,_next1
        move    x:(r0)+,y0
        move    y0,x:(r1)+
_next1
        nop
        nop
        nop
_end
        move    r0,x:buf_in_ptr
        move    #buffer,r0
        move    r0,x:Fg_rx_host_data_ptr
_last        
        nop
        rts

FDetect_ShortV8:

        move    #1,y0
        rts

FDetect_V8:

        move    #1,y0
        rts

FDetect_V25:

        move    #1,y0
        rts

	ENDSEC
