;------------------------------------------------------------------------------
; Module Name:	cpt_low.asm
;
; Description:	This module is designed to provide the low-level routines
;		invoked by the API routines found in cpt_api.asm.  These
;		routines perform the necessary calculations and tests for
;		the tone/silence detection module.
;
;------------------------------------------------------------------------------

    include "cpt_api.inc"                  ; include CPT definitions
    
    SECTION cpt_data	
    
;------------------------------------------------------------------------------ 
; Local Static Variable Definitions 
;------------------------------------------------------------------------------ 
	ORG     x: 

	;--- Include memory constant definitions ---

;********************************* 
; CPT detection scratch variables 
;********************************* 

;***** Buffers for each channel ***** 

sik     dsm     (2*NO_FIL_CPT*M)           ;Buffer for MG filter states 
                                           ;  and the delayed states for M 
                                           ;  channels 
                                           ;  2*NO_FIL_CPT locations per channel 
loop_cntr       ds    1                    ;general purpose loop counter

;***** Buffers common to all channels ***** 

mg_energy       ds    NO_FIL_CPT           ;Buffer for energy of MG filters 

;These below defined locations should appear in the same order 

Thresh5a_cpt    EQU     sik                ;Threshold for Rel En CPT
Thresh5b_cpt    EQU     sik+1
Thresh5c        EQU     sik+2              ;holds Thresh5c for CPT and is
                                           ; an input to REL_EN ()
Thresh4a        EQU     sik+3              ;Forward twist
Thresh4b        EQU     sik+4              ;Reverse twist
rel_mag_cpt     EQU     sik+5              ;4 Rel mag thresholds
pk_add          EQU     sik+9

    ENDSEC
	
	
	SECTION    cpt_code			

	;--- Low-Level Function Prototypes ---;
	GLOBAL    TST_CPT
	GLOBAL    NEWNUM_CPT

	
;------------------------------------------------------------------------------
; Module Code
;------------------------------------------------------------------------------
	ORG 	p:

	
;------------------------------------------------------------------------------
; Routine:	MG_EN
;
; Description:	
;       This routine calculates the Modified Goertzel filter energies for
;       the current channel using the MG filter states of that channel.
;
; Stack Parameters:	N/A
;
; Other Input/Output:
;  Input:
;     M - chl_no   = | 0000 0000  | 000i iiii |  in  lc
;     si(k)        = | s.fff ffff | ffff ffff |  in  x:sik+2*chl_no
;     si(k-1)      = | s.fff ffff | ffff ffff |  in  x:sik+2*chl_no+1
;                                                        i=0,..,NO_FIL-1
;     cosval(i)    = | s.fff ffff | ffff ffff |  in  x:cosval+i
;                                                        i=0,..,NO_FIL-1
;     y1           = Number of filters
;     r3           -> Appropriate cos table
;
;  Output:
;     mg_energy(i) = | 0.fff ffff | ffff ffff |  in  x:mg_energy+i
;                                                        i=0,..,NO_FIL-1
;
; Pseudocode:
;               for the current channel
;                   for i=0 to NO_FIL-1
;                       mg_energy(i) = si(N-1)*si(N-1) + si(N-2)*si(N-2)
;                                 - 2.0*cosval(i)*si(N-1)*si(N-2)
;------------------------------------------------------------------------------

MG_EN:

    move    #mg_energy-1,r0               ;r0 -> location before
	                                      ;  mg_energy(0)
	move    #sik,r1                       ;r1 = sik                   
					                      ;  i.e. r1 -> si(0) of first  
					                      ;  filter 
	move    x:(r0),b                      ;b = contents of location before
					                      ;  mg_energy(0), to account for
					                      ;  the write operation in the
			                              ;  first loop
	move    x:(r1)+,y0                    ;y0 = s0(k-1), x0 = cosval(0)
    move    x:(r3)+,x0                    ;  r1 -> s0(k-2) r3 -> cosval(1)

	do      y1,end_mg                     ;For all MG frequencies
	mpy     x0,y0,b         b,x:(r0)+     ;b = cosval(i) * si(N-1)
                                          ;store mg_energy(i-1)
                                          ;r0 -> mg_energy(i)
	asl     b               x:(r1)+,y1    ;b = 2 * cosval(i) * si(N-1)
					                      ;y1 = si(N-2)
                                          ;r1 -> next si(N-1)
	sub     y1,b            x:(r3)+,x0    ;b = 2*cosval(i)*si(N-1) - si(N-2)
                                          ;x0 = cosval(i+1)
                                          ;r3 -> cosval(i+2)
	move    b,b                           ;Saturate b
	mpy     -b1,y1,b                      ;b = si(N-2)*( si(N-2) - 
                                          ;       2*cosval(i)*si(N-1) )
                                          ;  = si(N-2)*si(N-2) -
                                          ;       2*cosval(i)*si(N-1)*si(N-2)
	mac     y0,y0,b         x:(r1)+,y0    ;b = si(N-1)*si(N-1)+si(N-2)*si(N-2)
                                          ;    - 2*cosval(i)*si(N-1)*si(N-2)
                                          ;y0 = next si(N-1)
                                          ;r1 -> next si(N-2)
end_mg
	move    b,x:(r0)+                     ;Store mg_energy(NO_FIL-1)
	rts
	
	
;------------------------------------------------------------------------------
; Routine:      NEWNUM_CPT
;
; Description:
;         This macro provides the interface to the low level CPT detection
;         modules
;         It resets all the MG filter states for all M channels to zero:
;         Then it calls the filter state updating subroutine for K samples 
;         for M channels.
;         Then it runs the CPT decision logic for all channels.
;
; Inputs:
;         ANA_BUF - Samples generated from GENERATE_ANALYSIS_ARRAY_CPT
;
; Outputs:
;         x0 = Group number if CPT is detected
;              0 if failed
;
;------------------------------------------------------------------------------

NEWNUM_CPT

	move    #ANA_BUF,r2                 ;Pointer to working buffer
	clr     a
	move    #(sik+2*NO_FIL_CPT*M-1),r1
                                        ;r1 -> sik(2*NO_FIL*M-1)
	move    #2*NO_FIL_CPT*M-1,m01       ;Set x0 for modulo 2*NO_FIL*M
	move    m01,x0                      ;
	rep     x0                          ;
	move    a,x:(r1)-                   ;For i = (0 to 2*NO_FIL*M-1),
	move    a,x:(r1)                    ;  set sik(i) to zero
                                        ;  r1 -> sik
	move    #(sik+2*NO_FIL_CPT*M-2),r0
                                        ;r0 -> sik(2*NO_FIL*M-2)
	move    #2,n                        ;Set n for offset of 2
	move    x:(r0),a                    ;Get last channel's si(k)
                                        ;  so that it will not be
                                        ;  overwritten
	jsr     UPDCPT                      ;SUbroutine for updating the filter
                                        ;  states
	move    #-1,m01

	rts

;------------------------------------------------------------------------------
; Routine:      TST_CPT
;
; Description:
;               This module calls other test modules to do various kinds of
;               tests to ensure CPT 
;
; Input:
;               None
;
; Output:
;               x0 = 0 if no CPT
;                  = Group number of CPT detected
;
;------------------------------------------------------------------------------

TST_CPT

	move    #NO_FIL_CPT,y1
	move    #cpt_cosval,r3             ;r3 -> cos table
	jsr     MG_EN                      ;COmpute CPT filter energies

	jsr     FIND_PK_CPT                ;Finds 2 peak energies

	jsr     GROUP_TST_CPT              ;This should be called immediately 
	tstw    x0                         ;  after FIND_PK_CPT
	beq     _end_tst_cpt
	jsr     LOAD_THRESH_CPT

	jsr     MAG_CPT                    ;Does a magnitude test on 2 peaks
	tstw    x0
	beq     _end_tst_cpt
	jsr     REL_EN_CPT                 ;Do relative energy comarison
	tstw    x0 
	beq     _end_tst_cpt
	jsr     TWIST_CPT
	tstw    x0
	beq     _end_tst_cpt
	jsr     REL_MAG_CPT                ;Do relative energy comarison
_end_tst_cpt

    rts



;-----------------------------------------------------------------------------
; Routine:      UPDCPT
;
; Description:
;              This module updates the MG filter states of CPT dtection.
:
;  Input:
;     x(k)            = | s.fff ffff | ffff ffff |     in  x:temp1
;
;     sig_energy(hi)  = | 0.fff ffff | ffff ffff |     in  x:(r2)
;     sig_energy(lo)  = | 0.fff ffff | ffff ffff |     in  x:(r2)+1
;     si(k)           = | s.fff ffff | ffff ffff |     in  x:sik+2*chl_no
;     si(k-1)         = | s.fff ffff | ffff ffff |     in  x:sik+2*chl_no+1
;                                                         i=0,..,NO_FIL-1
;                                                          chl_no=0,..,M-1
;              +-------------+
;              |   si(k)     | -+                     ---+
;              +-------------+  |-> 0th filter states    |
;              |   si(k-1)   | -+                        |
;              +-------------+                           |
;              |    ...      |                           |
;              +             +                           |---->Channel no.1
;              |    ...      |                           |
;              +-------------+                           |
;     r0-----> |   si(k)     | -+                        |
;  (initial)   +-------------+  |-> 9th filter states    |
;              |   si(k-1)   | -+                    --- +
;              +-------------+
;                     |
;                     |    ---------->  similarly for M channels
;                     |
;              +-------------+
;              |   si(k-1)   |
;              +-------------+
;     cosval(i)   = | s.fff ffff | ffff ffff |      in  x:cosval to
;                                                       x:cosval+15
;     r0 -> previous channel's last si(k) (modulo 2*NO_FIL*M)
;     r1 -> current channel's si(k-2)
;     r2 -> current channel's sig_energy
;     r3 -> cosval(1)
;     n  =  2
;     x0 =  cosval(0)
;     y1 =  si(k) of 1st channel
;      a =  previous channel's last si(k)
;
;  Output:
;     sig_energy  = | 0.fff ffff | ffff ffff |      in  x:(r2) & x:(r2)+1
;     si(k)       = | s.fff ffff | ffff ffff |      in  x:sik+2*chl_no
;     si(k-1)     = | s.fff ffff | ffff ffff |      in  x:sik+2*chl_no+1
;                                                          i=0,..,NO_FIL-1
;                                                          chl_no=0,..,M-1
;     r0 -> current channel's last si(k)
;     r1 -> next channel's si(k-2)
;     r2 -> next channel's sig_energy
;     r3 -> cosval(1)
;     x0 =  cosval(0)
;     y0 =  next channel's si(k-1)
;     y1 =  current channel's last si(k)
;
;
;------------------------------- Pseudo Code ------------------------------
;Module UPD
;          BEGIN
;               for i=0 to NO_FIL_CPT-1
;                   si(k-2) = si(k-1);
;                   si(k-1) = si(k);
;                   si(k) = x(k) + 2.0*cosval(i)*si(k-1) - si(k-2);
;               end_for
;          END
;End Module
;------------------------------- Resources --------------------------------
;
; Address Registers used:
;                        r0 : used to point to output (si(k))
;                        r1 : used to point to input
;                             (si(k-1), si(k-2))
;                        r2 : used to point to input buffer
;                        r3 : used to point to cosval(i)
;
; Offset Registers used:
;                        n  : Used as increment of 2
;-------------------------------------------------------------------------

UPDCPT

	move    #Nc_cpt,x:loop_cntr       ;Do for Nc_cpt samples of input
l1
	move    #cpt_cosval,r3            ;r3 -> cosval(12)
	move    x:(r1)+,y1                ;y1 = si(k) of 1st channel
                                      ;r1 -> si(k-1) of 1st channel
	move    x:(r0)+,y0                ;Dummy read in y0 and 
    move    x:(r3)+,x0             	  ;  x0 = cpt_cosval(12)
	move    x:(r2)+,y0                ;y0 = input sample
			                		  ;r2 -> next sample in inp_buf
	lea     (r0)-                     ;Adjust the pointer

	do      #NO_FIL_CPT,_end_updl     ;For i=0 to (NO_FIL_CPT-1)
	mpy     x0,y1,a   a,x:(r0)+n      ;a = si(k-1)*cosval(i),save
                                      ;  previous si(k)
                                      ;  r0 -> current si(k)
	move    x:(r1),b                  ;b = si(k-2), r1 -> si(k-2)
	asl     a         y1,x:(r1)+      ;a = 2.0 *si(k-1)*cosval(i)
                                      ;  si(k-2) = si(k-1),
                                      ;  r1 -> next si(k-1)
	add     y0,a      x:(r1)+,y1
    move    x:(r3)+,x0                ;a = x(k) + 2.0*si(k-1)*cosval(i)
                                      ;y1 = next si(k-1)
                                      ;r1 -> next si(k-2)
                                      ;x0 = cosval(i+1)
                                      ;r3 -> next cosval 
	sub     b,a                       ;a = si(k) = x(k) - si(k-2)
                                      ;  + 2.0*cosval*si(k-1)
_end_updl                             ;The last position also
		                              ;  contains cosval(0) so that
                                      ;  once a channel is over,x0
                                      ;  gets cosval(0) for the next
                                      ;  channel
                                      ;r1 -> si(k-1) of 1st channel
                                      ;x0 = cosval(0)
                                      ;r3 -> cosval(1)
	move    #sik,r1                   ;r1 -> sik buffer of next
                                      ;  channel
	decw    x:loop_cntr               ;Decrement the counter value
	bne     l1                        ;If counter value is nonzero,
                                      ;  goto level l1
	move    a,x:(r0)+n                ;Write last channel's last si(k)

	rts                               ;Return to the subroutine

End_upd_subroutine	



;-----------------------------------------------------------------------------
; Routine:      FIND_PK_CPT
;
; Description:
;               This module finds the 2 peak energies out of 4. The tones 
;               have been divided into 2 groups for ease of computation.
;               These are as given below
;
;               lo group  --  350 and 480
;               hi group  --  440 and 620
;
; Input:
;               4 MG filter energies starting from mg_energy
; Output:
;               index to 2 peak energies in y0 and y1.
;
; Pseudo Code:
;-----------------------------------------------------------------------------

FIND_PK_CPT

       move     #mg_energy,r0
       move     #0,y0                   ;Index to low group freq.
       move     #2,y1                   ;Index to high group freq.
       move     x:(r0)+,a
       move     x:(r0)+,x0
       cmp      x0,a           x:(r0)+,a
       bgt      _next_group
       move     #1,y0
_next_group
       move     x:(r0)+,x0
       cmp      x0,a
       bgt      _done
       move     #3,y1

_done
       move     #mg_energy,r0            ;Store the 2 peak energies in
       move     y0,n                     ;  pk_addr and pk_addr+1
       nop
       move     x:(r0+n),x0
       move     y1,n
       move     x0,x:pk_add
       move     x:(r0+n),x0
       move     x0,x:pk_add+1

       rts



;--------------------------------------------------------------------------
; Routine:      LOAD_THRESH_CPT
;
; Description:
;               This module loads the thresholds for Callprogress tones
;               detection depending on the group identified.
;
; Inputs:
;               x0 = group number
;
; Outputs:
;               CPT threshold variables updated
;--------------------------------------------------------------------------

LOAD_THRESH_CPT

	move    #Thresh5a_cpt,r0
	cmp     #1,x0                         ;GROUP1 Parameters
	bne     _load2
	move    #CPT_THRESH1_HI,x:cpt_level   ;Threshold for magnitude test
	move    #CPT_THRESH1_LO,x:cpt_level+1 ;Threshold for magnitude test
	move    #Thresh5a_cpt1,y0             ;3 thresholds for rel energy
	move    y0,x:(r0)+                    ;  test
	move    #Thresh5b_cpt1,y0
	move    y0,x:(r0)+
	move    #ThreshEN1,y0
	move    y0,x:(r0)+
	move    #Thresh4a_cpt1,y0             ;2 thresholds for twist test
	move    y0,x:(r0)+
	move    #Thresh4b_cpt1,y0
	move    y0,x:(r0)+
	move    #Thresh2a1_cpt1,y0            ;5 Thresholds for rel mag test
	move    y0,x:(r0)+
	move    #Thresh2a2_cpt1,y0
	move    y0,x:(r0)+
	move    #Thresh2a3_cpt1,y0
	move    y0,x:(r0)+
	move    #Thresh2a4_cpt1,y0
	move    y0,x:(r0)+
	jmp     _finish_load
_load2
	cmp     #2,x0                         ;GROUP2 Parameters
	bne     _load3                        
	move    #CPT_THRESH2_HI,x:cpt_level   ;Threshold for magnitude test
	move    #CPT_THRESH2_LO,x:cpt_level+1 ;Threshold for magnitude test
	move    #Thresh5a_cpt2,y0             ;3 thresholds for rel energy
	move    y0,x:(r0)+                    ;  test
	move    #Thresh5b_cpt2,y0
	move    y0,x:(r0)+
	move    #ThreshEN2,y0
	move    y0,x:(r0)+
	move    #Thresh4a_cpt2,y0             ;2 thresholds for twist
	move    y0,x:(r0)+
	move    #Thresh4b_cpt2,y0
	move    y0,x:(r0)+
	move    #Thresh2a1_cpt2,y0            ;5 Thresholds for rel mag test
	move    y0,x:(r0)+
	move    #Thresh2a2_cpt2,y0
	move    y0,x:(r0)+
	move    #Thresh2a3_cpt2,y0
	move    y0,x:(r0)+
	move    #Thresh2a4_cpt2,y0
	move    y0,x:(r0)+
	bra     _finish_load
_load3                                        ;GROUP3 parameters
	move    #CPT_THRESH3_HI,x:cpt_level   ;Threshold for magnitude test
	move    #CPT_THRESH3_LO,x:cpt_level+1 ;Threshold for magnitude test
	move    #Thresh5a_cpt3,y0             ;3 thresholds for rel energy
	move    y0,x:(r0)+                    ;  test
	move    #Thresh5b_cpt3,y0
	move    y0,x:(r0)+
	move    #ThreshEN3,y0
	move    y0,x:(r0)+
	move    #Thresh4a_cpt3,y0             ;2 thresholds for twist test
	move    y0,x:(r0)+
	move    #Thresh4b_cpt3,y0
	move    y0,x:(r0)+
	move    #Thresh2a1_cpt3,y0            ;4 Thresholds for rel mag test
	move    y0,x:(r0)+
	move    #Thresh2a2_cpt3,y0
	move    y0,x:(r0)+
	move    #Thresh2a3_cpt3,y0
	move    y0,x:(r0)+
	move    #Thresh2a4_cpt3,y0
	move    y0,x:(r0)+

_finish_load
	rts


;--------------------------------------------------------------------------
; Routine:      MAG_CPT
;
; Description:
;               This module tests the minimum of the 2 energy peaks
;               against a hard threshold. This test is performed to
;               reject noise at the gross level
;
; Inputs:
;               x:pk_add and x:pk_add+1 - contain the indices to the 2
;                 peak energies
;               x0 - Group corresponding to the 2 peaks
; Outputs:
;               x0 = group number if test passed, =0 if it the test fails
;--------------------------------------------------------------------------

MAG_CPT

       move     x:shift_count,y0
       asl      y0                            ;Scale factor for amplitude
       move     x:pk_add,a
       rep      y0                            ;Scale the signal to take care
       asr      a                             ;  of block floating point
       move     x:cpt_level,b
       move     x:cpt_level+1,b0
       cmp      b,a 
       blt      _mgnfailed
       move     x:pk_add+1,a
       rep      y0                            ;Scale the signal to take care
       asr      a                             ;  of block floating point
       cmp      b,a
       bge      _mgnpassed

_mgnfailed
       move     #0,x0
_mgnpassed
       rts



;-------------------------------------------------------------------------
; Routine:      GROUP_TST_CPT
;
; Description:
;               This module performs the validation test against the 2
;               identified peaks. The 2 frequencies should form one of
;               the specified DUAL signals group. Otherwise it means that
;               spurious tones have been picked up. 
;               The tones have been identified and placed under different
;               groups for processing. These groups are as follows.
;
;            Group1      --    350 + 440
;            Group2      --    480 + 620
;            Group3      --    440 + 480
;
;               For ease of computaion two groups viz., lo and high
;               are formed. And are as below
;
;            lo          --    350, 480
;            high        --    440, 620
;
; Inputs:
;               y0 and y1 contain the indices to the 2 peak energies
; Outputs:
;               x0 = 1 for group 1
;                  = 2 for group 2
;                  = 3 for group 3
;                  = 0 for invalid
;--------------------------------------------------------------------------

GROUP_TST_CPT

       move     #mg_energy,r2
       move     #$0,x0                      ;Start with invalid
       tstw     y0
       bne      _first_comb
       cmp      #3,y1
       beq      _exit                       ;The combination 350+620 is
					    ;  ruled out here
       move     x:(r2+1),a                  ;If peak(2) < peak(1)
       move     x:(r2+2),b                  ;  invalid
       cmp      b,a
       bgt      _exit
       move     #CPT_GROUP_1,x0             ;Identified as group 1
       bra      _exit
_first_comb
       move     y1,n
       move     x:(r2),a
       move     x:(r2+n),b                  ;If peak(0) > peak(high)
       cmp      b,a                         ;  invalid
       bgt      _exit                     
       move     #CPT_GROUP_3,x0             ;Identified as group 3
       cmp      #2,y1
       beq      _exit
       move     #CPT_GROUP_2,x0             ;Identified as group 2
_exit

       rts



;--------------------------------------------------------------------------
; Routine:       REL_EN_CPT
;
; Description:
;           This routine performs the Relative Energy tests as part of the
;           decision logic.
;
; Inputts:  x:pk_add and pk_add+1 contain the low and high group energies
;           respectively
;
; Outputs:
;           x0  =  0 if test failed
;                  1 if test passed
;
; Pseudo code:
;              if ((sig_energy*Thresh5c) > (lo_peak+hi_peak))
;                   return 0
;              if ((energy(620Hz) > Thresh*peak energy(lo,hi)
;                   return 0
;              return 1
;---------------------------------------------------------------------------

REL_EN_CPT
TWIST_CPT

	move    x:pk_add,y1               ;Get the low group peak
	move    x:pk_add+1,y0             ;Get the high group peak
	move    #Thresh4a,r1
	cmp     y0,y1
	blt     _maxy0                    ;Acc a contains the min of 2
	move    y0,a                      ;  peaks and y1 contains the max
	lea     (r1)+                     ;point to proper twist threshold
	bra     _continue_relen
_maxy0
	move    y1,a
	move    y0,y1

_continue_relen
	move    a,y0                      ;Save the min energy
	move    y1,n                      ;Save max energy

_TWIST_CPT
	move    n,b
	move    x:(r1)+,y1               
	mpy     b1,y1,b                   ;b = ener(max)*twist_thresh
	move    y0,a                      ;a = ener(min)
	cmp     b,a
	bgt     _twist_passed

_rel_en_failed
	clr     x0

_rel_en_passed
_twist_passed

	rts



;--------------------------------------------------------------------------
; Routine:       REL_MAG_CPT
;
; Description:
;           This routine performs the Relative Magnitude tests.
;
; Inputs:
;           a = min energy
;
; Outputs:
;           x0  =  0 if test failed
;                  the group number if test passed
;
; *** NOTE: The register x0 should not be disturbed throughout the module
;
; Pseudo code:
;---------------------------------------------------------------------------

REL_MAG_CPT

	move     #rel_mag_cpt,r3
	move     #mg_energy,r0
	move     #pk_add,r1
	cmp      #CPT_GROUP_1,x0
	bne      _rel_mag_grp2
	move     x:(r1)+,y1                   ;Get energy of mg_350 filter
	move     #4,n                         ;Offset to thresh for 280 Ener
	jsr      FIND_REL_MAG                 ;Compare 350 & 280 energies
	move     x:(r1),y1                    ;Get mg_440 energy
	move     #1,n
	jsr      FIND_REL_MAG                 ;Compare 440 & 480 energies
	move     #3,n
	jsr      FIND_REL_MAG                 ;Compare 440 & 620 energies
	move     #5,n
	jsr      FIND_REL_MAG                 ;Compare 440 & 700 energies
	bra      _rel_mag_passed

_rel_mag_grp2
	cmp      #CPT_GROUP_2,x0
	bne      _rel_mag_grp3
	move     x:(r1)+,y1                   ;Get energy of mg_480 filter
	move     #4,n                         ;Offset to thresh for 440 Ener
	jsr      FIND_REL_MAG                 ;Compare 480 & 280 energies
	move     #0,n
	jsr      FIND_REL_MAG                 ;Compare 350 & 480 energies
	move     #2,n
	jsr      FIND_REL_MAG                 ;Compare 480 & 440 energies
	move     x:(r1),y1                    ;Get mg_620 energy
	move     #5,n
	jsr      FIND_REL_MAG                 ;Compare 620 & 700 energies
	bra      _rel_mag_passed

_rel_mag_grp3
	move     x:(r1)+,y1                   ;Get energy of mg_480 filter
	move     #3,n                         ;Offset to thresh for 620 Ener
	jsr      FIND_REL_MAG                 ;Compare 480 & 620 energies
	move     #5,n
	jsr      FIND_REL_MAG                 ;Compare 700 & 480 energies
	move     x:(r1),y1                    ;Get energy of mg_440 filter
	move     #4,n
	jsr      FIND_REL_MAG                 ;Compare 440 & 280 energies
	move     #0,n
	jsr      FIND_REL_MAG                 ;Compare 440 & 350 energies
	bra      _rel_mag_passed

_rel_mag_failed
	move     #0,x0
_rel_mag_passed
	rts

FIND_REL_MAG
	move     x:(r3)+,b
	mpy      b1,y1,b
	move     x:(r0+n),a
	cmp      b,a
	bgt      _rel_mag_failed

_rel_mag_passed
	rts

_rel_mag_failed
	clr     x0
	lea     (sp)-                        ;Test failed, goto NEWNUM_CPT
	lea     (sp)-
	rts


    ENDSEC
