        include "gmdmequ.asm"
       

        SECTION  API

        GLOBAL   FV42_V22DRV_INIT

        GLOBAL   V42DRV_INIT
        GLOBAL   V22_V42DRV
        GLOBAL   V42_V22DRV
        GLOBAL   LAPM_MDM_INIT
        GLOBAL   READ_NIBBLE
        GLOBAL   End_ReadNibble
        GLOBAL   WRITE_NIBBLE        


ByteSyncFlg  equ    $007e
SyncWord     equ    $537e
   

        org   p:
        
        
V42DRV_INIT

        move    #0,x:WordWrFlg             ;Bit0 of WordWrFlg and WordRdFlg is 
        move    #0,x:WordRdFlg             ;used for Nibble Read/Write status. Bit1
                                           ;is used for Byte Read/Write status
        move    #0,x:StartCompare
        move    #SyncWord,x:SyncWord_mem   ;Sync_sent_status is initially set. It is
        move    #1,x:Sync_sent_status      ;reset after the Sync word is transmitted
                                           ;completely.
        move    #0,x:SyncWord_rx  
                
        rts        



FV42_V22DRV_INIT

        move    #0,x:WordRdFlg             ;Bit0 of WordWrFlg is for nibble read 
        move    r2,x:in_data_ptr           ;  and bit 1 for byte read. Bit3 & 4
                                           ;  are for 3rd and 4t nibble respectively
        rts
                

V22_V42DRV

        move    #0,y0                      ;Status set to no word received
        tstw    x:loopback
        bne     _loopback_mode
        brclr   #DABIT,x:MDMSTATUS,_end_write
        jsr     WRITE_NIBBLE
_end_write
        rts

_loopback_mode
        move    #0,y0                      ;Status set to no word received        
        tstw    x:StartCompare
        bne     _write_nibble

        move    x:rx_data,x0
        rep     #12
        lsl     x0
        
        move    x:SyncWord_rx,a1           ;Get recently received nibble
        rep     #4                         ;Shift it 
        lsr     a
        or      x0,a
        move    #0,a0
        move    a1,x:SyncWord_rx
        
        move    a1,x0
        cmp     x:SyncWord_mem,x0
        bne     _write_out
        move    #1,x:StartCompare
        move    #0,x:WordWrFlg
        bra     _write_out
                
_write_nibble
        jsr     WRITE_NIBBLE

_write_out
  
        rts
        

V42_V22DRV
        jsr     READ_NIBBLE                ;This routine is called when the
                                           ;  receiver enters data mode i.e.,
        rts                                ;  rx_st_id == 16
        


LAPM_MDM_INIT

        rts
                


WRITE_NIBBLE

        move    #1,y0
        rts                                ;Return nibble received status

       
READ_NIBBLE

        tstw    x:Sync_sent_status
        beq     _transmit_user_data
        tstw    x:loopback                 ;If in loopback mode, transmit
        bne     _sync_in_loopback          ;  the sync word
        move    #$ffff,a                   ;Send stop bits immediately after
        move    #0,x:Sync_sent_status      ;  entering the data mode
        bra     End_ReadNibble

_sync_in_loopback
        move    x:SyncWord_mem,a 
        bra     _send_sync_data
 
_transmit_user_data
     
        move    x:in_data_ptr,r2           ;Get the word
        nop
        move    x:(r2),a
 
_send_sync_data
 
        bftsth  #$0003,x:WordRdFlg         ;Bit0 : Nibble Read status
        bcs     _Fourth_nibble_read        ;Bit1 : Byte Read status
        bftsth  #$0002,x:WordRdFlg         ; 00 -> Start of new word
        bcs     _Third_nibble_read         ; 01 -> First LS Nibble Read complete
        bftsth  #$0001,x:WordRdFlg         ; 10 -> Byte read (Half word read)
        bcs     _Second_nibble_read        ; 11 -> 3 LS nibbles read complete
        
_new_word
        bfset   #$0001,x:WordRdFlg         ;Change status to 01 -> First LS 
        bra     End_ReadNibble             ;nibble read complete

_Second_nibble_read
        rep     #4                         ;Shift 2 nibble to LS nibble location
        lsr     a                            
        bfset   #$0002,x:WordRdFlg         ;Change status to 10 -> Byte 
        bfclr   #$0001,x:WordRdFlg         ;(2 nibbles) read complete
        bra     End_ReadNibble

_Third_nibble_read
        rep     #8                         ;Shift 3rd nibble to LS nibble 
        lsr     a                          ;location
        bfset   #$0003,x:WordRdFlg         ;Change status to 11 -> 3 nibbles read
        bra     End_ReadNibble             ;complete

_Fourth_nibble_read
        rep     #12                        ;Shift 4th nibble to LS location
        lsr     a
        bfclr   #$0003,x:WordRdFlg         ;Change status to 00 -> start of
                                           ;new word
        tstw    x:Sync_sent_status
        beq     _update_Buffer_ptr
        move    #0,x:Sync_sent_status
        bra     End_ReadNibble
        
_update_Buffer_ptr
        incw    x:in_data_ptr    

End_ReadNibble
        andc    #$000F,a
        move    a1,x:tx_data
        
        rts



        ENDSEC
