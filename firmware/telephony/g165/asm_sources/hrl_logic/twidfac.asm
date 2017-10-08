;********************************* Macro **************************************
;
;  Macro Name      : Find_twiddle_factors
;  Author          : Arun Hiregange
;  Date of origin  : 06/29/93
;  Last update     : 04 Sep 1995
;
;***************************** Macro Arguments ********************************
;
;  1. length : The number of points (N) in the FFT for which twiddle factors
;              have to be calculated
;  2. twid   : The address of the twiddle factors
;
;***************************** Input and Output *******************************
;
; Input:    length  (Number of points (N) in the FFT)
;           twid    (Address of twiddle factors)
;
; Output:   Complex twiddle factors W(k) k=0,...,N/2-1. W(k) = Wr(k) + jWi(k)
;           Real and imaginary parts stored consecutively from x:twid to
;           x:twid+N-1.
;
; NOTE :    Storage sequence is :
;           Wr(0),Wi(0),Wr(1),Wi(1),....,Wr(N/2-1),Wi(N/2-1)
;
;*************************** Calling Requirements *****************************
;
; None
;
;**************************** Macro Description *******************************
;
;       This macro calculates the N/2 complex twiddle factors (WN**k) needed
;       for an N point complex FFT and stores them in an N point complex
;       buffer x:twid
;
;       Symbols Used :
;                              WN**k <==> W(k)
;
;******************************* Pseudo Code **********************************
;
;               for k=1 to N/2 do
;                   Wr(k) = cos(2*Pi*k/N)
;                   Wi(k) = -sin(2*Pi*k/N)
;
;******************************* Resources ************************************
;
;                        Icycle Count  : Zero
;                        Program Words : Zero
;                        NLOAC         : 11
;
; Address Registers used : None
;
; Offset Registers used :  None
;
; Data Registers used :    None
;
; Registers Changed :      None
;
;****************************** Assembly Code *********************************
twidfac macro   length,twid               ;length=N, the number of points in
                                          ;  the complex FFT. Number of complex
                                          ;  twiddle factors needed is N/2
                                          ;N/2 point complex data buffer starts
PI      set     3.141592654               ;  at x:twid
freq    set     2.0*PI/@cvf(length)       ;Set freq=2*Pi/N

        org     x:twid                    ;X memory definition

        dc      $7fff                     ;Set real part of W(0)
        dc      $0000                     ;Find imaginary part of W(0)
        dupf    count,1,((length/4)-1)    ;Repeat N/4 times for k=1 to N/4-1
        dc      @cos(@cvf(count)*freq)    ;Find Wr(k)
        dc      @sin(@cvf(count)*freq)    ;Find Wi(k)
        endm
        dc      $0000
        dc      $7fff
        dupf    count,((length/4)+1),((length/2)-1)
                                          ;Repeat N/4 times for k=N/4+1 to 
                                          ;  N/2-1
        dc      @cos(@cvf(count)*freq)    ;Find Wr(k)
        dc      @sin(@cvf(count)*freq)    ;Find Wi(k)
        endm

        endm
;******************************************************************************
