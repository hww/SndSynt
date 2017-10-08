
        include "gmdmequ.asm"
        include "txmdmequ.asm"

        SECTION V22B_TX

        GLOBAL   GN_MDM_INIT


        org     p:


GN_MDM_INIT
        move    x:TXMEMSIZE,x0
        move    #TXMEMB,r0
        clr     a
        rep     x0
        move    a,x:(r0)+

        move    x:RXMEMSIZE,x0
        move    #RXMEMB,r0
        clr     a
        rep     x0
        move    a,x:(r0)+
        move    #0,x:MDMSTATUS
     
        move    #hndshk,x:mode_flg
        move    #V22Bis,x:mdm_flg
        move    #CCITT,x:ccitt_flg
        move    #1,x:flg_104
        move    #0,x:flg_106
        move    #0,x:flg_107
        move    #0,x:flg_109
        move    #0,x:flg_112
End_GN_MDM_INIT

        rts


        ENDSEC
