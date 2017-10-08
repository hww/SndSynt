
				SECTION flashdrv
				include "asmdef.h"
				GLOBAL FflashOpen
				ORG	P:
FflashOpen:
				moves   R2,X:<mr2
				moves   X:<mr2,X0
				cmp     #3,X0
				beq     _L13
				cmp     #2,X0
				beq     _L10
				cmp     #1,X0
				bne     _L16
_L7:
				movei   #FFlashDevice,R2
				movei   #FDriver,R3
				bra     _L17
_L10:
				movei   #FFlashDevice+8,R2
				movei   #FDriver+2,R3
				bra     _L17
_L13:
				movei   #FFlashDevice+16,R2
				movei   #FDriver+4,R3
				bra     _L17
_L16:
				movei   #-1,R2
				bra     _L22
_L17:
				move    X:(R2+2),X0
				move    X0,X:(R2+6)
				bftstl  #8,X:(SP-2)
				blo     _L20
				debug   
_L20:
				movei   #32768,X:(R2+7)
				movec   R3,R2
_L22:
				rts     


				GLOBAL FflashClose
				ORG	P:
FflashClose:
				movec   Y0,R2
				nop     
				movei   #0,X:(R2+7)
				movei   #0,Y0
				rts     


				GLOBAL FflashRead
				ORG	P:
FflashRead:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				move    X:<mr11,N
				push    N
				movei   #5,N
				lea     (SP)+N
				move    Y0,X:(SP)
				move    R2,X:(SP-1)
				move    Y1,X:(SP-2)
				movei   #0,X:(SP-4)
				move    X:(SP),R0
				move    R0,X:<mr8
				move    X:(SP-1),R0
				move    R0,X:<mr11
				move    X:(SP-2),X0
				move    X0,X:<mr9
				moves   X:<mr8,R2
				nop     
				move    X:(R2+6),X0
				move    X0,X:<mr10
				moves   X:<mr8,R2
				move    X:(SP-2),Y0
				jsr     FflashGetCorrectSize
				move    Y0,X:<mr9
				tstw    X:<mr9
				jeq     _L25
				moves   X:<mr8,R2
				jsr     FflashSetAddressMode
				move    Y0,X:(SP-3)
				moves   X:<mr8,R2
				nop     
				bftstl  #4,X:(R2+7)
				blo     _L19
				moves   X:<mr8,R2
				nop     
				move    X:(R2+7),X0
				andc    #1,X0
				tstw    X0
				beq     _L13
				moves   X:<mr8,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+5),R0
				bra     _L14
_L13:
				moves   X:<mr8,R1
				nop     
				move    X:(R1),R2
				nop     
				move    X:(R2+4),R0
_L14:
				moves   X:<mr10,R3
				moves   X:<mr9,Y0
				moves   X:<mr11,R2
				movei   #_L15,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L15:
				tstw    Y0
				beq     _L23
				moves   X:<mr9,X0
				add     X:<mr10,X0
				move    X0,X:<mr10
				moves   #0,X:<mr9
				bra     _L23
_L19:
				moves   X:<mr8,R2
				nop     
				move    X:(R2+7),X0
				andc    #1,X0
				tstw    X0
				beq     _L22
				moves   X:<mr8,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+1),R0
				moves   X:<mr10,R3
				moves   X:<mr9,Y0
				moves   X:<mr11,R2
				movei   #_L21,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L21:
				bra     _L23
_L22:
				moves   X:<mr8,R0
				nop     
				move    X:(R0),R1
				nop     
				move    X:(R1),R0
				moves   X:<mr10,R3
				moves   X:<mr9,Y0
				moves   X:<mr11,R2
				movei   #_L23,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L23:
				moves   X:<mr8,R2
				move    X:(SP-3),Y0
				jsr     FflashRestoreAddressMode
				moves   X:<mr9,X0
				add     X:<mr10,X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+6)
_L25:
				moves   X:<mr9,Y0
				lea     (SP-5)
				pop     N
				move    N,X:<mr11
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FflashWrite
				ORG	P:
FflashWrite:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				move    X:<mr11,N
				push    N
				movei   #13,N
				lea     (SP)+N
				move    Y0,X:(SP)
				move    R2,X:(SP-1)
				move    Y1,X:(SP-2)
				moves   #0,X:<mr10
				movei   #0,X:(SP-10)
				movei   #0,X:(SP-9)
				movei   #1,X:(SP-8)
				movei   #1,X:(SP-7)
				move    X:(SP),R0
				move    R0,X:(SP-6)
				move    X:(SP-1),R0
				move    R0,X:(SP-5)
				move    X:(SP-2),X0
				move    X0,X:(SP-4)
				move    X:(SP-6),R2
				nop     
				move    X:(R2+6),X0
				move    X0,X:<mr8
				move    X:(SP-6),R2
				move    X:(SP-2),Y0
				jsr     FflashGetCorrectSize
				move    Y0,X:(SP-4)
				tstw    X:(SP-4)
				jeq     _L69
				move    X:(SP-4),X0
				move    X0,X:(SP-12)
				move    X:(SP-6),R2
				jsr     FflashSetAddressMode
				move    Y0,X:(SP-3)
				tstw    X:(SP-8)
				jeq     _L64
_L16:
				moves   X:<mr8,Y0
				andc    #255,Y0
				movei   #256,X0
				sub     Y0,X0
				move    X0,X:(SP-11)
				move    X:(SP-11),X0
				cmp     X:(SP-12),X0
				blo     _L21
				move    X:(SP-12),X0
				move    X0,X:(SP-11)
				movei   #0,X:(SP-8)
				bra     _L22
_L21:
				move    X:(SP-12),X0
				sub     X:(SP-11),X0
				move    X0,X:(SP-12)
_L22:
				move    X:(SP-6),R2
				nop     
				move    X:(R2+5),R2
				movei   #-1,Y0
				movei   #256,Y1
				jsr     FmemMemset
				move    X:(SP-6),R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+4),R0
				move    X:(SP-6),R2
				nop     
				move    X:(R2+5),R2
				moves   X:<mr8,R3
				move    X:(SP-11),Y0
				movei   #_L24,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L24:
				tstw    Y0
				beq     _L26
				movei   #1,X:(SP-9)
_L26:
				move    X:(SP-9),X0
				cmp     #1,X0
				jne     _L39
				movei   #256,X0
				cmp     X:(SP-11),X0
				jls     _L39
				move    X:(SP-6),R0
				nop     
				move    X:(R0),R1
				nop     
				move    X:(R1),R0
				move    X:(SP-6),R2
				nop     
				move    X:(R2+5),R2
				moves   X:<mr8,X0
				andc    #-256,X0
				movec   X0,R3
				movei   #256,Y0
				movei   #_L29,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L29:
				move    X:(SP-6),R2
				nop     
				move    X:(R2+7),X0
				andc    #1,X0
				tstw    X0
				beq     _L32
				move    X:(SP-6),R2
				moves   X:<mr8,Y0
				andc    #255,Y0
				move    X:(R2+5),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-11),Y0
				move    X:(SP-5),R3
				jsr     FmemCopyPtoX
				bra     _L33
_L32:
				move    X:(SP-6),R2
				moves   X:<mr8,Y0
				andc    #255,Y0
				move    X:(R2+5),X0
				add     X0,Y0
				movec   Y0,R2
				move    X:(SP-11),Y0
				move    X:(SP-5),R3
				jsr     FmemMemcpy
_L33:
				move    X:(SP-6),R2
				nop     
				move    X:(R2+5),R0
				move    R0,X:<mr10
				move    X:(SP-11),X0
				add     X:(SP-5),X0
				move    X0,X:(SP-5)
				andc    #65280,X:<mr8
				movei   #256,X:(SP-11)
				move    X:(SP-6),R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),R0
				move    R0,X:(SP-10)
				bra     _L45
_L39:
				move    X:(SP-5),R0
				move    R0,X:<mr10
				move    X:(SP-11),X0
				add     X:(SP-5),X0
				move    X0,X:(SP-5)
				move    X:(SP-6),R2
				nop     
				move    X:(R2+7),X0
				andc    #1,X0
				tstw    X0
				beq     _L44
				move    X:(SP-6),R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+3),R0
				move    R0,X:(SP-10)
				bra     _L45
_L44:
				move    X:(SP-6),R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),R0
				move    R0,X:(SP-10)
_L45:
				move    X:(SP-9),X0
				cmp     #1,X0
				bne     _L47
				move    X:(SP-6),R2
				nop     
				move    X:(R2+1),Y0
				move    X:(SP-6),R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),R2
				moves   X:<mr8,Y1
				jsr     FflashHWErasePage
_L47:
				movei   #1,X:(SP-7)
				tstw    X:(SP-7)
				beq     _L63
_L49:
				moves   X:<mr8,Y0
				andc    #31,Y0
				movei   #32,X0
				sub     Y0,X0
				move    X0,X:<mr11
				moves   X:<mr11,X0
				cmp     X:(SP-11),X0
				blo     _L54
				move    X:(SP-11),X0
				move    X0,X:<mr11
				movei   #0,X:(SP-7)
				bra     _L55
_L54:
				move    X:(SP-11),X0
				sub     X:<mr11,X0
				move    X0,X:(SP-11)
_L55:
				moves   #0,X:<mr9
				moves   X:<mr9,X0
				cmp     X:<mr11,X0
				bhs     _L62
_L57:
				move    X:(SP-6),R2
				nop     
				move    X:(R2+1),Y0
				move    X:(SP-10),R2
				moves   X:<mr8,Y1
				moves   X:<mr10,R3
				jsr     FflashHWProgramWord
				inc     X:<mr8
				inc     X:<mr10
				inc     X:<mr9
				moves   X:<mr9,X0
				cmp     X:<mr11,X0
				blo     _L57
_L62:
				tstw    X:(SP-7)
				bne     _L49
_L63:
				tstw    X:(SP-8)
				jne     _L16
_L64:
				move    X:(SP-6),R2
				move    X:(SP-3),Y0
				jsr     FflashRestoreAddressMode
				move    X:(SP-6),R2
				nop     
				bftstl  #4,X:(R2+7)
				blo     _L68
				move    X:(SP-1),R2
				move    X:(SP),Y0
				move    X:(SP-2),Y1
				jsr     FflashRead
				move    Y0,X:(SP-4)
				bra     _L69
_L68:
				move    X:(SP-6),R2
				move    X:(SP-4),Y0
				move    X:(R2+6),X0
				add     X0,Y0
				move    Y0,X:(R2+6)
_L69:
				move    X:(SP-4),Y0
				lea     (SP-13)
				pop     N
				move    N,X:<mr11
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FflashIoctl
				ORG	P:
FflashIoctl:
				move    X:<mr8,N
				push    N
				movei   #3,N
				lea     (SP)+N
				move    Y0,X:(SP)
				move    Y1,X:(SP-1)
				move    X:(SP),R0
				move    R0,X:(SP-2)
				move    X:(SP-1),X0
				cmp     #7,X0
				jgt     _L25
				asl     X0
				add     #_L5,X0
				push    X0
				push    SR
				rti     
				jmp     _L25
				jmp     _L6
				jmp     _L9
				jmp     _L11
				jmp     _L13
				jmp     _L17
				jmp     _L19
				jmp     _L21
_L6:
				move    X:(SP-2),R2
				nop     
				move    X:(R2+2),X0
				move    X:(SP-2),R2
				nop     
				move    X0,X:(R2+6)
				move    X:(SP-2),R2
				nop     
				movei   #32768,X:(R2+7)
				jmp     _L25
_L9:
				move    X:(SP-2),R2
				nop     
				orc     #4,X:(R2+7)
				jmp     _L25
_L11:
				move    X:(SP-2),R2
				nop     
				andc    #65531,X:(R2+7)
				jmp     _L25
_L13:
				move    X:(SP-2),R2
				move    X:(SP-6),R0
				nop     
				move    X:(R0),Y0
				move    X:(R2+2),X0
				add     X0,Y0
				move    X:(SP-2),R2
				nop     
				move    Y0,X:(R2+6)
				move    X:(SP-2),R2
				move    X:(SP-2),R0
				move    X:(SP-2),R1
				move    X:(R1+3),Y0
				move    X:(R0+2),X0
				add     X0,Y0
				move    X:(R2+6),X0
				cmp     Y0,X0
				bls     _L25
				move    X:(SP-2),R2
				move    X:(SP-2),R0
				move    X:(R0+3),Y0
				move    X:(R2+2),X0
				add     X0,Y0
				move    X:(SP-2),R2
				nop     
				move    Y0,X:(R2+6)
				bra     _L25
_L17:
				move    X:(SP-2),R2
				nop     
				andc    #65534,X:(R2+7)
				bra     _L25
_L19:
				move    X:(SP-2),R2
				nop     
				orc     #1,X:(R2+7)
				bra     _L25
_L21:
				move    X:(SP-2),R2
				jsr     FflashSetAddressMode
				move    Y0,X:<mr8
				move    X:(SP-2),R2
				nop     
				move    X:(R2+1),Y0
				move    X:(SP-2),R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),R2
				move    X:(SP-2),R0
				move    X:(R0+2),Y1
				jsr     FflashHWErase
				move    X:(SP-2),R2
				moves   X:<mr8,Y0
				jsr     FflashRestoreAddressMode
				move    X:(SP-2),R2
				nop     
				move    X:(R2+2),X0
				move    X:(SP-2),R2
				nop     
				move    X0,X:(R2+6)
_L25:
				movei   #0,Y0
				lea     (SP-3)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FflashDevCreate
				ORG	P:
FflashDevCreate:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				moves   #0,X:<mr8
				moves   X:<mr8,X0
				cmp     #3,X0
				bge     _L10
				moves   X:<mr8,Y0
				movei   #3,X0
				asll    Y0,X0,X0
				add     #FFlashDevice,X0
				move    X0,X:<mr9
_L5:
				moves   X:<mr9,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FflashHWDisableISR
				moves   X:<mr9,R2
				nop     
				move    X:(R2+1),Y0
				jsr     FflashHWClearConfig
				moves   X:<mr9,X0
				add     #8,X0
				move    X0,X:<mr9
				inc     X:<mr8
				moves   X:<mr8,X0
				cmp     #3,X0
				blt     _L5
_L10:
				moves   #0,X:<mr8
				moves   X:<mr8,X0
				cmp     #3,X0
				bge     _L18
				moves   X:<mr8,Y0
				movei   #3,X0
				asll    Y0,X0,X0
				add     #FFlashDevice,X0
				move    X0,X:(SP-1)
_L13:
				move    X:(SP-1),R2
				nop     
				move    X:(R2+2),X0
				move    X:(SP-1),R2
				nop     
				move    X0,X:(R2+6)
				move    X:(SP-1),R2
				nop     
				movei   #0,X:(R2+7)
				move    X:(SP-1),X0
				add     #8,X0
				move    X0,X:(SP-1)
				inc     X:<mr8
				moves   X:<mr8,X0
				cmp     #3,X0
				blt     _L13
_L18:
				moves   #0,X:<mr8
				bra     _L27
_L20:
				move    X:(SP),R0
				nop     
				tstw    X:(R0)
				beq     _L22
				move    X:(SP),R0
				nop     
				move    X:(R0),R1
				moves   X:<mr8,N
				moves   X:<mr8,Y0
				move    X:FFlashDevice+1,X0
				add     Y0,X0
				movec   X0,R0
				move    X:(R1+N),X0
				move    X0,X:(R0+8)
_L22:
				move    X:(SP),R2
				nop     
				tstw    X:(R2+1)
				beq     _L24
				move    X:(SP),R2
				nop     
				move    X:(R2+1),R0
				moves   X:<mr8,N
				moves   X:<mr8,Y0
				move    X:FFlashDevice+9,X0
				add     Y0,X0
				movec   X0,R1
				move    X:(R0+N),X0
				move    X0,X:(R1+8)
_L24:
				move    X:(SP),R2
				nop     
				tstw    X:(R2+2)
				beq     _L26
				move    X:(SP),R2
				nop     
				move    X:(R2+2),R0
				moves   X:<mr8,N
				moves   X:<mr8,Y0
				move    X:FFlashDevice+17,X0
				add     Y0,X0
				movec   X0,R1
				move    X:(R0+N),X0
				move    X0,X:(R1+8)
_L26:
				inc     X:<mr8
_L27:
				moves   X:<mr8,X0
				cmp     #9,X0
				blo     _L20
				movei   #FflashOpen,R2
				jsr     FioDrvInstall
				movei   #0,Y0
				lea     (SP-2)
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				ORG	P:
FflashGetCorrectSize:
				move    Y0,X:<mr2
				moves   X:<mr2,Y1
				move    X:(R2+3),X0
				cmp     X0,Y1
				bls     _L4
				move    X:(R2+3),X0
				move    X0,X:<mr2
_L4:
				clr     B
				moves   X:<mr2,X0
				move    X0,B0
				clr     A
				move    X:(R2+6),A0
				add     B,A
				move    X:(R2+2),Y1
				move    X:(R2+3),X0
				add     X0,Y1
				clr     B
				movec   Y1,B0
				cmp     B,A
				bls     _L6
				move    X:(R2+2),X0
				move    X:(R2+3),Y1
				add     Y1,X0
				move    X:(R2+6),Y1
				sub     Y1,X0
				move    X0,X:<mr2
_L6:
				movei   #32767,X0
				cmp     X:<mr2,X0
				bhs     _L8
				moves   #32767,X:<mr2
_L8:
				moves   X:<mr2,Y0
				rts     


				ORG	P:
FflashHWDisableISR:
_L1:
				movec   Y0,R0
				nop     
				move    X:(R0),X0
				bftstl  #32768,X0
				bhs     _L1
				movec   Y0,R0
				movei   #0,X0
				move    X0,X:(R0+5)
				movec   Y0,R0
				movei   #0,X0
				move    X0,X:(R0+6)
				rts     


				ORG	P:
FflashHWClearConfig:
_L1:
				movec   Y0,R0
				nop     
				move    X:(R0),X0
				bftstl  #32768,X0
				bhs     _L1
				movec   Y0,R0
				nop     
				move    X:(R0),X0
				andc    #65471,X0
				move    X0,X:(R0)
				movec   Y0,R0
				movei   #0,X0
				move    X0,X:(R0+1)
				movec   Y0,R0
				movei   #0,X0
				move    X0,X:(R0+2)
				rts     


				ORG	P:
FflashHWErase:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				movei   #3,N
				lea     (SP)+N
				moves   Y0,X:<mr8
				move    R2,X:(SP)
				move    Y1,X:(SP-1)
				movei   #0,X:(SP-2)
				moves   X:<mr8,R0
				nop     
				move    X:(R0),X0
				andc    #-65,X0
				tstw    X0
				beq     _L5
				debug   
_L5:
				moves   X:<mr8,X0
				movec   X0,R0
				movei   #0,X0
				move    X0,X:(R0+6)
				moves   X:<mr8,X0
				movec   X0,R0
				movei   #16384,X0
				move    X0,X:(R0+2)
				moves   X:<mr8,R0
				nop     
				move    X:(R0),X0
				orc     #2,X0
				move    X0,X:(R0)
				move    X:(SP),R0
				move    X:(SP-1),R2
				movec   SP,R3
				lea     (R3-2)
				movei   #1,Y0
				movei   #_L9,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L9:
				moves   X:<mr8,R0
				nop     
				move    X:(R0),X0
				bftstl  #32768,X0
				bhs     _L9
				moves   X:<mr8,X0
				movec   X0,R0
				move    X:(R0+6),X0
				move    X0,X:<mr9
				moves   X:<mr9,X0
				andc    #3,X0
				tstw    X0
				beq     _L13
				debug   
_L13:
				moves   X:<mr8,R0
				nop     
				move    X:(R0),X0
				andc    #65533,X0
				move    X0,X:(R0)
				moves   X:<mr8,X0
				movec   X0,R0
				movei   #0,X0
				move    X0,X:(R0+2)
				moves   X:<mr8,X0
				movec   X0,R0
				movei   #0,X0
				move    X0,X:(R0+6)
				lea     (SP-3)
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				ORG	P:
FflashHWErasePage:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				movei   #2,N
				lea     (SP)+N
				moves   Y0,X:<mr8
				move    R2,X:(SP)
				moves   Y1,X:<mr10
				movei   #0,X:(SP-1)
				moves   X:<mr8,R0
				nop     
				move    X:(R0),X0
				andc    #-65,X0
				tstw    X0
				beq     _L5
				debug   
_L5:
				moves   X:<mr8,X0
				movec   X0,R0
				movei   #0,X0
				move    X0,X:(R0+6)
				moves   X:<mr10,Y0
				movei   #8,X0
				lsrr    Y0,X0,Y0
				orc     #16384,Y0
				moves   X:<mr8,X0
				movec   X0,R0
				move    Y0,X:(R0+2)
				move    X:(SP),R0
				moves   X:<mr10,R2
				movec   SP,R3
				nop     
				lea     (R3)-
				movei   #1,Y0
				movei   #_L8,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L8:
				moves   X:<mr8,R0
				nop     
				move    X:(R0),X0
				bftstl  #32768,X0
				bhs     _L8
				moves   X:<mr8,X0
				movec   X0,R0
				move    X:(R0+6),X0
				move    X0,X:<mr9
				moves   X:<mr9,X0
				andc    #3,X0
				tstw    X0
				beq     _L12
				debug   
_L12:
				moves   X:<mr8,X0
				movec   X0,R0
				movei   #0,X0
				move    X0,X:(R0+2)
				moves   X:<mr8,X0
				movec   X0,R0
				movei   #0,X0
				move    X0,X:(R0+6)
				lea     (SP-2)
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				ORG	P:
FflashHWProgramWord:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				movei   #2,N
				lea     (SP)+N
				moves   Y0,X:<mr8
				move    R2,X:(SP)
				moves   Y1,X:<mr10
				move    R3,X:(SP-1)
				moves   X:<mr8,R0
				nop     
				move    X:(R0),X0
				andc    #-65,X0
				tstw    X0
				beq     _L4
				debug   
_L4:
				moves   X:<mr8,X0
				movec   X0,R0
				movei   #0,X0
				move    X0,X:(R0+6)
				moves   X:<mr8,X0
				movec   X0,R0
				movei   #0,X0
				move    X0,X:(R0+5)
				moves   X:<mr10,Y0
				movei   #5,X0
				lsrr    Y0,X0,Y0
				orc     #16384,Y0
				moves   X:<mr8,X0
				movec   X0,R0
				move    Y0,X:(R0+1)
				move    X:(SP),R0
				moves   X:<mr10,R2
				move    X:(SP-1),R3
				movei   #1,Y0
				movei   #_L8,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L8:
				moves   X:<mr8,R0
				nop     
				move    X:(R0),X0
				bftstl  #32768,X0
				bhs     _L8
				moves   X:<mr8,X0
				movec   X0,R0
				move    X:(R0+6),X0
				move    X0,X:<mr9
				moves   X:<mr9,X0
				andc    #5,X0
				tstw    X0
				beq     _L12
				debug   
_L12:
				moves   X:<mr8,X0
				movec   X0,R0
				movei   #0,X0
				move    X0,X:(R0+1)
				moves   X:<mr8,X0
				movec   X0,R0
				movei   #0,X0
				move    X0,X:(R0+6)
				lea     (SP-2)
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				ORG	P:
FflashSetAddressMode:
				move    X:<mr8,N
				push    N
				lea     (SP)+
				move    R2,X:(SP)
				moves   #0,X:<mr8
				move    X:(SP),R2
				nop     
				move    X:(R2+4),X0
				andc    #6,X0
				tstw    X0
				beq     _L6
				bfset   #768,SR
				movei   #0,Y0
				jsr     FarchSetOperatingMode
				move    Y0,X:<mr8
_L6:
				moves   X:<mr8,Y0
				lea     (SP)-
				pop     N
				move    N,X:<mr8
				rts     


				ORG	P:
FflashRestoreAddressMode:
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    Y0,X:(SP-1)
				move    X:(SP),R2
				nop     
				move    X:(R2+4),X0
				andc    #6,X0
				tstw    X0
				beq     _L6
				move    X:(SP-1),Y0
				jsr     FarchSetOperatingMode
				bfset   #256,SR
				bfclr   #512,SR
_L6:
				lea     (SP-2)
				rts     


				GLOBAL FmemCmpXtoX
				ORG	P:
FmemCmpXtoX:
				move    X:<mr8,N
				push    N
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				moves   Y0,X:<mr8
				movei   #32767,X0
				cmp     X:<mr8,X0
				bhs     _L4
				debug   
_L4:
				move    X:(SP),R2
				move    X:(SP-1),R3
				moves   X:<mr8,Y0
				jsr     Fmemcmp
				lea     (SP-2)
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FmemCmpXtoP
				ORG	P:
FmemCmpXtoP:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				movei   #3,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				moves   Y0,X:<mr10
				moves   #0,X:<mr8
				move    X:(SP),R0
				move    R0,X:<mr9
				move    X:(SP-1),R0
				move    R0,X:(SP-2)
				movei   #32767,X0
				cmp     X:<mr10,X0
				bhs     _L13
				debug   
				bra     _L13
_L8:
				moves   X:<mr9,R2
				jsr     FmemReadP16
				move    X:(SP-2),R0
				nop     
				move    X:(R0),X0
				sub     Y0,X0
				move    X0,X:<mr8
				tstw    X:<mr8
				bne     _L14
				inc     X:<mr9
				inc     X:(SP-2)
				dec     X:<mr10
_L13:
				tstw    X:<mr10
				bne     _L8
_L14:
				moves   X:<mr8,Y0
				lea     (SP-3)
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FmemCmpPtoX
				ORG	P:
FmemCmpPtoX:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				movei   #3,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				moves   Y0,X:<mr10
				moves   #0,X:<mr8
				move    X:(SP),R0
				move    R0,X:(SP-2)
				move    X:(SP-1),R0
				move    R0,X:<mr9
				movei   #32767,X0
				cmp     X:<mr10,X0
				bhs     _L13
				debug   
				bra     _L13
_L8:
				moves   X:<mr9,R2
				jsr     FmemReadP16
				move    X:(SP-2),R0
				nop     
				move    X:(R0),X0
				sub     X0,Y0
				move    Y0,X:<mr8
				tstw    X:<mr8
				bne     _L14
				inc     X:(SP-2)
				inc     X:<mr9
				dec     X:<mr10
_L13:
				tstw    X:<mr10
				bne     _L8
_L14:
				moves   X:<mr8,Y0
				lea     (SP-3)
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FmemCmpPtoP
				ORG	P:
FmemCmpPtoP:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				movei   #4,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    R3,X:(SP-1)
				moves   Y0,X:<mr10
				moves   #0,X:<mr8
				move    X:(SP),R0
				move    R0,X:(SP-2)
				move    X:(SP-1),R0
				move    R0,X:<mr9
				movei   #32767,X0
				cmp     X:<mr10,X0
				bhs     _L13
				debug   
				bra     _L13
_L8:
				move    X:(SP-2),R2
				jsr     FmemReadP16
				move    Y0,X:(SP-3)
				moves   X:<mr9,R2
				jsr     FmemReadP16
				move    X:(SP-3),X0
				sub     X0,Y0
				move    Y0,X:<mr8
				tstw    X:<mr8
				bne     _L14
				inc     X:(SP-2)
				inc     X:<mr9
				dec     X:<mr10
_L13:
				tstw    X:<mr10
				bne     _L8
_L14:
				moves   X:<mr8,Y0
				lea     (SP-4)
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FarchSetOperatingMode
				ORG	P:
FarchSetOperatingMode:
				bfclr   #-4,Y0
				move    OMR,X0
				bfclr   #3,X0
				or      Y0,X0
				move    OMR,Y0
				bfclr   #-4,Y0
				move    X0,OMR
				rts     


				ORG	X:
FInterfaceVT    DC			FflashClose,FFlashDriver,FmemCmpPtoP,FmemCmpPtoX
FFlashDriver    DC			FmemMemcpy,FFlashDevice,FArchIO,FDriver,FflashOpen,.debug_flashOpen,.line_flashOpen,.debug_flashClose
				DC			.line_flashClose,FflashGetCorrectSize,FflashSetAddressMode,FflashRestoreAddressMode,.debug_flashRead,.line_flashRead,FmemMemset,FflashHWErasePage
				DC			FflashHWProgramWord,.debug_flashWrite,.line_flashWrite,FflashHWErase,.debug_flashIoctl,.line_flashIoctl,FflashDevCreate,FflashHWDisableISR
				DC			FflashHWClearConfig,FioDrvInstall,.debug_flashDevCreate,.line_flashDevCreate,.debug_flashGetCorrectSize,.line_flashGetCorrectSize,.debug_flashHWDisableISR,.line_flashHWDisableISR
				DC			.debug_flashHWClearConfig,.line_flashHWClearConfig,.debug_flashHWErase,.line_flashHWErase,.debug_flashHWErasePage,.line_flashHWErasePage,.debug_flashHWProgramWord,.line_flashHWProgramWord
				DC			FarchSetOperatingMode,.debug_flashSetAddressMode,.line_flashSetAddressMode,.debug_flashRestoreAddressMode,.line_flashRestoreAddressMode,Fmemcmp,.debug_memCmpXtoX,.line_memCmpXtoX
				DC			FmemReadP16,.debug_memCmpXtoP,.line_memCmpXtoP,.debug_memCmpPtoX,.line_memCmpPtoX,.debug_memCmpPtoP,.line_memCmpPtoP,.debug_archSetOperatingMode
				DC			.line_archSetOperatingMode,0,0,0,0,0,0,0
				DC			0,0,0,0,0,0,0,0
				DC			0,0,0,0,0,0,0,0
				DC			0,0,0,0,0,0,0,0
				DC			0,0,0,0,0,0,0,0
				DC			0,0,0,0,0,0,0,0
				DC			0,0,0,0,0,0,0,0
				DC			0,0,0,0,0,0,0,0
				DC			0,0,0,0,0,0,0,0
				DC			0,0,0,0,0,0,0,0
				DC			0,0,0,0,0,0,0,0
				DC			0,0,0,0,0,0,0,0
				DC			0,0,0,0,0,0,0,0
				DC			0,0,0,0,0,0,0,0
				DC			0,0,0,0,0,0,0,0
				DC			0,0,0,0,0,0,0,0
				DC			0,0,0,0,0,0,0,0
				DC			0,0,0,0,0,0,0,0
				DC			0,0,0,0,0,0,0,0
				DC			0,0,0,0,0,0,0,0
				DC			0,0,0,0,0,0,0,0
				DC			0,0,0,0,0,0,0,0
				DC			0,0,0,0,0,0,0,0
				DC			0,0,0,0,0,0,0,0
				DC			0,0,0,0,0,0,0,0
				DC			0,0,0,0,0,0,0,0
				DC			0,0,0,0
FFlashDevice    DC			FFlashDriver,FmemCmpPtoP,FmemCmpPtoX,FmemCopyPtoP,FmemCopyXtoP,FmemCopyPtoX,FmemCmpXtoP,FmemCmpXtoX
				DC			FmemMemcpy,FFlashDevice,FArchIO,FDriver,FflashOpen,.debug_flashOpen,.line_flashOpen,.debug_flashClose
				DC			.line_flashClose,FflashGetCorrectSize,FflashSetAddressMode,FflashRestoreAddressMode,.debug_flashRead,.line_flashRead,FmemMemset,FflashHWErasePage
FDriver         DC			FInterfaceVT,FflashIoctl,FflashWrite,FflashRead,FflashClose,FFlashDriver

				ENDSEC
				END
