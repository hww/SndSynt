	         SECTION rtlib
;
; Frac32 xfr16Det( Frac16 *pX, int rowscols )
; {
;
; Register assignments upon entry:
;   Y0 =>   rowscols
;   R2 =>   pX
;
; Register assignments during execution:
;   R3 =>   Frac16 *pX
;   R2 =>	Frac16 *px_tmp;
;   R1 =>   Frac16 *px_tmp2;
;   A  =>   Frac32 acca;
;   B  =>   Frac32 accb;
;	
	         include "portasm.h"
	
				GLOBAL Fxfr16Det
				ORG	P:
Fxfr16Det:
				move    R2,R3
;
;  switch ( rowscols ) {
;
_L6:
				cmp     #3,Y0
				beq     Case3
				cmp     #2,Y0
				beq     Case2
;  error -- this implementation only supports 2x2 or 3x3 matricies

	if ASSERT_ON_INVALID_PARAMETER==1
 
				debug
				
	endif
	
				clr     A
				jmp     EndDet
;
;  case 2:
;
Case2:
;
;  px_tmp = pX + 3;                      /*  pX->a11 , px_tmp->a22 */
;
				lea     (R2+3)
;
;  acca = L_mult( *pX++, *px_tmp-- );    /*  acca = a11*a22 , pX->a12 , px_tmp->a21 */
;
				move    X:(R3)+,Y1
				move    X:(R2)-,X0
				mpy     X0,Y1,A
;
;  acca = L_msu( acca, *pX, *px_tmp );   /*  acca = acca - a12*a21 */
;
				move    X:(R2),X0
				move    X:(R3),Y1
				mac     -Y1,X0,A
				jmp     EndDet
				
Case3:
;
;  px_tmp = pX + 4;                      /*  pX->a11, px_tmp->a22 */
;
				lea     (R2+4)
;
;  px_tmp2 = px_tmp + 4;
;
				move    R2,R1
				lea     (R1+4)
;
;  acca = L_mult( *pX++, *px_tmp++ );    /*  a11*a22*a33 */
;
				move    X:(R3)+,Y1
				move    X:(R2)+,X0
				mpy     X0,Y1,A
;
;  acca = L_mult_ls( acca, *px_tmp2 );
;
				move    X:(R1),X0
				move    A1,Y1
				move    A0,Y0
				mpysu   X0,Y0,A
				move    A1,A0
				move    A2,A1
				mac     Y1,X0,A
;
;  px_tmp2 -= 2;
;
				lea     (R1-2)
;
;  accb = L_mult( *pX++, *px_tmp );      /*  a12*a23*a31 */
;
				move    X:(R3)+,Y1
				move    X:(R2),X0
				mpy     X0,Y1,B
;
; 			px_tmp -= 2;
;
				lea     (R2-2)
;
;  accb = L_mult_ls( accb, *px_tmp2++ );
;
				move    X:(R1)+,X0
				move    B1,Y1
				move    B0,Y0
				mpysu   X0,Y0,B
				move    B1,B0
				move    B2,B1
				mac     Y1,X0,B
;
;  acca = L_add( acca, accb );
;  accb = L_mult( *pX, *px_tmp++ );      /*  a13*a21*a32 */
;
				add     B,A            X:(R2)+,Y1
				move    X:(R3),X0
				mpy     Y1,X0,B
;
;  accb = L_mult_ls( accb, *px_tmp2-- );
;
				move    X:(R1)-,X0
				move    B1,Y1
				move    B0,Y0
				mpysu   X0,Y0,B
				move    B1,B0
				move    B2,B1
				mac     Y1,X0,B
;
;  acca = L_add( acca, accb );
;  accb = L_mult( *pX, *px_tmp++ );      /*   - a13*a22*a31 */
;
				add     B,A           X:(R2)+,Y1
				move    X:(R3),X0
				mpy     Y1,X0,B
;
;  pX -= 2;
;
				lea     (R3-2)
;
;  accb = L_mult_ls( accb, *px_tmp2++ );
;
				move    X:(R1)+,X0
				move    B1,Y1
				move    B0,Y0
				mpysu   X0,Y0,B
				move    B1,B0
				move    B2,B1
				mac     Y1,X0,B
;
;  acca = L_sub( acca, accb );
;  accb = L_mult( *pX++, *px_tmp );      /*  - a11*a23*a32 */
;
				sub     B,A           X:(R3)+,Y1
				move    X:(R2),X0
				mpy     X0,Y1,B
;
;  px_tmp -= 2;
;
				lea     (R2-2)
;
;  accb = L_mult_ls( accb, *px_tmp2++ );
;
				move    X:(R1)+,X0
				move    B1,Y1
				move    B0,Y0
				mpysu   X0,Y0,B
				move    B1,B0
				move    B2,B1
				mac     Y1,X0,B
;
;  acca = L_sub( acca, accb );
;  accb = L_mult( *pX, *px_tmp++ );        /*  - a12*a21*a33 */
;
				sub     B,A           X:(R2)+,Y1
				move    X:(R3),X0
				mpy     Y1,X0,B
;
;  accb = L_mult_ls( accb, *px_tmp2 );
;
				move    X:(R1),X0
				move    B1,Y1
				move    B0,Y0
				mpysu   X0,Y0,B
				move    B1,B0
				move    B2,B1
				mac     Y1,X0,B
;
;  acca = L_sub( acca, accb );
;
				sub     B,A
;
EndDet:
;           return value is in A reg
				rts     

				ORG	X:

				ENDSEC
				END
