;**************************************************************************
;
;  Motorola India Electronics Ltd. (MIEL).
;
;  PROJECT ID           : V.8 bis
;
;  ASSEMBLER            : ASM56800 version 6.2.0
;
;  FILE NAME            : dsp_core_control.asm
;
;  PROGRAMMER           : B.S Shivashankar 
;
;  DATE CREATED         : 22/5/1998 
;
;  FILE DESCRIPTION     : This file consists dsp core control module, which
;                         calls modules to generate and detect signals and
;                         messages.
;
;  FUNCTIONS            : FDsp_Core_Control 
;
;  MACROS               : None
;
;*************************************************************************** 

        include "v8bis_equ.asm"
        
        SECTION dsp_core_control

        GLOBAL  FDsp_Core_Control

;****************************** Module ************************************
;
;  Module Name    : FDsp_Core_Control 
;  Author         : B.S Shivashankar 
;
;************************** Module Description ****************************
; This module calls the function to receive commands from statemachine. It
; calls signal generation, signal detection, message generation and message
; reception modules if appropriate flags are set. Finally it calls the 
; module to transmit DSP response to the state machine.
;
;
;  Calls :
;        Modules : FRx_Ctrl_Command
;                  FTx_Dsp_Response
;                  FSignal_Gen
;                  FSignal_Detect
;                  FMessage_Generation
;                  FMsg_Receive 
;
;        Macros  : None
;
;*************************** Revision History *****************************
;
;  Date         Author             Description 
;  ----         ------             -----------
;  22/05/98     B.S Shivashankar   Module Created 
;  17/08/98     B.S.Shivashankar   Incorporated Review Comments
;  03/07/2000   N R Prasad         Ported on to Metrowerks
;        
;************************* Calling Requirements ***************************
;
;  1. Initialize SP
;   
;************************** Input and Output ******************************
;
;  Input  : 
;          | iiii iiii | iiii iiii |   x:Fg_codec_tx_buf_ptr
;          | iiii iiii | iiii iiii |   x:Fg_codec_rx_buf_ptr
;          | iiii iiii | iiii iiii |   x:Fg_v8bis_flags     
;          | iiii iiii | iiii iiii |   x:Fv8_txgain    
;
;  Output :
;          | iiii iiii | iiii iiii |   x:Fg_codec_tx_buf_ptr
;          | iiii iiii | iiii iiii |   x:Fg_codec_rx_buf_ptr
;          | iiii iiii | iiii iiii |   x:Fg_samples_buf_ptr
;          | iiii iiii | iiii iiii |   x:Fg_v8bis_flags     
;          | 0000 0000 | iiii iiii |   x:Fv8_ssi_txctr     
;          | 0000 0000 | iiii iiii |   x:Fv8_ssi_rxctr     
;
;****************************** Resources *********************************
;
;  Registers Used:       x0,a,lc,r0,r1,m01 
;
;  Registers Changed:    x0,a,lc,r0,r1,m01
;                        
;  Number of locations 
;    of stack used:      2 
;
;  Number of DO Loops:   5               
;
;**************************** Assembly Code *******************************

        ORG     p:

FDsp_Core_Control

        jsr     FRx_Ctrl_Command          ;Go to Rx_Ctrl_Command module

;**************************************************************************
;
; If signal generation is enabled and the foreground isr has requested one
; buffer of samples, do the signal generation.
;
;**************************************************************************

;*************************************************************************
; Check the SIGNAL_GEN_ENABLE flag, if it is not set goto _msg_gen
; Check the SSI_TX_SAMPLES_RQST flag, if it is not set goto _msg_gen
; Clear the SSI_TX_SAMPLES_RQST flag
; Initialize g_samples_buf_ptr to fill up the generated samples.
; Initialize v8_ssi_txctr to 144.
;
;*************************************************************************

        brclr   #SIGNAL_GEN_ENABLE,x:Fg_v8bis_flags,_msg_gen
        brclr   #SSI_TX_SAMPLES_RQST,x:Fg_v8bis_flags,_sig_gen_end
        move    sr,x0
        bfset   #$0300,sr
        nop
        nop
        bfclr   #SSI_TX_SAMPLES_RQST,x:Fg_v8bis_flags
        move    #SAMPLES_PER_FRAME,y0
        add     y0,x:Fv8_ssi_txctr
        move    x0,sr
        move    #Fg_sig_samples_buffer,x:Fg_samples_buf_ptr
        jsr     FSignal_Gen
        move    x:Fv8_txgain,y0           ;Copy the gain factor to register
        move    #(CODEC_BUFFER_LENGTH-1),m01 
                                          ;Initalize the modulo buffer
        move    x:Fg_codec_tx_buf_ptr,r0  ;r0 <- Fg_codec_tx_buf_ptr
        move    r0,r2                     ;Pass r2 for local_tx_callback()
        move    #Fg_sig_samples_buffer,r1 ;r1 <- &Fg_sig_samples_buffer[0]
        move    #SAMPLES_PER_FRAME,lc
        do      lc,_loop1                 ;Copy the generated signal 
        move    x:(r1)+,x0                ;samples to codec tx buffer.
        mpyr     x0,y0,a                  ;multiply the samples with gain.
        move    a,x:(r0)+                
_loop1        
        move    r0,x:Fg_codec_tx_buf_ptr  ;save the codec pointer
        move    #-1,m01                   ;Reset to linear addressing
        move    #SAMPLES_PER_FRAME,y0     ;Pass y0
        jsr     Flocal_tx_callback        ;Give the generated samples to
                                          ; the user for transmission.
_sig_gen_end    
        jmp     _sig_det       


;**************************************************************************
;
; If message generation is enabled and the foreground isr has requested one
; buffer of samples, do the message generation.
; x:Fg_samples_buf_ptr contains the pointer, where the generated samples 
; are to be filled.
; Initialize v8_ssi_txctr to 24.
;
;**************************************************************************

_msg_gen

        brclr   #MESSAGE_GEN_ENABLE,x:Fg_v8bis_flags,_silence_gen
        brclr   #SSI_TX_SAMPLES_RQST,x:Fg_v8bis_flags,_msg_gen_end
        move    sr,x0
        bfset   #$0300,sr
        nop
        nop
        bfclr   #SSI_TX_SAMPLES_RQST,x:Fg_v8bis_flags
        move    #SAMPLES_PER_BAUD,y0
        add     y0,x:Fv8_ssi_txctr
        move    x0,sr
        move    #Fg_msg_samples_buffer,x:Fg_samples_buf_ptr
        jsr     FMessage_Generation
        move    x:Fv8_txgain,y0           ;Copy the gain factor to register
        move    #(CODEC_BUFFER_LENGTH-1),m01
                                          ;Initialize the modulo buffer
        move    x:Fg_codec_tx_buf_ptr,r0  ;r0 <- Fg_codec_tx_buf_ptr
        move    r0,r2                     ;Pass r2 for local_tx_callback ()
        move    #Fg_msg_samples_buffer,r1 ;r1 <- &Fg_msg_samples_buffer[0]
        do      #SAMPLES_PER_BAUD,_loop2  ;Copy the generated message
        move    x:(r1)+,x0                ;samples to codec tx buffer.
        mpyr    x0,y0,a                   ;multiply the samples with gain
        move    a,x:(r0)+                 
_loop2        
        move    r0,x:Fg_codec_tx_buf_ptr  ;save the codec pointer
        move    #-1,m01                   ;Reset to linear addressing
        move    #SAMPLES_PER_BAUD,y0      ;Pass y0
        jsr     Flocal_tx_callback        ;Give the generated samples to
                                          ; the user for transmission.
_msg_gen_end    
        jmp     _sig_det       

;**************************************************************************
;
; If both signal and message generation is disabled, Do silence generation.
;
;**************************************************************************
        
_silence_gen        
        
        brclr   #SSI_TX_SAMPLES_RQST,x:Fg_v8bis_flags,_sig_det
        move    sr,x0
        bfset   #$0300,sr
        nop
        nop
        bfclr   #SSI_TX_SAMPLES_RQST,x:Fg_v8bis_flags
        move    #SAMPLES_PER_BAUD,y0      ;Also pass y0
        add     y0,x:Fv8_ssi_txctr
        move    x0,sr
        move    #(CODEC_BUFFER_LENGTH-1),m01 
                                          ;Initalize the modulo buffer
        move    x:Fg_codec_tx_buf_ptr,r0  ;r0 <- Fg_codec_tx_buf_ptr
        move    r0,r2                     ;Pass r2 for local_tx_callback()
        clr     a
        move    #SAMPLES_PER_BAUD,lc
        do      lc,_sil_loop                
        move    a,x:(r0)+                
_sil_loop        
        move    r0,x:Fg_codec_tx_buf_ptr  ;save the codec pointer
        move    #-1,m01                   ;Reset to linear addressing
        jsr     Flocal_tx_callback        ;Give the generated samples to
                                          ; the user for transmission.

;**************************************************************************
;
; If signal detection is enabled and one buffer of input samples is ready
; for processing, do the signal detection. 
; x:Fg_samples_buf_ptr contains the pointer, where the input samples are
; stored.
; Initialize v8_ssi_rxctr to 144.
;
;**************************************************************************

_sig_det        

        brclr   #SIGNAL_DETECT_ENABLE,x:Fg_v8bis_flags,_msg_recpt
        brclr   #SSI_RX_SAMPLES_READY,x:Fg_v8bis_flags,_msg_recpt
        move    sr,x0
        bfset   #$0300,sr
        nop
        nop
        bfclr   #SSI_RX_SAMPLES_READY,x:Fg_v8bis_flags
        move    #SAMPLES_PER_FRAME,y0
        add     y0,x:Fv8_ssi_rxctr
        move    x0,sr

;*************************************************************************
; Clear the first 8 locations of Fg_sig_samples_buffer, and copy the 
; received signal samples from 9th location. This is the calling 
; requirement for signal detection module.
;*************************************************************************

        move    #Fg_sig_samples_buffer,r1 ;r1 <- &Fg_sig_samples_buffer[0]
        clr     a
        do      #8,_next
        move    a,x:(r1)+
_next   
                                          ;r1 <- &Fg_sig_samples_buffer[8]
        move    #(CODEC_BUFFER_LENGTH-1),m01
        move    x:Fg_codec_rx_buf_ptr,r0  ;r0 <- Fg_codec_rx_buf_ptr
        move    #SAMPLES_PER_FRAME,lc
        do      lc,_loop3                 ;Copy the received signal samples
        move    x:(r0)+,x0                ;to Fg_sig_samples_buffer
        move    x0,x:(r1)+
_loop3        
        move    r0,x:Fg_codec_rx_buf_ptr  ;save the codec pointer
        move    #-1,m01                   ;Reset to linear addressing

;*************************************************************************
; x:Fg_samples_buf_ptr <- &Fg_sig_samples_buffer[8]
; Call the signal detection module
;*************************************************************************

        move    #Fg_sig_samples_buffer+8,x:Fg_samples_buf_ptr
        jsr     FSignal_Detect               

;**************************************************************************
;
; If message reception is enabled and one buffer of input samples is ready
; for processing, do the message reception. 
; x:Fg_samples_buf_ptr contains the pointer, where the input samples are
; stored.
; Initialize v8_ssi_rxctr to 24. 
;
;**************************************************************************

_msg_recpt

        brclr   #MESSAGE_RECEPTION_ENABLE,x:Fg_v8bis_flags,_end
        brclr   #SSI_RX_SAMPLES_READY,x:Fg_v8bis_flags,_end
        move    sr,x0
        bfset   #$0300,sr
        nop
        nop
        bfclr   #SSI_RX_SAMPLES_READY,x:Fg_v8bis_flags
        move    #SAMPLES_PER_BAUD,y0
        add     y0,x:Fv8_ssi_rxctr
        move    x0,sr
        move    #(CODEC_BUFFER_LENGTH-1),m01
        move    x:Fg_codec_rx_buf_ptr,r0  ;r0 <- x:Fg_codec_rx_buf_ptr
        move    #Fg_msg_samples_buffer,r1 ;r1 <- &Fg_msg_samples_buffer[0]
        do      #SAMPLES_PER_BAUD,_loop4  ;Copy the received message samples
        move    x:(r0)+,x0                ;to Fg_msg_samples_buffer.
        move    x0,x:(r1)+
_loop4        
        move    r0,x:Fg_codec_rx_buf_ptr  ;Save the codec pointer
        move    #-1,m01                   ;Reset to linear addressing
        move    #Fg_msg_samples_buffer,x:Fg_samples_buf_ptr
        jsr     FMsg_Receive
_end
        jsr     FTx_Dsp_Response          ;Go to Tx_Dsp_Response
        rts

        ENDSEC


;**************************** End of File***********************************
