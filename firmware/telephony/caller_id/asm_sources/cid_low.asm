;**************************************************************************
;
;   (C) Motorola India Electronics Ltd.
;
;   Project Name    : CallerID detection
;
;   Original Author : Meera S. P.
;
;   Module Name     : cid_low.asm
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
;   DESCRIPTION  : This module contains all the functions which implement
;                  Caller ID signal detection
;
;**************************************************************************

        include 'cid_dc.asm'


        SECTION CID_LOW 
        
    	include 'cid_equ.inc'

;-------------------------------------------------------------------------
; External Routine Definitions
;-------------------------------------------------------------------------
        org p:

	; ----Low level Function Prototypes ----;

       
	global    CID_LOW_INIT
	global    CID_CTRL
	global    CID_MARK_INIT
	global    CID_ONHOOK_INIT
	global    CID_OFFHOOK_INIT
    global    CID_CSS_INIT
    global    CID_INFO_INIT
    global    CID_ENER_CAL
    global    CID_CPFSK_DEMOD
    global    CID_DC_ADJUST
    global    CID_AMP_ADJUST
    global    CID_FIND_ZERO_CROSS
    global    CID_GET_REMAIN_BITS
    global    CID_DC_SUB
    global    CID_DATA_HANDLER
;-------------------------------------------------------------------------
; External Variable References 
;-------------------------------------------------------------------------
	org     x:


;-------------------------------------------------------------------------
; External Variable Definitions 
;-------------------------------------------------------------------------
	org     x:


	global    CID_DATA_BUFF_PTR
	global    CID_SMPL_OUT_PTR
	global    CID_STATUS

;-------------------------------------------------------------------------
; Local Static Variable Definitions
;-------------------------------------------------------------------------
	org     x:



        ;--- CID Receiver scratch variables ---;
;************************************************************************
;*  FOR CW
;************************************************************************
             GLOBAL   CID_SMPL_GRID
             GLOBAL   CID_OFST_9OR10
             GLOBAL   CID_LMT_9OR10
             GLOBAL   CID_CAR_SUM1
             GLOBAL   CID_CAR_SUM2
             GLOBAL   CID_FRAME_CNT
             GLOBAL   CID_DATA_BYTE
             GLOBAL   CID_CSS_CNT
             GLOBAL   CID_CSS_ERR_CNT
             GLOBAL   CID_MARK_CNT
             GLOBAL   CID_DC_FRM_CNT
             GLOBAL   CID_CODEC_IGAIN
             GLOBAL   CID_MARK_ERR_CNT
             GLOBAL   CID_BITS_REG
             GLOBAL   CID_BITS_CNT
             GLOBAL   CID_CRC_WORD
             GLOBAL   CID_FRM_LEN
             GLOBAL   CID_BYTE_CNT
             GLOBAL   CID_FRM_STG
             GLOBAL   CID_ZERO_CROSS
             GLOBAL   CID_AMP_FRM_CNT
             GLOBAL   CID_SILEN_THRES

             GLOBAL   CID_DC_SUM2
             GLOBAL   CID_DC_SUM1
             GLOBAL   CID_DC_SUM0
             GLOBAL   CID_DC_VAL

             GLOBAL   CID_SIN1_DLY_BUFF
             GLOBAL   CID_SIN1_DLY_PTR
             GLOBAL   CID_COS1_DLY_PTR
             GLOBAL   CID_COS1_DLY_BUFF
             GLOBAL   CID_SIN0_DLY_PTR
             GLOBAL   CID_COS0_DLY_PTR
             GLOBAL   CID_SIN0_DLY_BUFF
             GLOBAL   CID_SMPL_OUT_PTR
             GLOBAL   CID_COS0_DLY_BUFF
             GLOBAL   CID_AVER_PTR
             GLOBAL   CID_AVER_BUFF
             GLOBAL   CID_ENER_BUFF_PTR
             GLOBAL   CID_DATA_BUFF_CNT
             GLOBAL   CID_STATE
             GLOBAL   CID_STATUS
             GLOBAL   CID_PREV_ENER
             GLOBAL   CID_PREV_EXTREME
             GLOBAL   CID_DATA_TMP_PTR
             GLOBAL   CID_samplecounter
             GLOBAL   CID_samplebuffer
             GLOBAL   CID_sampleptr

;************************************************************************
;*  END CW
;************************************************************************
CID_SMPL_GRID     ds    3
CID_mem_bgn       equ   CID_SMPL_GRID
CID_PREV_ENER     ds    21
CID_ENER_BUFF     equ   CID_PREV_ENER+1
CID_PREV_EXTREME  ds    4
CID_THREE_EXTREMA equ   CID_PREV_EXTREME+1
CID_OFST_9OR10    ds    1
CID_LMT_9OR10     ds    1
CID_CAR_SUM1      ds    1
CID_CAR_SUM2      ds    1
CID_FRAME_CNT     ds    1
CID_DATA_BYTE     ds    1
CID_CSS_CNT       ds    1
CID_CSS_ERR_CNT   ds    1
CID_MARK_CNT      ds    1
CID_DC_FRM_CNT    ds    1
CID_CODEC_IGAIN   ds    1
CID_MARK_ERR_CNT  ds    1
CID_BITS_REG      ds    1
CID_BITS_CNT      ds    1
CID_CRC_WORD      ds    1
CID_FRM_LEN       ds    1
CID_BYTE_CNT      ds    1
CID_FRM_STG       ds    1
CID_ZERO_CROSS    ds    1
CID_AMP_FRM_CNT   ds    1
CID_SILEN_THRES   ds    1

CID_DC_SUM2       ds    1          ;from sanjay 3 locs
CID_DC_SUM1       ds    1
CID_DC_SUM0       ds    1
CID_DC_VAL        ds    1

CID_SIN1_DLY_BUFF dsm   6
CID_SIN1_DLY_PTR  ds    1
CID_COS1_DLY_PTR  ds    1
CID_COS1_DLY_BUFF dsm   6
CID_SIN0_DLY_PTR  ds    1
CID_COS0_DLY_PTR  ds    1
CID_SIN0_DLY_BUFF dsm   6
CID_SMPL_OUT_PTR  ds    1
CID_COS0_DLY_BUFF dsm   6
CID_AVER_PTR      ds    1
CID_AVER_BUFF     dsm   6
CID_ENER_BUFF_PTR ds    1
CID_DATA_BUFF_CNT ds    1
CID_STATE         ds    1 
CID_STATUS        ds    1
CID_samplecounter ds    1
CID_samplebuffer  ds    20
CID_sampleptr     ds    1
CID_mem_end     equ   *

CID_mem_len     equ   CID_mem_end-CID_mem_bgn

;************************************************************************
;*  FOR CW
;************************************************************************
CID_SMPL_GRID_1   equ   CID_SMPL_GRID+1
CID_SMPL_GRID_2   equ   CID_SMPL_GRID+2
CID_ENER_BUFF_3   equ   CID_ENER_BUFF+3
CID_ENER_BUFF_9   equ   CID_ENER_BUFF+9
CID_ENER_BUFF_16  equ   CID_ENER_BUFF+16
CID_ENER_BUFF_19  equ   CID_ENER_BUFF+19
CID_THREE_EXTREMA_2 equ CID_THREE_EXTREMA+2
;************************************************************************
;*  END CW
;************************************************************************


CID_DATA_BUFF_PTR ds    1          ;CID receive data buffer pointers
CID_DATA_TMP_PTR  ds    1


;-------------------------------------------------------------------------
; Local Scratch Variable Definitions
;-------------------------------------------------------------------------
	org     x:


	org      p:

;-------------------------------------------------------------------------
; Routine:      CID_LOW_INIT
;
; Description:
;	This routine initializes the state of the Caller ID module after
;         RESET
;       Initialises all the variables needed for Caller ID
;;
; Stack Parameters:     N/A
;
; Other Input/Output:
;
;       Input:          x:CID_DATA_BUFF_PTR -> CID receive buffer
;
;       Output:         N/A
;
;       Return Value:   N/A
;
; Functions called:     N/A
;
; Pseudocode:
;	clear all timers and CID state variables
;
;-------------------------------------------------------------------------

CID_LOW_INIT:

        move    #CID_mem_bgn,r0    ;Initialising locs of CID_SCRATCH
        move    #-1,m01
        clr     a
        move    #CID_mem_len,x0
        do      x0,_clear_static   ;To allow interrupts
        move    a,x:(r0)+
_clear_static

    ;Initialize the sample buffer pointer
        move    #CID_samplebuffer,x:CID_sampleptr
        move    #20,x:CID_samplecounter
        
	;Initialise all delay line buffers/pointers 
        move    #CID_SIN1_DLY_BUFF,x:CID_SIN1_DLY_PTR
        move    #CID_SIN0_DLY_BUFF,x:CID_SIN0_DLY_PTR
        move    #CID_COS1_DLY_BUFF,x:CID_COS1_DLY_PTR
        move    #CID_COS0_DLY_BUFF,x:CID_COS0_DLY_PTR
        move    #CID_AVER_BUFF,x:CID_AVER_PTR
        move    #CID_ENER_BUFF,x:CID_ENER_BUFF_PTR
    	move    x:CID_DATA_BUFF_PTR,x0
        move    x0,x:CID_DATA_TMP_PTR
        
        move    #CID_ENER_THRES,x:CID_SILEN_THRES
        move    #10,x:CID_LMT_9OR10
        move    #9,x:CID_OFST_9OR10
        move    #CID_INIT_GAIN,x:CID_CODEC_IGAIN
;************************************************************************
;*  FOR CW
;************************************************************************
;       move    #$8000,x:(CID_THREE_EXTREMA+2)
        move    #$8000,x:CID_THREE_EXTREMA_2
        move    #CID_TYPE,x:CID_FRM_STG          ;Next msg starts from type
;************************************************************************
;*  FOR CW
;************************************************************************
;       move    #(CID_ENER_BUFF+3),x0
        move    #CID_ENER_BUFF_3,x0
        move    x0,x:CID_SMPL_GRID
;************************************************************************
;*  FOR CW
;************************************************************************
;       move    #(CID_ENER_BUFF+9),x0
;       move    x0,x:(CID_SMPL_GRID+1)
        move    #CID_ENER_BUFF_9,x0
        move    x0,x:CID_SMPL_GRID_1
;************************************************************************
;*  FOR CW
;************************************************************************
;       move    #(CID_ENER_BUFF+16),x0
;       move    x0,x:(CID_SMPL_GRID+2)
        move    #CID_ENER_BUFF_16,x0
        move    x0,x:CID_SMPL_GRID_2

	rts

     
CID_ONHOOK_INIT
        jsr     CID_CSS_INIT               ;Go into CSS state
	rts

CID_OFFHOOK_INIT
        jsr     CID_PREMARK_INIT
        rts
        


;**************************************************************************
;
;   MODULE NAME     : CID_CSS_INIT, CID_MARK_INIT and CID_INFO_INIT
;                     CID_PREMARK_INIT
;
;**************************************************************************
;
;   DESCRIPTION  : Initialises different variables to enter CSS state, 
;                  MARK state and Info state.
;
;**************************************************************************
        
CID_CSS_INIT

        move    #CID_CSS_STATE,x:CID_STATE
        move    #0,x:CID_CSS_CNT
        move    #0,x:CID_CSS_ERR_CNT
        move    #0,x:CID_MARK_CNT
        move    #CID_AMP_ADJ_FRAMES,x:CID_AMP_FRM_CNT
        move    #CID_DC_ADJ_FRAMES,x:CID_DC_FRM_CNT
        move    #0,x:CID_DC_SUM0
        move    #0,x:CID_DC_SUM1
        move    #0,x:CID_DC_SUM2
        rts
        
        

CID_MARK_INIT

        move    #CID_MARK_STATE,x:CID_STATE
        move    #0,x:CID_MARK_ERR_CNT
        bfclr   #CID_SEARCH_START,x:CID_STATUS
        move    #CID_ON_MARK_MAX,x0
        brset   #CID_ONHOOK,x:CID_STATUS,CID_On_Mark
        move    #CID_OFF_MARK_MAX,x0
CID_On_Mark
        move    x0,x:CID_MARK_CNT
        rts
        


CID_INFO_INIT
        move    #CID_INFO_STATE,x:CID_STATE
        rts

        

CID_PREMARK_INIT
	    move    #CID_DC_OFFHOOK_DEFAULT,x:CID_DC_VAL
        move    #CID_PREMARK_STATE,x:CID_STATE
        move    #0,x:CID_MARK_CNT
        rts



;**************************************************************************
;
;   MODULE NAME     : CID_CTRL
;
;**************************************************************************
;
;   DESCRIPTION  : 
;                  This is the main controller module for Caller ID 
;                  receiver. It calls demodulator, amplitude adjust,
;                  DC adjust and other functions to detect the raw bits.
;                  It then verifies the message against received checksum
;                  and returns CID_STATUS every frame of 20 samples at
;                  8KHz.
;
;**************************************************************************
;
;   INPUT         - None
; 
;   OUTPUT        - None
;
;   UPDATE        - 
;                  
;   READ          -
;
;   MODULES 
;    CALLED       - CID_CPFSK_DEMOD, CID_AMP_ADJUST, CID_DC_ADJUST,
;                   CID_VAL_CSS, CID_FIND_ZERO_CROSS, CID_DC_SUB,
;                   CID_GET_SBIT, CID_MARK_INIT, CID_INFO_INIT,
;                   CID_READ_BIT
;
;   CALLING
;    REQUIREMENTS - 
;
;
;**************************************************************************

CID_CTRL
        
        move    x:CID_ENER_BUFF_19,x0     ;Store the last energy value

        move    x0,x:CID_PREV_ENER        ;  before we get new values
        
        jsr     CID_CPFSK_DEMOD           ;Demodulate the codec samples
        
        brset   #CID_CAR_ON,x:CID_STATUS,_process_frame
                                          ;Process frame if carrier
        rts                               ;No carrier, return

_process_frame
        bftsth  #CID_CSS_STATE,x:CID_STATE
                                          ;If not in CSS state,
        jcc     _may_be_mark              ;  check for mark state
_css_state                                ;If CSS state,

        tstw    x:CID_AMP_FRM_CNT         ;Check if amp-adjust cnt
        beq     _next1                    ;  is on, if not, go to next
        decw    x:CID_AMP_FRM_CNT
        jsr     CID_VAL_CSS               ;Validate CSS before amp adjust
                                          ;If invalid AMP_CNT is reset to
                                          ;  initial value
_next0
        move    #2,x0
        cmp     x:CID_AMP_FRM_CNT,x0      ;Check the cnt for 1
        jne     _cid_frm_over             ;  if not 1, go to next1
        jsr     CID_AMP_ADJUST            ;Else, call amp-adjust rtn
        jmp     _cid_frm_over
_next1
        tstw    x:CID_DC_FRM_CNT          ;Check if dc-adjust cnt
        beq     _next2                    ;  is on, if not go to next
        jsr     CID_DC_ADJUST             ;Else, calculate dc value
        jsr     CID_VAL_CSS               ;***Sanjay: for rejecting silence
        tstw    x:CID_DC_FRM_CNT          ;Check if dc-adjust cnt
        jne     _cid_frm_over             ;  is on, if not go to next
        move    x:CID_CODEC_IGAIN,y0      ;Change the thres to higher
        move    x:CID_SILEN_THRES,x0      ;  val as amp-adjust is done
        impy    y0,x0,a                   ;  already
        move    a,x:CID_SILEN_THRES
        move    #CID_ENER_BUFF,x:CID_ENER_BUFF_PTR

        jsr     CID_FIND_ZERO_CROSS
                                          ;Check alternate 1's and 0's
        bra     _after_getbits            ;And skip the get-bits rtn
_next2
        jsr     CID_DC_SUB                ;Sub dc value from energies

_after_getbits

;************************************************************************
;*  FOR CW
;************************************************************************
;       move    x:(CID_THREE_EXTREMA+2),a ;Store the last bit of
        move    x:CID_THREE_EXTREMA_2,a    ;Store the last bit of
        move    a,x:CID_PREV_EXTREME      ;  previous frame for compare
        jsr     CID_GET_SBIT              ;call get-bits rtn
        move    #CID_THREE_EXTREMA-1,r0   ;Start from the last
        move    #CID_CSS_ERR_THRES,b      ;Check the error against
        move    x:(r0)+,x0                ;  bit of previous frame
        move    x:(r0),y0                 ;Check if the bits are 
        mpy     x0,y0,a                   ;  alternate
        do      #CID_BITS_PER_FRM,_css_pros
        bge     _css_err                  ;If not alternate, jump
        incw    x:CID_CSS_CNT             ;If alternate, cnt++
        move    b0,x:CID_MARK_CNT         ;Clear the mark count
        bra     _loop_next                ;Go for one more compare
_css_err
        tstw    y0                        ;If the bit is mark, jmp
        bge     _cnt_mark
        incw    x:CID_CSS_ERR_CNT         ;Else it's an error, cnt++
        move    b0,x:CID_MARK_CNT         ;  and clear mark cnt
        cmp     x:CID_CSS_ERR_CNT,b       ;  max. threshold
        bgt     _loop_next                ;If within threshold, loop
        bfset   #(CID_ERROR|CID_CSS_ERR),x:CID_STATUS
                                          ;Else, set error in a flag
                                          ;Set timer expiry
        enddo                             ;Break the do loop
        rts                               ;Exit from the routine

_cnt_mark
        incw    x:CID_MARK_CNT            ;If mark, cnt++
        move    #CID_MARK_MINLMT,x0       ;If a min. no. of marks
        cmp     x:CID_MARK_CNT,x0         ;  come continuously,
        bne     _loop_next
        jsr     CID_MARK_INIT             ;  change the state to mark
_exit_loop
        enddo                             ;Exit the loop
        jmp     _cid_frm_over             ;exit from the module	
_loop_next
        move    x:(r0)+,x0                ;Get two more for compare,
        move    x:(r0),y0                 ;  and loop back
        mpy     x0,y0,a
_css_pros
        jmp     _cid_frm_over             ;exit from the module	
_may_be_mark                              ;Mark state
        bftsth  #CID_MARK_STATE,x:CID_STATE
        jcc     _info_state               ;If not mark, it's info state
_mark_state
        jsr     CID_DC_SUB                ;Sub dc value from energies
        jsr     CID_GET_SBIT              ;Get the three bits
        bftsth  #CID_SEARCH_START,x:CID_STATUS
                                          ;If zero-cross search is on,
        jcc     _mark_pros
        move    #CID_ENER_BUFF,x:CID_ENER_BUFF_PTR
        jsr     CID_FIND_ZERO_CROSS       ;Find zero cross in frame
        bftsth  #CID_SEARCH_START,x:CID_STATUS
                                          ;If zero-cross is found
        jcs     _cid_frm_over
        jsr     CID_INFO_INIT             ;Initialise info state
        jmp     _cid_frm_over             ;Check for timer expiry
_mark_pros
        move    #CID_THREE_EXTREMA,r0     ;Check if bits are marks
        nop
        tstw    x:(r0)+
        do      #CID_BITS_PER_FRM,_cnt_marks
        bgt     _cnt_marks1
        incw    x:CID_MARK_ERR_CNT        ;If not mark, err-cnt++
        move    #CID_MARK_ERR_THRES,x0    ;If it crosses max. thres,
        cmp     x:CID_MARK_ERR_CNT,x0
        bgt     _cnt_marks1
        bfset   #(CID_ERROR|CID_MARK_ERR),x:CID_STATUS
        enddo
        rts                               ;Exit the routine
_cnt_marks1
        decw    x:CID_MARK_CNT            ;Count no. of mark bits
        tstw    x:(r0)+                   ;Take the next bit for mark
_cnt_marks
        tstw    x:CID_MARK_CNT
        jgt     _cid_frm_over
        bfset   #CID_SEARCH_START,x:CID_STATUS
                                          ;  search for zero cross
        jmp     _cid_frm_over             ;  from the next frame

_info_state
        bftsth  #CID_PREMARK_STATE,x:CID_STATE
        jcs     _premark_state
        jsr     CID_DC_SUB                ;Sub dc value from energies
        jsr     CID_GET_SBIT              ;Take three bits
        bftsth  #CID_SEARCH_START,x:CID_STATUS
                                          ;If zero-cross search is on,
        bcc     _info_pros
        move    #CID_ENER_BUFF,x:CID_ENER_BUFF_PTR
        jsr     CID_FIND_ZERO_CROSS       ;Find zero-cross in frame
        jmp     _cid_frm_over             ;Check if timer is expired

_info_pros
        move    #CID_BITS_PER_BYTE,y0     ;To check if 10 bits are there
        move    #CID_THREE_EXTREMA,r1

        do      #CID_BITS_PER_FRM,_take_bits
        jsr     CID_READ_BIT              ;Read each bit into a reg
        cmp     x:CID_BITS_CNT,y0         ;If 10 bits are collected
        bne     _next_bit
        move    x:CID_BITS_REG,y0         ;Bring the bits to ls side
        lsl     y0                        ;Throw the stop bit
        move    #CID_SHFTS_TO_LS,x0       ;  and throw the start bit
        lsrr    y0,x0,a                   ;  and shift to ls side
        move    a1,x:CID_DATA_BYTE
        jsr     CID_DATA_HANDLER          ;Process the byte
        bfset   #CID_SEARCH_START,x:CID_STATUS
                                          ;Again search for zero-cross
        move    lc,x0                     ;lc = 3,2,1 --> offset = 0,1,2
        move    #3,y0
        eor     y0,x0
        move    #CID_SMPL_GRID,a          ;Add the offset to buffer
        add     x0,a                      ;Energies upto this are used
        move    a1,r0                     ;  in getting 10 bits.
        nop
        move    x:(r0),a1
        move    a1,x:CID_ENER_BUFF_PTR
        enddo                             ;Terminate the loop
        jsr     CID_FIND_ZERO_CROSS       ;Find the zero-cross
        bra     _cid_frm_over
_next_bit
        lea     (r1)+                     ;Take the next bit
        nop
        nop
_take_bits
	    bra     _cid_frm_over

_premark_state
        jsr     CID_VALIDATE_MARK
        move    x:CID_MARK_CNT,y0
        cmp     #CID_MARK_MINLMT,y0
        blt     _cid_frm_over
        jsr     CID_MARK_INIT
        jsr     CID_AMP_ADJUST

_cid_frm_over
        rts




;**************************************************************************
;
;   MODULE NAME     : CID_ENER_CAL
;
;**************************************************************************
;
;   DESCRIPTION
;        It demodulates, filters and squares the result to get energy
;        in a sample. In this implementation, demodulation and LPF are
;        combined.
;;
;**************************************************************************
;
;   INPUT       -  y1                       Holds the codec sample
;                  r3 -> CID_LPF_COEF_BUFF[0..27]
;                  Filter coeffs. of 4 filters are kept in consecutive
;                  locations. Each time this module is called, r3 points
;                  to a new filter coeff. set.
;
;                  r0->CID_LPF_DLY_PTR      Pointer to LPF delay buffer
;                      (Mod 6 buffer)
;
;   OUTPUT      -  a                        Sample Energy
;                  r0->CID_LPF_DLY_PTR      Points to filter state buffer 
;                      (Mod 6 buffer)
;
;   UPDATE      -  CID_LPF_DLY_BUFF         Filter state buff in Mod 6
;
;   SUBROUTINES 
;    CALLED     -  None
;
;   CALLING 
;    REQUIREMENTS 
;               -  1. m01 should be initialised to 5.
;
;   RESOURCES   -  registers : x0  y0  a  r0  m01
;    (local)                         y1     r3
;                  
;**************************************************************************

CID_ENER_CAL   macro

        mpy     y1,x0,a      x:(r0)+,y0   x:(r3)+,x0
        mac     y0,x0,a      x:(r0)+,y0   x:(r3)+,x0
        mac     y0,x0,a      x:(r0)+,y0   x:(r3)+,x0
        mac     y0,x0,a      x:(r0)+,y0   x:(r3)+,x0
        mac     y0,x0,a      x:(r0)+,y0   x:(r3)+,x0
        mac     y0,x0,a      x:(r0)+,y0   x:(r3)+,x0
        macr    y0,x0,a      x:(r0)+n,y0  x:(r3)+,x0
        move    a,y0
        mpy     y0,y0,a                   ;Square the result to get energy
        move    y1,x:(r0)                 ;Store the sample

        endm




;**************************************************************************
;
;   MODULE NAME     : CID_CPFSK_DEMOD
;
;**************************************************************************
;
;   DESCRIPTION  : 
;        1. It demodulates and low pass filters the codec sample and 
;           calculates the energy. It is done for cosine and sine terms
;           of both the frequencies.
;        2. The results of sine and cosine limbs are added.
;        3. The result of space freq. limb is subtracted from the
;           result of mark freq. limb.
;        4. Moving average of the result is taken over the past 6
;           energies.
;        5. From the 20 energies, checks the presence of carrier.
;
;**************************************************************************
;
;   INPUT         - x:CID_SMPL_OUT_PTR->CID_SMPL_BUFF[0..19]
;                   x:CID_CODEC_IGAIN  -  Codec gain value
; 
;   OUTPUT        - CID_ENER_BUFF[0..19], CID_CAR_ON
;
;   UPDATE        - CID_SMPL_OUT_PTR, CID_SIN1_DLY_PTR, CID_COS1_DLY_PTR,
;                   CID_SIN0_DLY_PTR, CID_COS0_DLY_PTR, CID_AVER_PTR
;   READ          - CID_ENER_THRES, CID_LPF_COEFF_BUFF 
;
;   MACRO'S 
;    USED         - CID_ENER_CAL : It does demod. and low pass filtering.
;                                  and calculates the energy in the sample.
;
;   CALLING
;    REQUIREMENTS - 
;                   1. The subroutine should not disturb the y1 and m01
;                      registers.
;
;   RESOURCES     -  stack used :  4 
;    (local)         do loop depth :  1
;                    registers :  x0  y1 a  r0  m01  sp
;                                 y0  b  r2  n
;
;**************************************************************************

CID_CPFSK_DEMOD
        
        move    #CID_ENER_BUFF,r2
        move    x:CID_sampleptr,r1
        move    #-1,n
        move    #CID_DEMOD_DLY_MOD,m01    ;Modulo for delay-line 
        
        do      #CID_ENER_SIZE,CID_Demod  ;Process 20 samples 
        move    #CID_LPF_COEF_BUFF,r3     ;The coeffs for 4 LPFs are
                                          ;  kept in sequence
        move    x:CID_CODEC_IGAIN,x0      ;An integer gain
        move    x:(r1)+,y0                ;Take codec sample
        impy    x0,y0,a                   ;Multiply the sample with gain
        move    x:(r0)+,y1     x:(r3)+,x0 ;Dummy read in y1

        move    x:CID_SIN0_DLY_PTR,r0     ;r0->Filter state buffer
        move    a,y1                      ;Codec sampl after gain adjustment

        CID_ENER_CAL                      ;Demodulate,filter and square
        move    r0,x:CID_SIN0_DLY_PTR     ;Store ptr to filter state buff
        move    x:CID_COS0_DLY_PTR,r0     ;r0->Filter state buffer
        tfr     a,b                       ;b = SIN1_SUM
        
        CID_ENER_CAL                      ;Demodulate,filter and square
        move    r0,x:CID_COS0_DLY_PTR     ;Store ptr to filter state buff
        move    x:CID_SIN1_DLY_PTR,r0     ;r0->Filter state buffer
        add     a,b
        
        CID_ENER_CAL                      ;Demodulate,filter and square
        move    r0,x:CID_SIN1_DLY_PTR     ;Store ptr to filter state buff
        move    x:CID_COS1_DLY_PTR,r0     ;r0->Filter state buffer
        sub     a,b                       ;b=SIN1_SUM + COS1_SUM - SIN0_SUM
        
        CID_ENER_CAL                      ;Demodulate,filter and square
        move    r0,x:CID_COS1_DLY_PTR     ;Store ptr to filter state buff
        sub     a,b                       ;b=SIN1_SUM + COS1_SUM - SIN0_SUM
                                          ;  - COS0_SUM
        move    x:CID_AVER_PTR,r0         ;Pointer to moving average buff.
    	rnd     b
        move    b,x:(r0)+
        move    x:(r0)+,x0
        add     x0,b         x:(r0)+,x0   ;b = Average energy of the sample
        add     x0,b         x:(r0)+,x0   ;b = Average energy of the sample
        add     x0,b         x:(r0)+,x0   ;b = Average energy of the sample
        add     x0,b         x:(r0)+,x0   ;b = Average energy of the sample
        add     x0,b         x:(r0)+,x0   ;b = Average energy of the sample
        move    r0,x:CID_AVER_PTR
        abs     b            b,x:(r2)+    ;Store the sample energy in
                                          ;  CID_ENER_BUFF
        asr     b                         ;Only for carrier detection
        asr     b
        move    x:CID_CAR_SUM1,a
        move    x:CID_CAR_SUM2,a2
        add     b,a
        move    a1,x:CID_CAR_SUM1
        move    a2,x:CID_CAR_SUM2
CID_Demod

        bfclr   #CID_CAR_ON,x:CID_STATUS  ;Start with car. absent
        move    x:CID_CAR_SUM1,a          ;Compare the accumulated
        move    x:CID_CAR_SUM2,a2         ;  sum of abs. energies
        move    x:CID_SILEN_THRES,b       ;  with the threshold
        cmp     b,a                       ;If gt, car. is present
        blt     _no_car
        bfset   #CID_CAR_ON,x:CID_STATUS  ;Indicate carrier present
_no_car
        move    #0,x:CID_CAR_SUM1
        move    #0,x:CID_CAR_SUM2
        move    #-1,m01                   ;r0 in linear addr. mode

	rts



;**************************************************************************
;
;   MODULE NAME     : CID_DC_ADJUST
;
;**************************************************************************
;
;   DESCRIPTION 
;        It calculates the sum of enrgies of 400 samples (60 bits) which
;        consist of 30 spaces and 30 marks. So, if there is any non-zero
;        sum, it's because of DC shift in the signal 
;
;**************************************************************************
;
;   INPUT         -  CID_ENER_BUFF[0..19]
; 
;   OUTPUT        -  x:CID_DC_VAL           DC computed over 400 samples
;
;   UPDATE        -  x:CID_DC_SUM[0..2]
;                    x:CID_DC_FRM_CNT
;
;   SUBROUTINES 
;    CALLED       -  None
;
;   CALLING
;    REQUIREMENTS -  None
;
;   RESOURCES     -  do loop depth :  1 
;    (local)         registers :  x0  y0  a  r0
;                                         b
;
;                    Program Words  :  33
;                            NLOAC  :  29
;
;**************************************************************************

CID_DC_ADJUST
       
	    move    #CID_DC_SUM2,r1           ;DC accumulation buffer
        move    #CID_ENER_BUFF,r0
        move    x:(r1)+,a2                ;a = CID_DC_SUM
        move    x:(r1)+,a1
        move    x:(r1)-,a0
        move    x:(r0)+,b                 ;b = First energy sample
        do      #CID_ENER_SIZE,CID_Compute_Sum
                                          ;Compute sum of energies over
        move    b1,x0                     ;  20 samples
        move    b2,b
        move    x0,b0
        add     b,a          x:(r0)+,b
CID_Compute_Sum
	lea     (r1)-                     ;r1 -> CID_DC_SUM2
        move    a2,x:(r1)+                ;Store the partial sum
        move    a1,x:(r1)+
        move    a0,x:(r1)
        decw    x:CID_DC_FRM_CNT
        bne     CID_End_DC_Sum
        rep     #9
        asr     a                         ;DC_SUM=DC_SUM/512
        move    a0,a
        move    #CID_FRACTION,y0
        mpyr    a1,y0,a                   ;Compute DC_SUM*16/25
        move    a,x:CID_DC_VAL            ;Actual DC in x:CID_DC_VAL

        jsr     CID_DC_SUB                ;Subtracts dc value from
CID_End_DC_Sum                            ;  all energies

        rts



;**************************************************************************
;
;   MODULE NAME     : CID_AMP_ADJUST
;
;**************************************************************************
;
;   DESCRIPTION  :
;        Find the gain factor with which each codec sample has to be
;        multiplied. This, tries to get the Max. peak of the energy in
;        CSS state, and stretches it to full dynamic range (i.e., +1 & -1).
;
;**************************************************************************
;
;   INPUT         -  CID_ENER_BUFF[0..19]
; 
;   OUTPUT        -  x:CID_CODEC_IGAIN
;
;   UPDATE        -  None
;
;   SUBROUTINES 
;    CALLED       -  None
;
;   CALLING
;    REQUIREMENTS -  None
;
;   RESOURCES     - 
;    (local)         do loop depth :  1
;                    registers :  a  x0  r0 
;                                 b 
;
;                    Program Words  :  21
;                            NLOAC  :  25
;
;   NOTE  :   r0  gets disturbed at the end of this module
;
;**************************************************************************
        
CID_AMP_ADJUST

        move    #CID_ENER_BUFF,r3         ;r3 -> Energy buffer
        clr     b                         ;Max energy is initialised to 0

        do      #CID_ENER_SIZE,CID_Find_Max_Peak
        move    x:(r3)+,a
        abs     a
        cmp     b,a
        tgt     a,b                       ;b = Max sample energy at the
CID_Find_Max_Peak                         ;  end of the do loop

        move    #0,r0                     ;Initialise the shifts to 0
    	tst     b                         ;for flags updation
        rep     #16                       ;r0 - negative of no. of shifts
        norm    r0,b                      ;  reqd. to get full dynamic
        move    r0,a                      ;  of energy
        abs     a
        lsr     a                         ;Divide by 2 is done because,
                                          ;  this gain is applied before 
                                          ;  squaring the sample value
        move    x:CID_CODEC_IGAIN,x0
        rep     a1
        lsl     x0                        ;x0 = Integer gain to codec sample
        decw    x0
        bgt     _proper_gain
        move    #1,x0
_proper_gain
        move    x0,x:CID_CODEC_IGAIN      ;Store the sample gain

End_CID_AMP_ADJUST
        rts
        


;**************************************************************************
;
;   MODULE NAME     : CID_FIND_ZERO_CROSS
;
;**************************************************************************
;
;   DESCRIPTION     :
;
;   This module searches for zero-crossing (High to Low transtion) in the 
;   given energies of a frame and once it finds, it calls the routine
;   "CID_GET_REMAIN_BITS" to find out the peaks in the remaining energies
;   in that frame.
;
;**************************************************************************
;
;   INPUT       - x:CID_ENER_BUFF[0..19], x:CID_PREV_ENER
;
;   OUTPUT      - x:CID_SEARCH_START, x:CID_OFST_9OR10, x:CID_LMT_9OR10, y0
;
;   UPDATE      - x:CID_ENER_BUFF_PTR
;
;   SUBROUTINES
;    CALLED     -  CID_GET_REMAIN_BITS
;
;   CALLING
;    REQUIREMENTS - None
;
;**************************************************************************

CID_FIND_ZERO_CROSS
        
        move    x:CID_ENER_BUFF_PTR,y0    ;
        move    y0,r0                     ;CID_CNT = (CID_ENER_BUFF_PTR -
        sub     #CID_ENER_BUFF,y0         ;           CID_ENER_BUFF)
        move    #CID_ENER_SIZE,x0         ;          
        sub     y0,x0                     ;Temp = (20 - CID_CNT)
        move    #-1,n                     ;
        do      x0,_remaining_energies    ;
        tstw    x:(r0)                    ;Get the current energy value
        bge     _no_zero_cross            ;
        tstw    x:(r0+n)                  ;Get the previous energy value
        blt     _no_zero_cross            ;
        move    #9,x:CID_OFST_9OR10       ;If (abs(current energy) >=
        move    #10,x:CID_LMT_9OR10       ;   (abs(previous energy)),
        move    x:(r0),a                  ;   CID_OFFSET = 9 and
        move    x:(r0+n),b                ;   CID_LIMIT  = 10
        abs     a                         ;else
        cmp     b,a                       ;   CID_OFFSET = 10
        bge     _less_offset              ;   CID_LIMIT  = 9
        move    #10,x:CID_OFST_9OR10      ;
        move    #9,x:CID_LMT_9OR10        ;
_less_offset
        jsr     CID_GET_REMAIN_BITS       ;Get the remaining extrema bits
        bfclr   #CID_SEARCH_START,x:CID_STATUS
                                          ;  from the current frame ener.
        move    hws,x0                    ;Pop out of hardware stack in
        rts                               ;  order to go out of do loop
_no_zero_cross
        lea     (r0)+                     ;Increment the ener_buff pointer
        incw    y0                        ;Increment the count for 
        nop                               ;  marking zero_crossing point
_remaining_energies
        rts 




;**************************************************************************
;
;   MODULE NAME     : CID_GET_REMAIN_BITS
;
;**************************************************************************
;
;   DESCRIPTION     :
;
;   Once a zero-crossing is found (High-Low transition) in a frame by
;   FIND_ZERO_CROSS module, this module finds the three extremas in the 
;   remaining energies after the zero-crossing and interpretes them as mark
;   and space signals. It also gives positions of three samples to be taken
;   for peak decision from the next frame onwards.
;;
;**************************************************************************
;
;   INPUT       - x:CID_CNT(y0), x:CID_ENER_BUFF[0..19], x:CID_OFST_9OR10
;                 x:CID_LMT_9OR10
;
;   OUTPUT      - x:CID_SMPL_GRID, x:CID_BITS_REG, x:CID_BITS_CNT
;
;   UPDATE      - x:CID_BITS_REG, x:CID_BITS_CNT
;
;   SUBROUTINES
;    CALLED     -  CID_READ_BIT, UPDATE_GRID
;
;   CALLING
;    REQUIREMENTS - A zero crossing has to be detected in the energy buffer
;
;**************************************************************************

CID_GET_REMAIN_BITS
        
        clr     a                         ;Clear the accumulator
        move    a,x:CID_BITS_CNT          ;Clear the bit count
        move    a,x:CID_BITS_REG          ;Clear the bit value
        move    y0,a                      ;Get the offset to zero-crossing 
        move    #CID_ENER_BUFF,b          ;
        add     a,b                       ;Tmp=(CID_ENER_BUFF+CID_CNT)  
        cmp     #16,a                     ;
        ble     _l1                       ;If (CID_CNT > 16),
        move    #-17,x0                   ;Peak[0] = (tmp-17)
        move    x:CID_OFST_9OR10,y0       ;Peak[1] = (tmp+CID_OFST_9OR10
        sub     #20,y0                    ;           -20)
        move    #-4,y1                    ;Peak[2] = (tmp-4)
        bra     UPDATE_GRID               ;

_l1
        cmp     x:CID_LMT_9OR10,a         ;
        ble     _l2                       ;If (CID_CNT > CID_LMT_9OR10),
        move    x:CID_OFST_9OR10,x0       ;Peak[0] = (tmp+CID_OFST_9OR10
        sub     #20,x0                    ;           -20)
        move    #-4,y0                    ;Peak[1] = (tmp-4)
        move    #3,y1                     ;Peak[2] = (tmp+3)
        jsr     UPDATE_GRID               ;
        move    y1,r1                     ;
        bra     CID_READ_BIT              ;Get the bit value

_l2
        cmp     #3,a                      ;
        ble     _l3                       ;If (CID_CNT > 3),
        move    #-4,x0                    ;Peak[0] = (tmp-4)
        move    #3,y0                     ;Peak[1] = (tmp+3)
        move    x:CID_OFST_9OR10,y1       ;Peak[2] = (tmp+CID_OFST_9OR10)
        jsr     UPDATE_GRID               ;
        move    y0,r1                     ;                      
        jsr     CID_READ_BIT              ;Get the peak bit value 
        move    y1,r1                     ;
        bra     CID_READ_BIT              ;

_l3
        move    #3,x0                     ;else, Peak[0] = (tmp+3)
        move    x:CID_OFST_9OR10,y0       ;Peak[1] = (tmp+CID_OFST_9OR10)
        move    #16,y1                    ;Peak[2] = (tmp+16)
        jsr     UPDATE_GRID               ;
        move    x0,r1                     ;
        jsr     CID_READ_BIT              ;Get the peak bit values
        move    y0,r1                     ;
        jsr     CID_READ_BIT              ;
        move    y1,r1                     ;

CID_READ_BIT
        move    x:CID_BITS_REG,x0         ;
        lsr     x0                        ;If peak is positive, it is
                                          ;a mark signal, else if peak
        tstw    x:(r1)                    ;is negative, it is a space
        blt     _l4                       ;signal
        orc     #$8000,x0                 ;

_l4
        move    x0,x:CID_BITS_REG         ;
        incw    x:CID_BITS_CNT            ;Increment the no. of mark/
                                          ;  space signals
        rts
        


UPDATE_GRID
        add     b1,x0                     ;Find the extrema positions
        add     b1,y0                     ;  in energy buffer
        add     b1,y1                     ;
        move    x0,x:CID_SMPL_GRID        ;
;************************************************************************
;*  FOR CW
;************************************************************************
;       move    y0,x:(CID_SMPL_GRID+1)    ;
;       move    y1,x:(CID_SMPL_GRID+2)    ;
        move    y0,x:CID_SMPL_GRID_1       ;
        move    y1,x:CID_SMPL_GRID_2       ;
;************************************************************************
;*  END CW
;************************************************************************
        rts




;**************************************************************************
;
;   MODULE NAME     : CID_GET_SBIT
;
;**************************************************************************
;
;   DESCRIPTION  : 
;                 This has 2 modules, viz., CID_DC_SUB and CID_GET_SBIT 
;                  CID_DC_SUB removes the DC shift in CID_ENER_BUFF and 
;                  CID_GET_SBIT collects the 3 extremas into 
;                  CID_THREE_EXTREMA buffer.
;
;**************************************************************************
;
;   INPUT         - CID_ENER_BUFF[0..19]
;                   x:CID_DC_VAL
;                   CID_SMPL_GRID[0..2] - Contain pointers to CID_ENER_BUFF
; 
;   OUTPUT        - CID_THREE_EXTREMA[0..2] - Three extremas
;
;   UPDATE        - CID_ENER_BUFF[0..19]
;
;   SUBROUTINES 
;    CALLED       - None 
;
;   CALLING
;    REQUIREMENTS - None
;
;   RESOURCES     - 
;    (local)         do loop depth : 1
;                    registers :     x0  a  r0
;                                           r1
;                                           r3
;
;**************************************************************************
        
CID_DC_SUB

        move    #CID_ENER_BUFF,r0
        move    x:CID_DC_VAL,x0
        do      #CID_ENER_SIZE,CID_Sub_DC ;CID_ENER_BUFF[0..19] - =
        move    x:(r0),a                  ;  x:CID_DC_VAL
        sub     x0,a
        move    a,x:(r0)+
CID_Sub_DC
        rts


CID_GET_SBIT

        move    #CID_SMPL_GRID,r3         ;for i = 1:3,
        move    #CID_THREE_EXTREMA,r0     ;  *CID_THREEE_EXTREMA(i) = 
        move    x:(r3)+,r1                ;  *(*CID_SMPL_GRID(i))
        do      #3,CID_Get_Extremas
        move    x:(r1),x0
        move    x:(r3)+,r1
        move    x0,x:(r0)+
CID_Get_Extremas
        rts                               ;Return to the calling module
        



;**************************************************************************
;
;   MODULE NAME     : CID_VALIDATE_MARK
;
;**************************************************************************
;
;   DESCRIPTION
;        This module is called in CID_PREMARK_STATE to check whether
;        marks have arrived. It checks it by finding whether most of
;        the input energy is at mark frequency.
;
;**************************************************************************
;
;   INPUT       -  CID_ENER_BUFF - Linear buff of length 20
;                  CID_SMPL_BUFF - Modulo buff of length 60 
;
;   OUTPUT      -  CID_MARK_CNT
;
;   UPDATE      -  None
;
;   SUBROUTINES 
;    CALLED     -  None
;
;   CALLING 
;    REQUIREMENTS 
;               -  None
;
;   RESOURCES   -  registers : x0  y0  a  r0  n
;    (local)                           b  r1
;                  
;**************************************************************************

CID_VALIDATE_MARK

        move    x:CID_SMPL_OUT_PTR,r0     ;ptr1 = CID_SMPL_OUT_PTR - 
        move    #CID_ENER_BUFF,r3         ;ptr2 = CID_ENER_BUFF
        clr     a            x:(r0)+,y0   ;acc1 = 0
        clr     b                         ;acc2 = 0
        move    #0,n
        move    y0,y1
        do      #20,CID_Check_Mark 
        mac     y1,y0,a      x:(r0)+n,y0  x:(r3)+,x0
        asr     x0                        ;acc1 = acc1 + (*ptr1)**2
        add     x0,b         x:(r0)+,y1   ;acc2 = acc2 + (*ptr2)
CID_Check_Mark
        do      #4,CID_Shift
        asr     a                         ;acc1 = acc1 >> 4
        asr     b                         ;acc2 = acc2 >> 4
CID_Shift
        move    #CID_ENER_FACTOR,y0
        mpy     a1,y0,a                   ;mark bits if
        move    #0,x0                     ;acc2 > CID_ENER_FACTOR*acc1
        cmp     a,b
        ble     End_CID_VALIDATE_Mark
        move    x:CID_MARK_CNT,x0
        add     #3,x0

End_CID_VALIDATE_Mark
        move    x0,x:CID_MARK_CNT
        rts



;**************************************************************************
;
;   MODULE NAME     : CID_VAL_CSS
;
;**************************************************************************
;
;   DESCRIPTION  : This module is called in the CSS state for a few frames
;   in the beginning of the state. This module checks if there are 3 zero-
;   crossings and if the distance between crosses is correct in a frame of 
;   20 energies. If the frame violates any of the above rules, it will 
;   restart the CSS state again.
;
;**************************************************************************
;
;   INPUT         - CID_ENER_BUFF[-1..19]
; 
;   OUTPUT        - none
;
;   UPDATE        - none
;
;   SUBROUTINES 
;    CALLED       -  CID_CSS_INIT : Initialises variables for CSS state.
;
;   CALLING
;    REQUIREMENTS -  CID_PREV_ENER should contain the last energy of the 
;                    previous frame.
;
;   RESOURCES     -  scratch used : x:CID_ZERO_CROSS, x:CID_WRONG_CROSS
;    (local)                        x:CID_ZERO_TO_ZERO        
;
;   NOTE          -
;
;**************************************************************************

CID_VAL_CSS        

        move    #CID_ENER_BUFF-1,r0       ;Point to the last value of
                                          ;  previous frame
        move    #0,x:CID_ZERO_CROSS
        move    x:(r0)+,x0                ;Take the first value
        move    x:(r0),a                  ;Take the second value
        eor     x0,a                      ;Check for zero crossing

        do      #CID_ENER_SIZE,_count_zeros
        bge     _next_comp                ;Different signs, found
        incw    x:CID_ZERO_CROSS          ;  a zero cross
_next_comp
        move    x:(r0)+,x0                ;Take the next energy
        move    x:(r0),a                  ;Take the next energy
        eor     x0,a                      ;Else, if both values have
_count_zeros

        move    x:CID_ZERO_CROSS,a
        sub     #3,a                      ;If there are 3 zero crosses,
        beq     _end_val_css              ;Then, it's correct. So proceed
        abs     a
        decw    a
        beq     _end_val_css              ;Not 2,3 or 4. error
_error_frm                                ;and prev and current are same. error
        jsr     CID_CSS_INIT              ;Else, exit from the CID_CNTRL.

_end_val_css
        rts



;**************************************************************************
;
;   MODULE NAME     : CID_DATA_HANDLER
;
;**************************************************************************
;
;   DESCRIPTION     : 
;
; 1. It updates the CRC using the received byte, CID_DATA_BYTE. 
; 2. It stores the data in a buffer, CID_DATA_BUFF[0..59]. Once a complete 
;    message is received, it validates the crc and accepts the message if
;    it's correct.
; 3. If the CRC_WORD is wrong, it sets the MSB bit of the 1st data 
;    corresponding to that buffer.
; 4. Once a message is recieved, it will change the state to 
;    Channel Ceisure Signal state.
;
;**************************************************************************
;
;   INPUT       - x:CID_DATA_BYTE
; 
;   OUTPUT      - x:CID_DATA_READY, CID_DATA_BUFF[0..255]
;
;   UPDATE      - x:CID_CRC_WORD, x:CID_DATA_TMP_PTR, x:CID_BYTE_CNT, 
;                 x:CID_FRM_STG, x:CID_FRM_LEN, x:CID_DATA_BUFF_PTR, 
;                 x:CID_DATA_BUFF_CNT
;
;   SUBROUTINES
;    CALLED     -  None
;
;   CALLING
;    REQUIREMENTS - None
;
;**************************************************************************

CID_DATA_HANDLER
        move    x:CID_DATA_BYTE,x0        ;Compute the partial CRC
        move    x:CID_CRC_WORD,y0         ;  using the received byte
        add     x0,y0                     ;
        move    y0,x:CID_CRC_WORD         ;
        move    x:CID_DATA_TMP_PTR,r0     ;Keep the byte in the buffer
        incw    x:CID_BYTE_CNT            ;Increment the byte count
        move    x0,x:(r0)+                ;Store the data bytes in buffer

        move    r0,x:CID_DATA_TMP_PTR
        
        move    #CID_TYPE,y1              ;Message type value
        move    #CID_LENGTH,y0            ;Message length value
        cmp     x:CID_FRM_STG,y1          ;Check for message type byte
        bne     _must_be_len
        move    y0,x:CID_FRM_STG          ;If type is rxed, len has to
        rts                               ;  be rxed next

_must_be_len
        cmp     x:CID_FRM_STG,y0          ;Check for message length byte
        bne     _must_be_msg
        move    #CID_MESSAGE,x:CID_FRM_STG
                                          ;If len is rxed, msg comes next
        incw    x0                        ;Chksum is not included in 
        move    x0,x:CID_FRM_LEN          ;  length. So,increment by 1
        rts

;If the received byte is not message type or length, it has to be 
;message word

_must_be_msg
        decw    x:CID_FRM_LEN             ;If len==0, it's end of a msg.
        bne     end_handler
        bftstl  #$00ff,x:CID_CRC_WORD     ;  crc word
        bcs     _correct_crc
        bfset   #(CID_ERROR|CID_CHKSUM_ERR),x:CID_STATUS
        bra     end_handler
_correct_crc
        bfset   #CID_DATA_READY,x:CID_STATUS

end_handler
        rts


        ENDSEC
