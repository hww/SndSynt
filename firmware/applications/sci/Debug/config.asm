
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
				movei   #3,N
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
				movei   #0,X:FArchIO+260
				movei   #0,X:FArchIO+261
				movei   #0,X:FArchIO+262
				movei   #0,X:FArchIO+263
				movei   #0,X:FArchIO+264
				movei   #0,X:FArchIO+265
				movei   #0,X:FArchIO+266
				movei   #4352,X:FArchIO+267
				movei   #4369,X:FArchIO+268
				movei   #17,X:FArchIO+269
				movei   #0,X:FArchIO+270
				movei   #0,X:FArchIO+271
				bfset   #256,SR
				bfclr   #512,SR
				movei   #5,X:(SP-2)
				movei   #12,X0
				move    X0,X:(SP-1)
				movei   #FIODeviceTable$7,R0
				move    R0,X:(SP)
				movec   SP,R2
				lea     (R2-2)
				jsr     FioInitialize
				movei   #FSciInitialize$13,R2
				jsr     FsciDevCreate
				jsr     FUserPreMain
				lea     (SP-3)
				rts     


				GLOBAL FconfigFinalize
				ORG	P:
FconfigFinalize:
				jsr     FUserPostMain
				rts     


				ORG	X:
FarchISRType    DC			0,0,0,0
FSciBaudRate$8  DC			10,20,30,40,60,80,120,160
				DC			240,320,480,960,1920,3840,74,20
FSciInitialize$13DC			FSciBaudRate$8,FSciInitialize$13,FSci1ReceiveBuffer$12,FSci1SendBuffer$11,FSci0ReceiveBuffer$10,FSci0SendBuffer$9,FconfigInitialize,FArchIO
				DC			FArchCore
FSci1ReceiveBuffer$12BSC			9
FSci1SendBuffer$11BSC			9
FSci0ReceiveBuffer$10BSC			9
FSci0SendBuffer$9BSC			9
FIODeviceTable$7BSC			12

				ENDSEC
				END
