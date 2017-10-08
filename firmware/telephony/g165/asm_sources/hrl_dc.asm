
    
    SECTION HRL_CONST GLOBAL
    
    
    org    x:
HRL_FRMLEN1        equ      128

hanning_sum set     0.0
hann        dupf    count,1,HRL_FRMLEN1/2   
hann_value  set     0.5*(1.0-@cos(@cvf(count)*6.2831853/@cvf(HRL_FRMLEN1+1)))
            dc      hann_value
hanning_sum set     hanning_sum+(hann_value*hann_value)
            endm

    include "equates.asm"
     
     ENDSEC