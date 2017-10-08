;******************************* Function *********************************
;
;  Macro Name     : GET_KEY
;  Author         : Omkar.S.P
;  Date of Origin : 18 Mar 96
;  Last update    : 10 Apr 96
;
;*************************** Function Description *************************
;
;  This function gets the row and column indexes of the DTMF key detected
;  for the case of ASCII encoded key number values.
;
;**************************** Function Arguments **************************
;
;  None.
;
;************************* Calling Requirements ***************************
;
;  None.
;
;************************** Input and Output ******************************
;
;  Input  : 
;     key_num = |0000 0000 0iii iiii|, in a1, a2 is zero,a0 is zero.
;               (It is the 7 bit ASCII code for the key in hexadecimal).
;
;     The following figure gives the mapping of rindx and cindx to key 
;     numbers:
;     
;       cindx---->
;       0      1    2     3
;     +-----+-----+-----+-----+
;     |  1  | 2   | 3   | A   | 0 rindx
;     +-----+-----+-----+-----+      |
;     |  4  | 5   | 6   | B   | 1    |
;     +-----+-----+-----+-----+      |
;     |  7  | 8   | 9   | C   | 2    |
;     +-----+-----+-----+-----+      v
;     |  *  | 0   | #   | D   | 3
;     +-----+-----+-----+-----+
;
;     [For example, the digit 6 is represented by rindx=1, cindx=2.]
;
;  Output :
;     r_indx  = |0000 0000 0000 00ii|, in r0
;    
;     c_indx  = |0000 0000 0000 00ii|, in r1
;             
;
;****************************** Resources *********************************
;
;                        Cycle Count   : 37
;                        Program Words : 47
;                        NLOAC         : 52
;
; Address Registers used: 
;                        r0 : Used for output rindx
;                        r1 : Used for output cindx
;                        
;
; Offset Registers used: None
;
; Data Registers used:
;                        a0  b0    x0  y0  
;                        a1  b1        y1    
;                        a2  b2          
;
; Registers Changed:  
;                        r0    a0  b0    x0  y0    sr
;                        r1    a1  b1    y1        pc
;                              a2  b2                             
;
;***************************** Pseudo Code ********************************
;
;       [Note: here '%' denotes modulo division]
;       Begin
;           If( key_num > $30 && key_num <= $39)
;               If( key_num >= $34 && key_num <= $36)
;                  key_num = key_num + 1
;               Else if(key_num >= $37 && key_num <= $39)
;                  key_num = key_num + 2
;               Endif
;               akey_num = key_num -$31
;               rindx   = akey_num/4 
;               cindx   = akey_num%4
;           Else if(key_num > $40 && key_num < $45)
;               akey_num = key_num -$41
;               rindx   = akey_num
;               cindx   = 3
;           Else
;               rindx   = 3
;           Endif
;           If( key_num == $2a)     [i.e., '*' is 3,0]
;               cindx   = 0
;           Else if( key_num == $30)
;               cindx   = 1
;           Else if( key_num == $23)     [i.e.,'#' is 3,2]
;               cindx   = 2 
;           Endif
;       End
;
;**************************** Assembly Code *******************************

        SECTION DTMF  

        GLOBAL hi_buf
        GLOBAL lo_buf
        GLOBAL al_2
        GLOBAL ah_2
        GLOBAL Frindx
        GLOBAL r_indx
        GLOBAL Fcindx
        GLOBAL c_indx
           
         org x:
         
hi_buf    dsm    2
lo_buf    dsm    2
al_2      ds     1
ah_2      ds     1

r_indx    ds     1
Frindx    equ    r_indx

c_indx    ds     1
Fcindx    equ    c_indx

; ASM code was moved into C routine dtmfSetKey

		
        ENDSEC

;****************************** End of File *******************************
