
				SECTION kbdled
				include "asmdef.h"
				GLOBAL Fkbd_rfsh
				ORG	P:
Fkbd_rfsh:
				andc    #3,X:Fkbd_pos
				move    X:Fkbd_pos,R0
				nop     
				move    X:(R0+#Fkbd_matrix),X0
				move    X:Fkbd_pos,R0
				nop     
				move    X0,X:(R0+#Fled_matrix)
				move    X:Fkbd_pos,Y0
				movei   #4,X0
				lsll    Y0,X0,X0
				orc     #128,X0
				move    X0,X:FArchIO+433
				movei   #240,X:FArchIO+434
				move    X:FArchIO+433,X0
				andc    #15,X0
				move    X:Fkbd_pos,R0
				nop     
				move    X0,X:(R0+#Fkbd_matrix)
				movei   #255,X:FArchIO+434
				move    X:Fkbd_pos,Y0
				movei   #4,X0
				lsll    Y0,X0,Y0
				orc     #64,Y0
				move    X:Fkbd_pos,R0
				nop     
				move    X:(R0+#Fled_matrix),X0
				andc    #15,X0
				or      Y0,X0
				move    X0,X:FArchIO+433
				inc     X:Fkbd_pos
				rts     


				GLOBAL Fkbdled_init
				ORG	P:
Fkbdled_init:
				movei   #13,N
				lea     (SP)+N
				movei   #0,X:FArchIO+435
				movei   #192,X:FArchIO+433
				movei   #255,X:FArchIO+434
				movei   #0,X:Fkbd_pos
				movei   #Fkbd_rfsh,R0
				move    R0,X:(SP-9)
				movec   SP,R2
				lea     (R2-12)
				movec   SP,R3
				lea     (R3-8)
				movei   #1,Y0
				jsr     Ftimer_create
				movei   #0,X:(SP-7)
				movei   #0,X:(SP-6)
				movei   #33920,X:(SP-5)
				movei   #30,X:(SP-4)
				movei   #0,X:(SP-3)
				movei   #0,X:(SP-2)
				movei   #30,B
				movei   #-31616,B0
				move    B1,X:(SP)
				move    B0,X:(SP-1)
				movec   SP,R2
				lea     (R2-7)
				move    X:(SP-8),Y0
				movei   #0,Y1
				movei   #0,R3
				jsr     Ftimer_settime
				lea     (SP-13)
				rts     


				ORG	X:
Fkbd_pos        BSC			1
Fled_matrix     BSC			4
Fkbd_matrix     BSC			4

				ENDSEC
				END
