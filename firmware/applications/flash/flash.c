/*******************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
********************************************************************************
*
* FILE NAME: flash.c
*
*******************************************************************************/

#include "stdio.h"
#include "io.h"
#include "fcntl.h"
#include "bsp.h"

#include "flash.h"


#define DATA_LENGTH     1024

static UWord16 DataBuffer1[DATA_LENGTH];
static UWord16 DataBuffer2[DATA_LENGTH];

/*******************************************************************************
* 
* The application write first buffer (DataBuffer1) to flash data memory
* and read data from flash to second buffer (DataBuffer2).
*
*******************************************************************************/

void main(void)
{
   UWord16  I;
   UWord16  Address;
   int      FlashHandle;
   bool     Passed   = true;

   printf("Flash application started.\n");

   for (I = 0; I < DATA_LENGTH; I++)
   {
      DataBuffer1[I] = 0x8000 | I;
      DataBuffer2[I] = 0xABCD;
   }

   FlashHandle = open(BSP_DEVICE_NAME_FLASH_X, 0, NULL );

   if ( FlashHandle == -1 )
   {
      printf("Open BSP_DEVICE_NAME_FLASH_X device failed.\n");
      return;
   }

   write(FlashHandle, DataBuffer1, DATA_LENGTH );

   Address = 0x0000;

   ioctl(FlashHandle, FLASH_CMD_SEEK, &Address);

   read(FlashHandle, DataBuffer2, DATA_LENGTH );

   for ( I = 0; I < DATA_LENGTH; I++)
   {
      if (DataBuffer1[ I ] != DataBuffer2[ I ])
      {
         printf("Incorrect flash data, I = %d .\n", I);
         Passed = false;
      }
   }
   
   close(FlashHandle);

   if (Passed)
   {
      printf("Flash application successfully finished. \n");
   }

}



