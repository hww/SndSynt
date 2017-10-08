/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name: testg711.c
*
* Description: test PCM Encoding A-law and U-law  and PCM Decoding
*
* Modules Included:
*                   main () -  C function
*
* Author: Sandeep S
*
* Date: 02 Aug 2000
*
*****************************************************************************/

#include "g711.h"
#include "assert.h"
#include "fcntl.h"
#include "fileio.h"
#include "test.h"
#include "ascii2hex.c"

/*****************************************************************************
*
* Module: main()
*
* Description: test PCM Encoding A-law and U-law  and PCM Decoding
*
* Returns: None
*
* Arguments: None
*
* Range Issues: None
*
* Special Issues: None
*
* Test Method: tested through demo_g711.mcp
*
***************************** Change History ********************************
* 
*    DD/MM/YYYY     Code Ver     Description      Author
*    ----------     --------     -----------      ------
*    02-08-2000     0.1          Created          Sandeep Sehgal
*    05-08-2000     1.0          Baselined        Sandeep Sehgal
*
*****************************************************************************/

void main()
{
    static Int16 Input_Sample[8192], i;
    static short Linear_Buf[256];
    static unsigned char Enc_Buf[8192];
    static Int16 Temp_buf[600];
    Int16 k;
    test_sRec testRec;
    int Fd_input;
    
    testStart (&testRec, "Testing PCM Encoding");

   /* Linear Input values for PCM Encoding*/
    for (i = 0; i < 8192; i++)
    {
        Input_Sample[i] = -32768 + i*8;
    }
        
    /* Linear to A-law Conversion */
    
    Fd_input = open ("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\g711\\test_g711\\ref_outputs\\lin2alaw.ref", O_RDONLY);
    if (Fd_input == NULL) assert(!"Cannot open file");
    
    
    g711_linear2alaw(Input_Sample, Enc_Buf,8192);
    
    /*Compare with reference output*/
    for ( i = 0; i < 8192; i+=128)
    {  
        read(Fd_input, Temp_buf, 4*128);
        Ascii2hex (Temp_buf, 4*128);
        for (k = 0; k < 128; k++)
        {   
            if (Enc_Buf[i+k] != Temp_buf[k])
            {
                testFailed (&testRec, "Test failed");
                assert (!"Test Failed");
            }
        }      
    }  
    
    
    close (Fd_input);
    
    testComment(&testRec, "Linear to A-law Test passed");
  
  
    /* Linear to Mu-law Conversion */

    Fd_input = open ("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\g711\\test_g711\\ref_outputs\\lin2ulaw.ref", O_RDONLY);
    if (Fd_input == NULL) assert(!"Cannot open file");

   /* Linear Input values for PCM Encoding*/
    for (i = 0; i < 8192; i++)
    {
        Input_Sample[i] = i*8;    
    }

    g711_linear2ulaw(Input_Sample, Enc_Buf,8192);
    
    /*Compare with reference output*/
    for ( i = 0; i < 8192; i+=128)
    {          
        read(Fd_input, Temp_buf,4*128);
        Ascii2hex (Temp_buf, 4*128);
        for (k = 0; k < 128; k++)
        {
            if (Enc_Buf[i+k] != Temp_buf[k])
            {
                testFailed(&testRec, "Test failed");
                assert (!"Test Failed");
            }  
        }              
        
    }
    
    close (Fd_input);
    
    testComment(&testRec, "Linear to U-law Test passed");
    
    
    /* U - A - U  Conversion */
    
    g711_ulaw2alaw(Enc_Buf,Input_Sample,8192);
    g711_alaw2ulaw(Input_Sample,Input_Sample,8192);

    /*Compare with reference output*/ 
    for ( i = 0; i < 8192; i++)
    {  
        if (abs((Input_Sample[i] - Enc_Buf[i])) > 1)
        {
            testFailed (&testRec, "Test failed");
            assert (!"Test Failed");
        }
     
    }  

    testComment(&testRec, "U-law to A-law to U-law Test passed");
    
    /* A-law to U-law to A-law conversion */        
    g711_alaw2ulaw(Enc_Buf, Input_Sample,8192);
    g711_ulaw2alaw(Input_Sample, Input_Sample,8192);
        
    /*Compare with reference output*/        
    for ( i = 0; i < 8192; i++)
    {  
        if (abs((Input_Sample[i] - Enc_Buf[i])) > 1)
        {
            testFailed (&testRec, "Test failed");
            assert (!"Test Failed");
        }
     
    }  

    testComment(&testRec, "A-law to U-law to A-law Test passed");
   
    /* PCM Encoded input for PCM Decoding*/
    for (i = 0; i < 256; i++)
        Input_Sample[i] = i;
    
    
    /* A-law to Linear Conversion */
    
    Fd_input = open ("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\g711\\test_g711\\ref_outputs\\alaw2lin.ref", O_RDONLY);
    if (Fd_input == NULL) assert(!"Cannot open file");
    
 
    g711_alaw2linear (Input_Sample, Linear_Buf, 256);
    
    /*Compare with reference output*/
    for (i = 0; i < 256; i++)
    {
        read(Fd_input, Temp_buf, 6);
        Ascii2hex (Temp_buf,6);
        if (Linear_Buf[i] != Temp_buf[0])
        {
            testFailed(&testRec, "Test failed");
            assert (!"Test Failed");
        }    
    }
    
    close (Fd_input);
    
    testComment(&testRec, "A-law to Linear Test passed");
    
    /* Mu-law to Linear Conversion */
    
    Fd_input = open ("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\telephony\\g711\\test_g711\\ref_outputs\\ulaw2lin.ref", O_RDONLY);
    if (Fd_input == NULL) assert(!"Cannot open file");
    
    g711_ulaw2linear (Input_Sample, Linear_Buf, 256);

    /*Compare with reference output*/
    for (i = 0; i < 256; i++)
    {        
        read(Fd_input, Temp_buf, 6);
        Ascii2hex (Temp_buf,6);
        if (Linear_Buf[i] != Temp_buf[0])
        {
            testFailed(&testRec, "Test failed");
            assert (!"Test Failed");
        }            
    }
  
    close (Fd_input);
    
    testComment (&testRec, "U-Law to Linear Test Passed");    
    
    testEnd(&testRec);
}