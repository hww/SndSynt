#include "timespec.h"


#define NSECSINSEC 1000000000

#if 0
void timespecAdd (struct timespec * pTimeres, struct timespec * pTime1, struct timespec * pTime2)
{
	long sec;
	long nsec;

	sec  = pTime1 -> tv_sec  + pTime2 -> tv_sec;
	nsec = pTime1 -> tv_nsec + pTime2 -> tv_nsec;

	while (nsec >= NSECSINSEC) {
		sec++;
		nsec -= NSECSINSEC;
	}

	while (nsec <= -NSECSINSEC) {
		sec--;
		nsec += NSECSINSEC;
	}

	while (sec > 0 && nsec < 0) {
		sec--;
		nsec += NSECSINSEC;
	}

	while (sec < 0 && nsec > 0) {
		sec++;
		nsec -= NSECSINSEC;
	}

	pTimeres -> tv_sec  = sec;
	pTimeres -> tv_nsec = nsec;
}
#else
asm void timespecAdd (struct timespec * pTimeres, struct timespec * pTime1, struct timespec * pTime2)
{
;    9: 	long sec; 
;   10: 	long nsec; 
;   11:  
;
;
; Register Usage
;
;    A   - nsec
;    B   - sec
;    Y   - temp
;    X0  - save OMR
;    N   - save M01
;    R2  - pTimeres
;    R3  - pTime1
;    R0  - pTime2
;
		move     OMR,X0          ; save OMR in X0
		bfclr    #0x0010,OMR     ; turn saturation off
		move     M01,N           ; save M01 in N
		move     #-1,M01         ; set M01 to use R0
		
;
;   12: 	sec  = pTime1 -> tv_sec  + pTime2 -> tv_sec; 
;
		move     X:(SP-2),R0
		move     X:(R3+0x0001),Y1
		move     X:(R3),Y0
		move     X:(R0+0x0001),B
		move     X:(R0),B0
		add      Y,B
;
;   13: 	nsec = pTime1 -> tv_nsec + pTime2 -> tv_nsec; 
;   14:  
;
		move     X:(SP-0x0002),R0
		move     X:(R3+0x0003),Y1
		move     X:(R3+0x0002),Y0
		move     X:(R0+0x0003),A
		move     X:(R0+0x0002),A0
		add      Y,A
;
;   15: 	while (nsec >= NSECSINSEC) { 
;
StartLoop1:		
		movei    #15258,Y1
		movei    #-13824,Y0
		sub      Y,A
		blt      EndLoop1
;
;   16: 		sec++; 
;
		clr      Y1
		move     #1,Y0
		add      Y,B
;
;   17: 		nsec -= NSECSINSEC; 
;
		bra      StartLoop1
EndLoop1:
		add      Y,A

;   18: 	} 
;   19:  
;   20: 	while (nsec <= -NSECSINSEC) { 
;
StartLoop2:
		movei    #-15259,Y1    ;  Y = -NSECINSEC
		movei    #13824,Y0
		sub      Y,A           ;  Y contains -NSECINSEC
		bgt      EndLoop2
;
;   21: 		sec--; 
;
		clr      Y1
		move     #1,Y0
		sub      Y,B
;
;   22: 		nsec += NSECSINSEC; 
;
		bra      StartLoop2
EndLoop2:
		add      Y,A            ;  Y contains -NSECINSEC
;
;   23: 	} 
;   24:  
;
;
;   25: 	while (sec > 0 && nsec < 0) { 
;
StartLoop3:
		tst      B
		ble      EndLoop3
		tst      A
		bge      EndLoop3
;
;   26: 		sec--; 
;
		clr      Y1
		move     #1,Y0
		sub      Y,B
;
;   27: 		nsec += NSECSINSEC; 
;
		movei    #15258,Y1
		movei    #-13824,Y0
		add      Y,A    
		bra      StartLoop3
EndLoop3:
;
;   28: 	} 
;   29:  
;
;
;   30: 	while (sec < 0 && nsec > 0) { 
;
StartLoop4:
		tst      B
		bge      EndLoop4
		tst      A
		ble      EndLoop4
;
;   31: 		sec++; 
;
		clr      Y1
		move     #1,Y0
		add      Y,B
;
;   32: 		nsec -= NSECSINSEC; 
;
		movei    #15258,Y1
		movei    #-13824,Y0
		sub      Y,A      
		bra      StartLoop4
EndLoop4:
;
;   33: 	} 
;   34:  
;   35: 	pTimeres -> tv_sec  = sec; 
;
		move     B1,X:(R2+1)
		move     B0,X:(R2)
;
;   36: 	pTimeres -> tv_nsec = nsec; 
;
		move     A1,X:(R2+3)
		move     A0,X:(R2+2)
;
		move     N,M01          ; restore M01 reg
		move     X0,OMR         ; restore OMR reg
		rts
}      
#endif

#if 0
void timespecSub (struct timespec * pTimeres, struct timespec * pTime1, struct timespec * pTime2)
{
	struct timespec t;

	t.tv_sec  = -pTime2 -> tv_sec;
	t.tv_nsec = -pTime2 -> tv_nsec;

	timespecAdd (pTimeres, pTime1, &t);
}
#else
asm void timespecSub (struct timespec * pTimeres, struct timespec * pTime1, struct timespec * pTime2)
{
;
; Register Usage
;
;    A         - nsec
;    B         - sec
;    R2        - pTimeres
;    R3        - pTime1
;    R0        - pTime2
;    x:(SP-5)  - save M01
;    x:(SP-4)  - t.sec
;    x:(SP-2)  - t.nsec
;    x:(SP)    - pTimeres parameter for call to timespecAcc
;
;  191: 
;  192: 	struct timespec t; 
;  193:  
;
		movei    #6,N
		lea      (SP)+N
		move     M01,X:(SP-5)
		move     #-1,M01
;
;  194: 	t.tv_sec  = -pTime2 -> tv_sec; 
;
		move     X:(SP-0x0008),R0
		nop
		move     X:(R0+0x0001),B
		move     X:(R0),B0
		neg      B
		move     B1,X:(SP-0x0003)
		move     B0,X:(SP-0x0004)
;
;  195: 	t.tv_nsec = -pTime2 -> tv_nsec; 
;  196:  
;
		move     X:(R0+0x0003),B
		move     X:(R0+0x0002),B0
		neg      B
		move     B1,X:(SP-0x0001)
		move     B0,X:(SP-0x0002)
;
;  197: 	timespecAdd (pTimeres, pTime1, &t); 
;
		move     SP,R0
		lea      (R0-0x0004)
		move     R0,X:(SP)
		jsr      timespecAdd
;
;  198: } 
		move     x:(SP-5),M01
		lea      (SP-0x0006)
		rts      
}
#endif


#if 0
bool timespecGE (	struct timespec * pTime1, 
					struct timespec * pTime2)
{
	if (pTime1->tv_sec > pTime2->tv_sec)
	{
		return true;
	}
	
	if (pTime1->tv_sec < pTime2->tv_sec)
	{
		return false;
	}
	
	return (pTime1->tv_nsec >= pTime2->tv_nsec);
}				
#else
asm bool timespecGE (	struct timespec * pTime1, 
						struct timespec * pTime2)
{
;
;  204: 	if (pTime1->tv_sec > pTime2->tv_sec) 
;  205: 	{ 
;
		clr      Y0
		move     X:(R2+0x0001),B
		move     X:(R2),B0
		move     X:(R3+0x0001),A
		move     X:(R3),A0
		cmp      A,B
		bgt      ReturnTrue
;
;  206: 		return true; 
;  207: 	} 
;  208: 	 
;  209: 	if (pTime1->tv_sec < pTime2->tv_sec) 
;  210: 	{ 
;  211: 		return false; 
;  212: 	} 
;  213: 	 
		blt      ReturnFalse
;
;  214: 	return (pTime1->tv_nsec >= pTime2->tv_nsec); 
;
		move     X:(R2+0x0003),B
		move     X:(R2+0x0002),B0
		move     X:(R3+0x0003),A
		move     X:(R3+0x0002),A0
		cmp      A,B
		blt      ReturnFalse
;
;  215: }				 
;
ReturnTrue:
		move     #1,Y0
ReturnFalse:
		rts 
}     
#endif
