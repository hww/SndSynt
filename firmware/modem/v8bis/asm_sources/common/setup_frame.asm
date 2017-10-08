;************************************************************************
;
; Motorola India Electronics Ltd. (MIEL).
;
; PROJECT ID           : V.8 bis
;
; ASSEMBLER            : ASM56800 version 6.2.0
;
; FILE NAME            : Setup_Frame.asm
;
; PROGRAMMER           : Varadarajan G
;
; DATE CREATED         : 12 Jun 1998
; 
; FILE DESCRIPTION     : Setting up a frame for processing. 
;
; FUNCTIONS            : Setup_Frame
;
; MACROS               : None
;
;************************************************************************
        
        include "v8bis_equ.asm"
        include "periph_equ.asm"
        
        SECTION Setup_Frame GLOBAL

        GLOBAL  Setup_Frame
      
              
;****************************** Module ************************************
;
;  Module Name    : Setup_Frame
;  Author         : Varadarajan G
;
;************************** Module Description ****************************
;
;  This module reads a sample from the received input buffer into the rx
;  buffer.
;
;*************************** Revision History *****************************
;
;  Date         Author             Description 
;  ----         ------             -----------
; 15 Jun 1998  Varadarajan G.      First version.
; 17 Jun 1998  Varadarajan G,      Updated to have two diff. counters/flgs
;                                  for tx and rx.
; 21 Jul 1998  Varadarajan G.      Set flag to indicate the expiry of
;                                  5 sec. counter.
; 03 Jul 2000  N R Prasad          Ported on to Metrowerks.
; 23 Aug 2000  N R Prasad, Sanjay  Converted the ISR into function;
;                                  removed the transmit and receive
;                                  part from the code.
;
;************************** Input and Output ******************************
;
;  Input  :
;        Tx word       = | ssff ffff | ffff ffff | -> x:codec_tx_ptr
;        smpls/baud ctr
;        or smpls/frame
;        for Rx        = | 0000 0000 | iiii iiii | x:Fv8_ssi_rxctr
;        smpls/baud ctr
;        or smpls/frame
;        for Tx        = | 0000 0000 | iiii iiii | x:Fv8_ssi_txctr
;        Flag for baud
;        frame rqst    = | 0000 0000 | 0000 000i | x:Fg_v8bis_flags
;        5sec timeout  = | iiii iiii | iiii iiii | x:Fv_timeout_counter
;  Output :
;        Rx Word       = | sfff ffff | ffff ffff | -> x:codec_rx_ptr
;        smpls/baud ctr
;        or smpls/frame
;        for Rx        = | 0000 0000 | iiii iiii | x:Fv8_ssi_rxctr
;        smpls/baud ctr
;        or smpls/frame
;        for Tx        = | 0000 0000 | iiii iiii | x:Fv8_ssi_txctr
;        Flag for baud
;        frame rqst    = | 0000 0000 | 0000 000i | x:Fg_v8bis_flags
;****************************** Resources *********************************
;
;  Registers Used:       x0,r0,m01
;
;  Registers Changed:    x0,r0,m01
;                        
;  Number of DO Loops:   None          
;
;**************************** Assembly Code *******************************

        ORG     P:

FSetup_Frame        

        lea     (sp)+
        move    r0,x:(sp)+                ;Save Context
        move    x0,x:(sp)+
        move    m01,x:(sp)
        decw    x:Fv_timeout_counter      ;Decrement the 5sec timeout timer
        bne     _ctr_notexpired
        bfset   #FIVE_SECONDS_COUNTER,x:(Fg_v8bis_flags+1)
_ctr_notexpired                           ;Indicate expiry of 5sec ctr
        move    x:codec_rx_wptr,r0
        move    #(CODEC_BUFFER_LENGTH-1),m01
        move    x:(r2),x0                 ;Receive the sample    

        move    x0,x:(r0)+                ;Write into the codec interface
        move    r0,x:codec_rx_wptr        ;  buffer
        decw    x:Fv8_ssi_rxctr           ;If baud/frame length of samples
        bne     _tx_sample                ;  are rcvd., set request for Rx
                                          ;  baud/frame processing
        bfset   #SSI_RX_SAMPLES_READY,x:Fg_v8bis_flags
_tx_sample

        decw    x:Fv8_ssi_txctr           ;If baud/frame length of samples
        bne     End_Setup_Frame           ;  hv been txed., set request for
                                          ;  Tx baud/frame processing
        bfset   #SSI_TX_SAMPLES_RQST,x:Fg_v8bis_flags
End_Setup_Frame
        pop     m01
        pop     x0
        pop     r0                        ;Restore Context
        rts

        ENDSEC
;****************************** End of File *******************************
