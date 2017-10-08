;**************************************************************************
;
;   (C) Motorola India Electronics Ltd.
;
;   Project Name    : CallerID detection
;
;   Original Author : Meera S. P.
;
;   Module Name     : cid_init.asm
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
;   DESCRIPTION  : This module initializes all static variables used by
;                  the caller ID routines
;
;**************************************************************************


        SECTION CallerID_Init GLOBAL

         GLOBAL   FCallerID_Init

PASS    equ     0
FAIL    equ     -1

        org     p:

FCallerID_Init
 
        lea     (sp)+
        move    OMR,x:(sp)
        bfclr   #$0100,OMR                          ; set saturation mode off
        tstw    y0
        bne     off_hook_init 
        jsr     CID_START_ONHOOK
        bra     CallerID__Init_End
        
off_hook_init
        jsr     CID_START_OFFHOOK

CallerID__Init_End
        
        pop     OMR
        move    #PASS,y0
        
        rts
       
        ENDSEC