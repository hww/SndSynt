

        SECTION TX_MEM

        GLOBAL   MDMCONFIG
        GLOBAL   FMDMCONFIG

        GLOBAL   TX_GAIN

        GLOBAL   MDMSTATUS
        GLOBAL   FMDMSTATUS

        GLOBAL   mode_flg

        GLOBAL   rx_st_id
        GLOBAL   tx_st_id
        GLOBAL   flg_107
        GLOBAL   flg_112
        GLOBAL   flg_109
        GLOBAL   flg_104
        GLOBAL   flg_106
        GLOBAL   loopback
        GLOBAL   retrain_flag
        GLOBAL   Fretrain_flag

;-----------------------------------------;
;Initializations of flags                 ;
;-----------------------------------------;

    org x:
MDMCONFIG       ds           1
FMDMCONFIG      equ          MDMCONFIG
MDM_Equ         dc           10
TX_GAIN         ds           1
MDMSTATUS       ds           1
FMDMSTATUS      equ          MDMSTATUS
mode_flg        ds           1            ;Flag to denote handshake,
                                          ;  data and retrain modes
rx_st_id        ds           1
tx_st_id        ds           1            ;Identification number of a state
                                          ;  | xxxx xxxx xxxx nnnn |
                                          ;  nnnn = the state number
flg_107         ds           1            ;Data set ready flag
flg_112         ds           1            ;Data rate selector flag
flg_109         ds           1            ;Data channel received line
                                          ;  detector flag
flg_104         ds           1            ;
flg_106         ds           1            ;Ready for sending flag
loopback        ds           1            ;Only for testing purpose

retrain_flag    ds           1            ;For the user, Initialised in the
Fretrain_flag   equ          retrain_flag ;  V22BisAPI.asm file

        ENDSEC

