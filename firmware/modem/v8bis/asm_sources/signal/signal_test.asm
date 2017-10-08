;***********************************************************************
;
; Motorola India Electronics Ltd. (MIEL)
;
; PROJECT ID           : V.8 bis
;
; ASSEMBLER            : ASM56800 version 6.2.0
;
; FILE NAME            : signal_test.asm 
;
; PROGRAMMER           : G.Prashanth
;
; DATE CREATED         : 7:03:98
;
; FILE DESCRIPTION     : This file computes the tests for the dtmf as 
;                        well as single_tone using various testing 
;                        techniqs and outputs the decision.
;  
; FUNCTIONS            : Tst_Dtmf,Mag,Rel_En_I,Rel_En_II,Twist,
;                        Tst_Stf,Find_Pks,Test_Single_Tone 
;
; MACROS               : 
;
;************************************************************************  
   
        include 'tone_set.asm'
        SECTION signal_test                     
        GLOBAL    Tst_Dtmf      
        GLOBAL    Tst_Stf

        
;***************************** Module ********************************
;
;  Module Name   :  Tst_Dtmf
;  Author        :  G.Prashanth
;
;*************************** Description *******************************
;
;       This routine tests the existence of DTMF tone
;
;  Calls:
;       Modules  : Mag,Twist,Rel_En_I,Rel_En_II
;       Macro    : N/A 
;
;******************* Revision History ***************************
;
;   Date                 Author              Description 
;  ------              ----------              ---------
;  20:03:98            G.Prashanth          Module Created  
;  02:06:98            G.Prashanth          Incorporated Review comments
;  03:07:2000          N R Prasad           Ported on to Metrowerks
;  10:07:2000          L Prasad             Bug fixed in function
;                                           Test_Single_Tone. Earlier,
;                                           it used to detect all zero
;                                           input.
;************************ Calling Requirements *************************
;
;  1. Initialize mg_energy
;
;
;************************* Input and Output ****************************
;
;   Input  :  N/A 
;
;   Output :  
;             x0  =  decision  : | 0000 0000 | 0000 000i | 
;
;
;**************************** Resources *******************************
;
;  Registers Used      : x0
;
;  Registers Changed   : x0
;
;  Number of locations : 2(only for jsr) 
;  of stack used  
;
;  Number of Do loops  : N/A
;
;************************** Assembly Code *****************************

        ORG     p:
Tst_Dtmf
        jsr     Mag                       ;carry out Mag test
        tstw    x0
        beq     _FAILED_TEST              ;if x0 = 0 ,return 

        jsr     Twist                     ;carry out Twist test
        tstw    x0                        ;test x0 
        beq     _FAILED_TEST              ;if x0 = 0,return  

        jsr     Rel_En_I                  ;carry out Rel_En_I test
        tstw    x0                        ;test x0
        beq     _FAILED_TEST              ;if x0 = 0,return  
        
        jsr     Rel_En_II                 ;Carry out Rel_EN_II test
_FAILED_TEST    
        rts                               ; Return


;***************************** Module ********************************
;
;  Module Name   :  Mag
;  Author        :  G.Prashanth 
;
;*************************** Description *******************************
;
;       This routine checks that the magnitudes of the peak energies of
;       the low & high group of MG filters is greater than a threshold.
;
;  Calls:
;       Modules  : N/A
;       Macro    : N/A
;
;************************** Revision History ***************************
;
;   Date                 Author               Description 
;  ------              ----------              ---------
;  20:03:98            G.Prashanth          Module Created 
;  02:06:98            G.Prashanth          Incorporated Review comments
;  03:07:2000          N R Prasad           Ported on to Metrowerks
;
;************************ Calling Requirements *************************
;
;  1.Initialize x:dtmf_level
;
;************************* Input and Output ****************************
;
;  Input:
;     mg_energy(i) = | s.fff ffff | ffff ffff | in  x:mg_energy+i
;                          i=0,..,NO_DTMF-1,double_precision value
;
;  Output:
;     decision     = | 0000 0000 | 0000 000i | in x0 
;
;  Return Value    = 1 if test passes, 0 otherwise in x0
;
;**************************** Resources *******************************
;
;  Registers Used      : x0,y0,y1,b,a0,a
;
;  Registers Changed   : x0,y0,y1,b,a0,a
;
;  Number of locations : N/A
;  of stack used  
;
;  Number of Do loops  : N/A 
;
;************************** Assembly Code *****************************

Mag:
        move    #mg_energy,r0             ;r0-> mg_energy
        clr     x0                        ;x0 = 0 => failed
        move    x:(r0)+,b                 ;get mg_energy1(hi)   
        move    x:(r0)+,b0                ;get mg_energy1(hi) 
        move    x:dtmf_level,a            ;get DTMF thresh level(hi)E
        move    x:dtmf_level+1,a0         ;get DTMF threshold level(lo)
                                          ;   accumulator a will have E 
        move    x:shift_count,y0
        asl     y0                        ;scale the Emin to twise time
        rep     y0
        asl     a
        cmp     b,a          x:(r0)+,b    ;cmp mg_energy1 & E   
                                          ;  get mg_energy2(hi) 
        bgt     _FAILED                   ;If mg_energy1 < E goto
                                          ;  _Failed
        move    x:(r0),b0                 ;get mg_energy2(lo)
        cmp     b,a                       ;Compare mg_energy2 &  E
        bgt     _FAILED                   ;If mg_energy2 < E goto
                                          ;  _Failed
        move    #1,x0                     ;x0 = 1 => passed test
_FAILED
        rts


;***************************** Module ********************************
;
;  Module Name   : Rel_En_I
;  Author        : G.Prashanth
;
;*************************** Description *******************************
;
;      This routine performs the Relative energy tests as part of
;        the decision logic.Compares the mg_energies with the signal
;        energies which is computed before filtering.
;
;  Calls:
;       Modules  : N/A
;       Macro    : N/A
;
;************************** Revision History ***************************
;
;   Date                 Author                Description 
;  ------              ----------              ---------
;  20:03:98            G.Prashanth        Module Created  
;  02:06:98            G.Prashanth        Incorporated Review comments
;  03:07:2000          N R Prasad         Ported on to Metrowerks
;  07:08:2000          N R Prasad         Internal memory moved to 
;                                         external; hence dual parallel
;                                         moves converted into single
;                                         parallel moves.
;
;************************ Calling Requirements *************************
;
;  1.Initialies x:sig_energy
;
;
;************************* Input and Output ****************************
;
; Input: 
;   mg_energy(i)   = | s.fff ffff | ffff ffff | in x:mg_energy+i
;                       i = 0,..,NO_DTMF-1 in double_precision
;   sig_energy(hi) = | s.fff ffff | ffff ffff | in x:sig_energy
;   sig_energy(lo) = | ffff ffff | ffff ffff |  in x:sig_energy+1
;  
;  Output:
;          decision  : | 0000 0000 | 0000 000i | in x0 
;
;  Return Value: 1 if test passes, 0 otherwise in x0
;
;
;**************************** Resources *******************************
;
;  Registers Used      : x0,y0,y1,a0,a,b
;
;  Registers Changed   : x0,y0,y1,a0,a,b
;
;  Number of locations : N/A
;  of stack used  
;
;  Number of Do loops  : N/A 
;
;************************** Assembly Code *****************************

Rel_En_I:
        move    #mg_energy+2,r0           ;r0->mg_energy(2)
        move    #mg_energy,r1             ;r1->mg_energy(1)
        move    #sig_energy,r2            ;r2->sig_energy =E
        move    #Thresh1a,r3              ;r3->Thresh1a
        move    x:(r2)+,a                 ;a = sig_energy(hi)
                                          ;  r2->sig_energy(lo)
        move    x:(r2)-,a0                ;a0 = sig_energy(lo)
        move    x:(r0)+,y0   
        move    x:(r3)+,x0                ;x0 = Thresh1a,y0 = mg_en2(hi)
                                          ;  r0 -> mg_en2(lo),
                                          ;  dummy incr of r3 done.
        move    y0,b                      
        move    x:(r0)-,b0                ;b = mg_en2(hi)=B 
        sub     b,a                       ;a = sig_energy -B
;***************************************************
;Use Double Precision multiplication.
;***************************************************
        move    a0,y0                      
        move    a,y1
        mpysu   x0,y0,a
        move    a1,b0
        move    a2,a
        move    b0,a0                    
        mac     y1,x0,a                   ;a = (sig_energy-B)*Thresh1a
        move    x:(r1)+,b                 ;b = mg_en1(hi) r1->mg_en1(lo)
        move    x:(r1)+,b0                ;b0 = mg_en2(lo)
        cmp     b,a                       ;Compare 
                                          ;  (sig_energy-B)Thresh1a - A
        bgt     _FAILED                   ;if (sig_energy-B)Thresh1a>A
                                          ;  go to invalid_addr
        move    x:(r2)+,a                 ;a = sig_energy(hi)
                                          ;  r2 -> sig_energy(lo)       
        move    x:(r2),a0                 ;a0 = sig_energy(lo)
        sub     b,a                       ;a= sig_energy - y1
;***************************************************
;Use Double Precision multiplication.
;***************************************************
        move    a0,y0
        move    a,y1
        mpysu   x0,y0,a
        move    a1,b0
        move    a2,a
        move    b0,a0
        mac     y1,x0,a                   ;a = (sig_energy-B)*Thresh1a
        move    x:(r0)+,b                 ;b = mg_en1(hi)
                                          ;  r0 -> mg_en1(hi)
        move    x:(r0),b0                 ;b0 = mg_en1(lo) 
        cmp     b,a                       ;Compare (sig_energy-y1)
                                          ;  *Thresh1b - B      
        bgt     _FAILED                   ;If (sig_enery-A)*Thresh1b>B
                                          ;   go to invalid_addr
        move    #1,x0                     ;x0 = 1 ->passed Test
        rts
_FAILED
        clr     x0                        ;x0 = 0 ->failed Test 
        rts                                 


;***************************** Module ********************************
;
;  Module Name   : Rel_En_II
;  Author        : G.Prashanth
;
;*************************** Description *******************************
;
;         This routine performs the Relative energy tests as part of
;          the decision logic.The sig_energy used is computed after
;          passing through high pass filter.     
;
;
;  Calls:
;       Modules  : N/A
;       Macro    : N/A
;
;************************** Revision History ***************************
;
;   Date                 Author               Description 
;  ------              ----------              ---------
;  23:03:98            G.Prashanth        Module Created   
;  02:06:98            G.Prashanth        Incorporated Review comments
;  03:07:2000          N R Prasad         Ported on to Metrowerks
;  07:08:2000          N R Prasad         Internal memory moved to 
;                                         external; hence dual parallel
;                                         moves converted into single
;                                         parallel moves.
;
;************************ Calling Requirements *************************
;
;  1.Initialize x:sig_energy
;
;
;************************* Input and Output ****************************
;
; Input: 
;   mg_energy(i)   = | s.fff ffff | ffff ffff | in x:mg_energy+i
;                                                     i = 0,..,NO_DTMF-1
;   signal energy for the filtered output
;   sig_energy(hi) = | s.fff ffff | ffff ffff | in x:sig_energy+2
;   sig_energy(lo) = | ffff ffff | ffff ffff |  in x:sig_energy+3
;  
;  Output:
;        decision  = | 0000 0000 | 0000 000i | in x0 
;
; Return Value: 
;                  = 1 if test passes, 0 otherwise in x0
;
;**************************** Resources *******************************
;
;  Registers Used      : x0,y0,y1,a0,a,b
;
;  Registers Changed   : x0,y0,y1,a0,a1,b
;
;  Number of locations : N/A
;  of stack used  
;
;  Number of Do loops  : N/A 
;
;************************** Assembly Code *****************************

Rel_En_II:
        move    #mg_energy+2,r0           ;r0->mg_energy(2)
        move    #mg_energy,r1             ;r1->mg_energy(1)
        move    #sig_energy+2,r2          ;r2->sig_energy =E
        move    #Thresh2a,r3              ;r3->Thresh2a
        move    x:(r2)+,a                 ;a = sig_energy(hi)
                                          ;  r2->sig_energy(lo)
        move    x:(r2)-,a0                ;a0 = sig_energy(lo)
                                          ;  r2->sig_energy(hi)
        move    x:(r0)+,y0   
        move    x:(r3)+,x0                ;r0 -> mg_en2(lo),dummy incr
                                          ;   of r3 is done.
        move    y0,b                      ;get the mg_en in b  
        move    x:(r0)-,b0                ;b0 = mg_en2(lo)=B 
        sub     b,a                       ;a = sig_energy -B
;***************************************************
;Use Double Precision multiplication.
;***************************************************
        move    a0,y0
        move    a,y1
        mpysu   x0,y0,a
        move    a1,b0
        move    a2,a
        move    b0,a0
        mac     y1,x0,a                   ;a = (sig_energy-B)*Thresh2a
        move    x:(r1)+,b                 ;b0 = mg_en1(lo),r0->mg_en1(h)
        move    x:(r1),b0                 ;b = mg_en2
        cmp     b,a                       ;Compare 
                                          ;  (sig_energy-B)Thresh1a - A
        bgt     _FAILED                   ;if (sig_energy-B)Thresh1a>A
                                          ;  go to invalid_addr
        move    x:(r2)+,a                 ;a0 = sig_energy(lo)
                                          ;  r2 -> sig_energy(hi)       
        move    x:(r2),a0                 ;a1 = sig_energy(hi)
        sub     b,a                       ;a= sig_energy - y1
;***************************************************
;Use Double Precision multiplication.
;***************************************************
        move    a0,y0
        move    a,y1
        mpysu   x0,y0,a
        move    a1,b0
        move    a2,a
        move    b0,a0
        mac     y1,x0,a                   ;a = (sig_energy-y1)Thresh2b
        move    x:(r0)+,b                 ;  b = mg_en1(lo)
                                          ;  r0 -> mg_en1(hi)
        move    x:(r0),b0                 ;b0 = mg_en1(hi) 
        cmp     b,a                       ;Compare (sig_energy-y1)
                                          ;  *Thresh1b - B      
        bgt     _FAILED                   ;If (sig_enery-A)*Thresh1b>B
                                          ;  go to invalid_addr
        move    #1,x0                     ;x0 = 1 ->passed Test
        rts
_FAILED
        clr     x0                        ;x0 = 0 ->failed Test 
        rts                                 

;***************************** Module ********************************
;
;  Module Name   : Twist
;  Author        : G.Prashanth
; 
;*************************** Description *******************************
;
;        This routine checks if the 'twist' between the low freq and 
;        high freq MG filters is within a specifed range. 
;
;  Calls:
;       Modules  : N/A
;       Macro    : N/A
;
;************************** Revision History ***************************
;
;   Date                 Author              Description 
;  ------              ----------              ---------
;  23:03:98            G.Prashanth        Module Created 
;  02:06:98            G.Prashanth        Incorporated Review comments
;  03:07:2000          N R Prasad         Ported on to Metrowerks
;  07:08:2000          N R Prasad         Internal memory moved to 
;                                         external; hence dual parallel
;                                         moves converted into single
;                                         parallel moves.
;
;************************ Calling Requirements *************************
;
;  1.Initialise the Mg_energy. 
;
;
;************************* Input and Output ****************************
;
;  Input:
;    mg_energy(i) = | s.fff ffff | ffff ffff | in x:mg_energy+i
;                   i = 0,..,NO_DTMF-1 in double precision
;
;  Output:
;       decision  = | 0000 0000 | 0000 000i | in x0 
;
; Return Value: 
;                 = 1 if test passes,0 otherwise in x0       
;
;
;
;**************************** Resources *******************************
;
;  Registers Used      : x0,y0,y1,a,b
;
;  Registers Changed   : x0,y0,y1,a,b
;
;  Number of locations : N/A
;  of stack used  
;
;  Number of Do loops  : N/A 
;
;************************** Assembly Code *****************************
 
Twist:
        move    #Thresh3a,r3              ;r2->Thresh3a= Forward Twist
        move    #mg_energy,r0             ;r3 = Address of mg_energy(1)
        move    #mg_energy+2,r1           ;r0 =Address of mg_energy(2)
        move    x:(r0)+,y1   
        move    x:(r3)+,x0                ;get Thresh3a & mg_en1(hi)
                                          ;  r3->Thresh3b,r0->mg_en1(lo)
        move    x:(r0)-,y0                ;get mg_en1(lo),r0->mg_en1(hi)
;***************************************************
;Use Double Precision multiplication.
;***************************************************
        mpysu   x0,y0,b
        move    b1,a1
        move    b2,b
        move    a1,b0
        mac     y1,x0,b       
        move    x:(r1)+,a                 ;getmg_en2(hi),r2->mg_en2(lo) 
        move    x:(r1)-,a0                ;get mg_en2(lo),r2->mg_en2(h)
        cmp     b,a                       ;Compare mg(2) &
                                          ;  mg(1)*Thresh3a
        ble    _FAILED                    ;If mg_energy(2)<mg_energy(1)
                                          ;  *Thresh3a
                                          ;  go to _FAILED 
        move    x:(r1)+,y1   
        move    x:(r3)+,x0                ;get Thresh3b & mg_en2(hi)
                                          ;  r3->Thresh3b,r2->mg_en2(lo)
        move    x:(r1),y0                 ;get the lsb of mg_en2(lo)    
;***************************************************
;Use Double Precision multiplication.
;Thresh3b is +6dB which is stored as .25 so that
;mg_en2 > mg_en1*4 can be done as 
;mg_en2*.25 > mg_en1 for the test.
;***************************************************
        mpysu   x0,y0,b
        move    b1,a1
        move    b2,b
        move    a1,b0
        mac     y1,x0,b       
        move    x:(r0)+,a                 ;getmg_en1(hi),r0->mg_en1(lo) 
        move    x:(r0),a0                 ;get mg_en1(lo),r0->mg_en1(l)
        cmp     b,a                       ;Compare mg_enrgy1 & mg_ener
                                          ;  gy2/Thresh3b
                                          ;  Thresh3b is +6dB which is
                                          ;  stored as .25
        ble     _FAILED                   ;if mg_energy(2)*Thresh3b>
                                          ;   mg_energy(1)
                                          ;  go to _FAILED
        move    #1,x0                     ;x0 = 1 =>passed test
        rts 
_FAILED
        clr     x0                        ;x0 = 0 =>failed test 
        rts



;***************************** Module ********************************
;
;  Module Name   :  Tst_Stf
;  Author        :  G.Prashanth
;
;*************************** Description *******************************
;
;       This routine tests the existence of DTMF tone
;
;  Calls:
;       Modules  : Find_Pks,Test_Single_Tone 
;       Macro    : N/A 
;
;************************** Revision History ***************************
;
;   Date                 Author              Description 
;  ------              ----------              ---------
;  25:03:98            G.Prashanth          Module Created 
;  02:06:98            G.Prashanth          Incorporated Review comments
;  03:07:2000          N R Prasad           Ported on to Metrowerks
;
;************************ Calling Requirements *************************
;
;  1. Initialize mg_energy
;
;
;************************* Input and Output ****************************
;
;   Input  :  N/A 
;
;   Output :  
;          decision  : | 0000 0000 | 0000 000i | in x0 
;
;
;**************************** Resources *******************************
;
;  Registers Used      : x0
;
;  Registers Changed   : x0
;
;  Number of locations : 2 (only for jsr)  
;  of stack used  
;
;  Number of Do loops  : N/A
;
;************************** Assembly Code *****************************

Tst_Stf:
        ;set peak addresses to mg_energy[0],mg_energy[1]

        jsr     Find_Pks                  ;Find the peak of mg_energies
        move    r1,x:Fg_single_tone_detected
                                          ;move the index of the signal 
                                          ;  type detected. 
        clr     x0                        ;clear x0 to store decision  
        jsr     Test_Single_Tone          ;jump to test for the decision
                                          ;  if x0 = 0 => failed else if
                                          ;  if x0 = 1 => pass.
        rts



;***************************** Module ********************************
;
;  Module Name   : Find_Pks 
;  Author        : G.Prashanth
; 
;*************************** Description *******************************
;
;        This routine finds the peak of the single tone mg_energies 
;        stores the value in x:pk_add.
;  Calls:
;       Modules  : N/A
;       Macro    : N/A
;
;************************** Revision History ***************************
;
;   Date                 Author               Description 
;  ------              ----------              ---------
;  25:03:98            G.Prashanth          Module Created 
;  02:06:98            G.Prashanth          Incorporated Review comments
;  03:07:2000          N R Prasad           Ported on to Metrowerks
;
;
;************************ Calling Requirements *************************
;
;  1.Initialise the Mg_energies. 
;
;
;************************* Input and Output ****************************
;
;  Input:
;    mg_energy(i) = | 0.fff ffff | ffff ffff | in x:mg_energy+i
;                                                 i = 0,..,NO_STF-1
;
;  Output:  peak of mg_energy(32 bit precision) in 
;                 = | s.fff ffff  | ffff ffff | in x:pk_add
;                   | ffff ffff  | ffff ffff | in x:pk_add+1
;    data_word    = | 0000 0000   | 0000 0iii | in r1
;
;
;
;**************************** Resources *******************************
;
;  Registers Used      : x0,y0,y1,a,b
;
;  Registers Changed   : x0,y0,y1,a,b
;
;  Number of locations : N/A
;  of stack used  
;
;  Number of Do loops  : N/A 
;
;************************** Assembly Code *****************************
Find_Pks

        move    #mg_energy,r3             ;r3 -> mg_energy(i)
        move    #pk_add,r2                ;r1 -> mg_energy store peak
                                          ; value.  
        clr     r1                        ;r1 is used to find the 
                                          ; index of detected tone.
        clr     r0                        ;                       
        move    x:(r3)+,a                 ;move first value to a
        move    x:(r3)+,a0                ; r3 -> mg_energy(2)
        move    #5,y1
_end_peak
        move    x:(r3)+,b
        move    x:(r3)+,b0
        cmp     a,b          x:(r0)+,y0   ;compare with max value
                                          ;  increment r0.             
        tgt     b,a          r0,r1        ;if greater than transfer
                                          ;  record the index in r1.  
        decw    y1                        ;decrement the count.
        bgt     _end_peak   
        move    a,x:(r2)+                 ;move the peak value in 
        move    a0,x:(r2)                 ; memory locn.
        rts
;***************************** Module ********************************
;
;  Module Name   : Test_Single_Tone
;  Author        : G.Prashanth
; 
;*************************** Description *******************************
;
;        This routine checks if the peak of the single tone energy
;        passes the test. 
;
;  Calls:
;       Modules  : N/A
;       Macro    : N/A
;
;************************** Revision History ***************************
;
;   Date                 Author               Description  
;  ------              ----------              ---------
;  25:03:98            G.Prashanth        Module Created 
;  02:06:98            G.Prashanth        Incorporated Review comments
;  03:07:2000          N R Prasad         Ported on to Metrowerks
;  07:08:2000          N R Prasad         Internal memory moved to 
;                                         external; hence dual parallel
;                                         moves converted into single
;                                         parallel moves.
;
;************************ Calling Requirements *************************
;
;  1.Initialise the x:pk_add 
;
;
;************************* Input and Output ****************************
;
;  Input:
;    mg_energy_peak ,double precision value.
;    hi_add       = | s.fff ffff  | ffff ffff | in x:pk_add
;    lo_add       = | ffff ffff  | ffff ffff |  in x:pk_add+1
;
;  Output:
;   decision      = | 0000 0000  | 0000 000i | in x0
; Return Value: 
;                 = 1 if test passes,0 otherwise in x0       
;
;
;
;**************************** Resources *******************************
;
;  Registers Used      : x0,y0,y1,a,b
;
;  Registers Changed   : x0,y0,y1,a,b
;
;  Number of locations : N/A
;  of stack used  
;
;  Number of Do loops  : N/A 
;
;************************** Assembly Code *****************************
Test_Single_Tone

        move    #sig_energy,r0            ;r0->sig_energy =E
        move    #Thresh_s,r3              ;r3->Thresh_s
        move    #pk_add,r2                ;r2->mg_energy_peak

        move    x:(r0)+,y1   
        move    x:(r3)+,x0                ;get sig_energy(hi)&Thresh_s 
                                          ;  r0->sig_energy(lo),dummy
                                          ;  increment of r3 done 
        move    x:(r0)-,y0                ;get sig_energy(lo)
                                          ;  r0->sig_energy(hi)
;***************************************************
;Use Double Precision multiplication.
;***************************************************
        mpysu   x0,y0,a                   ;perform sig_energy * Thresh_s
        move    a1,b0
        move    a2,a
        move    b0,a0
        mac     y1,x0,a                   ;a = (sig_energy-B)*Thresh2a
        move    x:(r2)+,b                 ;get mg_en(hi),r2->mg_en1(lo)
        move    x:(r2),b0                 ;get mg_en(lo)
        clr     x0                        ;x0 = 0 => failed test
        cmp     b,a                       ;Compare 
                                          ; (sig_energy)Thresh_s - A
        bge     _FAILED                   ;code added by BLP
                                          ;if (sig_energy)Thresh_s>A
                                          ; branch to _Failed
        move    #1,x0                     ;x0 = 1 =>passed Test
_FAILED
        rts
        ENDSEC                                 

;*************************** End Of File ***************************************
