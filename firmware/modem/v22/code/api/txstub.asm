      

       SECTION API

       XREF   flg_109
       XREF   flg_112
       XREF   tx_ans_flg
       XREF   tx_st_chg
       XREF   tx_st_id

       GLOBAL tx_stub

        org     p:

tx_stub
        move    x:tx_ans_flg,x0           
        cmp     #1,x0                     ;Check for calling mode
        jne     calbis                    ;If calling goto calling routine
        
;--------------------------------------------------------------------------
;       TESTING FOR V.22BIS ANSWERING MODEM
;--------------------------------------------------------------------------

v22bisans
        move    x:tx_st_id,x0             ;Check for transmission of
fourba
        cmp     #0004,x0                  ;Check for transmission of
        bne     fiveba                    ;  un scr. bin. ones
        move    #$8000,x:flg_112          ;V22bis mode
        rts
fiveba
        cmp     #0007,x0                  ;Check for transmission of
        bne     eightba                   ;  scr. bin. ones at 2400 bps
        move    #$8000,x:flg_109
eightba
        rts
        
;--------------------------------------------------------------------------
;       TESTING FOR V.22BIS CALLING MODEM
;--------------------------------------------------------------------------

calbis        

        move    x:tx_st_id,x0             ;Check for transmission of
        cmp     #0001,x0
        bne     fiveca
        move    #1,x:tx_st_chg
fiveca        
        cmp     #0005,x0                  ;Check for transmission of
        bne     sixca                     ;  scr. bin. ones
        move    #$8000,x:flg_112
sixca
        rts

        cmp     #0007,x0
        bne     eightca
        move    #$8000,x:flg_109
eightca
        rts
        ENDSEC
