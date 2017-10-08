
;EC specific equates

EC_VAR_INT_XRAM               equ   0      ;For section EC_VAR
EC_CONST_INT_XRAM             equ   0      ;For section EC_CONST
TD_VAR_INT_XRAM               equ   0      ;For section TD_VAR
TD_CONST_INT_XRAM             equ   0      ;For section TD_CONST
HRL_VAR_INT_XRAM              equ   0      ;For section HRL_VAR
HRL_CONST_INT_XRAM            equ   0      ;For section HRL_CONST


EC_FRMLEN       equ          320
NL_HANGOVER     equ          3
NL_ATTENUATION  equ          0.25

;HRL specific equates

RELEASE_TIME      equ      160
HRL_FRMLEN        equ      128
HRL_FRMSPAN       equ      HRL_FRMLEN/8


FFT_DATA_INT_XRAM  equ  HRL_VAR_INT_XRAM
FFT_COEF_INT_XRAM  equ  HRL_CONST_INT_XRAM


hanning_sum set     0.0
           dupf    count,1,HRL_FRMLEN/2   
hann_value  set     0.5*(1.0-@cos(@cvf(count)*6.2831853/@cvf(HRL_FRMLEN+1)))
;            dc      hann_value
hanning_sum set     hanning_sum+(hann_value*hann_value)
            endm


WINDOW_CORRECTION equ      @cvf(HRL_FRMLEN)/(2.0*hanning_sum)
HRL_TONE_THRES1   equ      @POW(10.0,-28.5/10.0)/(4*WINDOW_CORRECTION)
HRL_TONE_THRES2   equ      @POW(10.0,-32.5/10.0)/(4*WINDOW_CORRECTION)
HRL_SNR_THRES     equ      @POW(10.0,5.5/10.0)
INDEX_200         equ      @CVI(200.0*HRL_FRMLEN/8000.0+0.5)
INDEX_700         equ      @CVI(700.0*HRL_FRMLEN/8000.0+0.5)
INDEX_3400        equ      @CVI(3400.0*HRL_FRMLEN/8000.0+0.5)



;TD specific equates

TD_TONE_THRES   equ     0.5*@POW(10.0,-33.0/10.0) ;Corresponds to -33 dBm0
TD_SNR_THRES    equ     @POW(10.0,5.25/10.0)      ;Corresponds to 5.25 dB
	
