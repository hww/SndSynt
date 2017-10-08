;************************************************************************
;
; Motorola India Electronics Ltd. (MIEL).
;
; PROJECT ID           : V.8 bis
;
; ASSEMBLER            : ASM56800 version 6.2.0
;
; FILE NAME            : v21_rxbchk.asm
;
; PROGRAMMER           : Varadarajan G
;
; DATE CREATED         : 02 Jun 1998
; 
; FILE DESCRIPTION     : This file contains functions, one of which is
;                          executed at the end of the each state.
;
; FUNCTIONS            : V21_Rxcdwait, V21_Rxagc, V21_Rxfirstzc, 
;                        V21_Rxdata
;
; MACROS               : None
;
;************************************************************************
;
;  Program memory used:  72
;
;**************************** Assembly Code *******************************
        

        include "v8bis_equ.asm"

        SECTION V21_Rxbchk

        GLOBAL    V21_Rxcdwait
        GLOBAL    V21_Rxagc
        GLOBAL    V21_Rxfirstzc
        GLOBAL    V21_Rxdata
        GLOBAL    V21_Rxwait

              
;****************************** Module ************************************
;
;  Module Name    : V21_Rxcdwait
;  Author         : Varadarajan G
;
;************************** Module Description ****************************
;
;  Receiver waits for the presence of the signal on the line. 
;
;  Calls :
;        Modules : None
;
;*************************** Revision History *****************************
;
;  Date         Author             Description 
;  ----         ------             -----------
; 02 Jun 98   Varadarajan G        First Version
; 03 Jul 2000 N R Prasad           Ported on to Metrowerks
;
;************************** Input and Output ******************************
;
;  Input  :
;        carrier detect= | 0000 0000 | 0000 000i | in x:v21_cdflag
;        baud counter  = | 0000 0000 | 0000 00ii | in x:v21_rxctr
;        
;  Output :
;        state change  = | 0000 0000 | 0000 000i | in x:v21_rxstchg
;        baud counter  = | 0000 0000 | 0000 00ii | in x:v21_rxctr
;        v8  status    = | iiii iiii | iiii iiii | in x:Fg_v8bis_flags
;        next state    = | iiii iiii | iiii iiii | in x:v21_rxsti_ptr
;        
; (for non 1.15 format, fill the format field)
;****************************** Resources *********************************

        ORG     p:

V21_Rxcdwait
        tstw    x:v21_cdflag              ;
        beq     _carrier_not_found        ;If carrier found,  
        decw    x:v21_rxctr               ;  coninuously for 3 bauds
        bgt     End_V21_Rxcdwait          ;  
        bfset   #CDBIT,x:Fg_v8bis_flags   ;  Declare the carrier found
        move    #V21_Rxagc_Init,x:v21_rxsti_ptr
        move    #CHG_STATE,x:v21_rxstchg  ;  effect state change
        bra     End_V21_Rxcdwait          ;
_carrier_not_found                        ;Else (carrier not found)
        move    #CDPRESENSE,x:v21_rxctr   ;  reinit state counter
End_V21_Rxcdwait
        rts
 
;****************************** Module ************************************
;
;  Module Name    : V21_Rxwait
;  Author         : Varadarajan G
;
;************************** Module Description ****************************
;
;  Accumulate energy for 3 bauds Dont detect first zerro crossing in this
;  state.
;  Calls :  None
;
;*************************** Revision History *****************************
;
;  Date         Author             Description 
;  ----         ------             -----------
; 23 Jun 98    Varadarajan G       First version
; 03 Jul 2000  N R Prasad          Ported on to Metrowerks
;
;************************** Input and Output ******************************
;
;  Input  :
;        carrier detect= | 0000 0000 | 0000 000i | in x:v21_cdflag
;        baud counter  = | 0000 0000 | 0000 00ii | in x:v21_rxctr
;
;  Output :
;        state change  = | 0000 0000 | 0000 000i | in x:v21_rxstchg
;        next state    = | iiii iiii | iiii iiii | in x:v21_rxsti_ptr
; (for non 1.15 format, fill the format field)
;****************************** Resources *********************************

V21_Rxwait
        decw    x:v21_rxctr
        bgt     End_V21_Rxwait
        tstw    x:v21_cdflag
        bne     _go_to_next_state
        move    #V21_Rxcdw_Init,x:v21_rxsti_ptr
        bfclr   #CDBIT,x:Fg_v8bis_flags   ;  Declare the carrier lost
        move    #CHG_STATE,x:v21_rxstchg
        bra     End_V21_Rxwait
_go_to_next_state
        move    #V21_Rxagcfzc_Init,x:v21_rxsti_ptr
        move    #CHG_STATE,x:v21_rxstchg
End_V21_Rxwait
        rts

;****************************** Module ************************************
;
;  Module Name    : V21_Rxagc
;  Author         : Varadarajan G
;
;************************** Module Description ****************************
;
;  Accumulate energy for 16 bauds or till the first zero crossing and 
;  compute the gain from this. If the zero crossing is found then goto
;  data state or goto the state to search for first zero crossing.
;
;  Calls : 
;    Modules : V21_Rxagcgjam
;
;*************************** Revision History *****************************
;
;  Date         Author             Description 
;  ----         ------             -----------
; 02 Jun 98    Varadarajan G       First version
; 03 Jul 2000  N R Prasad          Ported on to Metrowerks
;
;************************** Input and Output ******************************
;
;  Input  :
;        carrier detect= | 0000 0000 | 0000 000i | in x:v21_cdflag
;        baud counter  = | 0000 0000 | 0000 00ii | in x:v21_rxctr
;        zero cross flg= | 0000 0000 | 0000 000i | in x:first_zero_cross
;
;  Output :
;        state change  = | 0000 0000 | 0000 000i | in x:v21_rxstchg
;        next state    = | iiii iiii | iiii iiii | in x:v21_rxsti_ptr
;        v8  status    = | iiii iiii | iiii iiii | in x:Fg_v8bis_flags
; (for non 1.15 format, fill the format field)
;****************************** Resources *********************************


V21_Rxagc 
        tstw    x:v21_cdflag              
        bne     _chk_for_agcg             ;If carrier is lost
        move    #V21_Rxcdw_Init,x:v21_rxsti_ptr
        bfclr   #CDBIT,x:Fg_v8bis_flags   ;  Declare the carrier lost
        move    #CHG_STATE,x:v21_rxstchg  ;  Goto v21_rxcdwait state
        bra     End_V21_Rxagc
_chk_for_agcg
;--------------------------------------------------------------------------
; Order of checking first zero crossing detection first and then the 16 
;   baud counter expiry is important as it might happen that first zero
;   crossing might happen on the 16th baud, in which case next state should
;   be data state and not detection of first zerocrossing state.
;--------------------------------------------------------------------------
        tstw    x:first_zero_cross        ;If first zero crossing detected
        move    #V21_Rxdat_Init,x:v21_rxsti_ptr
                                          ;  goto data state after calling
        bne     _call_agcg                ;  agcgain computation module
        decw    x:v21_rxctr               ;If 16 bauds are over
        move    #V21_Rxfzc_Init,x:v21_rxsti_ptr
        bgt     End_V21_Rxagc             ;  goto search for first zero 
_call_agcg                                ;  crossing after calling
        jsr     V21_Rxagcgjam             ;  agcgain computation module
        move    #CHG_STATE,x:v21_rxstchg
End_V21_Rxagc
        rts

;****************************** Module ************************************
;
;  Module Name    : V21_Rxfirstzc
;  Author         : Varadarajan G
;
;************************** Module Description ****************************
;
;  When the first zero crossing is found, it will change to data state.
;  If a carrier loss if observed, this will go back to cdwait state
;
;  Calls : None
;
;*************************** Revision History *****************************
;
;  Date         Author             Description 
;  ----         ------             -----------
; 02 Jun 98    Varadarajan G       First Version
; 03 Jul 2000  N R Prasad          Ported on to Metrowerks
;
;************************** Input and Output ******************************
;
;  Input  :
;        carrier detect= | 0000 0000 | 0000 000i | in x:v21_cdflag
;        zero cross flg= | 0000 0000 | 0000 000i | in x:first_zero_cross
;        
;  Output :
;        state change  = | 0000 0000 | 0000 000i | in x:v21_rxstchg
;        next state    = | iiii iiii | iiii iiii | in x:v21_rxsti_ptr
;        v8  status    = | iiii iiii | iiii iiii | in x:Fg_v8bis_flags
; (for non 1.15 format, fill the format field)
;****************************** Resources *********************************


V21_Rxfirstzc
        tstw    x:v21_cdflag              ;If carrier is missing in line,
        bne     _chk_for_first_zerocross
        move    #V21_Rxcdw_Init,x:v21_rxsti_ptr
        bfclr   #CDBIT,x:Fg_v8bis_flags   ;  Declare the carrier lost
        move    #CHG_STATE,x:v21_rxstchg  ;  go back to wait for cd state
        bra     End_V21_Rxfirstzc
_chk_for_first_zerocross
        tstw    x:first_zero_cross        ;if first zero cross is found
        beq     End_V21_Rxfirstzc
        move    #V21_Rxdat_Init,x:v21_rxsti_ptr
        move    #CHG_STATE,x:v21_rxstchg  ;  goto data state
End_V21_Rxfirstzc
        rts


;****************************** Module ************************************
;
;  Module Name    : V21_Rxdata
;  Author         : Varadarajan G
;
;************************** Module Description ****************************
;
;  Data state. Will Go back to cdwait state if the carrier is not found
;  in the line for (20-80) ms which is (6-24) bauds. Arbitrarily 9 bauds
;  is chosen in this range
;
;  Calls : None
;
;*************************** Revision History *****************************
;
;  Date         Author             Description 
;  ----         ------             -----------
; 02 Jun 98    Varadarajan G       First Version
; 03 Jul 2000  N R Prasad          Ported on to Metrowerks
;
;************************** Input and Output ******************************
;
;  Input  :
;        carrier detect= | 0000 0000 | 0000 000i | in x:v21_cdflag
;
;  Output :
;        state change  = | 0000 0000 | 0000 000i | in x:v21_rxstchg
;        next state    = | iiii iiii | iiii iiii | in x:v21_rxsti_ptr
;        v8  status    = | iiii iiii | iiii iiii | in x:Fg_v8bis_flags
; (for non 1.15 format, fill the format field)
;****************************** Resources *********************************


V21_Rxdata
        tstw    x:v21_cdflag              ;If carrier is not found for 
        bne     End_V21_Rxdata
        decw    x:v21_rxctr               ;  the mentioned time,
        bgt     End_V21_Rxdata
        move    #V21_Rxcdw_Init,x:v21_rxsti_ptr
        bfclr   #CDBIT,x:Fg_v8bis_flags   ;  Declare the carrier lost
        move    #CHG_STATE,x:v21_rxstchg  ;  goto cdwait state
End_V21_Rxdata
        rts

        ENDSEC

;****************************** End of File *******************************
