
				SECTION tfr16
				include "asmdef.h"
				GLOBAL Ftfr16SinPIx
				ORG	P:
Ftfr16SinPIx:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				move    X:<mr11,N
				push    N
				movei   #6,N
				lea     (SP)+N
				move    Y0,X:(SP)
				movei   #0,X:(SP-5)
				movei   #0,X:(SP-4)
				movei   #0,X:(SP-3)
				tstw    X:(SP)
				bge     _L7
				movei   #1,X:(SP-5)
				move    X:(SP),B
				neg     B
				move    B,X:(SP)
_L7:
				move    X:(SP),X0
				cmp     #16384,X0
				ble     _L9
				move    X:(SP),Y0
				movei   #32767,X0
				sub     Y0,X0
				move    X0,X:(SP)
_L9:
				move    X:(SP),Y0
				move    X:(SP),X0
				mpyr    Y0,X0,B
				movec   B1,X0
				move    X0,X:<mr11
				move    X:FSineCoefs+5,Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-3)
				move    A0,X:(SP-4)
				move    X:FSineCoefs+6,Y0
				moves   X:<mr11,X0
				move    X:(SP-3),B
				move    X:(SP-4),B0
				macr    Y0,X0,B
				movec   B1,X0
				move    X0,X:<mr10
				moves   #4,X:<mr8
				tstw    X:<mr8
				blt     _L20
				moves   X:<mr8,X0
				add     #FSineCoefs,X0
				move    X0,X:<mr9
_L15:
				moves   X:<mr9,R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-3)
				move    A0,X:(SP-4)
				moves   X:<mr11,Y0
				moves   X:<mr10,X0
				move    X:(SP-3),B
				move    X:(SP-4),B0
				macr    Y0,X0,B
				movec   B1,X0
				move    X0,X:<mr10
				dec     X:<mr9
				dec     X:<mr8
				tstw    X:<mr8
				bge     _L15
_L20:
				move    X:(SP),Y0
				moves   X:<mr10,X0
				mpy     Y0,X0,B
				move    B1,X:(SP-1)
				move    B0,X:(SP-2)
				move    X:(SP-1),B
				move    X:(SP-2),B0
				asl     B
				asl     B
				asl     B
				move    B1,X:(SP-1)
				move    B0,X:(SP-2)
				move    X:(SP-1),B
				move    X:(SP-2),B0
				rnd     B
				move    B,X:<mr11
				move    X:(SP-5),X0
				cmp     #1,X0
				bne     _L25
				move    X:<mr11,B
				neg     B
				move    B,X:<mr11
_L25:
				moves   X:<mr11,Y0
				lea     (SP-6)
				pop     N
				move    N,X:<mr11
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Ftfr16CosPIx
				ORG	P:
Ftfr16CosPIx:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				movei   #2,N
				lea     (SP)+N
				moves   Y0,X:<mr8
				moves   #0,X:<mr10
				clr     B
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				tstw    X:<mr8
				bge     _L6
				move    X:<mr8,B
				neg     B
				move    B,X:<mr8
_L6:
				movei   #16384,X0
				cmp     X:<mr8,X0
				bge     _L9
				movei   #32767,X0
				sub     X:<mr8,X0
				move    X0,X:<mr8
				moves   #1,X:<mr10
_L9:
				movei   #16384,X0
				sub     X:<mr8,X0
				move    X0,X:<mr8
				moves   X:<mr10,X0
				cmp     #1,X0
				bne     _L12
				moves   X:<mr8,X0
				inc     X0
				move    X0,X:<mr8
_L12:
				moves   X:<mr8,Y0
				jsr     Ftfr16SinPIx
				move    Y0,X:<mr9
				moves   X:<mr10,X0
				cmp     #1,X0
				bne     _L15
				move    X:<mr9,B
				neg     B
				move    B,X:<mr9
_L15:
				moves   X:<mr9,Y0
				lea     (SP-2)
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Ftfr16AsinOverPI
				ORG	P:
Ftfr16AsinOverPI:
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
				movei   #0,X:(SP-4)
				movei   #0,X:(SP-3)
				movei   #0,X:(SP-2)
				movei   #0,X0
				move    X0,X:(SP-1)
				tstw    X:(SP)
				bge     _L8
				movei   #1,X:(SP-4)
				move    X:(SP),B
				neg     B
				move    B,X:(SP)
_L8:
				move    X:(SP),Y0
				move    X:(SP),X0
				mpyr    Y0,X0,B
				movec   B1,X0
				move    X0,X:<mr10
				move    X:(SP),X0
				cmp     #23170,X0
				ble     _L13
				movei   #1,X:(SP-3)
				moves   X:<mr10,X0
				movei   #32766,Y0
				sub     X0,Y0
				jsr     FL_deposit_h
				jsr     Fmfr32Sqrt
				move    Y0,X:(SP)
				move    X:(SP),Y0
				move    X:(SP),X0
				mpyr    Y0,X0,B
				movec   B1,X0
				move    X0,X:<mr10
_L13:
				move    X:FAsineCoefs+7,X0
				move    X0,X:<mr11
				moves   #6,X:<mr8
				tstw    X:<mr8
				blt     _L22
				moves   X:<mr8,X0
				add     #FAsineCoefs,X0
				move    X0,X:<mr9
_L17:
				moves   X:<mr9,R0
				nop     
				move    X:(R0),Y0
				jsr     FL_deposit_h
				move    A1,X:(SP-1)
				move    A0,X:(SP-2)
				moves   X:<mr10,Y0
				moves   X:<mr11,X0
				move    X:(SP-1),B
				move    X:(SP-2),B0
				macr    Y0,X0,B
				movec   B1,X0
				move    X0,X:<mr11
				dec     X:<mr9
				dec     X:<mr8
				tstw    X:<mr8
				bge     _L17
_L22:
				move    X:(SP),Y0
				moves   X:<mr11,X0
				mpyr    Y0,X0,B
				movec   B1,X0
				move    X0,X:<mr10
				move    X:(SP-3),X0
				cmp     #1,X0
				bne     _L25
				movei   #16384,X0
				sub     X:<mr10,X0
				move    X0,X:<mr10
_L25:
				move    X:(SP-4),X0
				cmp     #1,X0
				bne     _L27
				move    X:<mr10,B
				neg     B
				move    B,X:<mr10
_L27:
				moves   X:<mr10,Y0
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


				GLOBAL Ftfr16AcosOverPI
				ORG	P:
Ftfr16AcosOverPI:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				moves   Y0,X:<mr9
				moves   #0,X:<mr10
				tstw    X:<mr9
				bge     _L6
				moves   #1,X:<mr10
				move    X:<mr9,B
				neg     B
				move    B,X:<mr9
_L6:
				moves   X:<mr9,Y0
				jsr     Ftfr16AsinOverPI
				move    Y0,X:<mr8
				moves   X:<mr10,X0
				cmp     #1,X0
				bne     _L9
				move    X:<mr8,B
				neg     B
				move    B,X:<mr8
_L9:
				movei   #16384,X0
				sub     X:<mr8,X0
				move    X0,X:<mr8
				moves   X:<mr8,Y0
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Ftfr16AtanOverPI
				ORG	P:
Ftfr16AtanOverPI:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				move    X:<mr11,N
				push    N
				lea     (SP)+
				moves   Y0,X:<mr9
				movei   #0,X0
				move    X0,X:(SP)
				tstw    X:<mr9
				bge     _L6
				movei   #1,X0
				move    X0,X:(SP)
				move    X:<mr9,B
				neg     B
				move    B,X:<mr9
_L6:
				movei   #32767,X0
				cmp     X:<mr9,X0
				bne     _L9
				moves   #8192,X:<mr11
				bra     _L21
_L9:
				moves   X:<mr9,Y0
				moves   X:<mr9,X0
				mpyr    Y0,X0,B
				movec   B1,X0
				move    X0,X:<mr8
				tstw    X:<mr8
				ble     _L12
				moves   X:<mr8,X0
				inc     X0
				move    X0,X:<mr8
_L12:
				moves   X:<mr8,Y0
				moves   X:<mr8,X0
				mpyr    Y0,X0,B
				movec   B1,X0
				move    X0,X:<mr10
				tstw    X:<mr10
				ble     _L15
				moves   X:<mr10,X0
				inc     X0
				move    X0,X:<mr10
_L15:
				movei   #32767,Y0
				sub     X:<mr8,Y0
				jsr     FL_deposit_h
				jsr     Fmfr32Sqrt
				move    Y0,X:<mr8
				movei   #32767,Y0
				sub     X:<mr10,Y0
				jsr     FL_deposit_h
				jsr     Fmfr32Sqrt
				move    Y0,X:<mr10
				move    X:<mr8,B
				moves   X:<mr10,Y0
				movec   B,X0
				abs     B
				eor     Y0,X0
				bfclr   #1,SR
				rep     #16
				div     Y0,B
				bftsth  #8,SR
				bcc     _L19
				neg     B
_L19:
				movec   B0,X0
				move    X0,X:<mr9
				moves   X:<mr9,Y0
				jsr     Ftfr16AsinOverPI
				movei   #16384,X0
				sub     Y0,X0
				move    X0,X:<mr11
_L21:
				move    X:(SP),X0
				cmp     #1,X0
				bne     _L23
				move    X:<mr11,B
				neg     B
				move    B,X:<mr11
_L23:
				moves   X:<mr11,Y0
				lea     (SP)-
				pop     N
				move    N,X:<mr11
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Ftfr16Atan2OverPI
				ORG	P:
Ftfr16Atan2OverPI:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				move    X:<mr11,N
				push    N
				movei   #4,N
				lea     (SP)+N
				moves   Y0,X:<mr11
				moves   Y1,X:<mr10
				movei   #0,X:(SP-3)
				movei   #0,X:(SP-2)
				tstw    X:<mr11
				bne     _L8
				tstw    X:<mr10
				bne     _L8
				moves   #0,X:<mr8
				bra     _L19
_L8:
				move    X:<mr10,B
				abs     B
				move    B1,X:(SP-1)
				move    X:<mr11,B
				abs     B
				move    B1,X:(SP)
				move    X:(SP-1),Y0
				move    X:(SP),X0
				cmp     X0,Y0
				blt     _L15
				move    X:<mr11,B
				moves   X:<mr10,Y0
				movec   B,X0
				abs     B
				eor     Y0,X0
				bfclr   #1,SR
				rep     #16
				div     Y0,B
				bftsth  #8,SR
				bcc     _L13
				neg     B
_L13:
				movec   B0,X0
				move    X0,X:<mr8
				bra     _L19
_L15:
				move    X:<mr10,B
				moves   X:<mr11,Y0
				movec   B,X0
				abs     B
				eor     Y0,X0
				bfclr   #1,SR
				rep     #16
				div     Y0,B
				bftsth  #8,SR
				bcc     _L17
				neg     B
_L17:
				movec   B0,X0
				move    X0,X:<mr8
				movei   #1,X:(SP-3)
_L19:
				tstw    X:<mr8
				bge     _L22
				move    X:<mr8,B
				neg     B
				move    B,X:<mr8
				movei   #1,X:(SP-2)
_L22:
				moves   X:<mr8,Y0
				jsr     Ftfr16AtanOverPI
				move    Y0,X:<mr9
				move    X:(SP-3),X0
				cmp     #1,X0
				bne     _L25
				movei   #16384,X0
				sub     X:<mr9,X0
				move    X0,X:<mr9
_L25:
				move    X:(SP-2),X0
				cmp     #1,X0
				bne     _L27
				move    X:<mr9,B
				neg     B
				move    B,X:<mr9
_L27:
				moves   X:<mr9,Y0
				lea     (SP-4)
				pop     N
				move    N,X:<mr11
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Ftfr16SineWaveGenPAMCreate
				ORG	P:
Ftfr16SineWaveGenPAMCreate:
				movei   #3,N
				lea     (SP)+N
				move    Y0,X:(SP)
				move    Y1,X:(SP-1)
				movei   #4,Y0
				jsr     FmemMallocEM
				move    R2,X:(SP-2)
				move    X:(SP-6),X0
				push    X0
				move    X:(SP-6),X0
				push    X0
				move    X:(SP-4),R2
				move    X:(SP-2),Y0
				move    X:(SP-3),Y1
				jsr     Ftfr16SineWaveGenPAMInit
				lea     (SP-2)
				move    X:(SP-2),R2
				lea     (SP-3)
				rts     


				GLOBAL Ftfr16SineWaveGenPAMDestroy
				ORG	P:
Ftfr16SineWaveGenPAMDestroy:
				lea     (SP)+
				move    R2,X:(SP)
				tstw    X:(SP)
				beq     _L4
				move    X:(SP),R2
				jsr     FmemFreeEM
_L4:
				lea     (SP)-
				rts     


				GLOBAL Ftfr16SineWaveGenPAMInit
				ORG	P:
Ftfr16SineWaveGenPAMInit:
				moves   Y1,X:<mr2
				movec   R2,R3
				move    X:(SP-2),X0
				move    X0,X:(R3)
				lsl     Y0
				movec   Y0,B
				moves   X:<mr2,Y1
				movec   B,X0
				abs     B
				eor     Y1,X0
				bfclr   #1,SR
				rep     #16
				div     Y1,B
				bftsth  #8,SR
				bcc     _L6
				neg     B
_L6:
				movec   B0,X0
				move    X0,X:(R3+1)
				move    X:(SP-3),X0
				move    X0,X:(R3+3)
				rts     


				GLOBAL Ftfr16SineWaveGenPAMC
				ORG	P:
Ftfr16SineWaveGenPAMC:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				move    X:<mr11,N
				push    N
				movei   #2,N
				lea     (SP)+N
				move    R2,X:(SP)
				moves   R3,X:<mr10
				moves   Y0,X:<mr11
				move    X:(SP),R0
				move    R0,X:(SP-1)
				moves   #0,X:<mr9
				moves   X:<mr9,X0
				cmp     X:<mr11,X0
				bhs     _L15
_L5:
				move    X:(SP-1),R0
				move    X:(SP-1),R2
				nop     
				move    X:(R2+1),Y0
				move    X:(R0),X0
				add     X0,Y0
				move    Y0,X:<mr8
				movei   #32767,X0
				cmp     X:<mr8,X0
				bgt     _L10
				move    X:(SP-1),R0
				nop     
				move    X:(R0),X0
				sub     #32767,X0
				move    X0,X:<mr8
				move    X:(SP-1),R2
				nop     
				move    X:(R2+1),X0
				add     X:<mr8,X0
				move    X0,X:<mr8
				moves   X:<mr8,X0
				add     #-32768,X0
				move    X0,X:<mr8
_L10:
				move    X:(SP-1),R0
				nop     
				move    X:(R0),Y0
				jsr     Ftfr16SinPIx
				move    X:(SP-1),R2
				nop     
				move    X:(R2+3),X0
				mpy     Y0,X0,B
				movec   B1,X0
				moves   X:<mr10,R0
				nop     
				move    X0,X:(R0)
				inc     X:<mr10
				move    X:(SP-1),R0
				moves   X:<mr8,X0
				move    X0,X:(R0)
				inc     X:<mr9
				moves   X:<mr9,X0
				cmp     X:<mr11,X0
				blo     _L5
_L15:
				lea     (SP-2)
				pop     N
				move    N,X:<mr11
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Ftfr16SineWaveGenIDTLCreate
				ORG	P:
Ftfr16SineWaveGenIDTLCreate:
				movei   #4,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    Y0,X:(SP-1)
				move    Y1,X:(SP-2)
				movei   #5,Y0
				jsr     FmemMallocEM
				move    R2,X:(SP-3)
				move    X:(SP-7),X0
				push    X0
				move    X:(SP-7),X0
				push    X0
				move    X:(SP-5),R2
				move    X:(SP-2),R3
				move    X:(SP-3),Y0
				move    X:(SP-4),Y1
				jsr     Ftfr16SineWaveGenIDTLInit
				lea     (SP-2)
				move    X:(SP-3),R2
				lea     (SP-4)
				rts     


				GLOBAL Ftfr16SineWaveGenIDTLDestroy
				ORG	P:
Ftfr16SineWaveGenIDTLDestroy:
				lea     (SP)+
				move    R2,X:(SP)
				tstw    X:(SP)
				beq     _L4
				move    X:(SP),R2
				jsr     FmemFreeEM
_L4:
				lea     (SP)-
				rts     


				GLOBAL Ftfr16SineWaveGenIDTLInit
				ORG	P:
Ftfr16SineWaveGenIDTLInit:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				move    X:<mr11,N
				push    N
				movei   #4,N
				lea     (SP)+N
				move    R2,X:(SP)
				moves   R3,X:<mr11
				moves   Y0,X:<mr9
				move    Y1,X:(SP-1)
				move    X:(SP),R0
				move    R0,X:<mr8
				move    X:(SP-1),B
				move    X:(SP-10),Y0
				movec   B,X0
				abs     B
				eor     Y0,X0
				bfclr   #1,SR
				rep     #16
				div     Y0,B
				bftsth  #8,SR
				bcc     _L5
				neg     B
_L5:
				movec   B0,X0
				move    X0,X:(SP-3)
				moves   X:<mr11,R2
				moves   X:<mr9,Y0
				jsr     FmemIsAligned
				moves   X:<mr8,R0
				nop     
				move    Y0,X:(R0)
				moves   X:<mr9,X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+4)
				move    X:(SP-3),Y0
				moves   X:<mr9,X0
				mpy     Y0,X0,B
				movec   B1,X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+2)
				movei   #16384,Y0
				move    X:(SP-11),X0
				mpy     Y0,X0,B
				movec   B1,X0
				move    X0,X:<mr10
				tstw    X:(SP-11)
				bge     _L13
				move    X:(SP-11),X0
				add     #32767,X0
				move    X0,X:(SP-11)
				move    X:<mr10,B
				neg     B
				movec   B1,X0
				add     X:(SP-11),X0
				move    X0,X:<mr10
_L13:
				moves   X:<mr10,Y0
				moves   X:<mr9,X0
				mpy     Y0,X0,B
				movec   B1,X0
				move    X0,X:(SP-2)
				moves   X:<mr9,X0
				add     X:<mr11,X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+3)
				move    X:(SP-2),X0
				add     X:<mr11,X0
				moves   X:<mr8,R2
				nop     
				move    X0,X:(R2+1)
				lea     (SP-4)
				pop     N
				move    N,X:<mr11
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Ftfr16SineWaveGenIDTLC
				ORG	P:
Ftfr16SineWaveGenIDTLC:
				moves   R2,X:<mr3
				moves   X:<mr3,R2
				moves   #0,X:<mr2
				moves   X:<mr2,X0
				cmp     Y0,X0
				bhs     _L12
_L5:
				move    X:(R2+1),R0
				nop     
				move    X:(R0),X0
				move    X0,X:(R3)
				lea     (R3)+
				move    X:(R2+2),X0
				move    X:(R2+1),Y1
				add     Y1,X0
				move    X0,X:(R2+1)
				move    X:(R2+1),X0
				move    X:(R2+3),Y1
				cmp     Y1,X0
				blo     _L10
				move    X:(R2+4),Y1
				move    X:(R2+1),X0
				sub     Y1,X0
				move    X0,X:(R2+1)
_L10:
				inc     X:<mr2
				moves   X:<mr2,X0
				cmp     Y0,X0
				blo     _L5
_L12:
				rts     


				GLOBAL Ftfr16SineWaveGenRDTLCreate
				ORG	P:
Ftfr16SineWaveGenRDTLCreate:
				movei   #4,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    Y0,X:(SP-1)
				move    Y1,X:(SP-2)
				movei   #4,Y0
				jsr     FmemMallocEM
				move    R2,X:(SP-3)
				move    X:(SP-7),X0
				push    X0
				move    X:(SP-7),X0
				push    X0
				move    X:(SP-5),R2
				move    X:(SP-2),R3
				move    X:(SP-3),Y0
				move    X:(SP-4),Y1
				jsr     Ftfr16SineWaveGenRDTLInit
				lea     (SP-2)
				move    X:(SP-3),R2
				lea     (SP-4)
				rts     


				GLOBAL Ftfr16SineWaveGenRDTLDestroy
				ORG	P:
Ftfr16SineWaveGenRDTLDestroy:
				lea     (SP)+
				move    R2,X:(SP)
				tstw    X:(SP)
				beq     _L4
				move    X:(SP),R2
				jsr     FmemFreeEM
_L4:
				lea     (SP)-
				rts     


				GLOBAL Ftfr16SineWaveGenRDTLInit
				ORG	P:
Ftfr16SineWaveGenRDTLInit:
				moves   R2,X:<mr4
				moves   Y1,X:<mr3
				moves   X:<mr4,R2
				nop     
				move    R3,X:(R2+2)
				move    Y0,X:(R2+3)
				move    X:<mr3,B
				move    X:(SP-2),Y1
				movec   B,X0
				abs     B
				eor     Y1,X0
				bfclr   #1,SR
				rep     #16
				div     Y1,B
				bftsth  #8,SR
				bcc     _L7
				neg     B
_L7:
				movec   B0,X0
				move    X0,X:(R2+1)
				movei   #16384,Y1
				move    X:(SP-3),X0
				mpy     Y1,X0,B
				movec   B1,X0
				move    X0,X:<mr2
				tstw    X:(SP-3)
				bge     _L12
				move    X:(SP-3),X0
				add     #32767,X0
				move    X0,X:(SP-3)
				move    X:<mr2,B
				neg     B
				movec   B1,X0
				add     X:(SP-3),X0
				move    X0,X:<mr2
_L12:
				moves   X:<mr2,X0
				move    X0,X:(R2)
				rts     


				GLOBAL Ftfr16SineWaveGenRDTLC
				ORG	P:
Ftfr16SineWaveGenRDTLC:
				moves   R2,X:<mr4
				moves   X:<mr4,R2
				moves   #0,X:<mr2
				moves   X:<mr2,X0
				cmp     Y0,X0
				bhs     _L15
_L5:
				move    X:(R2),X0
				move    X:(R2+3),Y1
				mpy     X0,Y1,B
				movec   B1,X0
				move    X0,X:<mr3
				move    X:(R2+2),R0
				moves   X:<mr3,N
				move    X:(R0+N),X0
				move    X0,X:(R3)
				lea     (R3)+
				move    X:(R2+1),X0
				move    X:(R2),Y1
				add     Y1,X0
				cmp     #32767,X0
				blt     _L12
				move    X:(R2),Y1
				movei   #32767,X0
				sub     Y1,X0
				move    X0,X:(R2)
				move    X:(R2),Y1
				move    X:(R2+1),X0
				sub     Y1,X0
				move    X0,X:(R2)
				bra     _L13
_L12:
				move    X:(R2+1),X0
				move    X:(R2),Y1
				add     Y1,X0
				move    X0,X:(R2)
_L13:
				inc     X:<mr2
				moves   X:<mr2,X0
				cmp     Y0,X0
				blo     _L5
_L15:
				rts     


				GLOBAL Ftfr16SineWaveGenRDITLCreate
				ORG	P:
Ftfr16SineWaveGenRDITLCreate:
				movei   #4,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    Y0,X:(SP-1)
				move    Y1,X:(SP-2)
				movei   #5,Y0
				jsr     FmemMallocEM
				move    R2,X:(SP-3)
				move    X:(SP-7),X0
				push    X0
				move    X:(SP-7),X0
				push    X0
				move    X:(SP-5),R2
				move    X:(SP-2),R3
				move    X:(SP-3),Y0
				move    X:(SP-4),Y1
				jsr     Ftfr16SineWaveGenRDITLInit
				lea     (SP-2)
				move    X:(SP-3),R2
				lea     (SP-4)
				rts     


				GLOBAL Ftfr16SineWaveGenRDITLDestroy
				ORG	P:
Ftfr16SineWaveGenRDITLDestroy:
				lea     (SP)+
				move    R2,X:(SP)
				tstw    X:(SP)
				beq     _L4
				move    X:(SP),R2
				jsr     FmemFreeEM
_L4:
				lea     (SP)-
				rts     


				GLOBAL Ftfr16SineWaveGenRDITLInit
				ORG	P:
Ftfr16SineWaveGenRDITLInit:
				moves   R2,X:<mr3
				moves   Y1,X:<mr2
				moves   X:<mr3,R2
				nop     
				move    R3,X:(R2+2)
				move    Y0,X:(R2+3)
				move    X:<mr2,B
				move    X:(SP-2),X0
				movec   B,Y1
				abs     B
				eor     X0,Y1
				bfclr   #1,SR
				rep     #16
				div     X0,B
				bftsth  #8,SR
				bcc     _L7
				neg     B
_L7:
				movec   B0,X0
				move    X0,X:(R2+1)
				move    X:(SP-3),X0
				move    X0,X:(R2)
				movec   Y0,B
				movei   #16384,Y1
				movec   B,X0
				abs     B
				eor     Y1,X0
				bfclr   #1,SR
				rep     #16
				div     Y1,B
				bftsth  #8,SR
				bcc     _L11
				neg     B
_L11:
				movec   B0,X0
				asl     X0
				move    X0,X:(R2+4)
				move    X:(R2+4),X0
				lsr     X0
				lsr     X0
				move    X0,X:(R2+4)
				move    X:(R2+4),B
				tstw    B
				beq     _L21
				cmp     #-1,B
				bne     _L16
				movei   #15,B
				bra     _L21
_L16:
				tstw    B
				bgt     _L18
				not     B
				movei   #0,B2
_L18:
				movei   #0,R0
				movei   #14,R1
_L19:
				norm    R0,B
				tstw    (R1)-
				bne     _L19
				movec   R0,B
				neg     B
_L21:
				move    B,X:(R2+4)
				move    X:(R2+4),X0
				inc     X0
				move    X0,X:(R2+4)
				rts     


				GLOBAL Ftfr16SineWaveGenRDITLC
				ORG	P:
Ftfr16SineWaveGenRDITLC:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				movei   #6,N
				lea     (SP)+N
				moves   R2,X:<mr9
				moves   X:<mr9,R2
				move    Y0,X:<mr8
				moves   #0,X:<mr6
				moves   X:<mr6,X0
				cmp     X:<mr8,X0
				jhs     _L88
_L6:
				tstw    X:(R2)
				jlt     _L42
				move    X:(R2),X0
				cmp     #16384,X0
				bge     _L25
				move    X:(R2+4),X0
				cmp     #15,X0
				ble     _L10
				clr     B
				bra     _L21
_L10:
				move    X:(R2),B
				movec   X0,A
				tstw    A
				beq     _L21
				movei   #16,X0
				bge     _L16
				neg     A
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L13:
				tstw    (R0)-
				beq     _L21
				asl     B
				bra     _L13
_L16:
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L17:
				tstw    (R0)-
				beq     _L19
				asr     B
				bra     _L17
_L19:
				bftsth  #32768,B0
				bcc     _L21
				incw    B
_L21:
				movec   B1,X0
				move    X0,X:<mr2
				move    X:(R2),X0
				andc    #63,X0
				move    X0,X:<mr3
				moves   #1,X:<mr4
				jmp     _L76
_L25:
				move    X:(R2+4),X0
				cmp     #15,X0
				ble     _L27
				clr     B
				bra     _L38
_L27:
				move    X:(R2),B
				movec   B1,B0
				movec   B2,B1
				movei   #0,A
				movei   #-32768,A0
				sub     B,A
				movec   A0,Y1
				movec   Y1,B
				movec   X0,A
				tstw    A
				beq     _L38
				movei   #16,X0
				bge     _L33
				neg     A
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L30:
				tstw    (R0)-
				beq     _L38
				asl     B
				bra     _L30
_L33:
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L34:
				tstw    (R0)-
				beq     _L36
				asr     B
				bra     _L34
_L36:
				bftsth  #32768,B0
				bcc     _L38
				incw    B
_L38:
				movec   B1,X0
				move    X0,X:<mr2
				move    X:(R2),B
				movec   B1,B0
				movec   B2,B1
				movei   #0,A
				movei   #-32768,A0
				sub     B,A
				movei   #63,B0
				movec   Y0,X:(SP-5)
				movec   A0,Y0
				movec   B0,B1
				and     B1,Y0
				movec   Y0,B0
				movec   X:(SP-5),Y0
				movec   B0,X0
				move    X0,X:<mr3
				moves   #1,X:<mr4
				jmp     _L76
_L42:
				move    X:(R2),X0
				cmp     #-16384,X0
				bge     _L60
				move    X:(R2+4),X0
				cmp     #15,X0
				ble     _L45
				clr     B
				bra     _L56
_L45:
				move    X:(R2),B
				movec   B1,B0
				movec   B2,B1
				movei   #0,A
				movei   #-32768,A0
				add     B,A
				movec   A0,Y1
				movec   Y1,B
				movec   X0,A
				tstw    A
				beq     _L56
				movei   #16,X0
				bge     _L51
				neg     A
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L48:
				tstw    (R0)-
				beq     _L56
				asl     B
				bra     _L48
_L51:
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L52:
				tstw    (R0)-
				beq     _L54
				asr     B
				bra     _L52
_L54:
				bftsth  #32768,B0
				bcc     _L56
				incw    B
_L56:
				movec   B1,X0
				move    X0,X:<mr2
				move    X:(R2),B
				movec   B1,B0
				movec   B2,B1
				movei   #0,A
				movei   #-32768,A0
				add     B,A
				movei   #63,B0
				movec   Y0,X:(SP-5)
				movec   A0,Y0
				movec   B0,B1
				and     B1,Y0
				movec   Y0,B0
				movec   X:(SP-5),Y0
				movec   B0,X0
				move    X0,X:<mr3
				moves   #-1,X:<mr4
				bra     _L76
_L60:
				move    X:(R2+4),X0
				cmp     #15,X0
				ble     _L62
				clr     B
				bra     _L73
_L62:
				move    X:(R2),B
				abs     B
				movec   X0,A
				tstw    A
				beq     _L73
				movei   #16,X0
				bge     _L68
				neg     A
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L65:
				tstw    (R0)-
				beq     _L73
				asl     B
				bra     _L65
_L68:
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L69:
				tstw    (R0)-
				beq     _L71
				asr     B
				bra     _L69
_L71:
				bftsth  #32768,B0
				bcc     _L73
				incw    B
_L73:
				movec   B1,X0
				move    X0,X:<mr2
				move    X:(R2),B
				abs     B
				movec   B1,X0
				andc    #63,X0
				move    X0,X:<mr3
				moves   #-1,X:<mr4
_L76:
				move    X:(R2+2),R0
				moves   X:<mr2,N
				move    X:(R0+N),X0
				move    X0,X:<mr5
				moves   X:<mr2,X0
				move    X:(R2+2),Y1
				add     Y1,X0
				movec   X0,R0
				move    X:(R0+1),X0
				move    X0,X:<mr7
				moves   X:<mr7,X0
				sub     X:<mr5,X0
				moves   X:<mr3,Y1
				impy    Y1,X0,Y1
				move    X:(R2+4),X0
				asrr    Y1,X0,X0
				add     X:<mr5,X0
				moves   X:<mr4,Y1
				impy    Y1,X0,X0
				move    X0,X:(R3)
				lea     (R3)+
				move    X:(R2+1),X0
				move    X:(R2),Y1
				add     Y1,X0
				cmp     #32767,X0
				blt     _L85
				move    X:(R2),Y1
				movei   #32767,X0
				sub     Y1,X0
				move    X0,X:(R2)
				move    X:(R2),Y1
				move    X:(R2+1),X0
				sub     Y1,X0
				move    X0,X:(R2)
				move    X:(R2),X0
				add     #-32768,X0
				move    X0,X:(R2)
				bra     _L86
_L85:
				move    X:(R2+1),X0
				move    X:(R2),Y1
				add     Y1,X0
				move    X0,X:(R2)
_L86:
				inc     X:<mr6
				moves   X:<mr6,X0
				cmp     X:<mr8,X0
				jlo     _L6
_L88:
				lea     (SP-6)
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Ftfr16SineWaveGenRDITLQCreate
				ORG	P:
Ftfr16SineWaveGenRDITLQCreate:
				movei   #4,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    Y0,X:(SP-1)
				move    Y1,X:(SP-2)
				movei   #5,Y0
				jsr     FmemMallocEM
				move    R2,X:(SP-3)
				move    X:(SP-7),X0
				push    X0
				move    X:(SP-7),X0
				push    X0
				move    X:(SP-5),R2
				move    X:(SP-2),R3
				move    X:(SP-3),Y0
				move    X:(SP-4),Y1
				jsr     Ftfr16SineWaveGenRDITLQInit
				lea     (SP-2)
				move    X:(SP-3),R2
				lea     (SP-4)
				rts     


				GLOBAL Ftfr16SineWaveGenRDITLQDestroy
				ORG	P:
Ftfr16SineWaveGenRDITLQDestroy:
				lea     (SP)+
				move    R2,X:(SP)
				tstw    X:(SP)
				beq     _L4
				move    X:(SP),R2
				jsr     FmemFreeEM
_L4:
				lea     (SP)-
				rts     


				GLOBAL Ftfr16SineWaveGenRDITLQInit
				ORG	P:
Ftfr16SineWaveGenRDITLQInit:
				moves   R2,X:<mr3
				moves   Y1,X:<mr2
				moves   X:<mr3,R2
				nop     
				move    R3,X:(R2+2)
				move    Y0,X:(R2+3)
				move    X:<mr2,B
				move    X:(SP-2),X0
				movec   B,Y1
				abs     B
				eor     X0,Y1
				bfclr   #1,SR
				rep     #16
				div     X0,B
				bftsth  #8,SR
				bcc     _L7
				neg     B
_L7:
				movec   B0,X0
				asl     X0
				move    X0,X:(R2+1)
				move    X:(SP-3),X0
				move    X0,X:(R2)
				movec   Y0,B
				movei   #16384,Y1
				movec   B,X0
				abs     B
				eor     Y1,X0
				bfclr   #1,SR
				rep     #16
				div     Y1,B
				bftsth  #8,SR
				bcc     _L11
				neg     B
_L11:
				movec   B0,X0
				move    X0,X:(R2+4)
				move    X:(R2+4),B
				tstw    B
				beq     _L20
				cmp     #-1,B
				bne     _L15
				movei   #15,B
				bra     _L20
_L15:
				tstw    B
				bgt     _L17
				not     B
				movei   #0,B2
_L17:
				movei   #0,R0
				movei   #14,R1
_L18:
				norm    R0,B
				tstw    (R1)-
				bne     _L18
				movec   R0,B
				neg     B
_L20:
				move    B,X:(R2+4)
				move    X:(R2+4),X0
				inc     X0
				move    X0,X:(R2+4)
				rts     


				GLOBAL Ftfr16SineWaveGenRDITLQC
				ORG	P:
Ftfr16SineWaveGenRDITLQC:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				movei   #6,N
				lea     (SP)+N
				moves   R2,X:<mr9
				moves   X:<mr9,R2
				move    Y0,X:<mr8
				moves   #0,X:<mr6
				moves   X:<mr6,X0
				cmp     X:<mr8,X0
				jhs     _L81
_L6:
				tstw    X:(R2)
				jlt     _L34
				move    X:(R2),X0
				cmp     #16384,X0
				bge     _L21
				move    X:(R2),B
				move    X:(R2+4),A
				tstw    A
				beq     _L17
				movei   #16,X0
				bge     _L14
				neg     A
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L11:
				tstw    (R0)-
				beq     _L17
				asl     B
				bra     _L11
_L14:
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L15:
				tstw    (R0)-
				beq     _L17
				asr     B
				bra     _L15
_L17:
				movec   B1,X0
				move    X0,X:<mr2
				move    X:(R2),X0
				andc    #63,X0
				move    X0,X:<mr3
				moves   #1,X:<mr4
				jmp     _L60
_L21:
				move    X:(R2),B
				movec   B1,B0
				movec   B2,B1
				movei   #0,A
				movei   #-32768,A0
				sub     B,A
				movec   A0,X0
				movec   X0,B
				move    X:(R2+4),A
				tstw    A
				beq     _L30
				movei   #16,X0
				bge     _L27
				neg     A
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L24:
				tstw    (R0)-
				beq     _L30
				asl     B
				bra     _L24
_L27:
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L28:
				tstw    (R0)-
				beq     _L30
				asr     B
				bra     _L28
_L30:
				movec   B1,X0
				move    X0,X:<mr2
				move    X:(R2),B
				movec   B1,B0
				movec   B2,B1
				movei   #0,A
				movei   #-32768,A0
				sub     B,A
				movei   #63,B0
				movec   Y0,X:(SP-5)
				movec   A0,Y0
				movec   B0,B1
				and     B1,Y0
				movec   Y0,B0
				movec   X:(SP-5),Y0
				movec   B0,X0
				move    X0,X:<mr3
				moves   #1,X:<mr4
				jmp     _L60
_L34:
				move    X:(R2),X0
				cmp     #-16384,X0
				bge     _L48
				move    X:(R2),B
				movec   B1,B0
				movec   B2,B1
				movei   #0,A
				movei   #-32768,A0
				add     B,A
				movec   A0,X0
				movec   X0,B
				move    X:(R2+4),A
				tstw    A
				beq     _L44
				movei   #16,X0
				bge     _L41
				neg     A
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L38:
				tstw    (R0)-
				beq     _L44
				asl     B
				bra     _L38
_L41:
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L42:
				tstw    (R0)-
				beq     _L44
				asr     B
				bra     _L42
_L44:
				movec   B1,X0
				move    X0,X:<mr2
				move    X:(R2),B
				movec   B1,B0
				movec   B2,B1
				movei   #0,A
				movei   #-32768,A0
				add     B,A
				movei   #63,B0
				movec   Y0,X:(SP-5)
				movec   A0,Y0
				movec   B0,B1
				and     B1,Y0
				movec   Y0,B0
				movec   X:(SP-5),Y0
				movec   B0,X0
				move    X0,X:<mr3
				moves   #-1,X:<mr4
				bra     _L60
_L48:
				move    X:(R2),B
				move    X:(R2+4),A
				tstw    A
				beq     _L57
				movei   #16,X0
				bge     _L54
				neg     A
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L51:
				tstw    (R0)-
				beq     _L57
				asl     B
				bra     _L51
_L54:
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L55:
				tstw    (R0)-
				beq     _L57
				asr     B
				bra     _L55
_L57:
				movec   B1,X0
				movec   X0,B
				abs     B
				move    B1,X:<mr2
				move    X:(R2),B
				abs     B
				movec   B1,X0
				andc    #63,X0
				move    X0,X:<mr3
				moves   #-1,X:<mr4
_L60:
				move    X:(R2+2),R0
				moves   X:<mr2,N
				move    X:(R0+N),X0
				move    X0,X:<mr5
				moves   X:<mr2,X0
				move    X:(R2+2),Y1
				add     Y1,X0
				movec   X0,R0
				move    X:(R0+1),X0
				move    X0,X:<mr7
				moves   X:<mr7,X0
				sub     X:<mr5,X0
				moves   X:<mr3,Y1
				impy    Y1,X0,X0
				movec   X0,B
				move    X:(R2+4),A
				tstw    A
				beq     _L71
				movei   #16,X0
				bge     _L68
				neg     A
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L65:
				tstw    (R0)-
				beq     _L71
				asl     B
				bra     _L65
_L68:
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L69:
				tstw    (R0)-
				beq     _L71
				asr     B
				bra     _L69
_L71:
				movec   B1,X0
				add     X:<mr5,X0
				moves   X:<mr4,Y1
				impy    Y1,X0,X0
				move    X0,X:(R3)
				lea     (R3)+
				move    X:(R2+1),X0
				move    X:(R2),Y1
				add     Y1,X0
				cmp     #32767,X0
				blt     _L78
				move    X:(R2),Y1
				movei   #32767,X0
				sub     Y1,X0
				move    X0,X:(R2)
				move    X:(R2),Y1
				move    X:(R2+1),X0
				sub     Y1,X0
				move    X0,X:(R2)
				move    X:(R2),X0
				add     #-32768,X0
				move    X0,X:(R2)
				bra     _L79
_L78:
				move    X:(R2+1),X0
				move    X:(R2),Y1
				add     Y1,X0
				move    X0,X:(R2)
_L79:
				inc     X:<mr6
				moves   X:<mr6,X0
				cmp     X:<mr8,X0
				jlo     _L6
_L81:
				lea     (SP-6)
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Ftfr16SineWaveGenDOMCreate
				ORG	P:
Ftfr16SineWaveGenDOMCreate:
				movei   #3,N
				lea     (SP)+N
				move    Y0,X:(SP)
				move    Y1,X:(SP-1)
				movei   #3,Y0
				jsr     FmemMallocEM
				move    R2,X:(SP-2)
				move    X:(SP-6),X0
				push    X0
				move    X:(SP-6),X0
				push    X0
				move    X:(SP-4),R2
				move    X:(SP-2),Y0
				move    X:(SP-3),Y1
				jsr     Ftfr16SineWaveGenDOMInit
				lea     (SP-2)
				move    X:(SP-2),R2
				lea     (SP-3)
				rts     


				GLOBAL Ftfr16SineWaveGenDOMDestroy
				ORG	P:
Ftfr16SineWaveGenDOMDestroy:
				lea     (SP)+
				move    R2,X:(SP)
				tstw    X:(SP)
				beq     _L4
				move    X:(SP),R2
				jsr     FmemFreeEM
_L4:
				lea     (SP)-
				rts     


				GLOBAL Ftfr16SineWaveGenDOMInit
				ORG	P:
Ftfr16SineWaveGenDOMInit:
				move    X:<mr8,N
				push    N
				move    X:<mr9,N
				push    N
				move    X:<mr10,N
				push    N
				move    X:<mr11,N
				push    N
				movei   #3,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    Y0,X:(SP-1)
				move    Y1,X:(SP-2)
				move    X:(SP),R0
				move    R0,X:<mr11
				move    X:(SP-1),X0
				lsl     X0
				movec   X0,B
				move    X:(SP-2),Y0
				movec   B,X0
				abs     B
				eor     Y0,X0
				bfclr   #1,SR
				rep     #16
				div     Y0,B
				bftsth  #8,SR
				bcc     _L5
				neg     B
_L5:
				movec   B0,X0
				move    X0,X:<mr8
				move    X:(SP-9),X0
				sub     X:<mr8,X0
				move    X0,X:<mr9
				movei   #-32768,X0
				cmp     X:<mr9,X0
				blt     _L11
				movei   #-32768,X0
				sub     X:(SP-9),X0
				move    X0,X:<mr9
				moves   X:<mr9,X0
				add     X:<mr8,X0
				move    X0,X:<mr9
				move    X:<mr8,B
				neg     B
				movec   B1,X0
				move    X0,X:<mr8
_L11:
				moves   X:<mr9,X0
				sub     X:<mr8,X0
				move    X0,X:<mr10
				movei   #-32768,X0
				cmp     X:<mr10,X0
				blt     _L15
				movei   #-32768,X0
				sub     X:<mr9,X0
				move    X0,X:<mr10
				moves   X:<mr10,X0
				add     X:<mr8,X0
				move    X0,X:<mr10
_L15:
				moves   X:<mr9,Y0
				jsr     Ftfr16SinPIx
				move    X:(SP-10),X0
				mpy     Y0,X0,B
				movec   B1,X0
				moves   X:<mr11,R0
				nop     
				move    X0,X:(R0)
				moves   X:<mr10,Y0
				jsr     Ftfr16SinPIx
				move    X:(SP-10),X0
				mpy     Y0,X0,B
				movec   B1,X0
				moves   X:<mr11,R2
				nop     
				move    X0,X:(R2+1)
				moves   X:<mr8,Y0
				jsr     Ftfr16CosPIx
				moves   X:<mr11,R2
				nop     
				move    Y0,X:(R2+2)
				lea     (SP-3)
				pop     N
				move    N,X:<mr11
				pop     N
				move    N,X:<mr10
				pop     N
				move    N,X:<mr9
				pop     N
				move    N,X:<mr8
				rts     


				GLOBAL Ftfr16SineWaveGenDOMC
				ORG	P:
Ftfr16SineWaveGenDOMC:
				moves   R2,X:<mr3
				moves   X:<mr3,R2
				moves   #0,X:<mr2
				moves   X:<mr2,X0
				cmp     Y0,X0
				bhs     _L14
_L5:
				move    X:(R2),X0
				move    X:(R2+2),Y1
				mpy     X0,Y1,B
				movec   B1,X0
				move    X0,X:(R3)
				move    X:(R2+1),X0
				movei   #16384,Y1
				mpy     X0,Y1,B
				movec   B1,X0
				move    X0,X:(R2+1)
				move    X:(R2+1),Y1
				move    X:(R3),X0
				sub     Y1,X0
				move    X0,X:(R3)
				move    X:(R3),X0
				move    X:(R3),Y1
				add     Y1,X0
				move    X0,X:(R3)
				move    X:(R2),X0
				move    X0,X:(R2+1)
				move    X:(R3),X0
				move    X0,X:(R2)
				lea     (R3)+
				inc     X:<mr2
				moves   X:<mr2,X0
				cmp     Y0,X0
				blo     _L5
_L14:
				rts     


				GLOBAL Ftfr16WaveGenRDITLQCreate
				ORG	P:
Ftfr16WaveGenRDITLQCreate:
				movei   #4,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    Y0,X:(SP-1)
				move    Y1,X:(SP-2)
				movei   #4,Y0
				jsr     FmemMallocEM
				move    R2,X:(SP-3)
				move    X:(SP-3),R2
				move    X:(SP),R3
				move    X:(SP-1),Y0
				move    X:(SP-2),Y1
				jsr     Ftfr16WaveGenRDITLQInit
				move    X:(SP-3),R2
				lea     (SP-4)
				rts     


				GLOBAL Ftfr16WaveGenRDITLQDestroy
				ORG	P:
Ftfr16WaveGenRDITLQDestroy:
				lea     (SP)+
				move    R2,X:(SP)
				tstw    X:(SP)
				beq     _L4
				move    X:(SP),R2
				jsr     FmemFreeEM
_L4:
				lea     (SP)-
				rts     


				GLOBAL Ftfr16WaveGenRDITLQInit
				ORG	P:
Ftfr16WaveGenRDITLQInit:
				moves   R2,X:<mr3
				moves   Y1,X:<mr2
				moves   X:<mr3,R2
				nop     
				move    R3,X:(R2+1)
				move    Y0,X:(R2+2)
				moves   X:<mr2,X0
				move    X0,X:(R2)
				movec   Y0,B
				movei   #16384,Y1
				movec   B,X0
				abs     B
				eor     Y1,X0
				bfclr   #1,SR
				rep     #16
				div     Y1,B
				bftsth  #8,SR
				bcc     _L8
				neg     B
_L8:
				movec   B0,X0
				move    X0,X:(R2+3)
				move    X:(R2+3),B
				tstw    B
				beq     _L17
				cmp     #-1,B
				bne     _L12
				movei   #15,B
				bra     _L17
_L12:
				tstw    B
				bgt     _L14
				not     B
				movei   #0,B2
_L14:
				movei   #0,R0
				movei   #14,R1
_L15:
				norm    R0,B
				tstw    (R1)-
				bne     _L15
				movec   R0,B
				neg     B
_L17:
				move    B,X:(R2+3)
				move    X:(R2+3),X0
				inc     X0
				move    X0,X:(R2+3)
				rts     


				GLOBAL Ftfr16WaveGenRDITLQC
				ORG	P:
Ftfr16WaveGenRDITLQC:
				movei   #6,N
				lea     (SP)+N
				movec   R2,R3
				move    Y0,X:<mr5
				tstw    X:(R3)
				jlt     _L31
				move    X:(R3),X0
				cmp     #16384,X0
				bge     _L18
				move    X:(R3),B
				move    X:(R3+3),A
				tstw    A
				beq     _L14
				movei   #16,X0
				bge     _L11
				neg     A
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L8:
				tstw    (R0)-
				beq     _L14
				asl     B
				bra     _L8
_L11:
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L12:
				tstw    (R0)-
				beq     _L14
				asr     B
				bra     _L12
_L14:
				movec   B1,X0
				move    X0,X:<mr2
				move    X:(R3),X0
				andc    #63,X0
				move    X0,X:<mr3
				moves   #1,X:<mr4
				jmp     _L57
_L18:
				move    X:(R3),B
				movec   B1,B0
				movec   B2,B1
				movei   #0,A
				movei   #-32768,A0
				sub     B,A
				movec   A0,X0
				movec   X0,B
				move    X:(R3+3),A
				tstw    A
				beq     _L27
				movei   #16,X0
				bge     _L24
				neg     A
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L21:
				tstw    (R0)-
				beq     _L27
				asl     B
				bra     _L21
_L24:
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L25:
				tstw    (R0)-
				beq     _L27
				asr     B
				bra     _L25
_L27:
				movec   B1,X0
				move    X0,X:<mr2
				move    X:(R3),B
				movec   B1,B0
				movec   B2,B1
				movei   #0,A
				movei   #-32768,A0
				sub     B,A
				movei   #63,B0
				movec   Y0,X:(SP-5)
				movec   A0,Y0
				movec   B0,B1
				and     B1,Y0
				movec   Y0,B0
				movec   B0,X0
				move    X0,X:<mr3
				moves   #1,X:<mr4
				jmp     _L57
_L31:
				move    X:(R3),X0
				cmp     #-16384,X0
				bge     _L45
				move    X:(R3),B
				movec   B1,B0
				movec   B2,B1
				movei   #0,A
				movei   #-32768,A0
				add     B,A
				movec   A0,X0
				movec   X0,B
				move    X:(R3+3),A
				tstw    A
				beq     _L41
				movei   #16,X0
				bge     _L38
				neg     A
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L35:
				tstw    (R0)-
				beq     _L41
				asl     B
				bra     _L35
_L38:
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L39:
				tstw    (R0)-
				beq     _L41
				asr     B
				bra     _L39
_L41:
				movec   B1,X0
				move    X0,X:<mr2
				move    X:(R3),B
				movec   B1,B0
				movec   B2,B1
				movei   #0,A
				movei   #-32768,A0
				add     B,A
				movei   #63,B0
				movec   Y0,X:(SP-5)
				movec   A0,Y0
				movec   B0,B1
				and     B1,Y0
				movec   Y0,B0
				movec   B0,X0
				move    X0,X:<mr3
				moves   #-1,X:<mr4
				bra     _L57
_L45:
				move    X:(R3),B
				move    X:(R3+3),A
				tstw    A
				beq     _L54
				movei   #16,X0
				bge     _L51
				neg     A
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L48:
				tstw    (R0)-
				beq     _L54
				asl     B
				bra     _L48
_L51:
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L52:
				tstw    (R0)-
				beq     _L54
				asr     B
				bra     _L52
_L54:
				movec   B1,X0
				movec   X0,B
				abs     B
				move    B1,X:<mr2
				move    X:(R3),B
				abs     B
				movec   B1,X0
				andc    #63,X0
				move    X0,X:<mr3
				moves   #-1,X:<mr4
_L57:
				move    X:(R3+1),R0
				moves   X:<mr2,N
				move    X:(R0+N),X0
				move    X0,X:<mr6
				move    X:(R3+1),X0
				movec   X0,R0
				nop     
				lea     (R0)+
				moves   X:<mr2,N
				move    X:(R0+N),X0
				move    X0,X:<mr7
				moves   X:<mr7,Y1
				sub     X:<mr6,Y1
				moves   X:<mr3,X0
				impy    Y1,X0,X0
				movec   X0,B
				move    X:(R3+3),A
				tstw    A
				beq     _L68
				movei   #16,X0
				bge     _L65
				neg     A
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L62:
				tstw    (R0)-
				beq     _L68
				asl     B
				bra     _L62
_L65:
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L66:
				tstw    (R0)-
				beq     _L68
				asr     B
				bra     _L66
_L68:
				movec   B1,Y1
				add     X:<mr6,Y1
				moves   X:<mr4,X0
				impy    Y1,X0,X0
				move    X0,X:<mr2
				moves   X:<mr5,Y1
				move    X:(R3),X0
				add     X0,Y1
				cmp     #32767,Y1
				blt     _L74
				move    X:(R3),Y1
				movei   #32767,X0
				sub     Y1,X0
				move    X0,X:(R3)
				move    X:(R3),Y1
				moves   X:<mr5,X0
				sub     Y1,X0
				move    X0,X:(R3)
				move    X:(R3),X0
				add     #-32768,X0
				move    X0,X:(R3)
				bra     _L75
_L74:
				moves   X:<mr5,Y1
				move    X:(R3),X0
				add     X0,Y1
				move    Y1,X:(R3)
_L75:
				moves   X:<mr2,Y0
				lea     (SP-6)
				rts     


				GLOBAL Ftfr16SinPIxLUTCreate
				ORG	P:
Ftfr16SinPIxLUTCreate:
				movei   #3,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    Y0,X:(SP-1)
				movei   #3,Y0
				jsr     FmemMallocEM
				move    R2,X:(SP-2)
				move    X:(SP-2),R2
				move    X:(SP),R3
				move    X:(SP-1),Y0
				jsr     Ftfr16SinPIxLUTInit
				move    X:(SP-2),R2
				lea     (SP-3)
				rts     


				GLOBAL Ftfr16SinPIxLUTDestroy
				ORG	P:
Ftfr16SinPIxLUTDestroy:
				lea     (SP)+
				move    R2,X:(SP)
				tstw    X:(SP)
				beq     _L4
				move    X:(SP),R2
				jsr     FmemFreeEM
_L4:
				lea     (SP)-
				rts     


				GLOBAL Ftfr16SinPIxLUTInit
				ORG	P:
Ftfr16SinPIxLUTInit:
				moves   R2,X:<mr2
				moves   X:<mr2,R2
				nop     
				move    R3,X:(R2)
				move    Y0,X:(R2+1)
				movec   Y0,B
				movei   #16384,Y1
				movec   B,X0
				abs     B
				eor     Y1,X0
				bfclr   #1,SR
				rep     #16
				div     Y1,B
				bftsth  #8,SR
				bcc     _L7
				neg     B
_L7:
				movec   B0,X0
				move    X0,X:(R2+2)
				move    X:(R2+2),B
				tstw    B
				beq     _L16
				cmp     #-1,B
				bne     _L11
				movei   #15,B
				bra     _L16
_L11:
				tstw    B
				bgt     _L13
				not     B
				movei   #0,B2
_L13:
				movei   #0,R0
				movei   #14,R1
_L14:
				norm    R0,B
				tstw    (R1)-
				bne     _L14
				movec   R0,B
				neg     B
_L16:
				move    B,X:(R2+2)
				move    X:(R2+2),X0
				inc     X0
				move    X0,X:(R2+2)
				rts     


				GLOBAL Ftfr16SinPIxLUTC
				ORG	P:
Ftfr16SinPIxLUTC:
				movei   #6,N
				lea     (SP)+N
				movec   R2,R3
				tstw    Y0
				jlt     _L30
				cmp     #16384,Y0
				bge     _L17
				movec   Y0,B
				move    X:(R3+2),A
				tstw    A
				beq     _L13
				movei   #16,X0
				bge     _L10
				neg     A
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L7:
				tstw    (R0)-
				beq     _L13
				asl     B
				bra     _L7
_L10:
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L11:
				tstw    (R0)-
				beq     _L13
				asr     B
				bra     _L11
_L13:
				movec   B1,X0
				move    X0,X:<mr2
				andc    #63,Y0
				move    Y0,X:<mr3
				moves   #1,X:<mr4
				jmp     _L56
_L17:
				movec   Y0,B
				movec   B1,B0
				movec   B2,B1
				movei   #0,A
				movei   #-32768,A0
				sub     B,A
				movec   A0,X0
				movec   X0,B
				move    X:(R3+2),A
				tstw    A
				beq     _L26
				movei   #16,X0
				bge     _L23
				neg     A
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L20:
				tstw    (R0)-
				beq     _L26
				asl     B
				bra     _L20
_L23:
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L24:
				tstw    (R0)-
				beq     _L26
				asr     B
				bra     _L24
_L26:
				movec   B1,X0
				move    X0,X:<mr2
				movec   Y0,B
				movec   B1,B0
				movec   B2,B1
				movei   #0,A
				movei   #-32768,A0
				sub     B,A
				movei   #63,B0
				movec   Y0,X:(SP-5)
				movec   A0,Y0
				movec   B0,B1
				and     B1,Y0
				movec   Y0,B0
				movec   B0,X0
				move    X0,X:<mr3
				moves   #1,X:<mr4
				jmp     _L56
_L30:
				cmp     #-16384,Y0
				bge     _L44
				movec   Y0,B
				movec   B1,B0
				movec   B2,B1
				movei   #0,A
				movei   #-32768,A0
				add     B,A
				movec   A0,X0
				movec   X0,B
				move    X:(R3+2),A
				tstw    A
				beq     _L40
				movei   #16,X0
				bge     _L37
				neg     A
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L34:
				tstw    (R0)-
				beq     _L40
				asl     B
				bra     _L34
_L37:
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L38:
				tstw    (R0)-
				beq     _L40
				asr     B
				bra     _L38
_L40:
				movec   B1,X0
				move    X0,X:<mr2
				movec   Y0,B
				movec   B1,B0
				movec   B2,B1
				movei   #0,A
				movei   #-32768,A0
				add     B,A
				movei   #63,B0
				movec   Y0,X:(SP-5)
				movec   A0,Y0
				movec   B0,B1
				and     B1,Y0
				movec   Y0,B0
				movec   B0,X0
				move    X0,X:<mr3
				moves   #-1,X:<mr4
				bra     _L56
_L44:
				movec   Y0,B
				move    X:(R3+2),A
				tstw    A
				beq     _L53
				movei   #16,X0
				bge     _L50
				neg     A
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L47:
				tstw    (R0)-
				beq     _L53
				asl     B
				bra     _L47
_L50:
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L51:
				tstw    (R0)-
				beq     _L53
				asr     B
				bra     _L51
_L53:
				movec   B1,X0
				movec   X0,B
				abs     B
				move    B1,X:<mr2
				movec   Y0,B
				abs     B
				movec   B1,X0
				andc    #63,X0
				move    X0,X:<mr3
				moves   #-1,X:<mr4
_L56:
				move    X:(R3),R0
				moves   X:<mr2,N
				move    X:(R0+N),X0
				move    X0,X:<mr5
				move    X:(R3),X0
				movec   X0,R0
				nop     
				lea     (R0)+
				moves   X:<mr2,N
				move    X:(R0+N),X0
				move    X0,X:<mr6
				moves   X:<mr6,Y1
				sub     X:<mr5,Y1
				moves   X:<mr3,X0
				impy    Y1,X0,X0
				movec   X0,B
				move    X:(R3+2),A
				tstw    A
				beq     _L67
				movei   #16,X0
				bge     _L64
				neg     A
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L61:
				tstw    (R0)-
				beq     _L67
				asl     B
				bra     _L61
_L64:
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L65:
				tstw    (R0)-
				beq     _L67
				asr     B
				bra     _L65
_L67:
				movec   B1,Y1
				add     X:<mr5,Y1
				moves   X:<mr4,X0
				impy    Y1,X0,X0
				move    X0,X:<mr2
				moves   X:<mr2,Y0
				lea     (SP-6)
				rts     


				GLOBAL Ftfr16CosPIxLUTCreate
				ORG	P:
Ftfr16CosPIxLUTCreate:
				movei   #3,N
				lea     (SP)+N
				move    R2,X:(SP)
				move    Y0,X:(SP-1)
				movei   #3,Y0
				jsr     FmemMallocEM
				move    R2,X:(SP-2)
				move    X:(SP-2),R2
				move    X:(SP),R3
				move    X:(SP-1),Y0
				jsr     Ftfr16CosPIxLUTInit
				move    X:(SP-2),R2
				lea     (SP-3)
				rts     


				GLOBAL Ftfr16CosPIxLUTDestroy
				ORG	P:
Ftfr16CosPIxLUTDestroy:
				lea     (SP)+
				move    R2,X:(SP)
				tstw    X:(SP)
				beq     _L4
				move    X:(SP),R2
				jsr     FmemFreeEM
_L4:
				lea     (SP)-
				rts     


				GLOBAL Ftfr16CosPIxLUTInit
				ORG	P:
Ftfr16CosPIxLUTInit:
				moves   R2,X:<mr2
				moves   X:<mr2,R2
				nop     
				move    R3,X:(R2)
				move    Y0,X:(R2+1)
				movec   Y0,B
				movei   #16384,Y1
				movec   B,X0
				abs     B
				eor     Y1,X0
				bfclr   #1,SR
				rep     #16
				div     Y1,B
				bftsth  #8,SR
				bcc     _L7
				neg     B
_L7:
				movec   B0,X0
				move    X0,X:(R2+2)
				move    X:(R2+2),B
				tstw    B
				beq     _L16
				cmp     #-1,B
				bne     _L11
				movei   #15,B
				bra     _L16
_L11:
				tstw    B
				bgt     _L13
				not     B
				movei   #0,B2
_L13:
				movei   #0,R0
				movei   #14,R1
_L14:
				norm    R0,B
				tstw    (R1)-
				bne     _L14
				movec   R0,B
				neg     B
_L16:
				move    B,X:(R2+2)
				move    X:(R2+2),X0
				inc     X0
				move    X0,X:(R2+2)
				rts     


				GLOBAL Ftfr16CosPIxLUTC
				ORG	P:
Ftfr16CosPIxLUTC:
				movec   R2,R3
				tstw    Y0
				bge     _L4
				movec   Y0,B
				neg     B
				movec   B1,Y0
_L4:
				add     #-16384,Y0
				tstw    Y0
				blt     _L19
				movec   Y0,B
				move    X:(R3+2),A
				tstw    A
				beq     _L15
				movei   #16,X0
				bge     _L12
				neg     A
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L9:
				tstw    (R0)-
				beq     _L15
				asl     B
				bra     _L9
_L12:
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L13:
				tstw    (R0)-
				beq     _L15
				asr     B
				bra     _L13
_L15:
				movec   B1,X0
				move    X0,X:<mr2
				andc    #63,Y0
				move    Y0,X:<mr4
				moves   #-1,X:<mr5
				bra     _L31
_L19:
				movec   Y0,B
				move    X:(R3+2),A
				tstw    A
				beq     _L28
				movei   #16,X0
				bge     _L25
				neg     A
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L22:
				tstw    (R0)-
				beq     _L28
				asl     B
				bra     _L22
_L25:
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L26:
				tstw    (R0)-
				beq     _L28
				asr     B
				bra     _L26
_L28:
				movec   B1,X0
				movec   X0,B
				abs     B
				move    B1,X:<mr2
				movec   Y0,B
				abs     B
				movec   B1,X0
				andc    #63,X0
				move    X0,X:<mr4
				moves   #1,X:<mr5
_L31:
				move    X:(R3),R0
				moves   X:<mr2,N
				move    X:(R0+N),X0
				move    X0,X:<mr3
				move    X:(R3),X0
				movec   X0,R0
				nop     
				lea     (R0)+
				moves   X:<mr2,N
				move    X:(R0+N),X0
				move    X0,X:<mr6
				moves   X:<mr6,Y1
				sub     X:<mr3,Y1
				moves   X:<mr4,X0
				impy    Y1,X0,X0
				movec   X0,B
				move    X:(R3+2),A
				tstw    A
				beq     _L42
				movei   #16,X0
				bge     _L39
				neg     A
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L36:
				tstw    (R0)-
				beq     _L42
				asl     B
				bra     _L36
_L39:
				cmp     A1,X0
				tlt     X0,A
				movec   A1,R0
				nop     
_L40:
				tstw    (R0)-
				beq     _L42
				asr     B
				bra     _L40
_L42:
				movec   B1,Y1
				add     X:<mr3,Y1
				moves   X:<mr5,X0
				impy    Y1,X0,X0
				move    X0,X:<mr2
				moves   X:<mr2,Y0
				rts     


				ORG	X:
FSineCoefs      DC			12867,-21166,10445,-2440,336,-30,1
FAsineCoefs     DC			10430,1738,782,465,316,233,180,145
FInv_Threshold  DC			23170

				ENDSEC
				END
