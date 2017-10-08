       

        SECTION API

        XREF    rx_st_chg
        XREF    rx_st_id
        GLOBAL  rx_stub

        org     x:

cnt7    dc       3 
cnt20   dc       5

        org     p:

rx_stub
        move    x:rx_st_id,x0
        cmp     #7,x0
        bne     chk_st20
        decw    x:cnt7
        bgt     chk_st20
        move    #3,a
        move    a,x:cnt7
        move    #1,x:rx_st_chg

chk_st20

        rts          


        ENDSEC
