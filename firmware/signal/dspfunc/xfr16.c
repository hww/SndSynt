/* File: xfr16.c */

/**************************************************************************
*
*  Copyright (C) 1999 Motorola, Inc. All Rights Reserved 
*
**************************************************************************/

#include <stdio.h>
#include "dspfunc.h"
#include "assert.h"


EXPORT void xfr16MultC(Frac16 *, int, int, Frac16 *, int, Frac16 *);
EXPORT void xfr16TransC(Frac16 *, int, int, Frac16 *);
EXPORT Frac32 xfr16InvC( Frac16 *, int, Frac16 *);
EXPORT Frac32 xfr16DetC( Frac16 *, int);


void xfr16MultC ( Frac16 *pX, int xrows, int xcols, 
						Frac16 *pY, int ycols, 
						Frac16 *pZ)
{
	int      i, j, k;
	Frac16  *pXelem;
	Frac16  *pYelem;
	Frac32   temp;
	
	for (i=0; i<xrows; i++)
	{
		for (j=0; j<ycols; j++) 
		{
			pXelem = pX;
			pYelem = pY + j;
			temp   = 0;
			
			for (k=0; k<xcols; k++) 
			{
				temp = L_mac (temp, *pXelem, *pYelem);
				pXelem++;
				pYelem += ycols;
			}
			
			*pZ++ = round(temp);
		}
		pX += xcols;
	}
}


void xfr16TransC ( Frac16 *pX, int xrows, int xcols, 
						 Frac16 *pZ)
{
	int      i, j;
	Frac16 * pZtemp;
	
	for (i=0; i<xrows; i++)
	{
		pZtemp = pZ++;
		
		for (j=0; j<xcols; j++) 
		{
			*pZtemp = *pX++;
			pZtemp += xrows;
		}
	}
}
								

/*
-------------------------------------------------------------------------------------------------------

MATRIX INVERSE
==============

Definitions:

   -1      1
  A    =  --- A*
          |A|

i) for a 2x2 matrix

 |A| = | a11  a12 | = a11*a22 - a12*a22
       | a21  a22 |

                 T
 A* = ( adj Aij )  = | A11  A12 | = | a22  -a12 |
                     | A21  A22 |   | -a21  a11 |
                     

ii) for a 3x3 matrix

 |A| = | a11  a12  a13 | = a11*a22*a33 + a12*a23*a31 + a13*a21*a32 - a13*a22*a31 - a11*a23*a32-a12*a21*a33
       | a21  a22  a23 |
       | a31  a32  a33 |

                 T
 A* = ( adj Aij )


Note: NO implementation for other sizes
Note: this implementation tries to utilize the maximum accuracy


---------------------------------------------------------------------------------------------------------
*/

Frac32 xfr16InvC( Frac16 *pX, int rowscols, Frac16 *pZ)
{
   Frac16 *px_tmp;
   Frac32 acca, accb;
   
   acca = xfr16Det( pX, rowscols );  
   if( acca == 0 )  return (0);    /* determinant is equal to 0 => exit from routine */


   /* determinant != 0 => continue */
   switch( rowscols ) {
   case 2:
          pX += 3;                   /*  pX-> a22                 */
          *pZ++ = *pX;               /*  A11 = a22                */
          pX -= 2;                   /*  pX-> a12                 */
          *pZ++ = negate( *pX++ );   /*  A12 = -a12 , pX-> a21    */
          *pZ++ = negate( *pX );     /*  A21 = -a21               */
          pX -= 2;                   /*  pX-> a11                 */
          *pZ = *pX;                 /*  A22 = a11                */
          break;
          
   case 3:         
          pX += 4;
          px_tmp = pX + 4;
          accb = L_mult( *pX++, *px_tmp-- );        /*  a22*a33 - a23*a32         */
          *pZ++ = msu_r( accb, *pX, *px_tmp++ );
          //*pZ++ = extract_l( L_msu( accb, *pX, *px_tmp++ ) );
          pX -= 4;
          
          accb = L_mult( *pX++, *px_tmp-- );        /*  a12*a33 - a13*a32         */
          *pZ++ = negate( msu_r( accb, *pX--, *px_tmp ) );
          //*pZ++ = negate( extract_l( L_msu( accb, *pX--, *px_tmp )) );
          px_tmp -= 2;
          
          accb = L_mult( *pX++, *px_tmp-- );        /*  a12*a23 - a13*a22         */
          *pZ++ = msu_r( accb, *pX, *px_tmp-- );
          //*pZ++ = extract_l( L_msu( accb, *pX, *px_tmp-- ) );
          pX += 6;
          
          accb = L_mult( *pX, *px_tmp );            /*  a33*a21 - a31*a23         */
          pX -= 2;
          px_tmp += 2;
          *pZ++ = negate( msu_r( accb, *pX, *px_tmp ) );
          //*pZ++ = negate( extract_l( L_msu( accb, *pX, *px_tmp )) );
          pX += 2;
          px_tmp -= 5;
          
          accb = L_mult( *pX, *px_tmp );            /*  a33*a11 - a31*a13         */
          pX -= 2;
          px_tmp += 2;
          *pZ++ = msu_r( accb, *pX--, *px_tmp );
          //*pZ++ = extract_l( L_msu( accb, *pX--, *px_tmp ) );
          px_tmp -= 2;
            
          accb = L_mult( *pX, *px_tmp );            /*  a23*a11 - a21*a13         */
          pX -= 2;
          px_tmp += 2;
          *pZ++ = negate( msu_r( accb, *pX, *px_tmp ) );
          //*pZ++ = negate( extract_l( L_msu( accb, *pX, *px_tmp )) );
          px_tmp += 5;
 
          accb = L_mult( *pX++, *px_tmp-- );            /*  a21*a32 - a22*a31         */
          *pZ++ = msu_r( accb, *pX, *px_tmp++ );
          //*pZ++ = extract_l( L_msu( accb, *pX, *px_tmp++ ) );
          pX -= 4;
 
          accb = L_mult( *pX++, *px_tmp-- );            /*  a11*a32 - a12*a31         */
          *pZ++ = negate( msu_r( accb, *pX--, *px_tmp ) );
          //*pZ++ = negate( extract_l( L_msu( accb, *pX--, *px_tmp ) ));
          px_tmp -= 2;
          
          accb = L_mult( *pX++, *px_tmp-- );            /*  a11*a22 - a12*a21         */
          *pZ++ = msu_r( accb, *pX, *px_tmp );
          //*pZ++ = extract_l( L_msu( accb, *pX, *px_tmp ) );
          
          break;
   }
   
   
  return( acca );
}
								

/*
-------------------------------------------------------------------------------------------------------

DETERMINANT OF THE MATRIX
=========================

Definitions:

i) for a 2x2 matrix

 |A| = | a11  a12 | = a11*a22 - a12*a22
       | a21  a22 |



ii) for a 3x3 matrix

 |A| = | a11  a12  a13 | = a11*a22*a33 + a12*a23*a31 + a13*a21*a32 - a13*a22*a31 - a11*a23*a32-a12*a21*a33
       | a21  a22  a23 |
       | a31  a32  a33 |


Note: NO implementation for other sizes
Note: this implementation tries to utilize the maximum accuracy

---------------------------------------------------------------------------------------------------------
*/
Frac32 xfr16DetC( Frac16 *pX, int rowscols )
{

	Frac16 *px_tmp, *px_tmp2;
	Frac32 acca, accb;

	assert (rowscols <= 3);
	assert (rowscols >= 2);
	
   switch ( rowscols ) {
   	case 2:
			px_tmp = pX + 3;                      /*  pX->a11 , px_tmp->a22 */

			acca = L_mult( *pX++, *px_tmp-- );    /*  acca = a11*a22 , pX->a12 , px_tmp->a21 */
			acca = L_msu( acca, *pX, *px_tmp );   /*  acca = acca - a12*a21 */
			break;
           
		case 3:
			px_tmp = pX + 4;                      /*  pX->a11, px_tmp->a22 */
			/* px_tmp2 = pX + 8;  */              /*  px_tmp2->a33 */
			px_tmp2 = px_tmp + 4;

			acca = L_mult( *pX++, *px_tmp++ );    /*  a11*a22*a33 */
			acca = L_mult_ls( acca, *px_tmp2 );
			px_tmp2 -= 2;
        
			accb = L_mult( *pX++, *px_tmp );      /*  a12*a23*a31 */
			px_tmp -= 2;
			accb = L_mult_ls( accb, *px_tmp2++ );

			acca = L_add( acca, accb );

			accb = L_mult( *pX, *px_tmp++ );      /*  a13*a21*a32 */
			accb = L_mult_ls( accb, *px_tmp2-- );

			acca = L_add( acca, accb );

			accb = L_mult( *pX, *px_tmp++ );      /*   - a13*a22*a31 */
			pX -= 2;
			accb = L_mult_ls( accb, *px_tmp2++ );

			acca = L_sub( acca, accb );

			accb = L_mult( *pX++, *px_tmp );      /*  - a11*a23*a32 */
			px_tmp -= 2;
			accb = L_mult_ls( accb, *px_tmp2++ );

			acca = L_sub( acca, accb );

			accb = L_mult( *pX, *px_tmp );        /*  - a12*a21*a33 */
			accb = L_mult_ls( accb, *px_tmp2 );

			acca = L_sub( acca, accb );
			break;
	}

   return( acca );
}
