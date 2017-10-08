;********************************************************************
;
; Motorola Inc.
; (c) Copyright 2000 Motorola, Inc.
; ALL RIGHTS RESERVED.
;
;********************************************************************
;
; File Name:    dfr16rfft.asm
;
; Description:  Assembly module for Real FFT
;
; Modules
;    Included:  Fdfr16RFFT
;
; Author(s):    Sandeep S (Optimized by Meera S P)
;
; Date:         22 Feb 2000
;
;********************************************************************        
            
    include "portasm.h"
    
;********************************************************************
;
; Module Name:  Fdfr16RFFT
;
; Description:  Computes real FFT for the given input block.
;
; Functions 
;      Called:  Fdfr16Cbitrev - Complex bit reverse function.
;
; Calling 
; Requirements: 1. r2 -> Pointer to RFFT Handle.
;               2. r3 -> Pointer to input buffer whose RFFT is to be
;                        computed.
;               3. x:(sp) -> Pointer to output buffer.
;
; C Callable:   Yes.
;
; Reentrant:    Yes.
;
; Globals:      None.
;
; Statics:      None.
;
; Registers 
;      Changed: All.
;
; DO loops:     20; max. nesting depth = 2.
;
; REP loops:    None.
;
; Environment:  MetroWerks on PC.
;
; Special
;     Issues:   FFT with No Scale option gives correct results only for
;               low energy signals.
;
;******************************Change History************************
;
;    DD/MM/YY     Code Ver     Description      Author(s)
;    --------     --------     -----------      ------
;    22/02/2000   0.1          Module created   Sandeep S
;    09/03/2000   1.0          Reviewed &
;                              Baselined        Sandeep S
;    12/03/2000   1.1          Optimized the
;                              Post-Processing
;                              part             Sandeep S
;    29/01/2001   1.2          Optimized,
;                              Reviewed &
;                              Baselined        Meera S P
;
;********************************************************************
;=========================================================================
; Revision History:
;
; VERSION    CREATED BY    MODIFIED BY      DATE       COMMENTS  
; -------    ----------    -----------      -----      --------
;   0.1      Sandeep S         -          22-02-2000   Created.
;   1.0      Sandeep S         -          09-03-2000   Baselined.
;   1.1         -           Sandeep S     12-03-2000   Optimized the Post-
;                                                      processing part.
;=========================================================================

    SECTION  rtlib

    GLOBAL   Fdfr16RFFT


Fdfr16RFFT

Offset_options        equ    0
Offset_n              equ    1
Offset_Twiddle        equ    2
Offset_Twiddle_br     equ    3
Offset_No_of_Stages   equ    4
Scratch_Size          equ    14

START_BFLY_SZ         equ    2              ;To start with, butterfly size = 2.
THRESHOLD_BFP         equ    0.25           ;Minimum absolute value used in
                                            ;  BFP for comparison.

FFT_DEFAULT_OPTIONS               equ   0   ;Default all options bits 
                                            ;  to 0
FFT_SCALE_RESULTS_BY_N            equ   1   ;Unconditionally scale by N

FFT_SCALE_RESULTS_BY_DATA_SIZE    equ   2   ;Scale according to data 
                                            ;  sizes
FFT_INPUT_IS_BITREVERSED          equ   4   ;Default to normal (linear)
                                            ;  input
FFT_OUTPUT_IS_BITREVERSED         equ   8   ;Default to normal (linear)


    DEFINE    pRFFT          'X:(SP-1)'   ;r2 -> pRFFT
    DEFINE    pX             'X:(SP-2)'   ;r3 -> pX
    DEFINE    pZ             'X:(SP-3)'   ;x:(SP-12) -> pZ since 10
                                          ;  scratch variables r on stack.
    DEFINE    Twiddle        'X:(SP-4)'   ;Pointer to Twid' table.
    DEFINE    passes         'X:(SP-5)'   ;Total no. of stages.
    DEFINE    groups         'X:(SP-6)'   ;Total no. of groups in a
                                          ;  particular stage.
    DEFINE    old_omr        'X:(SP-7)'   ;Scratch to store old omr reg.
    DEFINE    ScaleBF        'X:(SP-8)'   ;Counter to count the number of
                                          ;  stages wherein scaling is done
                                          ;  in BFP method.
    DEFINE    length         'X:(SP-9)'   ;No. of points in FFT.
    DEFINE    tmp            'X:(SP-10)'  ;
    DEFINE    group_cnt      'X:(SP-11)'  
    DEFINE    num_bfly       'X:(SP-12)'
    DEFINE    Twiddle_br     'X:(SP-13)'  ;Pointer to Twid' table.


;---------------------------------
; Accommodate for scratch in stack
;---------------------------------

    move    #Scratch_Size,n                         ;Scratch locations needed for FFT.
    lea     (sp)+n                        ;Update stack pointer.

;----------------------------------------------------------
; Store the existing omr and set the saturation bit to 0
;----------------------------------------------------------

    move    omr,old_omr                   ;Store old omr.
    bfclr   #$30,omr                      ;S-bit = 0, 2's complement
                                          ;rounding.
    
;----------------------------------------
; Extract information from pRFFT
;----------------------------------------
    
    move    r2,pRFFT                      ;Store pointer to pRFFT.
    move    r3,pX                         ;Store pointer to pX.
    move    x:(sp-Scratch_Size-2),x0      ;Store pointer to pZ.
    move    x0,pZ
    move    x:(r2+Offset_Twiddle),x0      ;Store Twiddle factor pointer.
    move    x0,Twiddle
    move    x:(r2+Offset_Twiddle_br),x0      ;Store Twiddle factor pointer.
    move    x0,Twiddle_br
    move    x:(r2+Offset_n),x0            ;Compute no. of groups (to start
    move    x0,length
    move    x:(r2+Offset_No_of_Stages),x0
    move    x0,passes                     ;Number of stages in FFT.

FFT_Computation

;-----------------------------------------------
; Decide whether scaling is AS or BFP
;-----------------------------------------------

    move    pRFFT,r2                      ;r2 -> pRFFT
    nop
    brset   #FFT_SCALE_RESULTS_BY_N,x:(r2+Offset_options),AutoScaling
    move    x:(r2+Offset_options),x0      ;Check if scaling type is BFP
    andc    #FFT_SCALE_RESULTS_BY_DATA_SIZE,x0
    tstw    x0
    jne     BlockFloatingPoint            ;Block floating point...
    jmp     NoScaling                     ;If not, it implies no scaling.

AutoScaling

;----------------------------
; CASE 1: Code for AS.
;----------------------------
    
    move    length,n
    move    pZ,r2
    move    pX,r1
    move    r1,r3                   ;r3 -> 1st Ar of first pass
    move    n,b                     ;Find no. of butterflies in
    lea     (r3)+n                  ;r3 -> 1st Br of 1st pass
   
    move    r2,r0                   ;r0 -> 1st Br of first pass
    move    x:(r1)+,a               ;Get 1st Ar of 1st pass
    lea     (r0)+n
    lea     (r0)-                   ;Adjust r0 so that in first
    asr     b                       ;  first pass , which is half
    move    b,n                     ;  half the no. of DFT points
    move    x:(r0),b                ;Save the memory cotents so
                                    ;  that first parallel move
                                    ;  doesn't corrupt the data
    
    move    x:(r3)+,y0              ;Get 1st Br of 1st pass
    do      n,_first_pass           ;The first pass has to be
                                    ;  repeated length/2 times
    add     y0,a    b,x:(r0)+       ;Find Cr,save Di in previous
                                    ;  Bi. r0 -> Br
    asr     a       x:(r1)+,b       ;Find Cr/2,get Ai,r1 -> next Ar
    rnd     a       x:(r3)+,x0      ;round, get Bi, r3 -> next Br
    sub     y0,a    a,x:(r2)+       ;Find Dr/2 ,save Cr/2,r2 -> Ci
    add     x0,b    a,x:(r0)+       ;Find Ci,save Dr/2 ,r0 ->Di
    asr     b       x:(r1)+,a       ;Find Ci/2, get next Ar,
                                    ;  r1 -> next Ai
    rnd     b       x:(r3)+,y0      ;round Ci/2, get next Br,
                                    ;  r3 -> next Bi
    sub     x0,b    b,x:(r2)+       ;Find Di/2, save Ci/2 ,
                                    ;  r2 -> next Cr. Di/2 saved
                                    ;  in the next loop
_first_pass
    move    b,x:(r0)                ;Save last Di/2 of the 1st pass
    move    pZ,r1                   ;r1 -> 1st Ar of 2nd pass
    move    r1,r3                   ;r3 -> 1st Ar of 2nd pass
                                    ;n set to N, used for
                                    ;  controlling the no.of bflies
                                    ;  per group in the pass.
    move    #2,r2                   ;r2 set to 2,used for controlling
                                    ;  the no. of groups in the pass
    lea     (r3)+n                  ;r3 -> first Br of second pass
    move    passes,a                ;Set counter for no. of passes
    sub     #3,a                    ; last pass is also separate
    move    a,r0
    tstw    r0
    blt      _end_second_pass
_second_pass
    move    r2,x:(sp)+              ;Save r2 & r0 on software stack
    move    r0,x:(sp)+
    move    x:(sp-15),r0            ;r0 ->mem. location of the first
                                    ;  twiddle fac. ,twiddle fac.
                                    ;  stored in bit reversed fashion
    move    n,b                     ;Move n to b for halving
    asr     b                       ;  n =n/2
    move    b,n                     ;  butterflies per group is n
    move    r2,b                    ;Save the no. of groups/passin b
    move    r3,r2                   ;r2 -> first Br of the first pass        
    
    do      b,_end_group            ;Middle loop is done b times
                                    ;b=2**(pass number-1)
                                    ;b = no. of groups/pass
    move    la,x:(sp)+              ;Save the current lc and
    move    lc,x:(sp)+              ;la onto software stack
    move    x:(r0)+,y0   
    move    x:(r3)+,x0              ;y0=Wr,x0=Br,r0 ->Wi, r3 ->Bi
    move    x:(r0)+,y1              ;y1=Wi, r0 -> next Wr
                                    ;  (in bit reversed order)
    move    r0,x:(sp)               ;Save twiddle factor pointer
    move    r1,r0                   ;Move r1 to r0
    lea     (r2)-
 
    move    x:(r2),b                ;Save the contents so that the
                                    ;  mem. contents aren't corrupted
                                    ;  in the first middle loop
    do      n,_end_bfly             ;Inner loop is done n times
                                    ;  n=2**(L-passnumber)
                                    ;  n=no. of butterflies/group
    mpy     y0,x0,b      b,x:(r2)+  ;b=WrBr,store the previous
                                    ;  butterfly's Di,r1->current Ar
    mpy     y1,x0,a      x:(r3)+,x0 ;a=+WiBr,get Bi
    mac     -y0,x0,a                ;a=-WrBi+WiBr
    mac     y1,x0,b      x:(r1)+,x0 ;b=WrBr+WiBi,x0=Ar,r1 -> Ai
    add     x0,b                    ;Find Cr in b
    asr     b                       ;b=Cr/2,Scale down for storage
    rnd     b                       ;Round.The rounding done here
                                    ;  closely matches with the
                                    ;  autoscale mode rounding
    sub     b1,x0                   ;Find Dr/2
    neg     a            b,x:(r0)+  ;a= WrBi-WiBr
                                    ;  Store Cr/2
    move    x:(r1)+,b               ;fetch Ai into b,r1 -> next Ar
    add     b,a          x0,x:(r2)+ ;Find Ci ,store Dr/2,r2 -> Di
    asr     a            x:(r3)+,x0 ;a=Ci/2,x0 = Next Br,
                                    ;  r3 -> Next Bi
    rnd     a                       ;Round
    sub     a,b          a,x:(r0)+  ;b = Di/2, a = Ci/2
                                    ;  store Ci/2
                                    ;  Di/2 stored in next loop
_end_bfly
  
    move    b,x:(r2)+               ;Store last butterfly's Ci
    pop     r0                      ;Restore the pointer pointing
                                    ;  to the twiddle factors
    pop     lc                      ;Restore lc
    move    x:(sp),la               ;Restore la
    move    r2,r1                   ;r1 -> next group's first Ar
    lea     (r2)+n
    lea     (r2)+n                  ;r2 -> next group's first Br
    move    r2,r3                   ;r3 -> next group's first Br
_end_group
    lea     (sp)-
    pop     r0                      ;Restore no. of passes
    move    x:(sp),r2               ;Restore no. of group's
    move    pZ,r1                   ;r1 ->1st Ar,at start of each pass
    move    r1,r3                   ;r3 ->1st Ar,at start of each pass
    move    r2,b                    ;double the no of groups for next
    asl     b            x:(r3)+n,x0
                                    ;  pass,Dummy read  to adjust r3
                                    ;  r3 -> first Br of the next pass
    move    b,r2
    tstw    (r0)-                   ;Test the pass counter for Zero
    bne     _second_pass            ;If less than zero then go to
_end_second_pass                                    ;  last pass .
    move    r2,b
    move    Twiddle_br,r0              ;Get address of twiddle factors
    do      b,_last_pass            ;N/2 groups in last pass
    move    r3,r2
    move    x:(r0)+,y0              ;y0=Wr,r0 -> Wi
    move    x:(r3)+,x0              ;x0=Br,r3 -> Bi
    mpy     x0,y0,b      x:(r0)+,y1 ;b=BrWr, y1=Wi, r0 ->Next Wr
    mpy     y1,x0,a      x:(r3)+,x0 ;a=WiBr
    mac     -y0,x0,a                ;a=-WrBi+WiBr
    mac     y1,x0,b      x:(r1)+,x0 ;b=WiBi+WrBr, x0=Ar, r1 -> Ai
    add     x0,b                    ;Find Cr
    asr     b                       ;Find Cr/2
    rnd     b                       ;Round
    sub     b1,x0                   ;Find Dr/2
    move    b,x:(r1+$ffff)          ;Store Cr/2 , r1 -> Ai
    move    x:(r1)+,b               ;b = Ai, r1 -> Ai
    sub     b,a         x0,x:(r2)+  ;Find -Ci , store Dr/2,r2 ->Di
    asr     a           x:(r3)+n,x0 ;Find -Ci/2, Dummy read to
                                    ;  adjust r3 to next Br
    rnd     a
    add     a,b         x:(r1)+n,x0 ;Find Di/2,Dummy read to
                                    ;  adjust r1
    neg     a           b,x:(r2)+   ;Find Ci/2 ,store Di/2
    move    a,x:(r1+$fffd)          ;Store Ci/2
_last_pass
_End_fft
    
     jmp    PostProcessing

;---------------------------------------------------------------
; CASE 2: Code for BFP
;---------------------------------------------------------------

BlockFloatingPoint


;---------------------------------------------------------------
; See whether the magnitude of any of the data values is > 0.25
;---------------------------------------------------------------

    move    pX,r1                     ;r1 -> 1st Ar of 1st pass
    move    length,n
    move    pZ,r2
    move    n,a
    asl     a
    move    pX,b
    cmp     pZ,b
    beq     _avoid_copy_bfp
    do      a,_endcpy
    move    x:(r1)+,y0
    move    y0,x:(r2)+
_endcpy
_avoid_copy_bfp
    move    pZ,r1
    move    r1,r3                     ;r3 -> 1st Ar of 1st pass
    move    passes,x0
    dec     x0
    move    x0,tmp
    move    #1,r2                     ;r2 set to 1, for controlling
                                      ;  the no. of groups in the pass
    lea     (r3)+n                    ;r3 -> first Br of first pass
    move    #0,ScaleBF                ;Memory location used as a flag
                                      ;  0 indicates last pass is not
                                      ;  to be scaled down
_first_passBF
    move    r1,r0                     ;r0 -> first Br
    move    length,y0                 ;y0= number of points in fft
    move    #0,x0                     ;x0= 0; smallest positive number
    move    x:(r0)+,a                 ;a= first Ar, r0 -> First Ai
    do      y0,_chkp                  ;Repeat for all samples
    abs     a      x:(r0)+,b          ;Get the magnitude in acc a
                                      ;  get the next data in acc b
    or      a1,x0                     ;Get the most significant bit of
                                      ;  the largest number in x0
    abs     b      x:(r0)+,a          ;Get the magnitude of next data
                                      ;  in b and get next data in a
    or      b1,x0                     ;Find the max value in x0
_chkp
    move    Twiddle_br,r0             ;r0 ->memory location of the
                                      ;  first twiddle factor Wr
    move    n,b                       ;Move n to b for halving
    asr     b
    move    b,n                       ;n = n/2
    move    r2,group_cnt              ;Store the group count
    move    r2,b                      ;Save the no.of groups in a pass
    move    r3,r2                     ;r2 -> first Br of the pass
    cmp     #$2000,x0                  ;Compare the max value with 0.25
    ble     _nscdown                  ;If greater, perform the sc_down
                                      ;  pass, else no scale down pass
    incw    ScaleBF                   ;Increment the scale_fac by one
    do      b,_end_groupBF            ;Middle loop is done b times
                                      ;  b=2**(pass number-1)
                                      ;  b = no. of groups/pass
    move    la,x:(sp)+                ;Save the current loop counter and
    move    lc,x:(sp)+                ;  loop address onto software stack
    move    x:(r0)+,y0   
    move    x:(r3)+,x0                ;y0=Wr, x0=Br, r0 -> Wi, r3 -> Bi
    move    x:(r0)+,y1                ;y1=Wi, r0 -> next Wr
                                      ;  (in bit reversed order)
    move    r0,x:(sp)                 ;Save twiddle factor
    move    r1,r0                     ;Move r1 to r0
    lea     (r2)-
    move    x:(r2),b                  ;Save the contents so that they
                                      ;  are not corrupted in the first
                                      ;  middle loop
    do      n,_end_bflyBF             ;Inner loop is done n times
                                      ;  n=2**(L-passnumber)
                                      ;  n=no. of butterflies/group
    mpy     y0,x0,b      b,x:(r2)+    ;b=WrBr, store previous butter-
                                      ;  fly's Di , r1 -> current Ar
    mpy     y1,x0,a      x:(r3)+,x0   ;a=+WiBr, get Bi
    mac     -y0,x0,a                  ;a=-WrBi+WiBr
    mac     y1,x0,b      x:(r1)+,x0   ;b=WrBr+WiBi,x0=Ar,r1 -> Ai
    add     x0,b                      ;Find Cr in b
    asr     b                         ;b=Cr/2, Scale down for storage
    rnd     b                         ;Round. The rounding done here
                                      ;  closely matches with the
                                      ;  autoscale down mode rounding
    sub     b1,x0                     ;Find Dr/2
    neg     a            b,x:(r0)+    ;a = WrBi - WiBr
                                      ;  store Cr/2
    move    x:(r1)+,b                 ;Fetch Ai into b, r1-> next Ar
    add     b,a          x0,x:(r2)+   ;Find Ci, store Dr/2, r2-> Di
    asr     a            x:(r3)+,x0   ;a=Ci/2, x0= Next Br,
                                      ;  r3-> Next Bi
    rnd     a                         ;Round
    sub     a,b          a,x:(r0)+    ;b=Di/2, a=Ci/2, store Ci/2
                                      ;  Di/2 is stored in next loop
_end_bflyBF
    move    b,x:(r2)+                 ;Store last butterfly's Ci
    pop     r0                        ;Restore the pointer pointing
                                      ;  to the twiddle factors
    pop     lc                        ;Restore lc
    move    x:(sp),la                 ;Restore la
    move    r2,r1                     ;r1 -> next group's first Ar
    lea     (r2)+n
    lea     (r2)+n                    ;r2 -> next group's first Br
    move    r2,r3                     ;r3 -> next group's first Br
_end_groupBF
    move    pZ,r3                      ;r1 -> 1st Ar, for start of each
                                       ;  pass
    move    group_cnt,b                ;Restore no. of group's
    move    r3,r1                      ;r3 -> 1st Ar,for start of each
                                       ;  pass
    asl     b            x:(r3)+n,x0   ;Double the no of groups for next
                                       ;  pass ,Dummy read into x0
                                       ;  r3-> first Br of the next pass
    move    b,r2
    decw    tmp                        ;Test for pass counter
                                       ;  r2=2**(pass number-1)
    jne     _first_passBF              ;perform the loop till counter= 0
    bra     _lpass
_nscdown                               ;No scale down mode
    move    n,num_bfly                 ;Save the number of buttrflies
    do      b,_end_group2              ;Middle loop is done r2 times
                                       ;  r2=2**(pass number-1)
    move    la,x:(sp)+                 ;Save the current loop counter and
    move    lc,x:(sp)                  ;  loop address onto software
                                       ;  stack (in bit reversed order)
    move    n,lc
    move    #0,n                       ;Offset for each pass
    move    x:(r0)+,y0   
    move    x:(r3)+,x0                 ;y0=Wr, x0=first Br of the
                                       ;  group. r0->Next Wr. r3->first
                                       ;  Bi of the group.
    do      lc,_end_bfly2              ;Inner loop is done n times
                                       ;  n=2**(L-passnumber)
    mpy     x0,y0,b      x:(r0)+n,y1   
    move    x:(r3)-,x0
                                       ;y1=Wi, b=WrBr, x0=Bi, r3->Br
                                       ;  r0->Wi
    macr    x0,y1,b      x:(r1)+n,a    ;b=WrBr+WiBi, a=Ar, r1->Ar
    add     a,b                        ;Find Cr in b, b=Ar+WrBr+WiBi,
    asl     a            b,x:(r1)+     ;a=2Ar, store Cr. r1->Ai
    sub     b,a          x:(r3)+,b     ;Find Dr in a, b=Br, r3->Bi
    neg     b            a,x:(r2)+     ;b=-Br, store Dr, r2->Bi
    mpy     b1,y1,b      x:(r3)+,x0    ;b=-Brwi, x0=Bi, r3->Next Br
    macr    y0,x0,b      x:(r1)+n,a    ;b=WrBi-WiBr, a=Ai, r1->Ai
    add     a,b          x:(r3)+,x0    ;Find Ci in b, x0=Next Br,
                                       ;  r3->Next Bi
    asl     a            b,x:(r1)+     ;a=2Ai, store Ci, r1->Next Ar
    sub     b,a                        ;Find Di
    move    a,x:(r2)+                  ;Store Di, r2->Next Br
_end_bfly2
    lea     (r0)+                      ;r0->First Wr of next group
    pop     lc                         ;Restore lc
    pop     la                         ;Restore la
    lea     (sp)+
    move    num_bfly,n                 ;Restore the no. of butterflies
    move    r2,r1                      ;r1->next group,s first Ar
    lea     (r2)+n
    lea     (r2)+n                     ;r2 -> next group's first Br
    move    r2,r3                      ;r3-> Next groups first Br
_end_group2
    move    pZ,r3                      ;r1 -> 1st Ar, for start of each
                                       ;  pass
    move    group_cnt,b                ;Get the group count
    move    r3,r1                      ;r3 -> 1st Ar of next pass
    asl     b            x:(r3)+n,x0   ;Double the no of groups for next
                                       ;  pass ,Dummy read into x0 to
                                       ;  adjust r3, r3 -> first Br of
                                       ;  the next pass
    move    b,r2                       ;r2=number of groups
    decw    tmp                        ;Tets the pass counter for zero
                                       ;  r2=2**(pass number-1)
    jne     _first_passBF              ;If not equal to zero then go to
                                       ;  beginning of the pass
_lpass                                 ;data scanning for the last pass
    move    pZ,r0                      ;r0->first Ar
    move    length,y0                  ;y0= number of points in fft
    move    #0,x0                      ;x0= 0; smallest positive number
    move    x:(r0)+,a                  ;a= first Ar, r0 -> First Ai
    do      y0,_chklp                  ;Repeat for all samples
    abs     a      x:(r0)+,b           ;Get the magnitude in acc a
                                       ;  get the next data in acc b
    or      a1,x0                      ;Get the most significant bit of
                                       ;  the largest number in x0
    abs     b      x:(r0)+,a           ;Get the magnitude of next data
                                       ;  in b and get next data in a
    or      b1,x0                      ;Find the max value in x0
_chklp
    move    Twiddle_br,r0                 ;r0->first Wr
    cmp     #0.25,x0                   ;if the largest value is > 0.25
    ble     _lnscdown                  ;  perform scale down pass
    incw    ScaleBF                    ;Increment the scale factor
    do      r2,_last_pass1             ;N/2 groups in last pass
    move    r3,r2
    move    x:(r0)+,y0   
    move    x:(r3)+,x0                 ;y0=Wr, x0=Br, r0 -> Wi, r3 -> Bi
    mpy     x0,y0,b      x:(r0)+,y1    ;b=BrWr, y1=Wi, r0 -> Next Wr
    mpy     y1,x0,a      x:(r3)+,x0    ;a=WiBr
    mac     -y0,x0,a                   ;a=-WrBi+WiBr
    mac     y1,x0,b      x:(r1)+,x0    ;b=WiBi+WrBr, x0=Ar, r1 -> Ai
    add     x0,b                       ;Find Cr
    asr     b                          ;Find Cr/2
    rnd     b                          ;Round
    sub     b1,x0                      ;Find Dr/2
    move    b,x:(r1+$ffff)             ;Store Cr/2 , r1 -> Ai
    move    x:(r1)+,b                  ;b = Ai, r1 -> Ai
    sub     b,a         x0,x:(r2)+     ;Find -Ci , store Dr/2,r2 ->Di
    asr     a           x:(r3)+n,x0    ;Find -Ci/2, Dummy read to adjust
                                       ;  r3 to next Br
    rnd     a                          ;Round,Dummy read to adjust r1
                                       ;r1 -> Next Ar
    add     a,b         x:(r1)+n,x0    ;Find Di/2
    neg     a           b,x:(r2)+      ;Find Ci/2 ,store Di/2
    move    a,x:(r1+$fffd)             ;Store Ci/2
_last_pass1
    bra     _rev                       ;Perform bitreversal operation
_lnscdown                              ;Last pass no scale down
    move    #0,n                       ;Offset for the last pass
    do      r2,_last_pass2             ;N/2 number of butterflies
    move    x:(r0)+,y0   
    move    x:(r3)+,x0                 ;y0=Wr, x0=Br, r0->Wi, r3->Bi
    mpy     x0,y0,b      x:(r0)+,y1
    move    x:(r3)-,x0
                                       ;b=WrBr, y1=Wi, x0=Bi, r0->Wi
                                       ;  r3->Br
    macr    x0,y1,b      x:(r1)+n,a    ;b=WrBr+WiBi, a=Ar, r1->Ar
    add     a,b                        ;Find Cr in b, b=Ar+WrBr+WiBi,
    asl     a            b,x:(r1)+     ;a=2Ar, store Cr, r1->Ai
    sub     b,a          x:(r3)+n,b    ;Find Dr in a, a=2Ar-Cr, b=Br
                                       ;  r3->Br
    neg     b            a,x:(r3)+     ;b=-Br, store Dr, r3->Bi
    mpy     b1,y1,b      x:(r3)+n,x0   ;b=-BrWi, x0=Bi, r3->Bi
    macr    y0,x0,b      x:(r1)+n,a    ;b=WrBi-BrWi, a=Ai, r1->Ai
    add     a,b                        ;find Ci in acc b
    asl     a            b,x:(r1)+     ;a=2Ai, store Ci, r1->Br
    sub     b,a          x:(r1)+,x0    ;Find Di in acc a, dummy read
                                       ;  in x0, r1->Bi
    move    a,x:(r3)+                  ;Store Di, r3-> Ar of next
                                       ;  butterfly
    move    x:(r1)+,y0   
    move    x:(r3)+,x0                 ;Dummy reads, r1->Ar of next
                                       ;  butterfly, r3->Ai
    lea     (r3)+                      ;r3-> Br of next butterfly
_last_pass2
_rev

    jmp     PostProcessing
 
NoScaling

;---------------------------------------------------------------
; CASE 3: Code for no-scaling. 
;---------------------------------------------------------------

    move    length,n
    move    pZ,r2
    move    pX,r1
    move    r1,r3                   ;r3 -> 1st Ar of first pass
    move    n,b                     ;Find no. of butterflies in
    lea     (r3)+n                  ;r3 -> 1st Br of 1st pass
   
    move    r2,r0                   ;r0 -> 1st Br of first pass
    move    x:(r1)+,a               ;Get 1st Ar of 1st pass
    lea     (r0)+n
    lea     (r0)-                   ;Adjust r0 so that in first
    asr     b                       ;  first pass , which is half
    move    b,n                     ;  half the no. of DFT points
    move    x:(r0),b                ;Save the memory cotents so
                                    ;  that first parallel move
                                    ;  doesn't corrupt the data
    
    move    x:(r3)+,y0              ;Get 1st Br of 1st pass
    do      n,_first_pass_NS        ;The first pass has to be
                                    ;repeated length/2 times
    add     y0,a    b,x:(r0)+       ;Find Cr,save Di in previous
    rnd     a       x:(r3)+,x0      ;round, get Bi, r3 -> next Br
    sub     y0,a    a,x:(r2)+       ;save Cr,r2 -> Ci
    sub     y0,a    x:(r1)+,b       ;Find Dr,get Ai,r1 -> next Ar
    add     x0,b    a,x:(r0)+       ;Find Ci,save Dr ,r0 ->Di
    rnd     b       x:(r3)+,y0      ;round Ci, get next Br,
                                    ;r3 -> next Bi
    sub     x0,b    b,x:(r2)+       ;Find Di, save Ci,
                                    ;r2 -> next Cr.
    sub     x0,b    x:(r1)+,a       ;Find Di, get next Ar,                                    Di saved
                                    ;in the next loop
_first_pass_NS
    move    b,x:(r0)                ;Save last Di/2 of the 1st pass
    move    pZ,r1                   ;r1 -> 1st Ar of 2nd pass
    move    r1,r3                   ;r3 -> 1st Ar of 2nd pass
                                    ;n set to N, used for
                                    ;controlling the no.of bflies
                                    ;per group in the pass.
    move    #2,r2                   ;r2 set to 2,used for controlling
                                    ;the no. of groups in the pass
    lea     (r3)+n                  ;r3 -> first Br of second pass
    move    passes,a                ;Set counter for no. of passes
    sub     #3,a                    ;last pass is also separate
    brset   #$0008,sr,_fft_4_NS
    move    a,r0
_second_pass_NS
    move    r2,x:(sp)+              ;Save r2 & r0 on software stack
    move    r0,x:(sp)+
    move    x:(sp-15),r0            ;r0 ->mem. location of the first
                                    ;twiddle fac. ,twiddle fac.
                                    ;stored in bit reversed fashion
    move    n,b                     ;Move n to b for halving
    asr     b                       ;n =n/2
    move    b,n                     ;butterflies per group is n
    move    r2,b                    ;Save the no. of groups/passin b
    move    r3,r2                   ;r2 -> first Br of the first pass        
    
    do      b,_end_group_NS         ;Middle loop is done b times
                                    ;b=2**(pass number-1)
                                    ;b = no. of groups/pass
    move    la,x:(sp)+              ;Save the current lc and
    move    lc,x:(sp)+              ;la onto software stack
    move    x:(r0)+,y0   
    move    x:(r3)+,x0              ;y0=Wr,x0=Br,r0 ->Wi, r3 ->Bi
    move    x:(r0)+,y1              ;y1=Wi, r0 -> next Wr
                                    ;(in bit reversed order)
    move    r0,x:(sp)               ;Save twiddle factor pointer
    move    r1,r0                   ;Move r1 to r0
    lea     (r2)-
 
    move    x:(r2),b                ;Save the contents so that the
                                    ;mem. contents aren't corrupted
                                    ;in the first middle loop
    do      n,_end_bfly_NS          ;Inner loop is done n times
                                    ;n=2**(L-passnumber)
                                    ;n=no. of butterflies/group
    mpy     y0,x0,b      b,x:(r2)+  ;b=WrBr,store the previous
                                    ;butterfly's Di,r1->current Ar
    mpy     y1,x0,a      x:(r3)+,x0 ;a=+WiBr,get Bi
    mac     -y0,x0,a                ;a=-WrBi+WiBr
    mac     y1,x0,b      x:(r1)+,x0 ;b=WrBr+WiBi,x0=Ar,r1 -> Ai
    add     x0,b                    ;Find Cr in b
    rnd     b                       ;Round.The rounding done here
                                    ;closely matches with the
                                    ;autoscale mode rounding
    asl     x0                      ;Get 2*Ar                                     
    sub     b1,x0                   ;Find Dr [ Dr = 2*Ar - Cr]
    neg     a            b,x:(r0)+  ;a= WrBi-WiBr
                                    ;Store Cr
    move    x:(r1)+,b               ;fetch Ai into b,r1 -> next Ar
    add     b,a          x0,x:(r2)+ ;Find Ci ,store Dr,r2 -> Di
                                    ;r3 -> Next Bi
    rnd     a            x:(r3)+,x0 ;Round
    asl     b                       ;Get 2*Ai
    sub     a,b          a,x:(r0)+  ;Find Di,[Di = 2*Ai - Ci]
                                    ;store Ci
                                    ;Di stored in next loop
_end_bfly_NS
 
  
    move    b,x:(r2)+               ;Store last butterfly's Ci
    pop     r0                      ;Restore the pointer pointing
                                    ;to the twiddle factors
    pop     lc                      ;Restore lc
    move    x:(sp),la               ;Restore la
    move    r2,r1                   ;r1 -> next group's first Ar
    lea     (r2)+n
    lea     (r2)+n                  ;r2 -> next group's first Br
    move    r2,r3                   ;r3 -> next group's first Br
_end_group_NS
    lea     (sp)-
    pop     r0                      ;Restore no. of passes
    move    x:(sp),r2               ;Restore no. of group's
    move    pZ,r1                   ;r1 ->1st Ar,at start of each pass
    move    r1,r3                   ;r3 ->1st Ar,at start of each pass
    move    r2,b                    ;double the no of groups for next
    asl     b            x:(r3)+n,x0
                                    ;pass,Dummy read  to adjust r3
                                    ;r3 -> first Br of the next pass
    move    b,r2
    tstw    (r0)-                   ;Test the pass counter for Zero
    bne     _second_pass_NS         ;If less than zero then go to
                                    ;last pass .
_fft_4_NS

    move    r2,b                    ;double the no of groups for next    
    move    Twiddle_br,r0           ;Get address of twiddle factors
    do      b,_last_pass_NS         ;N/2 groups in last pass
    move    r3,r2
    move    x:(r0)+,y0   
    move    x:(r3)+,x0              ;y0=Wr,x0=Br,r0 -> Wi,r3 -> Bi
    mpy     x0,y0,b      x:(r0)+,y1 ;b=BrWr, y1=Wi, r0 ->Next Wr
    mpy     y1,x0,a      x:(r3)+,x0 ;a=WiBr
    mac     -y0,x0,a                ;a=-WrBi+WiBr
    mac     y1,x0,b      x:(r1)+,x0 ;b=WiBi+WrBr, x0=Ar, r1 -> Ai
    add     x0,b                    ;Find Cr
    rnd     b                       ;Round
    asl     x0                      ;Get 2*Ar
    sub     b1,x0                   ;Find Dr [Dr = 2*Ar - Cr]
    move    b,x:(r1+$ffff)          ;Store Cr , r1 -> Ai
    move    x:(r1)+,b               ;b = Ai, r1 -> Ai
    sub     b,a         x0,x:(r2)+  ;Find -Ci , store Dr,r2 ->Di
    rnd     a           x:(r3)+n,x0 ;Find -round(Ci), Dummy read to
                                    ;adjust r3 to next Br
    asl     b                       ;Get 2*Ai
    add     a,b         x:(r1)+n,x0 ;Find Di,Dummy read to
                                    ;adjust r1
    neg     a           b,x:(r2)+   ;Find Ci ,store Di
    move    a,x:(r1+$fffd)          ;Store Ci
_last_pass_NS
_End_fft_NS

PostProcessing

    move    pRFFT,r2                      ;r2 -> pRFFT.
    nop

    ;--------------------------------------------------------
    ; Set up the parameters for calling bit-reverse function
    ;--------------------------------------------------------

    move    x:(r2+Offset_n),y0            ;y0 = N, the size of FFT.
    move    pZ,r2
    move    r2,r3
    jsr     Fdfr16Cbitrev                 ;Call bit reverse function.
                                          ;Result is returned in y0.
    ;----------------------------------------------
    ; Post processing for RFFT on the output buffer
    ;----------------------------------------------

    move    pRFFT,r2                      ;r2 -> pRFFT.
    nop
    brset   #FFT_SCALE_RESULTS_BY_N,x:(r2+Offset_options),Start1
    move    x:(r2+Offset_options),x0      ;Group offset.
    andc    #FFT_SCALE_RESULTS_BY_DATA_SIZE,x0
    tstw    x0
    jeq     DonotScale                    ;No Scaling ...
            
    move    pZ,r0                         ;r0 -> pZ, the output buffer.
    move    x:(r2+Offset_n),y0            ;y0 = N.
    move    #0,x0                         ;x0 = smallest positive number.
    move    x:(r0)+,a                     ;a = First data value (real).
    
    do      y0,ChkMagnitude
    abs     a            x:(r0)+,b        ;a = |a|, b = Next data value
                                          ;  (imag).
    or      a1,x0                         ;Get the most significant bit of
                                          ;  the largest number, in x0.
    abs     b            x:(r0)+,a        ;b = |b|, a = Next data value
                                          ;  (real).
    or      b1,x0                         ;Get the most significant bit of
                                          ;  the largest number, in x0.
ChkMagnitude
    
    cmp     #THRESHOLD_BFP,x0             ;Compare the max value with 0.25.
    jle     DonotScale                    ;If <=, no scaling is required in
                                          ;  the first pass.
    incw    ScaleBF                       ;Increment the count which finally
  
Start1
    
    move    pZ,r1                         ;r1 --> zr[0]
    move    Twiddle,a                     ;a = Twiddle[0].real
    add     #3,a
    move    length,n                      ;size of FFT
    move    r1,r0                         ;r0 -->zr[0]
    move    a1,r3                         ;r3 -> Twiddle[1].imag
    lea     (r0)+n                        ;r0 -->zr[N/2-k]
    lea     (r0)+n 
    move    #-1,n                         ;n set for decrementing r1,r0,r3
    
    move    x:(r1)+,b                     ;A = b = zr[0], r1 --> zi[0]
    move    x:(r1)-,a                     ;C = a = zi[0], r1 --> zi[0]
    move    a,y1                          ;Copy of C
    add     b,a          x:(r0)+n,x0      ;a = A + C, Dummy read,
                                          ;  r0 -> pW[N/2-1].imag 
                                          ;  (i.e., last location)
    asr     a                             ;a = (A + C)/2 = zr[0]/2
    sub     y1,a         a,x:(r1)+        ;a = (A - C)/2, Store zr[0]/2,
                                          ;  r1 -> zi[0]
    move    a,x:(r1)+                     ;Store zi[0]/0, r1 -> zr[1] 
    
    move    length,a
    asr     a            x:(r1)+,y1       ;y1 = pW[i].real = zr[1]
                                          ;  r1 -> zi[1].
    do      a1,_endpass_AS            ;for k=0 to (N/4+1)
    move    x:(r0)+n,b                ;get zi[N/2-k], r0 --> zr[N/2-k]
    asr     b            x:(r1)+n,a   ;get zi[k], r1 --> zr[k]
    asr     a            x:(r3)+n,x0  ;get sin(2*pi*k/N)
                                      ;  r3 --> cos(2*pi*k/N)
    add     a,b                       ;compute C
    asl     a            b,x:(r1)+    ;Find 2*zi[k],save C at zr[k]
                                      ;  r1->zi[k]
    sub     b,a          x:(r0)+,b    ;compute D = 2*zi[k] - C
    asr     b
                                      ;  get zr[N/2-k],r0 -> zi[N/2-k]
    tfr     y1,a         a,x:(r0)+n   ;Get zr[k],save D at zi[N/2-k]
                                      ;  r0 --> zr[N/2-k]
    asr     a            x:(r1)+n,y0  ;compute B, dummy read
                                      ;  r1 --> zr[k] or C
    add     b,a          x:(r1)+,y1   ;compute A, y1 = C, r1 --> zi[k]  
    asl     b                         ;Find 2*zr[N/2-k]
    sub     a,b            
    move    b,y0                      ;Save B
    mpy     x0,y0,b      x:(r3)+,x0   ;Compute sin(2PIk/N)*B 
                                      ;  get cos(2*pi*k/N)
                                      ;  r3 --> sin(2*pi*k/N)
    macr    y1,x0,b                   ;compute sin(2PIk/N)*B+
                                      ;  cos(2PIk/N)*C
    add     a,b                       ;compute 2*xr[k]
    asr     b                         ;compute xr[k]
    sub     b,a          b,x:(r0)+    ;compute xr[N/2-k]
                                      ;  save xr[k] at zr[N/2-k]
                                      ;  r0 ->zi[k]
    mpy     y0,x0,b      x:(r0)+n,y0  ;b = B * Twid[i].real
                                      ;  y0 = D.
    move    x:(r3)+,x0                ;x0 = Twid[i].imag
                                      ;compute B*cos(2*pi*k/N)
                                      ;  get D,r0 -> zr[N/2-k]
                                      ;  get sin(2*pi*k/N)
                                      ;  r3 -> cos(2*pi*k/N)
    macr    -y1,x0,b                  ;compute -C*sin(2*pi*k/N)+
                                      ;  B*cos(2*pi*k/N)
    add     y0,b         x:(r3)+,x0   ;compute 2*xi[k],dummy read
                                      ;  r3 -> sin(2*pi*(k+1)/N)
    asr     b            x:(r1)+n,x0  ;compute xi[k],
                                      ;  dummy read ,r1 -> zr[k]
    move    b,x0
    sub     y0,b         x:(r0)+,y0   ;compute xi[N/2-k]
    
    move    y0,x:(r1)+
    move    b,x:(r0)+n
    move    a,x:(r0)+n
    move    x0,x:(r1)+
    move    x:(r1)+,y1                ;get zr[k+1],r1 -> zi[k+1]
                                      ;  r1 -> zi[k+1]
_endpass_AS
                                      ;computations for k=N/4+1
                                      ; at this stage r0 = r1
    move    x:(r1)+n,y0
    move    y1,x:(r1)+
    move    y0,x:(r1)

_end_rfft_AS


    jmp     return_AS


DonotScale
    move    pZ,r1                         ;r1 --> zr[0]
    move    Twiddle,a                     ;a = Twiddle[0].real
    add     #3,a
    move    length,n                      ;size of FFT
    move    r1,r0                         ;r0 -->zr[0]
    move    a1,r3                         ;r3 -> Twiddle[1].imag
    lea     (r0)+n                        ;r0 -->zr[N/2-k]
    lea     (r0)+n 
    move    #-1,n                         ;n set for decrementing r1,r0,r3
    
    move    x:(r1)+,b                     ;A = b = zr[0], r1 --> zi[0]
    move    x:(r1)-,a                     ;C = a = zi[0], r1 --> zi[0]
    move    a,y1                          ;Copy of C
    add     b,a          x:(r0)+n,x0      ;a = A + C, Dummy read,
                                          ;  r0 -> pW[N/2-1].imag 
                                          ;  (i.e., last location)
    sub     y1,b         a,x:(r1)+        ;b = A - C, Store zr[0],
                                          ;  r1 -> zi[0]
    move    b,x:(r1)+                     ;Store zi[0], r1 -> zr[1] 
    
    move    length,a
    asr     a            x:(r1)+,y1   ;y1 = pW[i].real
    do      a1,_endpass_NS            ;for k=0 to (N/4+1)
    move    x:(r0)+n,b                ;get zi[N/2-k], r0 --> zr[N/2-k]
    asr     b            x:(r1)+n,a   ;get zi[k], r1 --> zr[k]
    asr     a            x:(r3)+n,x0  ;get sin(2*pi*k/N)
                                      ;  r3 --> cos(2*pi*k/N)
    add     a,b                       ;compute C
    asl     a            b,x:(r1)+    ;Find 2*zi[k],save C at zr[k]
                                      ;  r1->zi[k]
    sub     b,a          x:(r0)+,b    ;compute D = 2*zi[k] - C
    asr     b
                                      ;  get zr[N/2-k],r0 -> zi[N/2-k]
    tfr     y1,a         a,x:(r0)+n   ;Get zr[k],save D at zi[N/2-k]
                                      ;  r0 --> zr[N/2-k]
    asr     a            x:(r1)+n,y0  ;compute B, dummy read
                                      ;  r1 --> zr[k] or C
    add     b,a          x:(r1)+,y1   ;compute A, y1 = C, r1 --> zi[k]  
    asl     b                         ;Find 2*zr[N/2-k]
    sub     a,b            
    move    b,y0                      ;Save B
    mpy     x0,y0,b      x:(r3)+,x0   ;Compute sin(2PIk/N)*B 
                                      ;  get cos(2*pi*k/N)
                                      ;  r3 --> sin(2*pi*k/N)
    mac     y1,x0,b                   ;compute sin(2PIk/N)*B+
                                      ;  cos(2PIk/N)*C
    add     a,b                       ;compute 2*xr[k]
    rnd     b
    asl     a            b,x:(r0)+    ;a = 2*A
                                      ;  save xr[k] at zr[N/2-k]
                                      ;  r0 ->zi[k]
    sub     b,a                       ;compute xr[N/2-k]
    mpy     y0,x0,b      x:(r0)+n,y0  ;b = B * Twid[i].real
                                      ;  y0 = D.
    move    x:(r3)+,x0                ;x0 = Twid[i].imag
                                      ;compute B*cos(2*pi*k/N)
                                      ;  get D,r0 -> zr[N/2-k]
                                      ;  get sin(2*pi*k/N)
                                      ;  r3 -> cos(2*pi*k/N)
    mac     -y1,x0,b                  ;compute -C*sin(2*pi*k/N)+
                                      ;  B*cos(2*pi*k/N)
    add     y0,b         x:(r3)+,x0   ;compute 2*xi[k],dummy read
                                      ;  r3 -> sin(2*pi*(k+1)/N)
    rnd     b            x:(r1)+n,x0  ;compute xi[k],
                                      ;  dummy read ,r1 -> zr[k]
    move    b,x0
    asl     y0                        ;y0 = 2*D
    sub     y0,b         x:(r0)+,y0   ;compute xi[N/2-k]
    
    move    y0,x:(r1)+
    move    b,x:(r0)+n
    move    a,x:(r0)+n
    move    x0,x:(r1)+
    move    x:(r1)+,y1                ;get zr[k+1],r1 -> zi[k+1]
                                      ;  r1 -> zi[k+1]
_endpass_NS
                                      ;computations for k=N/4+1
                                      ; at this stage r0 = r1
    move    x:(r1)+n,y0
    move    y1,x:(r1)+
    move    y0,x:(r1)

_end_rfft_NS


;----------------------------------------------------------
; Restore the existing omr and set the saturation bit to 0
;----------------------------------------------------------

return_AS

    move    pRFFT,r2                      ;r2 -> pRFFT.
    move    ScaleBF,y1                    ;Return amount of scaling done in
                                          ;  BFP method.
    move    old_omr,omr                   ;Restore previous OMR value.
    move    #-Scratch_Size,n
    lea     (sp)+n                        ;Restore SP
    move    x:(r2+Offset_options),x0
    brclr   #FFT_SCALE_RESULTS_BY_N,x0,return_BFP
                                          ;Is it AS?
    move    x:(r2+Offset_No_of_Stages),y0
    add     #1,y0
    rts

return_BFP

    brclr   #FFT_SCALE_RESULTS_BY_DATA_SIZE,x0,return_NS
    move    y1,y0                         ;Return amount of scaling done in
                                          ;  BFP method.
    rts

return_NS

    move    #0,y0                         ;No scaling is done, return 0.
    rts
              
    ENDSEC
