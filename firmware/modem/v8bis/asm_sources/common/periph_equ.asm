;************************************************************************
;
; Motorola India Electronics Ltd. (MIEL).
;
; PROJECT ID           : V.8 bis
;
; ASSEMBLER            : ASM56800 version 6.2.0
;
; FILE NAME            : per_equ.asm
;
; PROGRAMMER           : Varadarajan G 
;
; DATE CREATED         : 11 Jun 1998
; 
; FILE DESCRIPTION     : Defines the peripheral memory locations
;
; FUNCTIONS            : None
;
; MACROS               : None
;
;*************************** Revision History *****************************
;
;  Date         Author             Description 
;  ----         ------             -----------
; 11 Jun 1998   Varadarajan G      Created (Reuse from Vista)
;
;**************************************************************************

;--------  Define Important Addresses
PI_RES   equ    $0000                     ; reset P-mem location
PI_INT   equ    $0080                     ; one above interrupt vectors

;--------  On-chip Peripheral Registers
IPR      equ    $fffb                     ; X-address - Interrupt Priority Reg
BCR      equ    $fff9                     ; X-address - Bus Control Reg

;--------  PLL Registers
PCR1     equ    $fff3                     ; PLL Control Reg 1
PCR0     equ    $fff2                     ; PLL Control Reg 0

;--------  Watch Dog Registers   
COPCTL   equ    $fff1                     ; COP/RTI control registers
COPCNT   equ    $fff0                     ; COP/RTI count register (RO)
COPRST   equ    COPCNT                    ; COP Reset Register (WO)

;--------  PORTC Registers
PCD      equ    $ffef
PCDDR    equ    $ffee
PCC      equ    $ffed                     ; PortC Control Reg

;--------  PORT-B registers
PBD      equ    $ffec                     ; Port-B Data
PBDDR    equ    $ffeb                     ; Port-B Data Directions Reg
PBINT    equ    $ffea                     ; Port-B Interupt Reg.

;--------  SPI Registers
SPCR1    equ    $ffe6                     ;SPI1 Control register
SPSR1    equ    $ffe5                     ;SPI1 Status register
SPDR1    equ    $ffe4                     ;SPI1 Data register
SPCR0    equ    $ffe2                     ;SPI0 Control register
SPSR0    equ    $ffe1                     ;SPI0 Status register
SPDR0    equ    $ffe0                     ;SPI0 Data register

;--------  Timer Registers
TCR01    equ    $ffdf                     ;timer 0 & 1 control register
TPR0     equ    $ffde                     ;timer 0 preload register
TCT0     equ    $ffdd                     ;timer 0 count register
TPR1     equ    $ffdc                     ;timer 1 preload register
TCT1     equ    $ffdb                     ;timer 1 count register
TCR2     equ    $ffda                     ;timer 2 control register
TPR2     equ    $ffd9                     ;timer 2 preload register
TCT2     equ    $ffd8                     ;timer 2 count register

;--------  MSSI Registers
STSR     equ    $ffd5                     ; SSI time slot register
SCRRX    equ    $ffd4                     ; SSI RX Control
SCRTX    equ    $ffd3                     ; SSI TX Control
SCR2     equ    $ffd2                     ; SSI Control Register 2
SCSR     equ    $ffd1                     ; SSI Control/Status Register
SRX_STX  equ    $ffd0                     ; TX/RX register

;-------------------------------------
; BIT MAP for the Peripheral registers
;-------------------------------------

;-------- IPR Bit pattern

PB_INT   equ    $8000                     ; Port B GPIO interrupt
RTI_INT  equ    $4000                     ; Real Time Timer
SPI0_INT equ    $2000                     ; SPI0
SPI1_INT equ    $1000
TIMER_INT equ   $0800                     ; Timer modules
SSI_INT  equ    $0200                     ; SSI port

;-------- Port B bit pattern

CODEC_EN equ    $0100                     ;PB14 
SREQ     equ    $0002                     ;PB1

;-------- Port C bit pattern

SSI_PORTC equ   $0f00                     ;PC8-PC11 pins config.as SSI

;-------- Bit map for PLL

;         IF     CRYSTAL==2048
;YD       equ    $0100                     ; YD = 8 for 2.048MHz Crystal
;         ENDIF
;         IF     CRYSTAL==3686
YD       equ    $0080                     ; YD = 4 for 3.6864MHz Crystal
;         ENDIF

PS       equ    $0600                     ; prescaler o/p = PLL/256
CS       equ    $0080                     ; CLKO = Osc. clock
PLE_BIT  equ    $4000                     ; PLL enable bit position

;-------- Bit map for SSI port

;--- For SSI_TX/RX control register bit mapping

PSR_BIT  equ    $8000                     ; Prescalar disabled (PSR =0)
WL_FLD   equ    $6000                     ; No.bits/word = 16 (WL=3)
DC_FLD   equ    $0100                     ; Frame rate divider=2 (DC=1)
PM_FLD   equ    $0013                     ; Prescale Modulus=20 (PM=$13)

SCRTX_BIT_PATT equ (WL_FLD|DC_FLD|PM_FLD)  ;

;--- For SCR2 control register bit mapping

RIE_BIT  equ    $8000                     ;Rx Interrupt Enable
TIE_BIT  equ    $4000                     ;Tx Interrupt Enable
RE_BIT   equ    $2000                     ;Rx Enable
TE_BIT   equ    $1000                     ;Tx Enable
RBF_BIT  equ    $0800                     ;Rx Buf Enable
TBF_BIT  equ    $0400                     ;Tx Buf Enable
RXD_BIT  equ    $0200                     ;Rx Direction
TXD_BIT  equ    $0100                     ;Tx Direction
SYNC_BIT equ    $0080                     ;Synchronization
SHFD_BIT equ    $0040                     ;MSB/LSB first 
SCKP_BIT equ    $0020                     ;Clock Polarity
SSIEN_BIT equ   $0010                     ;SSI interrupt enable
NET_BIT  equ    $0008                     ;Network mode enable
FSI_BIT  equ    $0004                     ;Frame Sync Invert enable
FSL_BIT  equ    $0002                     ;Frame Sync Length
EFS_BIT  equ    $0001                     ;Early Frame sync

SCR2_BIT_PATT equ (TIE_BIT|RE_BIT|TE_BIT|TXD_BIT|SYNC_BIT|FSL_BIT|EFS_BIT)

;--- For SCSR bit pattern

RSHFD_BIT equ   $4000                     ;Rx Shft MSB/LSB first
RSCKP_BIT equ   $2000                     ;RxClock polarity
RFSI_BIT  equ   $0400                     ;Rx Frame sync invert
RFSL_BIT  equ   $0200                     ;Rx Frame sync length
REFS_BIT  equ   $0100                     ;Rx Early Frame sync

SCSR_BIT_PATT equ (RFSL_BIT|REFS_BIT)

