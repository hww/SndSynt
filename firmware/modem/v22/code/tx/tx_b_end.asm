
        SECTION V22B_TX 

        GLOBAL   end_tx

        org p:

end_tx
        move    x:DC_Alpha,x0
        move    x:DC_Tap,b
        move    x:DC_Error,y0
        macr    x0,y0,b
        move    b,x:DC_Tap
        asr     b                        
        asr     b
        asr     b
        move    b,x:DC_Tap_Scaled

        rts

        ENDSEC
     
