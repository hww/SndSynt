;**************************************************************************
;
;   (C) Motorola India Electronics Ltd.
;
;   Project Name    : CallerID detection
;
;   Original Author : Meera S. P.
;
;   Module Name     : cid_process.asm
;
;**************************************************************************
;
;   Date            : 11 May 2000
;
;
;**************************************************************************
;
;   PROCESSOR       : 568xx
;
;**************************************************************************
;
;   DESCRIPTION  : This module is an interface module for all low level
;                  caller ID signal detection modules
;
;**************************************************************************


        SECTION  CALLER_ID GLOBAL
        GLOBAL   FCallerID_Process

        include 'cid_equ.inc'

PASSED  equ     0
FAILED  equ     -1

     
        org     p:


FCallerID_Process

        move    x:CID_sampleptr,r0
        nop
        move    y0,x:(r0)+
        move    r0,x:CID_sampleptr
        decw    x:CID_samplecounter
        beq     process_samples
 
        rts
        
        
process_samples
        move    #20,x:CID_samplecounter
        move    #CID_samplebuffer,x:CID_sampleptr
                
        move    #CID_samplebuffer,y0        
        lea     (sp)+
        move    y0,x:(sp)+
        
        jsr     CID_FRAME_PROCESS
        
        pop     y0                    ;Get x:CID_STATUS
        pop     r0                    ;Dummy to clear the stack

        rts
        
                
        ENDSEC
