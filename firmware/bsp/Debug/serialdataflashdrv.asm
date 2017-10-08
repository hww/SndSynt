
				SECTION serialdataflashdrv
				include "asmdef.h"
				GLOBAL FserialdataflashOpen
				ORG	P:
FserialdataflashOpen:
				movei   #6,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    X:(SP),X0
				cmp     #12,X0
				jne     _L25
				movei   #0,X:(SP-3)
				movei   #0,X:(SP-2)
				movei   #7,X:(SP-4)
				movei   #1,X:(SP-5)
				andc    #-132,X:11f3
				orc     #131,X:11f2
				movec   SP,R0
				lea     (R0-5)
				push    R0
				movei   #0,X0
				push    X0
				movei   #32,R2
				jsr     Fopen
				lea     (SP-2)
				move    Y0,X:FSerialDataFlash+2
				move    X:FSerialDataFlash+2,R2
				nop     
				move    X:(R2+1),R0
				movei   #0,X0
				move    X0,X:(R0+6)
				move    X:FSerialDataFlash+2,R2
				nop     
				move    X:(R2+1),R0
				move    X:(R0+7),Y0
				movei   #4,X0
				lsll    Y0,X0,X0
				movec   X0,R0
				move    X:(R0+#FArchIO+320),X0
				orc     #8,X0
				move    X0,X:(R0+#FArchIO+320)
				move    X:FSerialDataFlash+2,R2
				nop     
				move    X:(R2+1),R0
				move    X:(R0+7),Y0
				movei   #4,X0
				lsll    Y0,X0,X0
				movec   X0,R0
				move    X:(R0+#FArchIO+320),X0
				orc     #4,X0
				move    X0,X:(R0+#FArchIO+320)
				move    X:FSerialDataFlash+2,R2
				nop     
				move    X:(R2+1),R0
				move    X:(R0+7),Y0
				movei   #4,X0
				lsll    Y0,X0,X0
				movec   X0,R0
				move    X:(R0+#FArchIO+320),X0
				andc    #-193,X0
				move    X0,X:(R0+#FArchIO+320)
				movei   #87,X:FSerialDataFlash+7
				movei   #255,X:FSerialDataFlash+8
				move    X:FSerialDataFlash+2,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),R0
				move    X:FSerialDataFlash+2,R2
				nop     
				move    X:(R2+1),Y0
				movei   #FSerialDataFlash+7,R2
				movei   #1,Y1
				movei   #_L17,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L17:
				move    X:FSerialDataFlash+2,R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+1),R0
				move    X:FSerialDataFlash+2,R2
				nop     
				move    X:(R2+1),Y0
				movei   #FSerialDataFlash+3,R2
				movei   #1,Y1
				movei   #_L19,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L19:
				movei   #1,X:FSerialDataFlash
				movei   #0,X:FSerialDataFlash+4
				movei   #0,X:FSerialDataFlash+5
				movei   #0,X:FSerialDataFlash+6
				movei   #FSerialDataFlash,R0
				move    R0,X:(SP-1)
				bra     _L26
_L25:
				movei   #65535,R2
				bra     _L31
_L26:
				bftstl  #8,X:(SP-8)
				blo     _L29
				move    X:(SP-1),R2
				nop     
				movei   #0,X:(R2+1)
				bra     _L30
_L29:
				move    X:(SP-1),R2
				nop     
				movei   #1,X:(R2+1)
_L30:
				movei   #FserialdataflashdrvDevice,R2
_L31:
				lea     (SP-6)
				rts     


				GLOBAL FserialdataflashClose
				ORG	P:
FserialdataflashClose:
				movei   #0,Y0
				rts     


				GLOBAL FserialdataflashRead
				ORG	P:
FserialdataflashRead:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				move    X:<mr11,N
				push    N
				movei   #15,N
				lea     (SP)+N
				move    Y0,X:(SP)
				move    R2,X:(SP-1)
				move    Y1,X:(SP-2)
				movei   #1,X:(SP-11)
				move    X:(SP-1),R0
				move    R0,X:<mr10
				move    X:(SP),R0
				move    R0,X:<mr8
				move    X:(SP-2),X0
				lsl     X0
				move    X0,X:(SP-10)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+5),B
				move    X:(R2+4),B0
				move    B1,X:(SP-8)
				move    B0,X:(SP-9)
				movei   #0,X:(SP-7)
				movei   #0,X:(SP-6)
				moves   #0,X:<mr9
				movei   #0,X:(SP-5)
				movei   #0,X:(SP-4)
				clr     B
				move    X:(SP-10),B0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+5),A
				move    X:(R2+4),A0
				add     B,A
				movei   #66,B
				cmp     B,A
				bls     _L16
				moves   X:<mr8,R2
				nop     
				move    X:(R2+5),B
				move    X:(R2+4),B0
				movei   #66,A
				sub     B,A
				movec   A0,X0
				move    X0,X:(SP-10)
				bra     _L16
_L14:
				movei   #0,B
				movei   #528,B0
				move    X:(SP-6),A
				move    X:(SP-7),A0
				add     A,B
				move    B1,X:(SP-6)
				move    B0,X:(SP-7)
				inc     X:(SP-5)
_L16:
				moves   X:<mr8,R2
				move    X:(SP-6),B
				move    X:(SP-7),B0
				move    X:(R2+5),A
				move    X:(R2+4),A0
				cmp     A,B
				bls     _L14
				dec     X:(SP-5)
				movei   #-1,B
				movei   #-528,B0
				move    X:(SP-6),A
				move    X:(SP-7),A0
				add     A,B
				move    B1,X:(SP-6)
				move    B0,X:(SP-7)
				moves   X:<mr8,R2
				move    X:(SP-6),B
				move    X:(SP-7),B0
				move    X:(R2+5),A
				move    X:(R2+4),A0
				sub     B,A
				movec   A0,X0
				move    X0,X:<mr9
				tstw    X:(SP-10)
				jeq     _L68
				move    X:(SP-10),X0
				move    X0,X:(SP-12)
				tstw    X:(SP-11)
				jeq     _L67
				move    X:(SP-5),X0
				lsl     X0
				lsl     X0
				move    X0,X:(SP-3)
_L24:
				movei   #528,X0
				sub     X:<mr9,X0
				move    X0,X:(SP-4)
				move    X:(SP-4),X0
				cmp     X:(SP-12),X0
				blo     _L29
				move    X:(SP-12),X0
				move    X0,X:(SP-4)
				movei   #0,X:(SP-11)
				bra     _L30
_L29:
				move    X:(SP-12),X0
				sub     X:(SP-4),X0
				move    X0,X:(SP-12)
_L30:
				moves   #0,X:<mr11
				moves   X:<mr11,X0
				cmp     X:(SP-4),X0
				jhs     _L62
_L32:
				moves   X:<mr8,R2
				nop     
				movei   #82,X:(R2+7)
				move    X:(SP-5),Y0
				movei   #6,X0
				lsrr    Y0,X0,X0
				andc    #127,X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+8)
				moves   X:<mr9,Y0
				movei   #8,X0
				lsrr    Y0,X0,Y0
				move    X:(SP-3),X0
				or      X0,Y0
				andc    #255,Y0
				moves   X:<mr8,R2
				nop     
				move    Y0,X:(R2+9)
				moves   X:<mr9,X0
				andc    #255,X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+10)
				moves   X:<mr8,R2
				nop     
				movei   #255,X:(R2+11)
				moves   X:<mr8,R2
				nop     
				movei   #255,X:(R2+12)
				moves   X:<mr8,R2
				nop     
				movei   #255,X:(R2+13)
				moves   X:<mr8,R2
				nop     
				movei   #255,X:(R2+14)
				moves   X:<mr8,R2
				nop     
				movei   #255,X:(R2+15)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R1
				move    X:(R1+1),Y0
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+7)
				movei   #9,Y1
				movei   #_L42,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L42:
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+1),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R1
				move    X:(R1+1),Y0
				movec   SP,R2
				lea     (R2-13)
				movei   #1,Y1
				movei   #_L44,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L44:
				move    X:(SP-13),Y0
				movei   #8,X0
				lsll    Y0,X0,X0
				andc    #-256,X0
				move    X0,X:(SP-13)
				inc     X:<mr9
				moves   X:<mr9,X0
				andc    #255,X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+10)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R1
				move    X:(R1+1),Y0
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+7)
				movei   #9,Y1
				movei   #_L49,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L49:
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+1),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R1
				move    X:(R1+1),Y0
				movec   SP,R2
				lea     (R2-14)
				movei   #1,Y1
				movei   #_L51,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L51:
				move    X:(SP-14),Y0
				andc    #255,Y0
				move    X:(SP-13),X0
				or      X0,Y0
				move    Y0,X:(SP-13)
				inc     X:<mr9
				moves   X:<mr8,R2
				nop     
				tstw    X:(R2+6)
				beq     _L58
				moves   X:<mr10,R0
				nop     
				move    X:(R0),X0
				cmp     X:(SP-13),X0
				beq     _L59
				clr     B
				move    X:(SP-10),B0
				move    X:(SP-8),A
				move    X:(SP-9),A0
				add     A,B
				moves   X:<mr8,R2
				nop     
				move    B1,X:(R2+5)
				move    B0,X:(R2+4)
				movei   #0,Y0
				bra     _L68
_L58:
				moves   X:<mr10,R0
				move    X:(SP-13),X0
				move    X0,X:(R0)
_L59:
				moves   X:<mr11,X0
				add     #2,X0
				move    X0,X:<mr11
				inc     X:<mr10
				moves   X:<mr11,X0
				cmp     X:(SP-4),X0
				jlo     _L32
_L62:
				moves   #0,X:<mr9
				move    X:(SP-3),X0
				add     #4,X0
				move    X0,X:(SP-3)
				inc     X:(SP-5)
				moves   X:<mr8,R2
				clr     B
				move    X:(SP-4),B0
				move    X:(R2+5),A
				move    X:(R2+4),A0
				add     A,B
				move    B1,X:(R2+5)
				move    B0,X:(R2+4)
				tstw    X:(SP-11)
				jne     _L24
_L67:
				move    X:(SP-10),Y0
				lsr     Y0
_L68:
				lea     (SP-15)
				pop     N
				move    N,X:<mr11
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FserialdataflashWrite
				ORG	P:
FserialdataflashWrite:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				move    X:<mr11,N
				push    N
				movei   #14,N
				lea     (SP)+N
				move    Y0,X:(SP)
				move    R2,X:(SP-1)
				move    Y1,X:(SP-2)
				movei   #1,X:(SP-12)
				move    X:(SP-1),R0
				move    R0,X:<mr11
				move    X:(SP),R0
				move    R0,X:<mr8
				move    X:(SP-2),X0
				lsl     X0
				move    X0,X:(SP-11)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+5),B
				move    X:(R2+4),B0
				move    B1,X:(SP-9)
				move    B0,X:(SP-10)
				movei   #0,X:(SP-8)
				movei   #0,X:(SP-7)
				movei   #0,X:(SP-6)
				movei   #0,X:(SP-5)
				movei   #0,X:(SP-4)
				clr     B
				move    X:(SP-11),B0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+5),A
				move    X:(R2+4),A0
				add     B,A
				movei   #66,B
				cmp     B,A
				bls     _L16
				moves   X:<mr8,R2
				nop     
				move    X:(R2+5),B
				move    X:(R2+4),B0
				movei   #66,A
				sub     B,A
				movec   A0,X0
				move    X0,X:(SP-11)
				bra     _L16
_L14:
				movei   #0,B
				movei   #528,B0
				move    X:(SP-7),A
				move    X:(SP-8),A0
				add     A,B
				move    B1,X:(SP-7)
				move    B0,X:(SP-8)
				inc     X:(SP-5)
_L16:
				moves   X:<mr8,R2
				move    X:(SP-7),B
				move    X:(SP-8),B0
				move    X:(R2+5),A
				move    X:(R2+4),A0
				cmp     A,B
				bls     _L14
				dec     X:(SP-5)
				movei   #-1,B
				movei   #-528,B0
				move    X:(SP-7),A
				move    X:(SP-8),A0
				add     A,B
				move    B1,X:(SP-7)
				move    B0,X:(SP-8)
				moves   X:<mr8,R2
				move    X:(SP-7),B
				move    X:(SP-8),B0
				move    X:(R2+5),A
				move    X:(R2+4),A0
				sub     B,A
				movec   A0,X0
				move    X0,X:(SP-6)
				tstw    X:(SP-11)
				jeq     _L85
				move    X:(SP-11),X0
				move    X0,X:(SP-13)
				tstw    X:(SP-12)
				jeq     _L82
				move    X:(SP-5),X0
				lsl     X0
				lsl     X0
				move    X0,X:(SP-3)
_L24:
				movei   #528,X0
				sub     X:(SP-6),X0
				move    X0,X:(SP-4)
				move    X:(SP-4),X0
				cmp     X:(SP-13),X0
				blo     _L29
				move    X:(SP-13),X0
				move    X0,X:(SP-4)
				movei   #0,X:(SP-12)
				bra     _L30
_L29:
				move    X:(SP-13),X0
				sub     X:(SP-4),X0
				move    X0,X:(SP-13)
_L30:
				moves   X:<mr8,R2
				nop     
				movei   #83,X:(R2+7)
				move    X:(SP-5),Y0
				movei   #6,X0
				lsrr    Y0,X0,X0
				andc    #127,X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+8)
				move    X:(SP-3),X0
				andc    #252,X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+9)
				moves   X:<mr8,R2
				nop     
				movei   #0,X:(R2+10)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R1
				move    X:(R1+1),Y0
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+7)
				movei   #4,Y1
				movei   #_L35,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L35:
				moves   X:<mr8,R2
				nop     
				movei   #87,X:(R2+7)
				moves   X:<mr8,R2
				nop     
				movei   #255,X:(R2+8)
_L38:
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R1
				move    X:(R1+1),Y0
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+7)
				movei   #2,Y1
				movei   #_L39,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L39:
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+1),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R1
				move    X:(R1+1),Y0
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+3)
				movei   #1,Y1
				movei   #_L41,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L41:
				moves   X:<mr8,R2
				nop     
				bftstl  #128,X:(R2+3)
				blo     _L38
				moves   X:<mr8,R2
				nop     
				movei   #132,X:(R2+7)
				moves   X:<mr8,R2
				nop     
				movei   #0,X:(R2+8)
				move    X:(SP-6),Y0
				movei   #8,X0
				lsrr    Y0,X0,X0
				andc    #3,X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+9)
				move    X:(SP-6),X0
				andc    #255,X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+10)
				moves   #0,X:<mr9
				moves   X:<mr9,X0
				cmp     X:(SP-4),X0
				bhs     _L55
_L49:
				moves   X:<mr11,R0
				nop     
				move    X:(R0),X0
				move    X0,X:<mr10
				inc     X:<mr11
				moves   X:<mr10,Y0
				movei   #8,X0
				lsrr    Y0,X0,Y0
				andc    #255,Y0
				moves   X:<mr9,X0
				add     X:<mr8,X0
				movec   X0,R2
				nop     
				move    Y0,X:(R2+11)
				moves   X:<mr10,Y0
				andc    #255,Y0
				moves   X:<mr9,X0
				add     X:<mr8,X0
				movec   X0,R2
				nop     
				move    Y0,X:(R2+12)
				moves   X:<mr9,X0
				add     #2,X0
				move    X0,X:<mr9
				moves   X:<mr9,X0
				cmp     X:(SP-4),X0
				blo     _L49
_L55:
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R1
				move    X:(R1+1),Y0
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+7)
				move    X:(SP-4),Y1
				add     #4,Y1
				movei   #_L56,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L56:
				moves   X:<mr8,R2
				nop     
				movei   #87,X:(R2+7)
				moves   X:<mr8,R2
				nop     
				movei   #255,X:(R2+8)
_L59:
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R1
				move    X:(R1+1),Y0
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+7)
				movei   #2,Y1
				movei   #_L60,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L60:
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+1),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R1
				move    X:(R1+1),Y0
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+3)
				movei   #1,Y1
				movei   #_L62,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L62:
				moves   X:<mr8,R2
				nop     
				bftstl  #128,X:(R2+3)
				blo     _L59
				moves   X:<mr8,R2
				nop     
				movei   #131,X:(R2+7)
				move    X:(SP-5),Y0
				movei   #6,X0
				lsrr    Y0,X0,X0
				andc    #127,X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+8)
				move    X:(SP-3),X0
				andc    #252,X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+9)
				moves   X:<mr8,R2
				nop     
				movei   #0,X:(R2+10)
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R1
				move    X:(R1+1),Y0
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+7)
				movei   #4,Y1
				movei   #_L69,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L69:
				moves   X:<mr8,R2
				nop     
				movei   #87,X:(R2+7)
				moves   X:<mr8,R2
				nop     
				movei   #255,X:(R2+8)
_L72:
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+2),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R1
				move    X:(R1+1),Y0
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+7)
				movei   #2,Y1
				movei   #_L73,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L73:
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R0
				nop     
				move    X:(R0),R2
				nop     
				move    X:(R2+1),R0
				moves   X:<mr8,R2
				nop     
				move    X:(R2+2),R1
				move    X:(R1+1),Y0
				moves   X:<mr8,X0
				movec   X0,R2
				nop     
				lea     (R2+3)
				movei   #1,Y1
				movei   #_L75,R1
				push    R1
				push    SR
				push    R0
				push    SR
				rts     
_L75:
				moves   X:<mr8,R2
				nop     
				bftstl  #128,X:(R2+3)
				blo     _L72
				movei   #0,X:(SP-6)
				move    X:(SP-3),X0
				add     #4,X0
				move    X0,X:(SP-3)
				inc     X:(SP-5)
				moves   X:<mr8,R2
				clr     B
				move    X:(SP-4),B0
				move    X:(R2+5),A
				move    X:(R2+4),A0
				add     A,B
				move    B1,X:(R2+5)
				move    B0,X:(R2+4)
				tstw    X:(SP-12)
				jne     _L24
_L82:
				moves   X:<mr8,R2
				nop     
				tstw    X:(R2+6)
				beq     _L85
				move    X:(SP-9),B
				move    X:(SP-10),B0
				moves   X:<mr8,R2
				nop     
				move    B1,X:(R2+5)
				move    B0,X:(R2+4)
				move    X:(SP-1),R2
				move    X:(SP),Y0
				move    X:(SP-2),Y1
				jsr     FserialdataflashRead
				bra     _L86
_L85:
				move    X:(SP-11),Y0
				lsr     Y0
_L86:
				lea     (SP-14)
				pop     N
				move    N,X:<mr11
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL FserialdataflashIoctl
				ORG	P:
FserialdataflashIoctl:
				movei   #4,N
				lea     (SP)+N
				moves   Y1,X:<mr2
				movec   Y0,R2
				moves   X:<mr2,X0
				cmp     #512,X0
				beq     _L12
				cmp     #256,X0
				beq     _L10
				cmp     #1,X0
				bne     _L18
_L7:
				movei   #0,X:FSerialDataFlash+4
				movei   #0,X:FSerialDataFlash+5
				movei   #0,X:FSerialDataFlash+6
				bra     _L18
_L10:
				move    X:(SP-6),R0
				nop     
				move    X:(R0),X0
				move    X0,X:(R2+6)
				bra     _L18
_L12:
				move    X:(SP-6),R0
				movei   #0,B
				movei   #1,B0
				movec   Y0,X:(SP-3)
				move    X:(R0+1),Y1
				move    X:(R0),Y0
				and     B1,Y1
				movec   B0,B1
				and     B1,Y0
				tfr     Y1,B
				movec   Y0,B0
				tst     B
				beq     _L14
				move    X:(SP-6),R0
				movei   #0,B
				movei   #1,B0
				move    X:(R0+1),A
				move    X:(R0),A0
				add     A,B
				bra     _L15
_L14:
				move    X:(SP-6),R0
				move    X:(R0+1),B
				move    X:(R0),B0
_L15:
				move    B1,X:(R2+5)
				move    B0,X:(R2+4)
				move    X:(R2+5),B
				move    X:(R2+4),B0
				movei   #65,A
				movei   #-1,A0
				cmp     A,B
				bls     _L18
				movei   #0,X:(R2+4)
				movei   #66,X:(R2+5)
_L18:
				movei   #0,Y0
				lea     (SP-4)
				rts     


				GLOBAL FserialdataflashDevCreate
				ORG	P:
FserialdataflashDevCreate:
				movei   #FserialdataflashOpen,R2
				jsr     FioDrvInstall
				movei   #0,X:FSerialDataFlash
				movei   #0,Y0
				rts     


				ORG	X:
FInterfaceVT    DC			FserialdataflashClose,FserialdataflashdrvDevice,FSerialDataFlash,FserialdataflashOpen
FserialdataflashdrvDeviceDC			FInterfaceVT,FserialdataflashIoctl
FSerialDataFlashBSC			543

				ENDSEC
				END
