/**********************************************************************
 * FILE		: FIFOtestC.c
 * CREATED	: June 29 2000
 * AUTHOR	: Lee Silverthorn
 * COPYRIGHT: DSPS, Motorola Inc. 2000
 * --------------------------------------------------------------------
 * DESCRIPTION	
 * --------------------------------------------------------------------
 * Tests for FIFO routines:
 * + fifoCreate
 * + fifoDestroy
 * + fifoInsertC
 * + fifoExtractC
 * + fifoPreviewC
 * + fifoClear
 * + fifoNumC
 *
 *
 * COVERAGE
 *
 *	void testFIFO_insextC( int fifoSize, int numSamples, int threshold );
 *	+	fifoCreate
 *	+	fifoDestroy
 *	+	fifoInsert
 *	+	fifoExtract
 *		fifoPreview
 *		fifoClear
 *	+	fifoNum
 *
 *	void testFIFO_boundaryC( void )
 *	+	fifoCreate
 *	+	fifoDestroy
 *	+	fifoInsert  (0/greater then FIFO size)
 *	+	fifoExtract ( greater then FIFO item number)
 *	+	fifoPreview ( greater then FIFO item number)
 *	+	fifoClear
 *	+	fifoNum
 *
 *	void testFIFO_clearC( void )
 *	+	fifoCreate
 *	+	fifoDestroy
 *	+	fifoInsert
 *	+	fifoExtract
 *		fifoPreview
 *	+	fifoClear
 *	+	fifoNum
 *
 *	void testFIFO_overtakeC( void )
 *	+	fifoCreate
 *	+	fifoDestroy
 *	+	fifoInsert
 *	+	fifoExtract
 *		fifoPreview
 *		fifoClear
 *		fifoNum
 *	
 *	void testFIFO_previewC( void )
 *	+	fifoCreate
 *	+	fifoDestroy
 *	+	fifoInsert
 *	+	fifoExtract
 *	+	fifoPreview  (less/greater then THRESHOLD)
 *	+	fifoClear
 *	+	fifoNum
 *
 *	void testFIFO_hysteresisC( void )
 *	+	fifoCreate
 *	+	fifoDestroy
 *	+	fifoInsert
 *	+	fifoExtract
 *		fifoPreview
 *		fifoClear
 *	+	fifoNum		(less/greater then THRESHOLD)
 *
 **********************************************************************/

#include "test.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "bsp.h"
#include "fifo.h"
#include "mem.h"

EXPORT void fifoInitC (fifo_sFifo * pFIFO, UWord16 size, UWord16 threshold);


extern UWord16 fifoNumC (fifo_sFifo * pFifo);


extern UWord16 fifoExtractC(fifo_sFifo * pFifo,
							Word16     * pData,
							UWord16      num);


extern UWord16 fifoPreviewC(fifo_sFifo * pFifo,
							Word16     * pData,
							UWord16      num);


extern UWord16 fifoInsertC ( fifo_sFifo * pFifo,
							Word16     * pData,
							UWord16      num);
									


#undef _VERBOSE_

#ifdef _VERBOSE_
#	include "fifopriv.h"
#endif

#ifndef DSP56801EVM
#define MSG_SIZE 64
static char buf[MSG_SIZE];
#endif
extern test_sRec      testRec;



#define TEST_FAILED( msg )			testFailed( &testRec, msg )

#define ABNORMAL_TERMINATE( msg )	{	TEST_FAILED( msg ); \
										goto EndOfTest;			}

void testFIFO_insextC( int fifoSize, int numSamples, int threshold );
void testFIFO_overtakeC( void );
void testFIFO_clearC( void );
void testFIFO_previewC( void );
void testFIFO_hysteresisC( void );
void testFIFO_boundaryC( void );




void testFIFO_insextC( int fifoSize, int numSamples, int threshold )
{
   unsigned int 	i           = 1;
	unsigned int 	last        = 1;
	unsigned int 	totSamples 	= numSamples;
	fifo_sFifo    *pFifo       = (fifo_sFifo *)NULL;
	short         *samples     = (short *)NULL;

	bool done = false;


	if ( threshold > numSamples )
	{
		TEST_FAILED( "Incorrect input parameters. Threshold is too big" );
		return;
	}
	
	if ( fifoSize < numSamples )
	{
	   totSamples = fifoSize;
	}
	
		
	samples = malloc ( sizeof(short) * totSamples );
	if ( samples == (short*)NULL )
	{
		TEST_FAILED( "Insufficient memory to allocate samples array" );
		return;
	}
	
	pFifo = fifoCreate( fifoSize, threshold );
	if ( pFifo == (fifo_sFifo*)0 )
	{
		TEST_FAILED( "Insufficient memory to allocate FIFO instance" );
		free( samples );
		return;
	}
	
	while( !done )
	{
		if ( i == totSamples )
		{
			done = true;
			i = 0;
		}
		
		if ( fifoInsertC( pFifo, (Word16*)&i, 1 ) == 0 )
		{
#if defined (DSP56801EVM)

			TEST_FAILED( "FIFO insert failed" );		
#else
			sprintf( buf, "FIFO insert failed. %d", (short)i );
			TEST_FAILED( buf );
#endif		
			
			break;
		}
		i++;
	}
#ifdef _VERBOSE_
	printf( "Inserted %d items\n", fifoNum( pFifo ) );
#endif	
	
	done = false;
	//
	if ( fifoExtractC( pFifo, samples, totSamples ) != totSamples )
	{
		TEST_FAILED( "FIFO extract failed" );
		done = true;
	}
#ifdef _VERBOSE_
	printf( "Extracted %d items\n", totSamples - fifoNum( pFifo ) );
#endif	
	if ( fifoNumC( pFifo ) )
	{
		TEST_FAILED( "fifoExtract didn't extract all items" );
		done = true;
	}
	
	while( !done )
	{
		for( i=0; i < totSamples; ++i )
		{
			if ( i+1 == totSamples )
			{
			   last = 0;
			}
			
			if ( samples[i] != last++ )
			{
#if defined (DSP56801EVM)
				TEST_FAILED( "fifoExtract received wrong value." );				
#else	
				sprintf( buf, "fifoExtract received wrong value. Index %d", i );
				TEST_FAILED( buf );
#endif						
				done = true;
				break;
			}
			
			if ( last == 1 )
			{
#ifdef _VERBOSE_
				printf( "All items have correct values\n" );
#endif	
				done = true;
				break;
			}
			
		}
	}
	
	fifoDestroy( pFifo ); 
	free( samples );
}






void testFIFO_overtakeC( void )
{
	#define        FIFO_SIZE   27
	#define        FRAME       11
	#define        READ_SIZE   5
	
	#define			ITERATIONS	23
	
	int				i;
	int				Iterations	= ITERATIONS;
	int				Last;
//	Word16*			pLast    = (Word16*)&Last;
	#define			pLast    (Word16*)&Last
	fifo_sFifo    *pFifo    = (fifo_sFifo *)NULL;
	short         *samples  = (short *)NULL;
	
	samples = malloc ( sizeof(short) * FRAME );
	if ( samples == (short*)NULL )
	{
		TEST_FAILED( "Insufficient memory to allocate samples array" );
		return;
	}
//	for( i = 0; i < totSamples; ++i )
//		samples[i] = -1;
	
	
	pFifo = fifoCreate( FIFO_SIZE, READ_SIZE );
	if ( pFifo == (fifo_sFifo*)NULL )
	{
		ABNORMAL_TERMINATE( "fifoCreate failed" );
	}
//	for( i =0; i < pFifo->size; ++i )
//		pFifo->pCircBuffer[i] = -1;
		
	for( Last = 1; Last <= FRAME; ++Last )
	{
		if ( fifoInsertC( pFifo, pLast, 1 ) == 0 )
		{
			ABNORMAL_TERMINATE( "fifoInsert failed" );
		}
	}
	
	while( Iterations-- )
	{
		if ( fifoExtractC( pFifo, samples, READ_SIZE ) == 0 )
		{
			ABNORMAL_TERMINATE( "fifoExtract failed" );
		}
		for( i=0; i < READ_SIZE; ++i )
		{
			if ( samples[i] != (Last - FRAME +i) )
			{
#if defined (DSP56801EVM)
				ABNORMAL_TERMINATE( "fifoExtract received wrong value" );
#else
				sprintf( buf, "fifoExtract received wrong value %d must be %d", samples[i], Last );
				ABNORMAL_TERMINATE( buf );
#endif
				
			}
		}
		
		for( i = 0; i < READ_SIZE; ++i, ++Last )
		{
			if ( fifoInsertC( pFifo, pLast, 1 ) == 0 )
			{
				ABNORMAL_TERMINATE( "fifoInsert failed" );
			}
		}
#ifdef _VERBOSE_
		printf( "HEAD:%02d  TAIL:%02d\n", ((fifo_sFifoPriv*)pFifo)->get, ((fifo_sFifoPriv*)pFifo)->put );
#endif
	}
	

EndOfTest:	
	fifoDestroy( pFifo );
	free( samples );
}





void testFIFO_clearC( void )
{
	#define        FIFO_SIZE   27
	#define        FRAME_SIZE  FIFO_SIZE
	#define        THRESHOLD   5
	#define        THRESHOLD2  15

	int				i;
	int				samps		= 0;
	int            count;
	fifo_sFifo    *pFifo 	= (fifo_sFifo *)NULL;
	Word16        *samples = (Word16 *)NULL;

	
	samples = malloc ( sizeof(Word16) * FRAME_SIZE );
	if ( samples == (Word16*)NULL )
	{
		TEST_FAILED( "Insufficient memory to allocate samples array" );
		return;
	}
	for( i = 0; i < FRAME_SIZE; ++i )
		samples[i] = i;
	
	
	pFifo = fifoCreate( FIFO_SIZE, THRESHOLD );
	if ( pFifo == (fifo_sFifo*)NULL )
	{
		ABNORMAL_TERMINATE( "fifoCreate failed" );
	}

   count = fifoInsertC( pFifo, samples, FRAME_SIZE );
	if ( count == 0 || count != FRAME_SIZE )
	{
		ABNORMAL_TERMINATE( "fifoInsert failed" );
	}
	
#ifdef _VERBOSE_
	printf( "The FIFO contains %d items\n", fifoNum( pFifo ) );
#endif	
	
	fifoClear( pFifo, THRESHOLD2 );	
	
#ifdef _VERBOSE_
	printf( "After fifoClear it contains %d items\n", fifoNum( pFifo ) );
#endif	

	if ( fifoNumC( pFifo ) )
	{
		ABNORMAL_TERMINATE( "fifoClear doesn't clean the FIFO" );
	}
	
	/*** Check new threshold value *********************************/
#ifdef _VERBOSE_
	printf( "New value of the Threshold is %d\n", ((fifo_sFifoPriv*)pFifo->PrivData)->threshold );
#endif

	for( i = 1; i <= THRESHOLD2; ++i )
	{
		if ( fifoInsertC( pFifo, (Word16*)&i, 1 ) == 0 )
		{
			ABNORMAL_TERMINATE( "fifoInsert failed" );
		}
	
		if ( i == THRESHOLD2 )
			samps = i;
			
		if ( fifoExtractC( pFifo, samples, fifoNum( pFifo ) ) != samps )
		{
			ABNORMAL_TERMINATE( "fifoExtract yields incorrect data" );
		}
#ifdef _VERBOSE_
		else
		{
			printf( "Inserted %d items. It is extracted %d items\n", i, samps );
		}
#endif	
	}
	/**************************************************************/
	
	
	
EndOfTest:	
	fifoDestroy( pFifo );
	free( samples );
}






void testFIFO_previewC( void )
{
	#undef         THRESHOLD
	#define        FIFO_SIZE   27
	#define        THRESHOLD   15

	int            i;
	int            count    = 2;
	fifo_sFifo    *pFifo    = (fifo_sFifo *)NULL;
	Word16        *samples  = (Word16 *)NULL;

	
	samples = malloc ( sizeof(Word16) * FIFO_SIZE );
	if ( samples == (Word16*)NULL )
	{
		TEST_FAILED( "Insufficient memory to allocate samples array" );
		return;
	}
	for( i = 0; i < FIFO_SIZE; ++i )
		samples[i] = i;
	
	
	pFifo = fifoCreate( FIFO_SIZE, THRESHOLD );
	if ( pFifo == (fifo_sFifo*)NULL )
	{
		ABNORMAL_TERMINATE( "fifoCreate failed" );
	}

	if ( fifoInsertC( pFifo, samples, THRESHOLD-1 ) == 0 )
	{
		ABNORMAL_TERMINATE( "fifoInsert failed" );
	}
#ifdef _VERBOSE_
		printf( "Inserted %d items\n", THRESHOLD-1 );
#endif	
	if ( fifoPreviewC( pFifo, samples, FIFO_SIZE ) != 0 )
	{
		ABNORMAL_TERMINATE( "fifoPreview returned data less then FIFO threshold" );
	}

	fifoClear( pFifo, THRESHOLD );
	
	if ( fifoInsertC( pFifo, samples, FIFO_SIZE ) == 0 )
	{
		ABNORMAL_TERMINATE( "fifoInsert failed" );
	}
#ifdef _VERBOSE_
	else
	{
		printf( "Inserted %d items\n", FIFO_SIZE );
	}
#endif	
	
	while( count-- )
	{	
#ifdef _VERBOSE_
		printf( "The FIFO contains %d items\n", fifoNum( pFifo ) );
#endif	
		for( i = 0; i < FIFO_SIZE; ++i )
			samples[i] = 0;
	
		if ( fifoPreviewC( pFifo, samples, FIFO_SIZE ) == 0 )
		{
			ABNORMAL_TERMINATE( "fifoPreview failed" );
		}
	
		if ( fifoNumC( pFifo ) != FIFO_SIZE )
		{
			ABNORMAL_TERMINATE( "FIFO contains invalid items number after fifoPreview" );
		}
		for( i = 0; i < FIFO_SIZE; ++i )
		{
			if ( samples[i] != i )
			{
				ABNORMAL_TERMINATE( "fifoPreview yields incorrect data" );
			}
		}
#ifdef _VERBOSE_
		printf( "After fifoPreview it contains %d items\n", fifoNum( pFifo ) );
#endif	
	}
	
	if ( fifoExtractC( pFifo, samples, FIFO_SIZE ) != FIFO_SIZE )
	{
		ABNORMAL_TERMINATE( "fifoExtract failed" );
	}
	
	for( i = 0; i < FIFO_SIZE; ++i )
		samples[i] = 0;
	
	if ( fifoPreviewC( pFifo, samples, FIFO_SIZE ) != 0 )
	{
		ABNORMAL_TERMINATE( "fifoPreview failed" );
	}
	
	for( i = 0; i < FIFO_SIZE; ++i )
	{
		if ( samples[i] != 0 )
		{
			ABNORMAL_TERMINATE( "fifoPreview yields incorrect data" );
		}
	}
	
EndOfTest:	
	fifoDestroy( pFifo );
	free( samples );
}




void testFIFO_hysteresisC( void )
{
	#undef         THRESHOLD
	#undef         FIFO_SIZE
	
	#define        COUNT       3
	#define        FIFO_SIZE   45
	#define        INSERT_SIZE FIFO_SIZE / COUNT
	#define        THRESHOLD   FIFO_SIZE * 2 / COUNT

	int         i;
	int         extr    = FIFO_SIZE / 2;
	fifo_sFifo *pFifo   = (fifo_sFifo *)NULL;
	Word16     *samples = (Word16 *)NULL;

	
	samples = malloc ( sizeof(Word16) * FIFO_SIZE );
	if ( samples == (Word16*)NULL )
	{
		TEST_FAILED( "Insufficient memory to allocate samples array" );
		return;
	}

	/* Create FIFO */	
	pFifo = fifoCreate( FIFO_SIZE, THRESHOLD );
	if ( pFifo == (fifo_sFifo*)NULL )
	{
		ABNORMAL_TERMINATE( "fifoCreate failed" );
	}


	for( i = 1; i <= COUNT; ++i )
	{
		if ( fifoInsertC( pFifo, samples, INSERT_SIZE ) == 0 )
		{
			ABNORMAL_TERMINATE( "fifoInsert failed" );
		}
#ifdef _VERBOSE_
		printf( "Inserted %d items ", INSERT_SIZE );
#endif	
		if ( ( i*INSERT_SIZE < THRESHOLD ) )
		{
			if ( fifoNumC( pFifo ) != 0 )
			{
				ABNORMAL_TERMINATE( "fifoNum returns value less then FIFO threshold" );
			}
			if ( fifoExtractC( pFifo, samples, 1 ) != 0 )
			{
				ABNORMAL_TERMINATE( "fifoExtract returns value less then FIFO threshold" );
			}
		}
		else
		{
			if ( fifoNumC( pFifo ) != i*INSERT_SIZE ) 
			{
				ABNORMAL_TERMINATE( "fifoNum returns inorrect value" );
			}
		}
		
#ifdef _VERBOSE_
		printf( "FIFO contains %d items, fifoNum returned %d\n", i*INSERT_SIZE, fifoNum( pFifo ) );
#endif	
	}

	/* Extract FIFO_SIZE / 2 items ************************************/
	if ( fifoExtractC( pFifo, samples, extr ) == 0 )
	{
		ABNORMAL_TERMINATE( "fifoExtract failed" );
	}
#ifdef _VERBOSE_
	printf( "Extracted %d items ", extr );
#endif	
	if ( fifoNumC( pFifo ) != ( FIFO_SIZE - extr ) )
	{
		ABNORMAL_TERMINATE( "fifoNum returns incorrect value" );
	}
#ifdef _VERBOSE_
	printf( "FIFO contains %d items, fifoNum returned %d\n", FIFO_SIZE - extr, fifoNum( pFifo ) );
#endif	

	
EndOfTest:	
	fifoDestroy( pFifo );
	free( samples );
}




void testFIFO_boundaryC( void )
{
	#undef         THRESHOLD
	#undef         FIFO_SIZE
	#undef         INSERT_SIZE
	
	#define        FIFO_SIZE   10
	#define        INSERT_SIZE FIFO_SIZE * 2
	#define        THRESHOLD   FIFO_SIZE 
	#define        SET_VALUE   0xE1E1

	int         count;
	fifo_sFifo *pFifo   = (fifo_sFifo *)NULL;
	Word16     *samples = (Word16 *)NULL;

	
	samples = malloc ( sizeof(Word16) * INSERT_SIZE );
	if ( samples == (Word16*)NULL )
	{
		TEST_FAILED( "Insufficient memory to allocate samples array" );
		return;
	}
	for( count=0; count < INSERT_SIZE; count++ )
	{
	   samples[count] = count;
	}

	/* Create FIFO */	
	pFifo = fifoCreate( FIFO_SIZE, THRESHOLD );
	if ( pFifo == (fifo_sFifo*)NULL )
	{
		ABNORMAL_TERMINATE( "fifoCreate failed" );
	}

   /* Insert 3 items */
   count = fifoInsertC( pFifo, samples, 3 );
   if ( count != 3 )
   {
      ABNORMAL_TERMINATE( "FIFO contains incorrect number of items" );
   }
   
   /* Insert MAX items*/
   count = fifoInsertC( pFifo, samples, INSERT_SIZE );
	if ( count != FIFO_SIZE - 3)
	{
		ABNORMAL_TERMINATE( "fifoInsert failed to insert correct number" );
	}
	
	if ( fifoNumC(pFifo) != FIFO_SIZE)
	{
		ABNORMAL_TERMINATE( "fifoInsert failed to accumulate correctly" );
	}
	
	fifoClear (pFifo, THRESHOLD);
	
   /* Insert 0 items */
   count = fifoInsertC( pFifo, samples, 0 );
   if ( count || fifoNumC( pFifo ) )
   {
      ABNORMAL_TERMINATE( "FIFO contains incorrect number of items" );
   }
   
   /* Insert MAX items*/
   count = fifoInsertC( pFifo, samples, INSERT_SIZE );
	if ( count == 0 || count > FIFO_SIZE )
	{
		ABNORMAL_TERMINATE( "fifoInsert failed. FIFO overflow" );
	}
	
#ifdef _VERBOSE_
	printf( "Inserted %d items ", INSERT_SIZE );
	printf( "FIFO contains %d items, fifoNum returned %d\n", INSERT_SIZE, fifoNum( pFifo ) );
#endif	

	count = fifoNumC( pFifo );
	if ( count != FIFO_SIZE )
	{
		ABNORMAL_TERMINATE( "fifoNum failed" );
	}
	
	memset( samples, SET_VALUE, sizeof(Word16)*INSERT_SIZE );

	// fifoPreview
	count = fifoPreviewC( pFifo, samples, INSERT_SIZE );
	if ( count != 0 )
	{
	   ABNORMAL_TERMINATE( "fifoPreview failed" );
	}
   /* check no previewed data */
   for( count=0; count < INSERT_SIZE; count++ )
   {
      if ( samples[count] != SET_VALUE )
      {
         ABNORMAL_TERMINATE( "fifoPreview modifies buffer" );
      }
   }
   if ( fifoNumC( pFifo ) != FIFO_SIZE )
   {
      ABNORMAL_TERMINATE( "fifoNum yields incorrect value" );
   }
	
	// fifoExtract
	count = fifoExtractC( pFifo, samples, INSERT_SIZE );
	if ( count != 0 )
	{
	   ABNORMAL_TERMINATE( "fifoExtract failed" );
	}
	if ( fifoNumC( pFifo ) != FIFO_SIZE )
	{
	   ABNORMAL_TERMINATE( "fifoNum failed" );
	}
   /* check no extracted data */
   for( count=0; count < INSERT_SIZE; count++ )
   {
      if ( samples[count] != SET_VALUE )
      {
         ABNORMAL_TERMINATE( "fifoExtract modifies buffer" );
      }
   }
	
	
	/* Preview all items ************************************/
	count = fifoPreviewC( pFifo, samples, FIFO_SIZE );
	if ( count == 0 || count != FIFO_SIZE )
	{
		ABNORMAL_TERMINATE( "fifoPreview failed" );
	}
   /* check previewed data */
   for( count=0; count < FIFO_SIZE; count++ )
   {
      if ( samples[count] != count )
      {
         ABNORMAL_TERMINATE( "fifoPreview yields incorrect data" );
      }
   }
   /* check buffer contain */
   for( count=FIFO_SIZE; count < INSERT_SIZE; count++ )
   {
      if ( samples[count] != SET_VALUE )
      {
         ABNORMAL_TERMINATE( "fifoPreview modifies buffer" );
      }
   }
	if ( fifoNumC( pFifo ) != FIFO_SIZE )
	{
      ABNORMAL_TERMINATE( "fifoNum yields incorrect value" );
	}
	
	
	/* Extract all items ************************************/
	memset( samples, SET_VALUE, sizeof(Word16)*INSERT_SIZE );
	count = fifoExtractC( pFifo, samples, FIFO_SIZE );
	if ( count == 0 || count != FIFO_SIZE )
	{
		ABNORMAL_TERMINATE( "fifoExtract failed" );
	}
#ifdef _VERBOSE_
	printf( "Extracted %d items ", count );
#endif	
   /* check extracted data */
   for( count=0; count < FIFO_SIZE; count++ )
   {
      if ( samples[count] != count )
      {
         ABNORMAL_TERMINATE( "fifoExtract yields incorrect data" );
      }
   }
   /* check buffer contain */
   for( count=FIFO_SIZE; count < INSERT_SIZE; count++ )
   {
      if ( samples[count] != SET_VALUE )
      {
         ABNORMAL_TERMINATE( "fifoExtract yields incorrect data" );
      }
   }

	if ( fifoNumC( pFifo ) != 0 )
	{
		ABNORMAL_TERMINATE( "fifoNum returns incorrect value" );
	}
#ifdef _VERBOSE_
	printf( "FIFO contains %d items, fifoNum returned %d\n", FIFO_SIZE - extr, fifoNum( pFifo ) );
#endif	

   /* Threshold > FIFO_SIZE */

   fifoClear( pFifo, FIFO_SIZE +1 );
   
	for( count=0; count < FIFO_SIZE+1; count++ )
	{
	   samples[count] = count;
	}

   count = fifoInsertC( pFifo, samples, FIFO_SIZE-1 );
#ifdef _VERBOSE_
	printf( "FIFO contains %d items (threshold=%d), fifoNum returned %d\n", FIFO_SIZE-1, ((fifo_sFifoPriv*)pFifo)->threshold, fifoNum( pFifo ) );
#endif	
   if ( fifoNumC( pFifo ) != 0 )
   {
      ABNORMAL_TERMINATE( "fifoNum yields incorrect data" );
   }
	memset( samples, SET_VALUE, sizeof(Word16)*INSERT_SIZE );
   if ( fifoPreviewC( pFifo, samples, count ) != 0)
   {
      ABNORMAL_TERMINATE( "fifoPreview returns incorrect value" );
   }
   for( count=0; count < INSERT_SIZE; ++count )
   {
      if ( samples[count] != SET_VALUE )
      {
         ABNORMAL_TERMINATE( "fifoPreview returns incorrect data" );
      }
   }
   if ( fifoExtractC( pFifo, samples, count ) != 0)
   {
      ABNORMAL_TERMINATE( "fifoExtract returns incorrect value" );
   }
   for( count=0; count < INSERT_SIZE; ++count )
   {
      if ( samples[count] != SET_VALUE )
      {
         ABNORMAL_TERMINATE( "fifoExtract returns incorrect data" );
      }
   }
   
   count = 0;
   count = fifoInsertC( pFifo, (Word16 *)&count, 1 );
#ifdef _VERBOSE_
	printf( "FIFO contains %d items, fifoNum returned %d\n", FIFO_SIZE, fifoNum( pFifo ) );
#endif	
   /*Thershold must be equal to FIFO_SIZE*/
   if ( fifoNumC( pFifo ) != FIFO_SIZE )
   {
      ABNORMAL_TERMINATE( "fifoNum yields incorrect data" );
   }
   /* check fifoPreview */
	memset( samples, SET_VALUE, sizeof(Word16)*INSERT_SIZE );
   if ( fifoPreviewC( pFifo, samples, FIFO_SIZE ) != FIFO_SIZE )
   {
      ABNORMAL_TERMINATE( "fifoPreview returns incorrect value" );
   }
   for( count=0; count < FIFO_SIZE; ++count )
   {
      if ( count == FIFO_SIZE -1 )
      {
         if ( samples[count] == 0 )
            continue;
      }
      else
      {
         if ( samples[count] == count )
            continue;   
      }
      ABNORMAL_TERMINATE( "fifoPreview returns incorrect data" );
   }
   for( count=FIFO_SIZE; count < INSERT_SIZE; count++ )
   {
      if ( samples[count] != SET_VALUE )
      {
         ABNORMAL_TERMINATE( "fifoPreview modifies buffer" );
      }
   }
   
   /* check fifoExtract */   
	memset( samples, SET_VALUE, sizeof(Word16)*INSERT_SIZE );
   if ( fifoExtractC( pFifo, samples, FIFO_SIZE ) != FIFO_SIZE )
   {
      ABNORMAL_TERMINATE( "fifoExtract returns incorrect value" );
   }
   for( count=0; count < FIFO_SIZE; ++count )
   {
      if ( count == FIFO_SIZE -1 )
      {
         if ( samples[count] == 0 )
            continue;
      }
      else
      {
         if ( samples[count] == count )
            continue;   
      }
      ABNORMAL_TERMINATE( "fifoExtract returns incorrect data" );
   }
   for( count=FIFO_SIZE; count < INSERT_SIZE; count++ )
   {
      if ( samples[count] != SET_VALUE )
      {
         ABNORMAL_TERMINATE( "fifoExtract modifies buffer" );
      }
   }
   
EndOfTest:	
	fifoDestroy( pFifo );
	free( samples );
}
