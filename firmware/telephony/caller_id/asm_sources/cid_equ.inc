;**************************************************************************
;
;   (C) Motorola India Electronics Ltd.
;
;   Project Name    : CallerID detection
;
;   Original Author : Meera S. P.
;
;   Module Name     : cid_dc.asm
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
;   DESCRIPTION  : The equates needed by the low level assembly routines
;                  are declaired in this file
;
;**************************************************************************


        SECTION CID_CONSTANTS   GLOBAL


;Various buffer sizes
CID_ENER_SIZE       set          20
CID_DATA_SIZE       set          258
FRAME_SIZE          set          20
NUM_FRAMES          set          FRAME_SIZE/20

;Various modulo sizes of modulo buffers
CID_DEMOD_DLY_MOD   set          5

;Various sections in the SDMF and MDMF
CID_TYPE            set          01
CID_LENGTH          set          02
CID_MESSAGE         set          03

;Various stages in CID data receiption, CID_STATE
CID_CSS_STATE       set          01
CID_MARK_STATE      set          02
CID_INFO_STATE      set          04
CID_PREMARK_STATE   set          08

;Various types of status in CID_STATUS
CID_DATA_READY      set          $01   ;Same as CID_COMPL_STAT in main DTAD
CID_TIME_EXPIRE     set          $02   ;same as CID_TIMEOUT_STAT in DTAD main
CID_ERROR           set          $04   ;For DATA main only
NO_CID_TX           set          $08   ;To indicate DTAD that there is no
				       ;  caller ID transmission form SPCS
CID_CHKSUM_ERR      set          $10   ;Checksum error bit
CID_CSS_ERR         set          $20
CID_MARK_ERR        set          $40
CID_LEN_ERR         set          $80
CID_SEARCH_START    set          $100
CID_ONHOOK          set          $200
CID_CAR_ON          set          $400  ;Carrier status bit
CID_PRESENT         set          $800  ;Gets set for the first time carrier is
				       ;  detected ON

;Miscellanoeus constants
CID_ON_TIM_MAX      set          1760  ;For 4.4sec, max data period
CID_OFF_TIM_MAX     set          1400  ;For 3.5 sec offhook CID
CID_OFFHOOK_WAIT    set           256  ;Wait for 640 msec for CID data after
				       ;  sending DTMF-D Ack
CID_CSS_SIL         set          640   ;for 1.6 sec (20 samples frames)
			               ;  end of first power ring and the
				       ;  transmission of CSS is 1.6 sec
CID_ENER_THRES      set          $0019 ;Min. value of accumulated energy
                                       ; of a frame to see carrier presence
                                       ; *** $0008, $4, $44
CID_BITS_PER_FRM    set          3     ;No. of bits per frame
CID_OFF_MARK_MAX    set          40    ;in off-hook state
CID_ON_MARK_MAX     set          140   ;Max. no of marks before searching
                                       ;  for info state in on-hook state
CID_BITS_PER_BYTE   set          10    ;With start, stop and byte
CID_SHFTS_TO_LS     set          8     ;To shift the byte & start bit to ls
CID_AMP_ADJ_FRAMES  set          20    ;**8 Frames to wait before amp adjust
CID_DC_ADJ_FRAMES   set          26    ;Frames over which DC adj is done
				       ;  Amplitude and DC adjustment
CID_CSS_ERR_THRES   set          30    ;Max. allowable no. of CSS errors
CID_MARK_MINLMT     set          10    ;Min. marks to change to MARK state
CID_MARK_ERR_THRES  set          20    ;Max. allowable no. of MARK errors

CID_ENER_FACTOR     set          0.7   ;(Eo/Ei) in mark state in off-hook
CID_INIT_GAIN       set          1     ;Initial gain which can be changed
CID_FRACTION        set          5.12/5.2
CID_DC_OFFHOOK_DEFAULT    set    0

        ENDSEC
