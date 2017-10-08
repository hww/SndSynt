/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name: ascii2hex.c
*
* Description: This module converts the samples from ascii format into
*              the hex format. The hex format is needed by the 
*              G.165 algorithm whereas the file I/O driver in the
*              SDK reads the data in ascii format. This module is an
*              interface betwen the File I/O driver and the algorithm. Also
*              the function Hex2ascii converts the hex data into ascii for
*              writing it back into the file on the host memory.
*
* Modules Included:
*                   Ascii2hex ()
*                   Hex2ascii ()
*
* Author : Sandeep Sehgal
*
* Date   : 12 July 2000
*
*****************************************************************************/

#include "stdio.h"
#include "port.h"


/*****************************************************************************
*
* Module: Ascii2hex()
*
* Description: Converts Ascii data in the buffer, filled up by file read,
*              into a hex data.
*
* Returns: None
*
* Arguments: pBuf -> Ascii buffer pointer
*            Buffer_size -> Buffer size to be processed
*
* Range Issues: None
*
* Special Issues: Overwrites the buffer with the hexadecimal values, between
*                 the enter keys (0x0d and 0x0A)
*
*                 Enter key should be pressed after the last line in the file
*                 so that the last word is recorded in the output buffer.
*
* Test Method:    tested through demo_g165.mcp
*
***************************** Change History ********************************
* 
*    DD/MM/YYYY     Code Ver     Description      Author
*    ----------     --------     -----------      ------
*    12-07-2000     0.1          Created          Sandeep S
*
*****************************************************************************/

Ascii2hex(Int16 *pBuf, UInt16 Buffer_size);

Ascii2hex(Int16 *pBuf,UInt16 Buffer_size)
{
    Int16 Temp_val, count, *buf_tmp_ptr, pack1;
    Int16 pack = 0;
    
    buf_tmp_ptr = pBuf;
    
    for (count=0; count < Buffer_size; count++)
    {
    
        Temp_val = *pBuf++;
        
        if (Temp_val == 13) /*Lookfor ascii representation
                                for enter key character*/
        {
            *buf_tmp_ptr = pack;
            buf_tmp_ptr++;
            pack = 0;
            continue;
        }
            
        switch (Temp_val)
        {
            
            case 48: pack1 = 0x0;
                     break;
            case 49: pack1 = 0x1;
                     break;
            case 50: pack1 = 0x2;
                     break;
            case 51: pack1 = 0x3;
                     break;
            case 52: pack1 = 0x4;
                     break;
            case 53: pack1 = 0x5;
                     break;
            case 54: pack1 = 0x6;
                     break;
            case 55: pack1 = 0x7;
                     break;
            case 56: pack1 = 0x8;
                     break;
            case 57: pack1 = 0x9;
                     break;
            case 65: pack1 = 0xA;
                     break;
            case 66: pack1 = 0xB;
                     break;
            case 67: pack1 = 0xC;
                     break;
            case 68: pack1 = 0xD;
                     break;
            case 69: pack1 = 0xE;
                     break;
            case 70: pack1 = 0xF;
                     break;
            case 97: pack1 = 0xa;
                     break;
            case 98: pack1 = 0xb;
                     break;
            case 99: pack1 = 0xc;
                     break;
            case 100: pack1 = 0xd;
                      break;
            case 101: pack1 = 0xe;
                      break;
            case 102: pack1 = 0xf;
                      break;
            case 10: pack1=0;
                     pack=0;
                     break;
            default: break;
          }
          /* pack the nibbles into a word/byte*/
          pack = (pack << 4) | pack1;
    }
    
    return;
}  


/*****************************************************************************
*
* Module: Hex2ascii()
*
* Description: Converts hex data in the buffer, to filled up in file write,
*              into a ascii data.
*
* Returns: None
*
* Arguments: pBuf -> Hex buffer pointer
*            Buffer_size -> Buffer size to be processed
*
* Range Issues: None
*
* Special Issues: The output buffer should be 6 times the size of the input
*                 buffer
*
*                 This function should be called before doing file writes.
*
* Test Method:    tested through demo_g165.mcp
*
***************************** Change History ********************************
* 
*    DD/MM/YYYY     Code Ver     Description      Author
*    ----------     --------     -----------      ------
*    12-07-2000     0.1          Created          Sandeep S
*
*****************************************************************************/

void Hex2ascii(Int16 *pBuf, UInt16 Buffer_size, Int16 *outBuf);

void Hex2ascii(Int16 *pBuf,UInt16 Buffer_size, Int16 *outBuf )
{
    UInt16 Temp_val, count, shift_count=12;
    UInt16 unpack1, temp_var;
    Int16 unpack = 0, nibble_count, out_data;
        
    for (count=0; count < Buffer_size; count++)
    {
    
        Temp_val = *pBuf++;
        unpack1 = 0xF;
        
        for (nibble_count = 0; nibble_count < 4; nibble_count++)
        {
            /* Break the word/byte into nibbles*/
            temp_var = unpack1 & (Temp_val >> shift_count);
            shift_count-=4;
                        
            switch (temp_var)
            {
            
                case 0: out_data = 48;
                        break;
                case 1: out_data = 49;
                        break;
                case 2: out_data = 50;
                        break;
                case 3: out_data = 51;
                        break;
                case 4: out_data = 52;
                        break;
                case 5: out_data = 53;
                        break;
                case 6: out_data = 54;
                        break;
                case 7: out_data = 55;
                        break;
                case 8: out_data = 56;
                        break;
                case 9: out_data = 57;
                        break;
                case 10: out_data = 65;
                         break;
                case 11: out_data = 66;
                         break;
                case 12: out_data = 67;
                         break;
                case 13: out_data = 68;
                         break;
                case 14: out_data = 69;
                         break;
                case 15: out_data = 70;
                         break;
                default: break;
            }
            
            *outBuf = out_data;/*store nibbles in the output buffer*/
            outBuf++;
        }
        
        *outBuf = 0x0D;/*Ascii representation for enter key chars.*/
        outBuf++;
        *outBuf = 0x0A;
        outBuf++;
    }
    
    return;
}  