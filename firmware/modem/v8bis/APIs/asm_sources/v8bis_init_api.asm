NO_OF_COMMANDS    equ    8
        
        SECTION V8BIS_IS_RS_INIT GLOBAL
        GLOBAL  FV8bis_IS_init
        GLOBAL  FV8bis_RS_init
        GLOBAL  count
        GLOBAL  tx_counter
        GLOBAL  buf_in_ptr
        GLOBAL  flag

        org     x:
count           ds   1
tx_counter      ds   1
buf_in_ptr      ds   1
flag            ds   1

        org     p:

FV8bis_IS_init:                    ;Initialization of initiating station

        move    r2,x:buf_in_ptr    ;Retrieve the argument passed
                                   ; r2->pConfig.MessagePtr

        move    #0,x:flag
        move    #NO_OF_COMMANDS,x:count
        
        move    #600,x0
        do      x0,_loop
        nop
        nop
        nop
        nop
        nop
_loop	

        jsr     FV8bis_Init
        nop
        rts



FV8bis_RS_init:                   ;Initialization of responding station

        move    r2,x:buf_in_ptr    ;Retrieve the argument passed
                                   ; r2->pConfig.MessagePtr

        move    #0,x:flag
        move    #NO_OF_COMMANDS,x:count
        

        jsr     FV8bis_Init
        nop
        rts


       ENDSEC
