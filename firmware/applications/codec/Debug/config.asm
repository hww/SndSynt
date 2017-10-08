
				SECTION config
				include "asmdef.h"
				GLOBAL FconfigUnhandledInterruptISR
				ORG	P:
FconfigUnhandledInterruptISR:
				debug   
				bra     _L1


				GLOBAL FconfigInitialize
				ORG	P:
FconfigInitialize:
				movei   #24,N
				lea     (SP)+N
				movei   #0,X:FArchIO
				movei   #21845,X:FArchIO+290
				movei   #43690,X:FArchIO+290
				movei   #4095,X:FArchIO+289
				movei   #0,X:FArchIO+288
				movei   #0,X:FArchCore+121
				movei   #65087,X:FArchCore+123
				movei   #0,X0
				push    X0
				movei   #0,X0
				push    X0
				movei   #130,Y0
				movei   #291,Y1
				jsr     FplldrvInitialize
				lea     (SP-2)
				movei   #0,X:FArchIO+256
				movei   #0,X:FArchIO+257
				movei   #0,X:FArchIO+258
				movei   #0,X:FArchIO+259
				movei   #4352,X:FArchIO+260
				movei   #4369,X:FArchIO+261
				movei   #0,X:FArchIO+262
				movei   #0,X:FArchIO+263
				movei   #0,X:FArchIO+264
				movei   #0,X:FArchIO+265
				movei   #0,X:FArchIO+266
				movei   #0,X:FArchIO+267
				movei   #0,X:FArchIO+268
				movei   #0,X:FArchIO+269
				movei   #4640,X:FArchIO+270
				movei   #1,X:FArchIO+271
				bfset   #256,SR
				bfclr   #512,SR
				move    X:FmemEXbit,X0
				move    X0,X:(SP-23)
				move    X:FmemNumEMpartitions,X0
				move    X0,X:(SP-22)
				move    X:FmemNumIMpartitions,X0
				move    X0,X:(SP-21)
				movei   #FmemEMpartitionList,R0
				move    R0,X:(SP-19)
				movei   #FmemIMpartitionList,R0
				move    R0,X:(SP-20)
				movec   SP,R2
				lea     (R2-23)
				jsr     FmemInitialize
				movei   #5,X:(SP-18)
				movei   #12,X:(SP-17)
				movei   #FIODeviceTable$8,R0
				move    R0,X:(SP-16)
				movec   SP,R2
				lea     (R2-18)
				jsr     FioInitialize
				movei   #33792,X:(SP-13)
				movei   #24364,X:(SP-12)
				movei   #24840,X:(SP-11)
				movei   #24840,X:(SP-10)
				movei   #36,X:(SP-8)
				movei   #48,X:(SP-6)
				movec   SP,R2
				lea     (R2-15)
				jsr     Ffsimple_ssiInitialize
				movei   #FgpiodrvIOOpen,R2
				jsr     FioDrvInstall
				jsr     FUserPreMain
				lea     (SP-24)
				rts     


				GLOBAL FconfigFinalize
				ORG	P:
FconfigFinalize:
				jsr     FUserPostMain
				rts     


				ORG	X:
FarchISRType    DC			0,0,0,0
FIODeviceTable$8BSC			12

				ENDSEC
				END
