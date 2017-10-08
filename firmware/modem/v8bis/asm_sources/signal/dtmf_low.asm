;***********************************************************************
;
; Motorola India Electronics Ltd. (MIEL)
;
; PROJECT ID           : V.8 bis
;
; ASSEMBLER            : ASM56800 version 6.2.0
;
; FILE NAME            : dtmf_low.asm 
;
; PROGRAMMER           : G.Prashanth
;
; DATE CREATED         : 27:03:98
;
; FILE DESCRIPTION     : This file computes the mg_energy  
;  
; FUNCTIONS            : Upd, Newnum,Calc_Mg_En
;
; MACROS               : Nil
;
;************************************************************************  
        

        include 'tone_set.asm'
        include 'v8bis_equ.asm'
        
        SECTION dtmf_low                        
        GLOBAL    Newnum
        GLOBAL    Calc_Mg_En

;***************************** Module ********************************
;
;  Module Name   :  Upd
;  Author        :  G.Prashanth
; 
;*************************** Description *******************************
;
;       This is a macro, uses the input to update the 
;       MG filter states for NO_DTMF filters, ie. for DTMF filter
;       and NO_STF filters if it is for STF filters.
;
;
;  Calls:
;       Modules  : 
;       Macro    : 
;
;************************** Revision History ***************************
;
;   Date                 Author              Description 
;  ------              ----------              ---------
;  18:03:98           G.Prashanth        Module Created. 
;  01:06:98           G.Prashanth        Incorporated Review comments
;  03:07:2000         N R Prasad         Ported on to Metrowerks;
;                                        converted macro UPD to 
;                                        function Upd.
;  07:08:2000         N R Prasad         Internal memory moved to 
;                                        external; hence dual parallel
;                                        moves converted into single
;                                        parallel moves.
;
;************************ Calling Requirements *************************
;
;  1. Initialize x:no_of_filter.
;
;
;************************* Input and Output ****************************
;
;    Input:
;       x(k)        = | s.fff ffff | ffff ffff |      in  a 
;       si(k)       = | s.fff ffff | ffff ffff |      in  x:sik
;       si(k-1)     = | s.fff ffff | ffff ffff |      in  x:sik+1
;                     i=0,..,NO_DTMF-1 for DTMF NO_STF for STF
;       cosval(i)   = | s.fff ffff | ffff ffff |      in
;                     cosval_dtmf to cosval_stf+3 for DTMF and cosval_stf to 
;                     cosval_stf+5 for STF                                      
;       r0          -> last si(k) (modulo 2*NO_DTMF for DTMF and NO_STF for STF)
;       r3          -> current channel's s0(k-2) 
;       r1          -> cosval(0) or cosval_stf(0)
;       n           =  2
;       x0          =  current channel's s0(k-2)
;       y1          =  current channel's s0(k-1)
;       b           =  last si(k)
;    x:no_of_filter =  | 0000 0000 | 0000 0iii|  
;                      NO_DTMF for DTMF and NO_STF for STF     
;
;    Output:
;       si(k)       = | s.fff ffff | ffff ffff |      in  x:sik
;       si(k-1)     = | s.fff ffff | ffff ffff |      in  x:sik+1
;              i=0,..,NO_DTMF-1 for DTMF and NO_STF for STF
;       r0 -> current channel's last si(k)
;       r3 -> s(k-2)
;       r1 -> cosval_dtmf(3), cosval_stf(5) for STF
;       y0 =  cosval_dtmf(5), cosval_stf(5) for STF
;       y1 =  s(k-1)
;       x0 =  s(k-2)
;       b  =  last si(k)
;
;**************************** Resources *******************************
;
;  Registers Used      : x0,y0,y1,a,b,r1
;
;  Registers Changed   : x0,y0,y1,b,r1
;
;  Number of locations : N/A
;  of stack used  
;
;  Number of Do loops  : 1 
;
;************************** Assembly Code *****************************

Upd

        move    x:(r1)+,y0                ;y0 = cosval_dtmf for DTMF
                                          ;   for STF cosval_stf(0)
                                          ;   r1 -> cosval_dtmf(1),cosval_stf(1)
        move    x:no_of_filter,lc
        do      lc,_END_UPDL              ;Do for MG filters
        mpy     y0,y1,b      b,x:(r0)+n   ;b = si(k-1)*coeff(i), save
                                          ;  previous si(k)
                                          ;  r0 -> current si(k)
        asl     b            y1,x:(r3)+n  ;b = 2.0*si(k-1)*coeff(i),
                                          ;  si(k-2) = si(k-1)
                                          ;  r3 -> s(k-2) of next filter
        sub     x0,b         x:(r1)+,y0   
        move    x:(r3)-,x0
                                          ;b = -si(k-2) 
                                          ;  + 2.0*coef*si(k-1)
                                          ;  y0 = next coef
                                          ;  r1 -> coeff(i+2)
                                          ;  The last position also
                                          ;  contains coeff(0) so that
                                          ;  once a channel is over, x0
                                          ;  gets coeff(0) for the next
                                          ;  channel
                                          ;  x0 = next si(k-2)  
                                          ;  r3 ->next si(k-1) 
        add     a,b          x:(r3)+,y1   ;b=x(k)+2.0*si(k-1)*coeff(i)
                                          ;  - si(k-2)
                                          ;  y1 = s(k-1) of next filter
                                          ;  r3 -> next s(k-2)
_END_UPDL

        rts
        
        
        
;***************************** Module ********************************
;
;  Module Name   :  Newnum
;  Author        :  G.Prashanth
;
;*************************** Description *******************************
;
;       This subroutine is the main DTMF loop.
;       It runs the filter state updating module
;       for 144 samples.
;
;
;  Calls:
;       Function : Upd
;
;************************** Revision History ***************************
;
;   Date                 Author              Description 
;  ------              ----------              ---------
;  18:03:98           G.Prashanth        Module Created 
;  01:06:98           G.Prashanth        Incorporated Review comments
;  03:07:2000         N R Prasad         Ported on to Metrowerks
;  07:08:2000         N R Prasad         Internal memory moved to 
;                                        external; hence dual parallel
;                                        moves converted into single
;                                        parallel moves.
;
;************************ Calling Requirements *************************
;
;  1. analysis buffer should be generated.
;  2. Initialise r0 -> s(k-1) 
;  3. Initialise m01= 2*NO_DTMF-1 for DTMF & 2*NO_STF-1 for STF 
;  4. Initialise x:coeff_ptr.
;
;
;************************* Input and Output ****************************
;
;       Input:          ana_buf - Samples generated from
;                       Generate_Analysis_Array
;       m01           = |0000 0000 | 0000 iiii | 2*NO_DTMF-1 for DTMF
;                                               &2*NO_STF-1 for STF 
;       r0            -> last sik(k-1)
;       x:coeff_ptr   -> cosval_dtmf(0) for DTMF &
;                        cosval_stf(0) for STF. 
;
;       Output:         N/A
;
;       Return Value:   N/A
;
;       The structure of filter states is shown below 
;          
;                    ______________
;          sik(0)-> |______________|
;                   |______________|
;                   |______________|
;                   |______________|
;                   |______________|
;                   |       -      |
;      r0 -> si(k-1)|       -      |
;                   |______________|   
;
;       k = 12 for STF and 4 for DTMF.   
;**************************** Resources *******************************
;
;  Registers Used      : x0,y1,a,n,m01
;                        r2,r0,r3,r1
;
;  Registers Changed   : x0,y1,a,n,m01
;                        r2,r3,r1,r0
;
;  Number of locations : - 
;  of stack used  
;
;  Number of Do loops  : - 
;
;************************** Assembly Code *****************************

        org     p:
Newnum:
        move    #ana_buf,r2               ;Pointer to working buffer
        clr     b                         ;b = 0 
        move    #sik,r3                   ;r3 ->si(k-1)of first filter
        move    #2,n                      ;Set n for offset of 2

        move    x:(r0)+,y1   
        move    x:(r3)+,x0                ;y1 =si(k-1)of 1st channel=0
                                          ;  r0->si(k-1) of last filter
                                          ;  x0 = 0 = si(k-2)
                                          ;  r3->si(k-2)of first filter
        move    #NS,x:loop_cntr           ;Do for NS samples time. 
do_Nc_times
        move    x:coeff_ptr,r1            ;r1 -> cosval(0),cosval_stf(0)
        move    x:(r2)+,a                 ;a = tone[r2]
        jsr     Upd                       ;Update MG filter states
        move    #sik,r3                   ;r3->si(k-1)of first channel      
        decw    x:loop_cntr
        move    x:(r3)+,y1                ;y1 = si(k-1)
        move    x:(r3),x0                 ;y0 = si(k-2)
        bgt     do_Nc_times
        move    b,x:(r0)+n                ;Write last si(k)
        move    #-1,m01                   ;Restore r0 & r1 to linear 
                                          ; addressing
        rts
        
        
;***************************** Module ********************************
; 
;  Module Name   :  Calc_Mg_En
;  Author        :  G.Prashanth
; 
;*************************** Description *******************************
;
;      This routine computes the MG_energies of all MG filters
;      calculates the Modified Goertzel filter energies for
;      the current channel using the MG filter states of that channel.
;
;  Calls:
;       Modules  :  - 
;       Macro    :  -
;
;************************** Revision History ***************************
;
;   Date                 Author              Description 
;  ------              ----------              ---------
;  18:03:98           G.Prashanth        Module Created     
;  01:06:98           G.Prashanth        Incorporated Review comments
;  03:07:2000         N R Prasad         Ported on to Metrowerks
;  07:08:2000         N R Prasad         Internal memory moved to 
;                                        external; hence dual parallel
;                                        moves converted into single
;                                        parallel moves.
;
;************************ Calling Requirements *************************
;
;  1. Initialize x:sik
;  2. Initialise the mg_filter coefficients.
;  3. Initialise the x:no_of_filter.
;
;************************* Input and Output ****************************
;
;   Input  : mg_frequency offset in x:coeff_ptr
;     msg_word   : | 0000 0000 | 0000 0iii | in x:coeff_ptr
;     si(k)        = | s.fff ffff | ffff ffff |  in  x:sik+2*chl_no
;     si(k-1)      = | s.fff ffff | ffff ffff |  in  x:sik+2*chl_no+1
;                                                        i=0,..,FIL-1
;     cosval_dtmf(i)    = | s.fff ffff | ffff ffff | in  x:cosval_dtmf+i
;                       i=0,..,NO_DTMF-1 if DTMF
;     cosval_stf(i)    = | s.fff ffff | ffff ffff |  in  x:cosval_stf+i
;                       i=0,..,NO_STF-1 if STF
;     y1           = Number of filters
;     r3           -> Appropriate cos table
;
;  Output:
;     mg_energy_l(i) = | 0.fff ffff | ffff ffff |
;     mg_energy_h(i) = | ffff ffff  | ffff ffff |  in  x:mg_energy+i
;                          i=0,..,FIL-1 in Double Precision.
;
;**************************** Resources *******************************
;
;  Registers Used      : x0,y0,y1,b
;                        r0,r1,r3
;
;  Registers Changed   : x0,y0,y1,b
;                        r0,r1,r3
;
;  Number of locations : N/A
;  of stack used  
;
;  Number of Do loops  : 1 
;
;************************** Assembly Code *****************************
Calc_Mg_En:

        move    x:no_of_filter,y1         ;get the no. of filters.
        move    x:coeff_ptr,r3            ;r3 -> cosval_dtmf(0) for DTMF
                                          ;  cosval_stf(0) for STF
        move    #mg_energy-2,r0           ;r0 -> location before
                                          ;  mg_energy(0)
        move    #sik,r1                   ;r1 = sik                   
                                          ;  i.e. r1 -> si(0) of first  
                                          ;  filter
        move    #3,n                                              
        move    x:(r0),b                  ;b=contents of location before
                                          ;  mg_energy(0),to accountfor
                                          ;  the write operation in the
                                          ;  first loop
                             
        move    x:(r1)+,y0    
        move    x:(r3)+,x0                ;y0 = s0(k-1), x0 = coeff(0)
        do      y1,_END_MG                ;For all MG frequencies
                                          ;  r0 -> mg_energy(i-2)
        mpy     x0,y0,b       b,x:(r0)+n  ;b = coeff(i) * si(N-1)
                                          ;  store the msb of mg energy
                                          ;  r0 -> mg_energy(i+1)
        asl     b             x:(r1)+,y1  ;b = 2 * coeff(i) * si(N-1)
                                          ;  y1 = si(N-2)
                                          ;  r1 -> next si(N-1)
        sub     y1,b          x:(r3)+,x0  ;b = 2*coeff(i)*si(N-1)
                                          ;  - si(N-2)
                                          ;  x0 = coeff(i+1)
                                          ;  r3 -> coeff(i+2)
        move    b,b                       ;Saturate b
        mpy     -b1,y1,b                  ;b = si(N-2)*( si(N-2) - 
                                          ;  2*coeff(i)*si(N-1) )
                                          ;  = si(N-2)*si(N-2) -
                                          ;2*coeff(i)*si(N-1)*si(N-2)
        mac     y0,y0,b       x:(r1)+,y0  ;b=si(N-1)*si(N-1)+si(N-2)
                                          ;  *si(N-2)
                                          ;  -2*coeff(i)*si(N-1)*si(N-2)
                                          ;  y0 = next si(N-1)
                                          ;  r1 -> next si(N-2)
        move    b0,x:(r0)-                ;store mg_energy(NO_DTMF-1)
                                          ;  r1 -> s0(k-2)r3 -> coeff(1)
_END_MG
        move    b,x:(r0)                  ;store the last value.
        rts
        ENDSEC
;************************** End of File *******************************************
