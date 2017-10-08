

        SECTION ROM_XMEM

        GLOBAL   RXBPF22H
        GLOBAL   RXBPF22L
        GLOBAL   PAR_2100
        GLOBAL   tx_fm_coef_high
        GLOBAL   tx_fm_coef_low

        org    x:


;-----------------------------------------;
; Storage allocation for tones            ;
;-----------------------------------------;
PAR_2100        dc           $01e0,$e0c1,$dd60

;-----------------------------------------;
; BPF filter coefficients
;-----------------------------------------;
RXBPF22H        dc      -63,41
                dc      -13,-66
                dc       3,60
                dc      -31,-16
                dc      -82,34
                dc       33,-125
                dc       63,136
                dc      -124,-93
                dc       186,29
                dc      -256,82
                dc       268,-348
                dc       105,599
                dc      -638,-370
                dc       760,-223
                dc      -422,704
                dc      -58,-836
                dc       513,847
                dc      -1325,-577
                dc       1959,-793
                dc      -838,2739
                dc      -2195,-2963
                dc       4482,-171
                dc      -2640,4422
                dc      -2505,-5066
                dc       5931,639
                dc      -3728,4779
                dc      -2068,-5509
                dc       5404,1025
                dc      -3300,3696
                dc      -1301,-4041
                dc       3353,723
                dc      -1714,1914
                dc      -595,-1636
                dc       973,68
                dc      -54,376
                dc      -205,231
                dc      -389,-379
                dc       602,-256
                dc      -27,643
                dc      -474,-258
                dc       309,-244
                dc       81,232
                dc      -128,15
                dc      -32,-83
                dc       76,-63
                dc       24,82
                dc      -62,-31
                dc       27,-29

RXBPF22L        dc      -11,48
                dc      -27,47
                dc      -91,76
                dc      -127,12
                dc      -140,-20
                dc      -85,-100
                dc      -27,-120
                dc       48,-147
                dc       205,-117
                dc       338,85
                dc       229,410
                dc      -237,538
                dc      -629,160
                dc      -502,-377
                dc      -78,-504
                dc       56,-331
                dc       19,-509
                dc       687,-835
                dc       1812,22
                dc       1452,2205
                dc      -1438,3203
                dc      -4308,530
                dc      -3095,-4025
                dc       2128,-5237
                dc       5961,-804
                dc       3710,4883
                dc      -2411,5479
                dc      -5596,476
                dc      -2745,-4226
                dc       2146,-3752
                dc       3521,211
                dc       978,2530
                dc      -1423,1349
                dc      -1148,-651
                dc       327,-815
                dc       604,255
                dc      -236,568
                dc      -592,-132
                dc      -43,-590
                dc       465,-203
                dc       271,294
                dc      -132,267
                dc      -185,-20
                dc      -10,-101
                dc       82,48
                dc      -24,96
                dc      -60,51
                dc      -56,-17
;----------------------------------------------------
;tx_fm filter coefficients
;----------------------------------------------------

tx_fm_coef_low                            ;Filter modulator coefficients
                                          ;  for low band transmission
        dc      $ff7d,$fed2,$2cdc,$fe83,$16e4,$02ef
        dc      $ffcd,$fcdb,$1ed2,$2e79,$0365,$0db0
        dc      $03b8,$fb29,$e418,$3adb,$f908,$0218
        dc      $081f,$fedb,$b7ea,$0696,$00c1,$fae9
        dc      $0743,$05b2,$d317,$c150,$060f,$01a5
        dc      $ffcf,$08f8,$2048,$b858,$0034,$076a
        dc      $fa4a,$0502,$4c3a,$f876,$f950,$0329
        dc      $fab5,$0126,$293d,$3a94,$fa9f,$fc0d
        dc      $f979,$019d,$e43c,$3a15,$016e,$fc91
        dc      $f30a,$fc52,$c917,$0313,$019a,$0032
        dc      $f682,$eb6f,$e93b,$da0d,$007f,$01ef
        dc      $111a,$e347,$11a9,$e3c9,$fe0c,$005e

tx_fm_coef_high                           ;Filter modulator coefficients
                                          ;  for high band transmission
        dc      $00ea,$0205,$2cd9,$fca7,$142d,$0318
        dc      $fe0f,$fd72,$e4a2,$300d,$f976,$08bf
        dc      $0701,$03f7,$e111,$c6e6,$fc44,$fe25
        dc      $f698,$01ad,$478b,$0499,$fde0,$fc31
        dc      $09f5,$fa05,$d4f8,$3e3b,$07cf,$fce6
        dc      $fe04,$0b2f,$e100,$b929,$ffdd,$0945
        dc      $fcd6,$f827,$4c3a,$09cf,$fb10,$fa13
        dc      $07ac,$059c,$d3ee,$38c9,$0754,$ff49
        dc      $f49e,$ff12,$e961,$c418,$0192,$0221
        dc      $0f41,$f6d7,$35cc,$0924,$ffac,$0145
        dc      $f929,$1931,$e33f,$21dc,$0108,$fd99
        dc      $e99b,$e3ec,$f449,$e15e,$0234,$015d



        ENDSEC
