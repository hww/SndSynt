#include "port.h"
#include "io.h"
#include "bsp.h"
#include "fcntl.h"
#include "test.h"

#include "serialdataflash.h"
#include <stdio.h>


#define TST_WRITE_SIZE 		0x0100
#define TST_READ_SIZE 		0x4000

UWord16 WriteBuf1  [ TST_WRITE_SIZE ];
UWord16 WriteBuf2  [ TST_WRITE_SIZE ];
UWord16 ReadBuf    [ TST_READ_SIZE ]; 


/******************************************************************************/
int main()
{
	UWord16 ReturnSize;
	UWord16 i;
	int 	SerialDataFlashHandle;
    UWord32 SerialDataFlashAddress 	= 0x0000;
    bool 	VerifyMode 		= true;
    bool 	ProtectMode		= true;
    test_sRec      testRec;

	testStart (&testRec, "Serial DataFlash");

	/* Prepare data to test */
	
	for (i = 0;i < TST_WRITE_SIZE; i++)
    {
        WriteBuf1[ i ] = i + 0x7000;
        WriteBuf2[ i ] = i + 0x8000 + 2;
    }

	for (i = 0;i < TST_READ_SIZE; i++)
    {
        ReadBuf [ i ] = 0xA5C3;
    }
    
	/* OPEN SERIAL DATAFLASH DEVICE  */

	SerialDataFlashHandle = open(BSP_DEVICE_NAME_SERIAL_DATAFLASH_0,0);
	
	/*********************************************************************/
	/********* FILL THE ENTIRE SERIAL DATAFLASH WITH 0xA5C3 **************/
	/*********************************************************************/

	testComment (&testRec, "Filling DataFlash[0x00000..0x03fff] with 0xA5C3");

	ReturnSize = write(SerialDataFlashHandle, ReadBuf, TST_READ_SIZE );

	testComment (&testRec, "Filling DataFlash[0x04000..0x07fff] with 0xA5C3");

	ReturnSize = write(SerialDataFlashHandle, ReadBuf, TST_READ_SIZE );

	testComment (&testRec, "Filling DataFlash[0x08000..0x0bfff] with 0xA5C3");

	ReturnSize = write(SerialDataFlashHandle, ReadBuf, TST_READ_SIZE );
	
	testComment (&testRec, "Filling DataFlash[0x0c000..0x0ffff] with 0xA5C3");

	ReturnSize = write(SerialDataFlashHandle, ReadBuf, TST_READ_SIZE );
	
	testComment (&testRec, "Filling DataFlash[0x10000..0x107ff] with 0xA5C3");

	ReturnSize = write(SerialDataFlashHandle, ReadBuf, TST_READ_SIZE );

	/*********************************************************************/
	/***** READ AND VERIFY THE ENTIRE SERIAL DATAFLASH             *******/
	/***** IS FILLED WITH 0xA5C3                                   *******/
	/*********************************************************************/

	SerialDataFlashAddress 	= 0x0000; 	
	VerifyMode 		= true;
	ioctl(SerialDataFlashHandle, SERIAL_DATAFLASH_SEEK, &SerialDataFlashAddress );
	ioctl(SerialDataFlashHandle, SERIAL_DATAFLASH_MODE_VERIFY, &VerifyMode );

    testComment (&testRec, "Reading DataFlash[0x00000..0x03fff] and verifying");

	ReturnSize = read(SerialDataFlashHandle, ReadBuf, TST_READ_SIZE );
	
	if ( ReturnSize == 0 )
	{
	    testFailed(&testRec,"DataFlash[0x00000..0x03fff] verify error: Return size = 0");
    }    

	if ( ReturnSize != TST_READ_SIZE )
	{
	    testFailed(&testRec,"DataFlash[0x00000..0x03fff] verify error: Size too big");
    }    

    testComment (&testRec, "Reading DataFlash[0x04000..0x07fff] and verifying");

	ReturnSize = read(SerialDataFlashHandle, ReadBuf, TST_READ_SIZE );

	if ( ReturnSize == 0 )
	{
	    testFailed(&testRec,"DataFlash[0x04000..0x07fff] verify error: Return size = 0");
    }    

	if ( ReturnSize != TST_READ_SIZE )
	{
	    testFailed(&testRec,"DataFlash[0x04000..0x07fff] verify error: Size too big");
    }    

    testComment (&testRec, "Reading DataFlash[0x08000..0x0bfff] and verifying");

	ReturnSize = read(SerialDataFlashHandle, ReadBuf, TST_READ_SIZE );
	
	if ( ReturnSize == 0 )
	{
	    testFailed(&testRec,"DataFlash[0x08000..0x0bfff] verify error: Return size = 0");
    }    

	if ( ReturnSize != TST_READ_SIZE )
	{
	    testFailed(&testRec,"DataFlash[0x08000..0x0bfff] verify error: Size too big");
    }    

    testComment (&testRec, "Reading DataFlash[0x0c000..0x0ffff] and verifying");

	ReturnSize = read(SerialDataFlashHandle, ReadBuf, TST_READ_SIZE );
	
	if ( ReturnSize == 0 )
	{
	    testFailed(&testRec,"DataFlash[0x0c000..0x0ffff] verify error: Return size = 0");
    }    

	if ( ReturnSize != TST_READ_SIZE )
	{
	    testFailed(&testRec,"DataFlash[0x0c000..0x0ffff] verify error: Size too big");
    }    

    testComment (&testRec, "Reading DataFlash[0x10000..0x107ff] and verifying");

	ReturnSize = read(SerialDataFlashHandle, ReadBuf, TST_READ_SIZE );

	if ( ReturnSize == 0 )
	{
	    testFailed(&testRec,"DataFlash[0x10000..0x107ff] verify error: Return size = 0");
    }    

	if ( ReturnSize != TST_READ_SIZE )
	{
	    testFailed(&testRec,"DataFlash[0x10000..0x107ff] verify error: Size too big");
    }    

	/*********************************************************************/
	/**** FILL THE SERIAL DATAFLASH WITH TEST DATA STARTING AT      ******/
	/**** ADDRESS 0x0312 AND DO NOT VERIFY THE WRITE                ******/
	/*********************************************************************/
	
	
	SerialDataFlashAddress = 0x0312; 	
	ioctl(SerialDataFlashHandle, SERIAL_DATAFLASH_SEEK, &SerialDataFlashAddress );

	testComment (&testRec, "Filling DataFlash[0x00312..0x00411] with data");

	ReturnSize = write(SerialDataFlashHandle, WriteBuf1, TST_WRITE_SIZE );
	
	/*********************************************************************/
	/**** FILL THE SERIAL DATAFLASH WITH TEST DATA STARTING AT      ******/
	/**** ADDRESS 0x0412 AND VERIFY THE WRITE                       ******/
	/*********************************************************************/
		
	VerifyMode 		= true;
	ioctl(SerialDataFlashHandle, SERIAL_DATAFLASH_MODE_VERIFY, &VerifyMode );

	/* Write second buffer after first one */
	/* Check verification results */
	
	testComment (&testRec, "Filling DataFlash[0x00412..0x00511] with data and verifying");

	ReturnSize = write(SerialDataFlashHandle, WriteBuf2, TST_WRITE_SIZE );
	
	if ( ReturnSize == 0 )
	{
	    testFailed(&testRec,"DataFlash[0x00412..0x00511] verify error: Return size = 0");
    }    

	if ( ReturnSize != TST_WRITE_SIZE )
	{
	    testFailed(&testRec,"DataFlash[0x00412..0x00511] verify error: Size too big");
    }    

	/* INITIALIZE THE READ BUFFER TO A VALUE THAT IS DIFFERENT THAN WHAT */
    /* IS STORED IN THE SERIAL DATAFLASH */
    
	for (i = 0;i < TST_READ_SIZE; i++)
    {
        ReadBuf [ i ] = 0x1234;
    }
    
	/*********************************************************************/
	/** READ, BUT DO NOT VERIFY THE ENTIRE SERIAL DATAFLASH IS ***********/
	/** FILLED WITH 0x1234                                     ***********/
	/*********************************************************************/	

	SerialDataFlashAddress 	= 0x0000; 	
	VerifyMode 		= false;
	ioctl(SerialDataFlashHandle, SERIAL_DATAFLASH_SEEK, &SerialDataFlashAddress );
	ioctl(SerialDataFlashHandle, SERIAL_DATAFLASH_MODE_VERIFY, &VerifyMode );

    testComment (&testRec, "Reading DataFlash[0x00000..0x03fff] and not verifying");

	ReturnSize = read(SerialDataFlashHandle, ReadBuf, TST_READ_SIZE );
	
    testComment (&testRec, "Reading DataFlash[0x04000..0x07fff] and not verifying");

	ReturnSize = read(SerialDataFlashHandle, ReadBuf, TST_READ_SIZE );

    testComment (&testRec, "Reading DataFlash[0x08000..0x0bfff] and not verifying");

	ReturnSize = read(SerialDataFlashHandle, ReadBuf, TST_READ_SIZE );
	
    testComment (&testRec, "Reading DataFlash[0x0c000..0x0ffff] and not verifying");

	ReturnSize = read(SerialDataFlashHandle, ReadBuf, TST_READ_SIZE );
	
    testComment (&testRec, "Reading DataFlash[0x10000..0x107ff] and not verifying");

	ReturnSize = read(SerialDataFlashHandle, ReadBuf, TST_READ_SIZE );

	/*********************************************************************/
	/***** READ AND VERIFY THE SERIAL DATAFLASH STARTING AT        *******/
	/***** ADDRESS 0x0312                                          *******/
	/*********************************************************************/

	SerialDataFlashAddress 	= 0x0312; 
	VerifyMode 		= true;
	ioctl(SerialDataFlashHandle, SERIAL_DATAFLASH_SEEK, &SerialDataFlashAddress );
	ioctl(SerialDataFlashHandle, SERIAL_DATAFLASH_MODE_VERIFY, &VerifyMode );

	testComment (&testRec, "Reading DataFlash[0x00312..0x00411] and verifying");

	ReturnSize = read(SerialDataFlashHandle, WriteBuf1, TST_WRITE_SIZE );
	
	if ( ReturnSize == 0 )
	{
	    testFailed(&testRec,"DataFlash[0x00312..0x00411] verify error: Return size = 0");
    }    

	if ( ReturnSize != TST_WRITE_SIZE )
	{
	    testFailed(&testRec,"DataFlash[0x00312..0x00411] verify error: Size too big");
    }    

	/*********************************************************************/
	/***** READ AND VERIFY THE SERIAL DATAFLASH STARTING AT        *******/
	/***** ADDRESS 0x0412                                          *******/
	/*********************************************************************/

	
	testComment (&testRec, "Reading DataFlash[0x00412..0x00511] and verifying");

	ReturnSize = read(SerialDataFlashHandle, WriteBuf2, TST_WRITE_SIZE );
	
	if ( ReturnSize == 0 )
	{
	    testFailed(&testRec,"DataFlash[0x00412..0x00511] verify error: Return size = 0");
    }    

	if ( ReturnSize != TST_WRITE_SIZE )
	{
	    testFailed(&testRec,"DataFlash[0x00412..0x00511] verify error: Size too big");
    }    
 
    testEnd(&testRec);
}
