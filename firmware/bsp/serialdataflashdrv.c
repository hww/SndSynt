/*******************************************************************************
*
* Motorola Inc.
* (c) Copyright 2001 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
********************************************************************************
*
* FILE NAME:   serialdataflashdrv.c
*
* DESCRIPTION: source file for the Atmel AT45DB321 SPI Bus Serial DataFlash
*
*******************************************************************************/

#include "port.h"
#include "arch.h"
#include "io.h"
#include "fcntl.h"

#include "stdlib.h"
#include "string.h"
#include "stdarg.h"

#include "bsp.h"
#include "spi.h"
#include "gpio.h"
#include "serialdataflash.h"
#include "serialdataflashdrv.h"

#define HANDLE_0 0

/* Atmel AT45DB321 flags and defined */
#define AT45DB321_PAGE_SIZE                           528
#define AT45DB321_DATA_BUFFER_LEN                     (8 + AT45DB321_PAGE_SIZE)
#define AT45DB321_MAX_ADDRESS                         0x0041ffffu

/* Atmel AT45DB321 Instruction set */
#define AT45DB321_BLOCK_ERASE                         0x50u
#define AT45DB321_MAIN_MEM_PAGE_READ                  0x52u
#define AT45DB321_MAIN_MEM_PAGE_TO_BUFF_TRANSFER      0x53u
#define AT45DB321_BUFF_READ                           0x54u
#define AT45DB321_STATUS_REGISTER                     0x57u
#define AT45DB321_AUTO_PAGE_REWRITE                   0x58u
#define AT45DB321_MAIN_MEM_PAGE_TO_BUFF_COMPARE       0x60u
#define AT45DB321_PAGE_ERASE                          0x81u
#define AT45DB321_MAIN_MEM_PAGE_PRGM                  0x82u
#define AT45DB321_BUFF_TO_MAIN_MEM_PAGE_PRGM_W_ERASE  0x83u
#define AT45DB321_BUFF_WRITE                          0x84u
#define AT45DB321_BUFF_TO_MAIN_MEM_PAGE_PRGM_WO_ERASE 0x88u

/* Atmel AT45DB321 status register flags */
#define AT45DB321_BUSY_FLAG         0x80u



static io_sInterface InterfaceVT = {
   serialdataflashClose,
   serialdataflashRead,
   serialdataflashWrite,
   serialdataflashIoctl,
};

typedef struct
{
   bool        bInitialized;
   bool        bBlocking;
   int         Spi;
   UWord16     State;
   UWord32     Address;
   bool        bVerify;
   UWord16     Buffer[AT45DB321_DATA_BUFFER_LEN];
} sSerialDataFlash;

static sSerialDataFlash SerialDataFlash[1];

io_sDriver serialdataflashdrvDevice = { &InterfaceVT, (int)&SerialDataFlash[0] };

#define SPIMX0   gpioPin(F,0)
#define SPIMX1   gpioPin(F,1)
#define SPI_SS   gpioPin(F,7)

/*******************************************************************************
*
* NAME: serialdataflashOpen()
*
* PURPOSE: Open and initialize a serial DataFlash device.
*
* DESCRIPTION: This function opens the desired serial DataFlash device.
*              This device uses SPI1 to interface to the serial DataFlash.
*
********************************************************************************
* PARAMETERS:	pName - Name of device
*               OFlags - Information used for configuring the device
*
* RETURN:		Serial DataFlash device descriptor if open is successful.
*               -1 value if open failed.
*
* SIDE EFFECTS:   This function assumes the parameters passed in are
*                 initialized.  Unexpected behavior will result if they
*                 are not initialized.
*
* DESIGNER NOTES: 
*
* DEPENDENCIES: serialdataflashDevCreate() must be called first
*******************************************************************************/

io_sDriver * serialdataflashOpen(const char * pName, int OFlags, ...)
{
   sSerialDataFlash * pSerialDataFlash;

   if(pName == BSP_DEVICE_NAME_SERIAL_DATAFLASH_0)
   {
      UWord16 InitData;
      spi_sParams SpiParams;
	  SpiParams.pSlaveSelect     = NULL;
	  SpiParams.pSlaveDeselect   = NULL;
	  SpiParams.TransmissionSize = 0x0007; /* This is one less than the actual size */
      SpiParams.bSetAsMaster = 1;          /* This will set SPI1 as a master */

      gpioIoctl((int)BSP_DEVICE_NAME_GPIO_F, GPIO_SETAS_GPIO, SPI_SS | SPIMX0 | SPIMX1,
                     BSP_DEVICE_NAME_GPIO_F);
      gpioIoctl((int)BSP_DEVICE_NAME_GPIO_F, GPIO_SETAS_OUTPUT, SPI_SS | SPIMX0 | SPIMX1,
                     BSP_DEVICE_NAME_GPIO_F); 

      SerialDataFlash[HANDLE_0].Spi = open(BSP_DEVICE_NAME_SPI_1, 0, &SpiParams);

      ioctl(SerialDataFlash[HANDLE_0].Spi, SPI_DATAFORMAT_EIGHTBITCHARS, NULL);
      ioctl(SerialDataFlash[HANDLE_0].Spi, SPI_CLK_POL_RISING_EDGE, NULL);
      ioctl(SerialDataFlash[HANDLE_0].Spi, SPI_CLOCK_PHASE_SET, NULL);
	  ioctl(SerialDataFlash[HANDLE_0].Spi, SPI_BAUDRATE_DIVIDER_2, NULL);

      SerialDataFlash[HANDLE_0].Buffer[0] = AT45DB321_STATUS_REGISTER;
      SerialDataFlash[HANDLE_0].Buffer[1] = 0x00ff;

      /* READ STATUS FROM THE SERIAL DATAFLASH */
      
      write(SerialDataFlash[HANDLE_0].Spi, &(SerialDataFlash[HANDLE_0].Buffer), 1 );    

      /* READ STATUS FROM THE SPI */
      
      read(SerialDataFlash[HANDLE_0].Spi, &(SerialDataFlash[HANDLE_0].State), 1);       
   
      SerialDataFlash[HANDLE_0].bInitialized      = true;
      SerialDataFlash[HANDLE_0].Address           = 0x0000;
      SerialDataFlash[HANDLE_0].bVerify           = false;
      
      pSerialDataFlash = &(SerialDataFlash[HANDLE_0]);
   }
   else
   {
      return (io_sDriver *) -1;
   }

   if((UWord16)OFlags & O_NONBLOCK)
   {
      pSerialDataFlash -> bBlocking = false;
   }
   else
   {
      pSerialDataFlash -> bBlocking = true;
   }

   return &serialdataflashdrvDevice;
}

/*******************************************************************************
*
* NAME: serialdataflashClose()
*
* PURPOSE: Close the serial DataFlash device.
*
* DESCRIPTION: This function does nothing.
*
********************************************************************************
* PARAMETERS:	pHandle - Handle assigned to the serial DataFlash device
*
* RETURN:		0
*
* SIDE EFFECTS:   
*
* DESIGNER NOTES:   
*
* DEPENDENCIES: serialdataflashOpen must be called first
*******************************************************************************/

int serialdataflashClose(int FileDesc)
{
   return 0;
}

/*******************************************************************************
*
* NAME: serialdataflashRead()
*
* PURPOSE: Read from the serial DataFlash device.
*
* DESCRIPTION: This function reads data from the serial DataFlash via
*              the SPI1 device.
*              
*
********************************************************************************
* PARAMETERS:	pHandle - Handle assigned to the serial DataFlash device
*               pBuffer - Array to store the received bytes in
*               Size - Requested number of samples to read
*
* RETURN:		Number of bytes read
*
* SIDE EFFECTS:   
*
* DESIGNER NOTES:   
*
* DEPENDENCIES: serialdataflashOpen must be called first
*******************************************************************************/

ssize_t serialdataflashRead(int FileDesc, void * pBuffer, size_t Size)
{
    UWord16   TmpWord;
    UWord16   DataWord;
    UWord16   ByteSizeCounter; 
    bool      bContinue       = true;
    UWord16   i;
    UWord16 * pUserData   = (UWord16 *) pBuffer;
    sSerialDataFlash * pSerialDataFlash      = (sSerialDataFlash *) FileDesc;
    UWord16   ByteSize    = Size << 1;
    UWord32   SaveAddress = pSerialDataFlash->Address;
    UWord32   RunningAddress  = 0;
    UWord16   PageAddress     = 0;
    UWord16   PageNumber      = 0;
    UWord16   BytesInCurrentPage = 0;

   /* PROTECT FROM OVERWRITING */
   
   if ((UWord32)( ByteSize + pSerialDataFlash->Address ) > (UWord32)( AT45DB321_MAX_ADDRESS + 1 ))
   {
      ByteSize = ( AT45DB321_MAX_ADDRESS + 1 ) - pSerialDataFlash->Address;
   }
         
   while(RunningAddress <= pSerialDataFlash->Address)
   {
       RunningAddress += AT45DB321_PAGE_SIZE;
       PageNumber++;
   }
         
   PageNumber--;
   RunningAddress -= AT45DB321_PAGE_SIZE;
   PageAddress = (UWord16) (pSerialDataFlash->Address - RunningAddress);
   
   if ( ByteSize != 0 )
   {

      ByteSizeCounter = ByteSize;

      /* READ SERIAL DATAFLASH PAGE BY PAGE */
      
      while (bContinue)
      {
          /* DETERMINE NUMBER OF BYTES THAT CAN BE WRITTEN TO THE CURRENT PAGE */
          
          BytesInCurrentPage = AT45DB321_PAGE_SIZE - PageAddress;
                  
          if ( BytesInCurrentPage >= ByteSizeCounter)
          {
              BytesInCurrentPage = ByteSizeCounter;
              bContinue   = false;
          }
          else
          {
              ByteSizeCounter -= BytesInCurrentPage;
          }

          for (i = 0; i < BytesInCurrentPage; i+=2, pUserData++ )
          {
              /* READ SERIAL DATAFLASH PAGE BY PAGE  */
   
              pSerialDataFlash->Buffer[0] = AT45DB321_MAIN_MEM_PAGE_READ;
              pSerialDataFlash->Buffer[1] = (PageNumber >> 6) & 0x0007f;
              pSerialDataFlash->Buffer[2] = ((PageNumber << 2) | (PageAddress >> 8)) & 0x00ff;
              pSerialDataFlash->Buffer[3] = PageAddress & 0x00ff;
              pSerialDataFlash->Buffer[4] = 0xff;
              pSerialDataFlash->Buffer[5] = 0xff;
              pSerialDataFlash->Buffer[6] = 0xff;
              pSerialDataFlash->Buffer[7] = 0xff;
              pSerialDataFlash->Buffer[8] = 0xff;
              
              /* READ HIGH DATA BYTE FROM DATAFLASH */
              
              write(pSerialDataFlash->Spi, &(pSerialDataFlash->Buffer), 9 );
                
              /* READ HIGH DATA BYTE FROM SPI */
              
              read(pSerialDataFlash->Spi, &(DataWord), 1 );

              DataWord = ( DataWord << 8 ) & 0xff00;
       
              PageAddress++;
        
              pSerialDataFlash->Buffer[3] = PageAddress & 0x00ff;

              /* READ LOW DATA BYTE FROM DATAFLASH */

              write(pSerialDataFlash->Spi, &(pSerialDataFlash->Buffer), 9 );
            
              /* READ LOW DATA BYTE FROM SPI */

              read(pSerialDataFlash->Spi, &(TmpWord), 1 );
      
              DataWord |= TmpWord & 0x00ff;
      
              PageAddress++;
      
              if (pSerialDataFlash->bVerify)
              {
                  if (*pUserData != DataWord)
                  {
                     /* SET DATAFLASH ADDRESS BACK TO INITIAL ADDRESS */
                     
                     pSerialDataFlash->Address = SaveAddress + ByteSize;
                     
                     /* RETURN 0 IF DATA VERIFICATION FAILED */
                     
                     return 0;
                  }
              }
              else
              {
                  *pUserData = DataWord;
              }
          }    /* for ()*/
    
          PageAddress = 0;
          PageNumber++;
          pSerialDataFlash->Address += BytesInCurrentPage;
          
      } /* while (bContinue) */

      return (ByteSize >> 1);
    }
}

/*******************************************************************************
*
* NAME: serialdataflashWrite()
*
* PURPOSE: Write to the serial DataFlash device.
*
* DESCRIPTION: This function writes data to the serial DataFlash via the
*              SPI1 device.
*
********************************************************************************
* PARAMETERS:	pHandle - Handle assigned to the serial DataFlash device
*               pBuffer - Array containing the bytes to be transmitted
*               Size - Requested number of bytes to write
*
* RETURN:		Number of bytes written
*
* SIDE EFFECTS:   
*
* DESIGNER NOTES:   
*
* DEPENDENCIES: serialdataflashOpen() must be called first
*******************************************************************************/

ssize_t serialdataflashWrite(int FileDesc, const void * pBuffer, size_t Size)
{
    UWord16   DataByte;
    UWord16   i;
    UWord16   ByteSizeCounter; 
    bool      bContinue       = true;
    UWord16 * pUserData       = (UWord16 *) pBuffer; 
    sSerialDataFlash * pSerialDataFlash = (sSerialDataFlash *)  FileDesc;
    UWord16   ByteSize        = Size << 1; 
    UWord32   SaveAddress     = pSerialDataFlash->Address;
    UWord32   RunningAddress  = 0;
    UWord16   PageAddress     = 0;
    UWord16   PageNumber      = 0;
    UWord16   BytesInCurrentPage = 0;
   
   /* PROTECT FROM OVERWRITING */
   
   if ((UWord32)( ByteSize + pSerialDataFlash->Address ) > (UWord32)( AT45DB321_MAX_ADDRESS + 1 ))
   {
      ByteSize = ( AT45DB321_MAX_ADDRESS + 1 ) - pSerialDataFlash->Address;
   }
   
   while(RunningAddress <= pSerialDataFlash->Address)
   {
       RunningAddress += AT45DB321_PAGE_SIZE;
       PageNumber++;
   }
   
      
   PageNumber--;
   RunningAddress -= AT45DB321_PAGE_SIZE;
   PageAddress = (UWord16) (pSerialDataFlash->Address - RunningAddress);
   
   if ( ByteSize != 0 )
   {

      ByteSizeCounter = ByteSize;

      /* WRITE SERIAL DATAFLASH PAGE BY PAGE */
      
      while (bContinue)
      {
          /* DETERMINE NUMBER OF BYTES THAT CAN BE WRITTEN TO THE CURRENT PAGE */
          
          BytesInCurrentPage = AT45DB321_PAGE_SIZE - PageAddress;
                  
          if ( BytesInCurrentPage >= ByteSizeCounter)
          {
              BytesInCurrentPage = ByteSizeCounter;
              bContinue   = false;
          }
          else
          {
              ByteSizeCounter -= BytesInCurrentPage;
          }

          /********************************************************************/
          /* MAIN MEMORY PAGE TO BUFFER TRANSFER                              */
          /********************************************************************/

          pSerialDataFlash->Buffer[0] = AT45DB321_MAIN_MEM_PAGE_TO_BUFF_TRANSFER;
          pSerialDataFlash->Buffer[1] = (PageNumber >> 6) & 0x007F;
          pSerialDataFlash->Buffer[2] = (PageNumber << 2) & 0x00FC;
          pSerialDataFlash->Buffer[3] = 0;
          
          /* READ HIGH DATA BYTE FROM DATAFLASH */
            
          write(pSerialDataFlash->Spi, &(pSerialDataFlash->Buffer), 4 );
       
          /* READ STATUS UNTIL NOT BUSY */
          
          pSerialDataFlash->Buffer[0] = AT45DB321_STATUS_REGISTER;
          pSerialDataFlash->Buffer[1] = 0xff;
        
          /* WAIT UNTIL WRITE OPERATION COMPLETED */
          do 
          {
              /* READ STATUS FROM DATAFLASH */
              
              write(pSerialDataFlash->Spi, &(pSerialDataFlash->Buffer), 2 );
              read(pSerialDataFlash->Spi, &(pSerialDataFlash->State), 1 );
          }
          while ( !(pSerialDataFlash->State & AT45DB321_BUSY_FLAG) );     
        
          /* WRITE DATA TO BUFFER */
          
          pSerialDataFlash->Buffer[0] = AT45DB321_BUFF_WRITE;
          pSerialDataFlash->Buffer[1] = 0;
          pSerialDataFlash->Buffer[2] = (PageAddress >> 8) & 0x0003;
          pSerialDataFlash->Buffer[3] = PageAddress & 0x00ff;
                  
          for ( i = 0 ; i < BytesInCurrentPage ; i+=2 )
          {
              /* GET 2 DATA BYTES FROM X MEMORY */
              
              DataByte = *pUserData;     
            
              pUserData++;
      
              pSerialDataFlash->Buffer[4 +     i ] = ( DataByte >> 8 ) & 0x00ff;
              pSerialDataFlash->Buffer[4 + 1 + i ] =   DataByte        & 0x00ff;        
          }
                    
          /* READ HIGH DATA BYTE FROM DATAFLASH */
          
          write(pSerialDataFlash->Spi, &(pSerialDataFlash->Buffer), 4 + BytesInCurrentPage );  
       
          /* READ STATUS UNTIL NOT BUSY */

          pSerialDataFlash->Buffer[0] = AT45DB321_STATUS_REGISTER;
          pSerialDataFlash->Buffer[1] = 0xff;
        
          /* WAIT UNTIL WRITE OPERATION COMPLETED */
          do 
          {
              /* READ STATUS FROM DATAFLASH */
              
              write(pSerialDataFlash->Spi, &(pSerialDataFlash->Buffer), 2 );
              read(pSerialDataFlash->Spi, &(pSerialDataFlash->State), 1 );
          }  
          while ( !(pSerialDataFlash->State & AT45DB321_BUSY_FLAG) );
            
          /* BUFFER TO MAIN MEMORY PAGE PROGRAM WITH BUILT-IN ERASE */
          
          pSerialDataFlash->Buffer[0] = AT45DB321_BUFF_TO_MAIN_MEM_PAGE_PRGM_W_ERASE;
          pSerialDataFlash->Buffer[1] = (PageNumber >> 6) & 0x007F;
          pSerialDataFlash->Buffer[2] = (PageNumber << 2) & 0x00FC;
          pSerialDataFlash->Buffer[3] = 0;
          
          /* READ HIGH DATA BYTE FROM DATAFLASH  */
          
          write(pSerialDataFlash->Spi, &(pSerialDataFlash->Buffer), 4 );  
       
          /* READ STATUS UNTIL NOT BUSY */
          
          pSerialDataFlash->Buffer[0] = AT45DB321_STATUS_REGISTER;
          pSerialDataFlash->Buffer[1] = 0xff;
        
          /* WAIT UNTIL WRITE OPERATION COMPLETED */
          do 
          {
              /* READ STATUS FROM DATAFLASH */
              
              write(pSerialDataFlash->Spi, &(pSerialDataFlash->Buffer), 2 );
              read(pSerialDataFlash->Spi, &(pSerialDataFlash->State), 1 );
          }
          while ( !( pSerialDataFlash->State & AT45DB321_BUSY_FLAG) );

          PageAddress = 0;
          PageNumber++;
          pSerialDataFlash->Address += BytesInCurrentPage;
          
      } /* while (bContinue) */
   
      if (pSerialDataFlash->bVerify)
      {
          /* SET DATAFLASH ADDRESS BACK TO INITIAL ADDRESS */
                     
          pSerialDataFlash->Address = SaveAddress;
          
          /* READ DATA STORED IN FLASH AND VERIFY IT IS THE SAME THAT WAS WRITTEN */
          
          return serialdataflashRead( FileDesc, (void *)pBuffer, Size);
      }
   }  /* if ( ByteSize != 0 ) */

   return ByteSize >> 1;

}

/*******************************************************************************
*
* NAME: serialdataflashIoctl()
*
* PURPOSE: Control the serial DataFlash device.
*
* DESCRIPTION: This function configures the serial DataFlash device. 
*
*              The SERIAL_DATAFLASH_DEVICE_RESET command sets the serial
*              DataFlash device back to it default state (address = 0 and
*              verify = false).
*
*              The SERIAL_DATAFLASH_MODE_VERIFY command enables or disables
*              verifing the data written to the serial DataFlash.
*
*              The SERIAL_DATAFLASH_SEEK command ...
*
*
*
********************************************************************************
* PARAMETERS:	pHandle - Handle assigned to the serial DataFlash device
*               Cmd - Configuration Command
*               pParams - pointer to structure containing configuration data
*
* RETURN:		0
*
* SIDE EFFECTS:   
*
* DESIGNER NOTES:   
*
* DEPENDENCIES: serialdataflashDevCreat() must be called first
*******************************************************************************/

UWord16 serialdataflashIoctl(int FileDesc, UWord16 Cmd, void * pParams, ...)
{
   sSerialDataFlash * pSerialDataFlash = (sSerialDataFlash *) FileDesc;

   switch(Cmd)
   {
      case SERIAL_DATAFLASH_DEVICE_RESET:
      {
         SerialDataFlash[HANDLE_0].Address     = 0x0000;
         SerialDataFlash[HANDLE_0].bVerify     = false;
         break;
      }
      case SERIAL_DATAFLASH_MODE_VERIFY:
      {
         pSerialDataFlash->bVerify = *((bool *)(pParams));
         break;
      }
      case SERIAL_DATAFLASH_SEEK:
      {
         /* Adjust address to word boudary */
         pSerialDataFlash->Address = ( *((UWord32 *)(pParams)) & 0x0001) ? *((UWord32 *)(pParams)) + 1 : 
                                                   *((UWord32 *)(pParams));
         /* protect from overwriting */
         if (pSerialDataFlash->Address  > AT45DB321_MAX_ADDRESS )
         {
            pSerialDataFlash->Address = AT45DB321_MAX_ADDRESS + 1; 
         }  
      
         break;
      }

      default:
         break;
   }

   return 0;
}

/*******************************************************************************
*
* NAME: serialdataflashDevCreat()
*
* PURPOSE: Create the serial DataFlash device.
*
* DESCRIPTION: This function creates serial DataFlash device by registering it
*              with the ioLib library. Once the driver is registered, the serial
*              DataFlash driver services are available for use by application  
*              via ioLib and POSIX calls.
*
********************************************************************************
* PARAMETERS:	pName - Name of the serial DataFlash device
*               pConfig - Pointer to configuration data for the serial DataFlash
*
* RETURN:		0
*
* SIDE EFFECTS:   
*
* DESIGNER NOTES:
*
* DEPENDENCIES: This function must be called prior to calling any of the serial
*               DataFlash I/O functions.  The call to this function is 
*               conditionally compiled in config.c when INCLUDE_SERIAL_DATAFLASH
*               is defined appconfig.h
*******************************************************************************/

UWord16 serialdataflashDevCreate(const char * pName, UWord16 OFlags)
{
   ioDrvInstall(serialdataflashOpen);

   SerialDataFlash[HANDLE_0].bInitialized = false;

   return 0;
}

