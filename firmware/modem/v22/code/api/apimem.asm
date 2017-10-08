      
       SECTION API


       GLOBAL     s_ctr
       GLOBAL     Rx_Baud_Flg
       GLOBAL     TIME_CNT
       GLOBAL     TIME_CNTH
       GLOBAL     TIME_CNTL

       GLOBAL     in_data_ptr
       GLOBAL     txrx_status

       GLOBAL     WordWrFlg 
       GLOBAL     WordRdFlg
       GLOBAL     StartCompare
       GLOBAL     SyncWord_mem
       GLOBAL     Sync_sent_status
       GLOBAL     SyncWord_rx
       GLOBAL     Tx_Baud_Count
              
       
       org     x:


s_ctr              ds     1
Tx_Baud_Count      ds     1
Rx_Baud_Flg        ds     1

TIME_CNT           ds     1                           
TIME_CNTL          ds     1
TIME_CNTH          ds     1

in_data_ptr        ds     1     ;Get initialized in the Transmitter
txrx_status        ds     1

;To be used by the V42 interface

WordWrFlg          ds     1  
WordRdFlg          ds     1
StartCompare       ds     1
SyncWord_mem       ds     1
Sync_sent_status   ds     1
SyncWord_rx        ds     1


       ENDSEC

