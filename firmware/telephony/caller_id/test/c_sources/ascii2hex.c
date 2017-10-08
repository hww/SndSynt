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
*              Caller ID algorithm whereas the file I/O driver in the
*              SDK reads the data in ascii format. This module is an
*              interface betwen the File I/O driver and the algorithm.
*
* Modules Included:
*                   Ascii2hex ()
*
* Author : Sandeep Sehgal
*
* Date   : 12 July 2000
*
*****************************************************************************/

#include "stdio.h"
#include "port.h"

Ascii2hex(UInt16 *pBuf, UInt16 Buffer_size);

Ascii2hex(UInt16 *pBuf,UInt16 Buffer_size)
{
    UInt16 Temp_val, count, *buf_tmp_ptr, pack1;
    Int16 pack = 0;
    
    buf_tmp_ptr = pBuf;
    
    for (count=0; count < Buffer_size; count++)
    {
    
        Temp_val = *pBuf++;
        
        if (Temp_val == 13) 
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
          
          pack = (pack << 4) | pack1;
    }
    
    return;
}    