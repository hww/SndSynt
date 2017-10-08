
;**************************************************************************
;
;   Motorola India Electronics Ltd.
;
;   Project Name    : VISTA360
;
;   Original Author : Varadarajan,
;
;   Modified by     : Sanjay Karpoor
;
;   Module Name     : V22bisAPI.asm
;
;**************************************************************************
;
;   Module Tested   : Modem Tx and Modem Rx
;
;   Date            : 01.04.96
;
;   Date Modified   : 14 Apr 2000
;
;**************************************************************************
;
;   PROCESSOR       : 568xx
;
;**************************************************************************
;
;   DESCRIPTION  : This module performs the initialization of modem
;                  parameters and calls V22bis init functions to complete
;                  the v22bis data pump initializations.
;
;**************************************************************************
;--------------------------------------------------------------------------
;     Include the macros
;--------------------------------------------------------------------------

 
          SECTION API


          include "gmdmequ.asm"
          include "rxmdmequ.asm"
          
;--------------------------------------------------------------------------
;     All the equates and definitions
;--------------------------------------------------------------------------

     XREF    DC_Tap_Scaled
     
     GLOBAL    FINITIALIZE_V22BIS
     GLOBAL    FV22BIS_TRANSMIT_DATA_INIT
     GLOBAL    FV22BIS_TRANSMIT
     GLOBAL    FV22BIS_RECEIVE_DATA_INIT
     GLOBAL    FV22BIS_RECEIVE_SAMPLE


;--------------------------------------------------------------------------
;     All the memory definitions
;--------------------------------------------------------------------------

 
        org     p:

;--------------------------------------------------------------------------
;     Setup PLL ans stack
;--------------------------------------------------------------------------

FINITIALIZE_V22BIS 


;--------------------------------------------------------------------------
;     The Datapump initialisations
;--------------------------------------------------------------------------

        move    #0,x:retrain_flag       ;To be checked in the API, for
                                        ;  the user        
        move    #0,x:loopback           ;No loopback operation
       
        bfset   #V22bisEN,y0            ;Enable V22bis by default
        
        bftsth  #CALLANS,y0
        bcs     tx_gain_for_answer
        
tx_gain_for_call        
        move    #$7fff,x:TX_GAIN
        bra     continue_init
                                  
tx_gain_for_answer                                                                                
        move    #$7fff,x:TX_GAIN        ;Not user programmable
          
continue_init        
        move    y0,x:MDMCONFIG          ;set the modem parameters
        
        bftsth  #LOOPBACK,x:MDMCONFIG
        bcc     dov22bisinit
        
loopback_init

        move    #1,x:loopback           ;Digital loopback init
        move    #$108,x:MDMCONFIG       ;Init tx as CALL modem and RX as
                                        ;  answer modem
        move    #$7fff,x:TX_GAIN 

dov22bisinit

        move    #12,x:Tx_Baud_Count
        move    #0,x:DC_Tap_Scaled      ;Used in V22BIS_RX to remove the DC
                                        ;  error from the received samples
        
        jsr     V22BIS_INIT             ;Call V22BIS Init routine
  
        jsr     V42DRV_INIT             ;LAPM drivers for reading and 
                                        ;  writing data from/to V22bis
                                        ;  interface
        
        move    #0,y0                   ;Initialization successful               
        
        rts



;**************************************************************************
;
;   Module Name     : V22BIS_TRANSMIT
;
;**************************************************************************
;
;   Date            : 15.04.96
;
;   Date Modified   : 14 Apr 2000
;
;**************************************************************************
;
;   PROCESSOR       : 568xx
;
;**************************************************************************
;
;   DESCRIPTION  : This module performs modulation on the input bit stream
;                  and returns 12 samples everytime it is called. In the
;                  handshake mode this routine returns 12 samples of 
;                  data related for modem handshake. Till the data mode is
;                  reached it keeps giving samples related to handshake 
;                  mode. 
;
;   OUTPUT       : pointer to the 12 sampless buffer in r2
;                : y0 = ESTABLISHING_CONNECTIN = 0,
;                     = DATA_TRANSMISSION_INPROGRESS = 1,
;                     = DATA_TRANSMISSION_OVER = 2,
;                     
;
;**************************************************************************
;--------------------------------------------------------------------------
;     Include the macros
;--------------------------------------------------------------------------


FV22BIS_TRANSMIT
                                           

        tstw    x:loopback
        beq     _check_data_mode
        move    x:rx_st_id,x0
        move    #$16,y1
        cmp     x0,y1
        bne     _noinputdata
        bra     _loopbackdata
    
_check_data_mode    
 
        brclr   #DABIT,x:MDMSTATUS,_noinputdata
        
_loopbackdata        
        jsr     V42_V22DRV                 ;Fill Tx_data with the next
                                           ;nibble of data to be transmi
                                           ;tted, if in data mode       
_noinputdata

        jsr     V22BIS_TX
        
        move    #tx_out,r0
        move    r0,r1
        
        move    x:TX_GAIN,y0 
               
        do      #12,copy_samples           ;Copy samples to the output
        move    x:(r0)+,x0                 ;  buffer
        mpyr    y0,x0,a                    ;Apply the tx attenuation factor
        move    a,x:(r1)+
copy_samples
        
        rts    


 
        
;**************************************************************************
;
;   Module Name     : V22BIS_RECEIVE_SAMPLE
;
;**************************************************************************
;
;   Date            : 15.04.96
;
;   Date Modified   : 14 Apr 2000
;
;**************************************************************************
;
;   PROCESSOR       : 568xx
;
;**************************************************************************
;
;   DESCRIPTION  : This module receives a sample from the codec and checks
;                  whether baud processing is needed. If needed it will 
;                  process a block of data received previously and returns
;                  the received bits to the calling routine
;
;   INPUT        : y0 = Received sample
;
;   OUTPUT       :    
;
;**************************************************************************
;--------------------------------------------------------------------------
;     Include the macros
;--------------------------------------------------------------------------


FV22BIS_RECEIVE_SAMPLE

        lea     (sp)+
        move    y0,x:(sp)                 ;Save the recent sample
        move    #0,x:txrx_status          ;Clear the status register
        
        tstw    x:retrain_flag
        beq     _donot_report_retrain
        bfset   #$0010,x:txrx_status      ;Indicate to the user that modem
        move    #0,x:retrain_flag         ;  is in retraining mode
               
_donot_report_retrain
        tstw    x:Sync_sent_status        ;If it is set, it means the sync 
        beq     _datamode                 ;  not sent after the handshake
        
        decw    x:Tx_Baud_Count   
        bne     _no_tx_request

        move    #12,x:Tx_Baud_Count       ;Reset the tx count to 12        
        jsr     FV22BIS_TRANSMIT          ;Get 12 samples
        bfset   #$0004,x:txrx_status      ;bit 2 to indicate TX buffer full
        tstw    x:Sync_sent_status
        bne     _connection_not_established
        bfset   #$0008,x:txrx_status      ;bit 3 to indicate connection esta-
                                          ;  blished
                
_connection_not_established                
_datamode
_no_tx_request                

        pop     a                         ;Retreive the sample
        
        move    x:IBPTR_IN,r0             ;Get the input pointer to write
        move    #IBSIZ,x0
        sub     #1,x0
        move    x0,m01

        move    x:DC_Tap_Scaled,x0        ;Subtract the DC Tap from the
        sub     x0,a                      ;  received codec sample to 
        move    a,x:DC_Error              ;  adjust for the DC error
        rnd     a
        move    a,x:(r0)+                 ;Store the result in IB buffer
        move    r0,x:IBPTR_IN             ;Save the updated pointer
        move    #$ffff,m01                ;Make the pointer linear
        move    x:IBCNT,a
        move    #$0100,x0
        sub     x0,a                      ;Decrement Rx Sample buffer
        move    a1,x:IBCNT
        jgt     NoRxBaudReq               ;If it is <= 0

        add     #$0c00,a                  ;  of samples per baud) to the 
                                          ;  Rx sample count
        move    r0,x:IBPTR                ;Set the o/p ptr to IB buffer to
                                          ;  be used by interpol module
        move    a1,x:IBCNT

        jsr     V22BIS_RX
        
        jsr     V22_V42DRV                ;Write back Rx_data to V42 Driver
        tstw    y0                        ;Returns the status in y0
        beq     _nooutputdata             ;y0 = 0->no word, 1->nibble received
        
        bfset   #$0001,x:txrx_status      ;Nibble received
                
;--------------------------------------------------------------------------
;Call Tx and Rx stubs only during loopback to change states whenever
;necessary
;--------------------------------------------------------------------------

_nooutputdata

        tstw    x:loopback
        beq     _noloopback
        
        jsr     tx_stub
        jsr     rx_stub

_noloopback
        
        move    x:mode_flg,a
        bftsth  #datamd,a
        bcs     Receive_End
        
        brset   #TXERR,x:MDMSTATUS,Exit_Error     ; Tx error
        brset   #RXERR,x:MDMSTATUS,Exit_Error     ; Rx error
        brset   #DISCON,x:MDMSTATUS,Exit_Error    ; Disconnected
               
        bra     Receive_End
        
              
Exit_Error
;--------------------------------------------------------------------------------
;Return with FAIL status
;--------------------------------------------------------------------------------

        bfset   #$0002,x:txrx_status      ;Receive error in handshake mode
        
        
Receive_End
NoRxBaudReq

        move    x:txrx_status,y0          ;Pass the status to calling routine

        rts      


        ENDSEC

