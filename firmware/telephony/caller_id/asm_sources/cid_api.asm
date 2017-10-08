;**************************************************************************
;
;   (C) Motorola India Electronics Ltd.
;
;   Project Name    : CallerID detection
;
;   Original Author : Meera S. P.
;
;   Module Name     : cid_api.asm
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
;   DESCRIPTION  : This module contains functions those call the signal
;                  Caller ID signal detection modules
;
;**************************************************************************


        opt     CC,MEX,NOPP
        page    132


        SECTION CALLER_ID GLOBAL
	
    	include 'cid_equ.inc'           ; CID constant definitions

;------------------------------------------------------------------------------
; External Routine Definitions
;------------------------------------------------------------------------------
	     org     p:


        global    CID_START_ONHOOK
        global    CID_START_OFFHOOK
        global    CID_FRAME_PROCESS


;------------------------------------------------------------------------------
; Local Static Variable Definitions
;------------------------------------------------------------------------------
	org     x:

CID_TIMER_CNT     ds    1
CID_WAIT_TMR      ds    1              ;Timer to count 1.4sec in CSS state
CID_DATA_BUFF     ds    CID_DATA_SIZE  ;To store the received data bytes
FCID_DATA_BUFF    equ   CID_DATA_BUFF
CID_DATA_OUT_PTR  ds    1              ;For use in CIDFETCH_DATA

;------------------------------------------------------------------------------
; Local Scratch Variable Definitions
;------------------------------------------------------------------------------
	org     x:

CID_loop_cnt      ds    1 

;------------------------------------------------------------------------------
; Local defines
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; Module Code
;------------------------------------------------------------------------------
        org     p:


;------------------------------------------------------------------------------
; Routine:      CID_START_ONHOOK (decision_del)
;
; Description:
;	This routine sets up the state of the Caller ID module for ON HOOK
;	caller ID protocol. And also initializes the static variables used
;       by Caller ID. Also read calling requirements
;
;       For  details see the design document.
;
; Stack Parameters:     
;
;       ------------
;            PC         x:(sp-1)
;       ------------
;            SR         x:(sp)
;       ------------
;
; Other Input/Output:
;
;       Input:          N/A
;
;       Output:         N/A
;
;       Return Value:   N/A
;
; Calling Requirements:
;        This module should be called after detecting the power ring and
;        a minimum silence of 230msec (250 according to spec), for all power rings.
;        It is also to be called immediately after the CPE goes offhook.
;        This is because SPCS transmits CID if CPE was aborted in the last ONHOOK
;        state.
;
; Pseudocode:
;	set ONHOOK in CID_STATUS variable
;	Set CSS_SIL_TMR to 1.4 sec to check the presence of CID
;	set CID_ACTIVE in TELE_STATUS variable
;	call REPORT_CID_ACTIVE
;	call IO_SETUP_CID to set codec io bits correctly
;
; NOTE: The position of first 2 instructions should not be changed
;
;------------------------------------------------------------------------------

CID_START_ONHOOK:

	move    #CID_DATA_BUFF,x:CID_DATA_BUFF_PTR
                					 ;This pointer is for data storage
	jsr     CID_LOW_INIT             ;Init all CID static variables
	bfset   #CID_ONHOOK,x:CID_STATUS ;Set to indicate on hook state
	bfclr   #CID_PRESENT,x:CID_STATUS
	move    #CID_CSS_SIL,x:CID_WAIT_TMR
				                	 ;560 frames delay = 1.4sec
	move    #CID_ON_TIM_MAX,x:CID_TIMER_CNT
	jsr     CID_ONHOOK_INIT          ;Initialise variables for onhook

    rts



;------------------------------------------------------------------------------
; Routine:      CID_START_OFFHOOK
;
; Description:
;	This routine sets up the state of the Caller ID module for OFF HOOK
;	caller ID protocol. It also initialised the static variables used
;       by Caller ID
;
;       For  details see the design document.
;
; Stack Parameters:     N/A
;
; Other Input/Output:
;
;       Input:          N/A
;
;       Output:         N/A
;
;       Return Value:   N/A
;
; Calling Requirements:
;       This module needs to be called once in the beginning everytime a fresh 
;       CID in the OFFHOOK is expected
;
; Pseudocode:
;	set   OFFHOOK in CID_STATUS variable
;       call  CID_LOW_INIT to initialise CID static variables
;       call  CID_OFFHOOK_INIT to initialise OFFHOOK state specific
;             variables
;
; NOTE: The position of first 2 instructions should not be changed
;
;------------------------------------------------------------------------------

CID_START_OFFHOOK:

	move    #CID_DATA_BUFF,x:CID_DATA_BUFF_PTR
					 ;This pointer is for data storage
	jsr     CID_LOW_INIT             ;Init all CID static variables

	bfclr   #CID_ONHOOK,x:CID_STATUS ;Indicate offhook status
	move    #CID_OFFHOOK_WAIT,x:CID_WAIT_TMR
	move    #CID_OFF_TIM_MAX,x:CID_TIMER_CNT
					 ;Max period to receive data
	jsr     CID_OFFHOOK_INIT         ;Offhook statics init

	rts



;------------------------------------------------------------------------------
; Routine:      CID_FRAME_PROCESS (input_buffer,status_word)
;
; Description:
;	This routine implements the processing for a frame of input data,
;	including tracking the state of the ongoing caller ID protocol.
;
;       For  details see the design document.
;
; Stack Parameters:     
;       ------------
;        input_buffer   x:(sp-3)    ;It is also an o/p of this module. It 
;                                   ;  contains the pointer to the CID
;                                   ;  data buffer
;       ------------
;        status_word    x:(sp-2)
;       ------------
;            PC         x:(sp-1)
;       ------------
;            SR         x:(sp)
;       ------------
;
; Other Input/Output:
;
;       Input:          N/A
;
;       Output:         N/A
;
;       Return Value:   status_word return values are:
;				$0000 = no change in status
;				$0001 = CID_COMPL_STAT, CID process complete
;				$0002 = CID_TMOUT_STAT, CID process timeout
;					(only applies to on-hook CID)
;                               $0004 = CID_ERROR
;
; Pseudocode:
;	call CID receiver routine (multiple times) to service input buffer 
;		of 160 samples
;		Track state of CID protocol in states:
;		WAIT - waiting for start of CID protocol, only in on-hook CID
;		CSS - alternating mark and space bits to acquire channel
;		MARK - mark bits sent before data
;		INFO - FSK data being received
;		NO CARRIER - completion of FSK data reception detected
;		CHECKSUM - calculating and checking checksum
;	put bytes to CID data buffer as they are received
;	return status of CID protocol in status_word, esp. the complete indic.
;
;------------------------------------------------------------------------------

CID_FRAME_PROCESS:

	;define stack positions of routine parameters
	
    define  SP_input_buffer   'x:(sp-3)'
	define  SP_status_word    'x:(sp-2)'

	move    SP_input_buffer,x0

_process_frames
	move    x0,x:CID_SMPL_OUT_PTR    ;Pointer to be used by Caller ID
	jsr     CID_CTRL                 ;Call receiver 
	brset   #CID_DATA_READY,x:CID_STATUS,_end_cid
				         ;If reception complete, exit
    brset   #CID_CAR_ON,x:CID_STATUS,_continue_cid
	brset   #CID_PRESENT,x:CID_STATUS,_continue_onhook
    decw    x:CID_WAIT_TMR
	bgt     _still_in_wait
	bfset   #(CID_ERROR|NO_CID_TX),x:CID_STATUS
					 ;No CID tx from SPCS
	bra     _end_cid


_continue_cid
	bfset   #CID_PRESENT,x:CID_STATUS ;Carrier is detected atleast 1s

_continue_offhook
_continue_onhook
_still_in_wait
	brset   #CID_ERROR,x:CID_STATUS,_end_cid
					 ;If cid_error then exit
	decw    x:CID_TIMER_CNT
	bgt     _time_not_expired
	bfset   #(CID_ERROR|CID_TIME_EXPIRE),x:CID_STATUS
	bra     _end_cid                 ;  time expired
_time_not_expired
 	move    x:CID_SMPL_OUT_PTR,x0

_end_cid
	move    x:CID_STATUS,x0         
	move    #CID_DATA_BUFF,y0        ;Pass the CID data buffer beginning
	move    y0,SP_input_buffer       ;  to DTAD main
	move    x0,SP_status_word        ;Return the status at frame
                                         ;  interval
	rts

	;define stack positions of routine parameters
	undef   SP_input_buffer
	undef   SP_status_word


    ENDSEC
