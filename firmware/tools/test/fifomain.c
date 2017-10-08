/*
TEST 1001	FIFO test suite
*/

#include "test.h"

test_sRec      testRec;


void testFIFO_insext     ( int fifoSize, int numSamples, int threshold );
void testFIFO_overtake   ( void );
void testFIFO_clear      ( void );
void testFIFO_preview    ( void );
void testFIFO_hysteresis ( void );
void testFIFO_boundary   ( void );

void testFIFO_insextC     ( int fifoSize, int numSamples, int threshold );
void testFIFO_overtakeC   ( void );
void testFIFO_clearC      ( void );
void testFIFO_previewC    ( void );
void testFIFO_hysteresisC ( void );
void testFIFO_boundaryC   ( void );


int main(void)
{
	testStart   (&testRec, "FIFO test");
	testComment (&testRec, "Testing FIFO routines...");

   /**/  
	testComment( &testRec, "...fifoCreate, fifoInsert, fifoExtract..." );
	/*				FIFO Size,  Samples Number, Threshold */
	testFIFO_insext( 7, 18, 15 );
	testFIFO_insext( 7, 18, 5 );
	testFIFO_insext( 15, 8, 5 );
	testFIFO_insext( 78, 78, 25 );

	/**/
	testComment( &testRec, "...boundary..." );
   testFIFO_boundary();
   
	/**/
	testComment( &testRec, "...the tail overtakes the head..." );
	testFIFO_overtake();
	
	/**/
	testComment( &testRec, "...fifoClear..." );
	testFIFO_clear();
	
	/**/
	testComment( &testRec, "...fifoPreview..." );
	testFIFO_preview();
	
	/**/
	testComment( &testRec, "...FIFO hysteresis..." );
	testFIFO_hysteresis();


	/* Test FIFO C Routines */
	
	testComment (&testRec, "Testing FIFO C routines...");

   /**/  
	testComment( &testRec, "...fifoCreate, fifoInsert, fifoExtract..." );
	/*				FIFO Size,  Samples Number, Threshold */
	testFIFO_insextC( 7, 18, 15 );
	testFIFO_insextC( 7, 18, 5 );
	testFIFO_insextC( 15, 8, 5 );
	testFIFO_insextC( 78, 78, 25 );

	/**/
	testComment( &testRec, "...boundary..." );
   testFIFO_boundaryC();
   
	/**/
	testComment( &testRec, "...the tail overtakes the head..." );
	testFIFO_overtakeC();
	
	/**/
	testComment( &testRec, "...fifoClear..." );
	testFIFO_clearC();
	
	/**/
	testComment( &testRec, "...fifoPreview..." );
	testFIFO_previewC();
	
	/**/
	testComment( &testRec, "...FIFO hysteresis..." );
	testFIFO_hysteresisC();

	testEnd(&testRec);
	
	return 0;
}



