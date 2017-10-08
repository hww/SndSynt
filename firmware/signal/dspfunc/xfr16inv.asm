	         SECTION rtlib
;
; Frac32 xfr16Inv( Frac16 *pX, int rowscols, Frac16 *pZ)
; {
;
; Register assignments upon entry:
;   Y0 =>   rowscols
;   R2 =>   pX
;   R3 =>   pZ
;
; Register assignments during execution:
;   R2 =>   Frac16 *pX
;   R3 =>	Frac16 *pZ;
;   R1 =>   Frac16 *px_tmp;
;   A  =>   Frac32 Determinant;
;   B  =>   Frac32 accb
;	
	         include "portasm.h"
	
				GLOBAL Fxfr16Inv
				XREF   Fxfr16Det
				
				ORG	P:
Fxfr16Inv:
				push    Y0             ; save registers to make call
				push    R2
				push    R3
;
;   acca = xfr16Det( pX, rowscols );  
;   if( acca == 0 )  return (0);    /* determinant is equal to 0 => exit from routine */
;
				jsr     Fxfr16Det
				pop     R3
				pop     R2
				pop     Y0
				tst     A
				bne     DetNot0
				jmp     EndInv
;
;    switch( rowscols ) {
;
DetNot0:
				cmp     #3,Y0
				beq     Case3
				cmp     #2,Y0
				beq     Case2
; error -- this implementation only supports 2x2 and 3x3 matricies

	if ASSERT_ON_INVALID_PARAMETER==1
 
				debug
				
	endif
	
				clr     A
				jmp     EndInv
Case2:
;
;  pX += 3;                   /*  pX-> a22                 */
;
				lea     (R2+3)
;
;  *pZ++ = *pX;               /*  A11 = a22                */
;
				move    X:(R2),X0
				move    X0,X:(R3)+
;
;  pX -= 2;                   /*  pX-> a12                 */
;
				lea     (R2-2)
;
;  *pZ++ = negate( *pX++ );   /*  A12 = -a12 , pX-> a21    */
;
				move    X:(R2)+,B
				neg     B
				move    B,X:(R3)+
;
;  *pZ++ = negate( *pX );     /*  A21 = -a21               */
;
				move    X:(R2),B
				neg     B
				move    B,X:(R3)+
;
;  pX -= 2;                   /*  pX-> a11                 */
;
				lea     (R2-2)
;
;  *pZ = *pX;                 /*  A22 = a11                */
;
				move    X:(R2),X0
				move    X0,X:(R3)
				jmp     EndInv
;
Case3:
;
;  pX += 4;
;
				lea     (R2+4)
;
;  px_tmp = pX + 4;
;
				move    R2,R1
				lea     (R1+4)
;
;  accb = L_mult( *pX++, *px_tmp-- );        /*  a22*a33 - a23*a32         */
;
				move    X:(R2)+,Y0
				move    X:(R1)-,X0
				mpy     Y0,X0,B
;
;  *pZ++ = msu_r( accb, *pX, *px_tmp++ );
;
				move    X:(R2),Y0
				move    X:(R1)+,X0
				macr    -Y0,X0,B
				move    B,X:(R3)+
;
;  pX -= 4;
;
				lea     (R2-4)
;
;  accb = L_mult( *pX++, *px_tmp-- );        /*  a12*a33 - a13*a32         */
;
				move    X:(R2)+,Y0
				move    X:(R1)-,X0
				mpy     Y0,X0,B
;
;  *pZ++ = negate( msu_r( accb, *pX--, *px_tmp ) );
;
				move    X:(R2)-,Y0
				move    X:(R1),X0
				macr    -Y0,X0,B
				neg     B
				move    B,X:(R3)+
;
;  px_tmp -= 2;
;
				lea     (R1-2)
;
;  accb = L_mult( *pX++, *px_tmp-- );        /*  a12*a23 - a13*a22         */
;
				move    X:(R2)+,Y0
				move    X:(R1)-,X0
				mpy     Y0,X0,B
;
;  *pZ++ = msu_r( accb, *pX, *px_tmp-- );
;
				move    X:(R2),Y0
				move    X:(R1)-,X0
				macr    -Y0,X0,B
				move    B,X:(R3)+
;
;  pX += 6;
;
				lea     (R2+6)
;
;  accb = L_mult( *pX, *px_tmp );            /*  a33*a21 - a31*a23         */
;
				move    X:(R2),Y0
				move    X:(R1),X0
				mpy     Y0,X0,B
;
;  pX -= 2;
;
				lea     (R2-2)
;
;  px_tmp += 2;
;
				lea     (R1+2)
;
;  *pZ++ = negate( msu_r( accb, *pX, *px_tmp ) );
;
				move    X:(R2),Y0
				move    X:(R1),X0
				macr    -Y0,X0,B
				neg     B
				move    B,X:(R3)+
;
;  pX += 2;
;
				lea     (R2+2)
;
;  px_tmp -= 5;
;
				lea     (R1-5)
;
;  accb = L_mult( *pX, *px_tmp );            /*  a33*a11 - a31*a13         */
;
				move    X:(R1),Y0
				move    X:(R2),X0
				mpy     Y0,X0,B
;
;  pX -= 2;
;
				lea     (R2-2)
;
;  px_tmp += 2;
;
				lea     (R1+2)
;
;  *pZ++ = msu_r( accb, *pX--, *px_tmp );
;
				move    X:(R2)-,Y0
				move    X:(R1),X0
				macr    -Y0,X0,B
				move    B,X:(R3)+
;
;  px_tmp -= 2;
;
				lea     (R1-2)
;
;  acca = L_mult( *pX, *px_tmp );            /*  a23*a11 - a21*a13         */
;
				move    X:(R2),Y0
				move    X:(R1),X0
				mpy     Y0,X0,B
;
;  pX -= 2;
;
				lea     (R2-2)
;
;  px_tmp += 2;
;
				lea     (R1+2)
;
;          *pZ++ = negate( msu_r( accb, *pX, *px_tmp ) );
;
				move    X:(R2),Y0
				move    X:(R1),X0
				macr    -Y0,X0,B
				neg     B
				move    B,X:(R3)+
;
;  px_tmp += 5;
;
				lea     (R1+5)
;
;  accb = L_mult( *pX++, *px_tmp-- );            /*  a21*a32 - a22*a31         */
;
				move    X:(R2)+,Y0
				move    X:(R1)-,X0
				mpy     Y0,X0,B
;
;  *pZ++ = msu_r( accb, *pX, *px_tmp++ );
;
				move    X:(R2),Y0
				move    X:(R1)+,X0
				macr    -Y0,X0,B
				move    B,X:(R3)+
;
;  pX -= 4;
;
				lea     (R2-4)
;
;  accb = L_mult( *pX++, *px_tmp-- );            /*  a11*a32 - a12*a31         */
;
				move    X:(R2)+,Y0
				move    X:(R1)-,X0
				mpy     Y0,X0,B
;
;  *pZ++ = negate( msu_r( accb, *pX--, *px_tmp ) );
;
				move    X:(R2)-,Y0
				move    X:(R1),X0
				macr    -Y0,X0,B
				neg     B
				move    B,X:(R3)+
;
;  px_tmp -= 2;
;
				lea     (R1-2)
;
;  accb = L_mult( *pX++, *px_tmp-- );            /*  a11*a22 - a12*a21         */
;
				move    X:(R2)+,Y0
				move    X:(R1)-,X0
				mpy     Y0,X0,B
;
;  *pZ++ = msu_r( accb, *pX, *px_tmp );
;
				move    X:(R2),Y0
				move    X:(R1),X0
				macr    -Y0,X0,B
				move    B,X:(R3)+

EndInv:
				; return value of determinant is in A register
				rts     

				ORG	X:

				ENDSEC
				END
