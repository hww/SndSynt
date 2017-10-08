;********************************* Macro **************************************
;
;  Macro Name      : coefpas
;  Author          : A Saimanohara
;  Date of origin  : 27 Jun 1994
;  Last update     : 04 Sep 1995
;
;***************************** Macro Arguments ********************************
;
;  length  : The number of points (N) in the real FFT for which complex
;              coefficients have to be calculated for the final pass
;  coef    : The address of the complex coefficients
;
;***************************** Input and Output *******************************
;
;  Input  :
;       length             Number of points (N) in the real FFT
;       coef               Address of complex coefficients
;
;  Output :
;       W(k) k=0,..,N/4    Complex coefficients, W(k) = Wr(k) + jWi(k)
;                          Imaginary and Real parts stored consecutively
;                          from x:coef to x:coef+N/2+1.
;
;  NOTE   :
;      Storage sequence is :
;           Wi(0),Wr(0),Wi(1),Wr(1),....,Wi(N/4),Wr(N/4)
;
;*************************** Calling Requirements *****************************
;
; None
;
;**************************** Macro Description *******************************
;
;  This macro calculates the N/4+1 complex coefficients needed for the final
;  pass in N point real FFT and stores them in an N/2+2 point complex buffer
;  x:coef
;
;******************************* Pseudo Code **********************************
;
;               for k=0 to N/4 do
;                   Wr(k) = cos(2*Pi*k/N)
;                   Wi(k) = sin(2*Pi*k/N)
;
;******************************* Resources ************************************
;
;                        Icycle Count  : Zero
;                        Program Words : Zero
;                        NLOAC         : 11
;
; Address Registers used : None
;
; Offset Registers used  : None
;
; Data Registers used    : None
;
; Registers Changed      : None
;
;****************************** Assembly Code *********************************
coefpas ;macro   length,coef               ;length=N, the number of points in
;coefpas macro   length,coef               ;length=N, the number of points in
                                          ;  the real FFT. Number of complex
                                          ;  coefficients needed is N/4
                                          ;N/4+1 point complex data buffer
                                          ;  starting at x:coef
PI      set     3.141592654
freq    set     2.0*PI/@cvf(HRL_FRMLEN)       ;Set freq=2*Pi/N


        org     x:coefs                    ;X memory definition

        dc      $0000                     ;Set imaginary part of W(0)
        dc      $7fff                     ;Set real part of W(0)
        dupf    count,1,(length/4-1)      ;Repeat N/4 times for k=1 to N/4-1
        dc      @sin(@cvf(count)*freq)    ;Set Wi(k)
        dc      @cos(@cvf(count)*freq)    ;Set Wr(k)
        endm
        dc      $7fff                     ;Set imaginary part of W(N/4)
        dc      $0000                     ;Set real part of W(N/4)


		rts

;        endm
;******************************************************************************
