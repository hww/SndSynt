/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name: g165_speech.c
*
* Description: File I/O based demo for G.165 echo canceller
*
* Modules Included:
*                   main ()
*                   Callback ()
*
* Author: Sandeep S
*
* Date: 10 July 2000
*
*****************************************************************************/

#include "mem.h"
#include "assert.h"
#include "fileio.h"
#include "ascii2hex.c"
#include "test.h"

/* G165 specific include files */
#include "g165.h"

#define G165_OUT_BUF_LENGTH 320

Int16 File_wr_buffer[G165_OUT_BUF_LENGTH*6];

void Callback (void *pCallbackArg, Int16 * pSamples, UInt16 NumSamples);

int Fd_input;
int Fd_output;


/*****************************************************************************
*
* Module: main()
*
* Description: - File I/O demo
*              - Input files in "inputs" directory
*              - Output files in "outputs" directory
*              - Input file is interlaced with Reference speech
*                and Sin signal (near end speech + echo of far end 
*                speech) "speech.in". Echo is generated from Ref. speech.
*                The interlaced file only serves as the input file to MW
*                and cannot be played. 
*              - Outputs are stored in a file "ec_cancel.out" in 
*                the form of hexadecimal 16 bit samples
*              - File "rin.au" (Ref. speech), "sin.au" (near end speech + 
*                echo of far end speech).
*                These files can be played by Windwos media player / Real 
*                player. Output samples from the file "ec_cancel.out" 
*                can be onverted to .au format, by using the utility 
*                conv2au.exe in \src\x86\win32\applications\auspeech.
*                Then play the converted "filename".au file in Windows media
*                player / Real audio player
*              - The output speech file should have speech without echo, i.e
*                none of the conversations in rin.au.
*
* DEMO STEPS : 1) Play "rin.au" (Far end speech , ref. speech)
*              2) Play "sin.au" (near end speech + echo of far end speech)
*                 You will hear speech and echo of far end speaker.
*              3) Run G.165 EC on Metrowerks to get output file 
*                 "ec_cancel.out".
*              4) Convert this output file to "ec_cancel.au" 
*                 by using the
*                 conversion utility \src\x86\win32\applications\auspeech\
*                 conv2au.exe
*              5) Play this speech file in Windows Media Player/ Real 
*                 audio player, to hear echo cancelled speech.
*
*
* Returns: None
*
* Arguments: None
*
* Range Issues: None
*
* Special Issues: None
*
* Test Method: Tested through demo_g165.mcp
*
***************************** Change History ********************************
*
* VERSION    CREATED BY          DATE           COMMENTS  
* -------    ----------          -----          --------
*   0.1      Sandeep Sehgal      10-07-2000     For review.
*   1.0           -              12-07-2000     Reviewed and
*                                               baselined
* 
*****************************************************************************/

void main()
{
    g165_sConfigure * pConfig;
    g165_sHandle * pG165;
    Result res;
    test_sRec      testRec;    
    Int16 k, wrds, cmp_loop;
    static Int16 RinBuffer[320], SinBuffer[320];
    Int16 loopcnt;
    static Int16 Temp_Buffer[640*6];
    UInt16 BufSz = 640;  
        
    testStart (&testRec, "Testing G165 EchoCanceller : ");    
            
    pConfig = (g165_sConfigure *) memMallocEM(sizeof (g165_sConfigure));
    if (pConfig == NULL) assert(!"Cannot allocate memory for pConfig");
                       
    pConfig->Flags= 0;
    pConfig->EchoSpan = 320;
    pConfig->callback.pCallback = Callback;
    pConfig->callback.pCallbackArg = NULL;
    
    pG165 = g165Create(pConfig);
    if (pG165 == NULL) assert(!"Cannot allocate memory for pG165");
    
    testComment (&testRec, "Instance of G165 created");
    
    res = g165Init(pG165, pConfig);
    
    if (res == FAIL) assert(!"EchoSpan outside valid  range");
    
    testComment (&testRec, "G165 Init passed ");
         
    Fd_input = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\applications\\telephony\\g165\\inputs\\speech.in", O_RDONLY);
    if (Fd_input == NULL) assert(!"Cannot open file");
    
    Fd_output = open("\\\\PC\\Embedded SDK\\src\\dsp56826evm\\nos\\applications\\telephony\\g165\\outputs\\ec_cancel.out", O_WRONLY);
    if (Fd_output == NULL) assert(!"Cannot open file");
    
    k=0;
    
    testComment (&testRec, "Reading from input speech file of 224692 samples");
    testComment (&testRec,"Processing 320 Samples per loop");
    
    for (k = 0; k < 702; k++)
    {
        wrds = read(Fd_input, Temp_Buffer, BufSz*6); 
        Ascii2hex(Temp_Buffer, BufSz*6);
        for ( loopcnt = 0; loopcnt < 320; loopcnt++)
        {
            RinBuffer[loopcnt] = Temp_Buffer[2*loopcnt];
            SinBuffer[loopcnt] = Temp_Buffer[2*loopcnt + 1];
        }    
        
        res = g165Process(pG165, RinBuffer, SinBuffer, 320);
        printf ("Processed  Loop %d \n", (k+1));

    }    
    
    wrds = read(Fd_input, Temp_Buffer, 104*6); 
    Ascii2hex(Temp_Buffer, 104*6);
    for ( loopcnt = 0; loopcnt < 52; loopcnt++)
    {
        RinBuffer[loopcnt] = Temp_Buffer[2*loopcnt];
        SinBuffer[loopcnt] = Temp_Buffer[2*loopcnt + 1];
    }    
     
    
    res = g165Process(pG165, RinBuffer, SinBuffer, 52);

    g165Control (pG165, G165_DEACTIVATE);
          
    
    testComment (&testRec, "Speech file processed");

    testComment(&testRec,"Output file ec_cancel.out created ");
    
    close (Fd_input);
    close (Fd_output);
    
    g165Destroy(pG165);
    memFreeEM(pConfig);

    return;
}

    
/*****************************************************************************
*
* Module: Callback ()
*
* Description: To store the echo cancelled output speech data
*              in a file 
*
* Returns: None
*
* Arguments: pCallbackArg  - supplied by the user in the g165_sCallback
*                            structure. This value is passed back to the user 
*                            during the call to the callback procedure.
*                            User has to write his/her own callback function
*                 pSamples - Pointer to the echo cancelled samples buffer
*                 NumSamples - Number of samples in the buffer.
*
* Range Issues: None
*
* Special Issues: None
*
* Test Method: Tested through demo_g165.mcp
*
***************************** Change History ********************************
*
* VERSION    CREATED BY          DATE           COMMENTS  
* -------    ----------          -----          --------
*   0.1      Sandeep Sehgal      10-07-2000     For review.
*   1.0           -              12-07-2000     Reviewed and
*                                               baselined
* 
*****************************************************************************/

void Callback ( void *pCallbackArg, Int16 *pSamples, UInt16 NumSamples)
{

      Hex2ascii ( pSamples, NumSamples, File_wr_buffer);
      write(Fd_output, File_wr_buffer, NumSamples*6);

     
    return;
}                