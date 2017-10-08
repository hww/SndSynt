/*****************************************************************************
*
* fileiodrv.h - header file for the Motorola dsp56824 fileio device driver.
*
*****************************************************************************/
#include "port.h"
#include "arch.h"
#include "assert.h"
#include "io.h"
#include "fcntl.h"

#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "stdarg.h"

#include "mem.h"

#include "bsp.h"
#include "sci.h"
#include "fileiodrv.h"
#include "types.h"
#include "gpio.h"

#define TXRX gpioPin(D,5)
#define TX2  gpioPin(D,6)

#define FILE_IO_NAME            "\\\\PC\\"
#define FILE_IO_SDK_PATH        "\\\\PC\\Embedded SDK\\"
#define FILE_IO_NAME_LENGTH     5
#define FILE_IO_SDK_PATH_LENGTH 18
#define FILE_IO_HANDLE_WRITE    0
#define FILE_IO_HANDLE_READ     1

/* !!! Не может быть больше 7F для RAW и
       больше FF для 8 битного режима */
#define BUFFER_SIZE             0x7F


static io_sInterface InterfaceVT = {
	fileioClose,
	fileioRead,
	fileioWrite,
	fileioIoctl,
};

typedef enum
{
	EightBitChars,
	Raw
} eDataFormat;

typedef struct
{
	UWord16      Handle;
	UWord16      UartHandle;
	eDataFormat  DataFormat;
	UWord32 	 size;
	UWord32 	 loc;
}sFileIO;

typedef struct
{
	char Command;
	char Path;
	char NumBytes;
}sHeader;

typedef struct
{
	char Command;
	char FD;
}sCloseHeader;

static sFileIO FileIO[2];
static bool    bUartIsOpened = false;

static io_sDriver fileDriverWrite = {&InterfaceVT, (int)&FileIO[FILE_IO_HANDLE_WRITE]};
static io_sDriver fileDriverRead  = {&InterfaceVT, (int)&FileIO[FILE_IO_HANDLE_READ]};

static int PortD;

/*****************************************************************************/
static io_sDriver * fileioOpen(const char * pName, int OFlags, ...)
{
	sFileIO        * pFileIO;
	int              Uart;
	int              Length;	
	int              CompareResult;
	UWord16          NewUartState;
	sHeader          FileIOSetup;
	sci_sConfig       SciConfig;
	io_sDriver     * pDriver;
		

	if(strncmp(pName, FILE_IO_NAME, FILE_IO_NAME_LENGTH) == 0)
	{
		if(OFlags == O_WRONLY)
		{
			pFileIO = &(FileIO[FILE_IO_HANDLE_WRITE]);
			pDriver = &fileDriverWrite;
		}
		else
		{
			pFileIO = &(FileIO[FILE_IO_HANDLE_READ]);
			pDriver = &fileDriverRead;
		}
		
		pFileIO -> Handle     = OFlags;
		pFileIO -> DataFormat = EightBitChars;
		pFileIO -> size       = 0;
		pFileIO -> loc     	  = 0;
	
		// Управление драйверами интерфейса RS422
		PortD = open(BSP_DEVICE_NAME_GPIO_D, NULL);
		ioctl(PortD, GPIO_SETAS_GPIO, TXRX | TX2); 
		ioctl(PortD, GPIO_SETAS_OUTPUT, TXRX | TX2); 
		ioctl(PortD, GPIO_SET, TX2); 
		ioctl(PortD, GPIO_CLEAR, TXRX); 
		
		SciConfig.SciCntl    =  SCI_CNTL_WORD_8BIT | SCI_CNTL_PARITY_NONE;
   	    SciConfig.SciHiBit   =  SCI_HIBIT_0;
   	    SciConfig.BaudRate   =  SCI_BAUD_USER2;

		if(bUartIsOpened == false)
		{
			/* open SCI 0 in Blocking mode with 8 bit word length without parity */
			/* and on 9600 baud rate.  */ 
			Uart = open(BSP_DEVICE_NAME_SERIAL_1, O_RDWR, &(SciConfig));
			
			if (Uart  == -1)
			{
				assert(!" Open /sci0 device failed.");
			}

			bUartIsOpened = true;

			FileIO[FILE_IO_HANDLE_READ].UartHandle  = Uart;
			FileIO[FILE_IO_HANDLE_WRITE].UartHandle = Uart;

			ioctl(Uart, SCI_DATAFORMAT_EIGHTBITCHARS, NULL);
		}
		else
		{
			Uart = FileIO[FILE_IO_HANDLE_WRITE].UartHandle;
		}

		FileIOSetup.Command  = 'O';
	
		if(strncmp(pName, FILE_IO_SDK_PATH, FILE_IO_SDK_PATH_LENGTH))
		{
			FileIOSetup.NumBytes = (char)strlen(pName) - 4;
			FileIOSetup.Path     = 'N';
			
			write(Uart, &FileIOSetup, sizeof(FileIOSetup));
									
			write(Uart, pName + 5, sizeof(char));
			write(Uart, ":", sizeof(char));
	
			Length = strlen(pName) - 6;
			write(Uart, pName + 6, Length * sizeof(char));
		}
		else
		{
			FileIOSetup.NumBytes = (char)strlen(pName) - FILE_IO_SDK_PATH_LENGTH;
			FileIOSetup.Path     = 'S';
			
			write(Uart, &FileIOSetup, sizeof(FileIOSetup));
			write(Uart, pName + 18, (FileIOSetup.NumBytes)*sizeof(char));
		}
	
		write(Uart, &OFlags, sizeof(char));
		// прочитаем размер файла
		ioctl(Uart, SCI_DATAFORMAT_RAW, NULL);
		read (Uart, &pFileIO -> size, 2 );
		ioctl(Uart, SCI_DATAFORMAT_EIGHTBITCHARS, NULL);
	}
	else
	{
		return (io_sDriver *) -1;
	}

	if(pFileIO -> size == 0xFFFFFFFF ) return (io_sDriver *) -1;
	
	return (io_sDriver *) pDriver;
}

/*****************************************************************************/
static int fileioClose(int FileDesc)
{
	sCloseHeader CloseCommand;
	UWord16      Uart            = ((sFileIO *)FileDesc)->UartHandle;	

	CloseCommand.Command = 'C';
	CloseCommand.FD      = ((sFileIO *)FileDesc)->Handle;

	write(Uart, &CloseCommand, 2 * sizeof(char));

	close(PortD);
	return 1;
}

/*****************************************************************************/
static ssize_t fileioRead(int FileDesc, void * pUserBuffer, size_t NBytes)
{
	sFileIO * pFileIO     = (sFileIO *) FileDesc;
	UWord16   Uart        = ((sFileIO *)FileDesc)->UartHandle;
	UWord16   Bytes       = BUFFER_SIZE;
	sHeader   ReadCommand = {'R', BUFFER_SIZE};
	UWord16 * pBuffer     = (UWord16 *)pUserBuffer;
	ssize_t   ReadCount;
	ssize_t   TotalCount  = 0;
	UWord32   delta;
	
	delta = pFileIO->size - pFileIO->loc;	// Сколько до конца файла?		

	do
	{
		if(NBytes < BUFFER_SIZE)
		{
			Bytes = NBytes;
		}

		if(pFileIO -> DataFormat == Raw)
		{
			ReadCommand.NumBytes = Bytes * 2;

			if(ReadCommand.NumBytes > delta)
			{
				ReadCommand.NumBytes=delta;
			}

			write(Uart, &ReadCommand, sizeof(sHeader));

			ioctl(Uart, SCI_DATAFORMAT_RAW, NULL);

			ReadCount = read (Uart, pBuffer, Bytes * sizeof(char));

			ioctl(Uart, SCI_DATAFORMAT_EIGHTBITCHARS, NULL);
		}
		else
		{
			ReadCommand.NumBytes = Bytes;

			if(ReadCommand.NumBytes > delta)
			{
				ReadCommand.NumBytes=delta;
			}

			write(Uart, &ReadCommand, sizeof(sHeader));

			ReadCount = read (Uart, pBuffer, Bytes * sizeof(char));
		}

		TotalCount += ReadCount;
		pBuffer    += Bytes;
		
	}while(((NBytes -= Bytes) != 0) & (TotalCount<delta));
	
	pFileIO -> loc +=(UWord32) TotalCount;
	return TotalCount;
}

/*****************************************************************************/
static ssize_t fileioWrite(int FileDesc, const void * pUserBuffer, size_t Size)
{
	sFileIO * pFileIO     = (sFileIO *) FileDesc;
	sHeader   Header      = { 'W', BUFFER_SIZE};
	UWord16   Uart        = ((sFileIO *)FileDesc)->UartHandle;
	UWord16   Bytes       = BUFFER_SIZE;
	UWord16 * pBuffer     = (UWord16 *)pUserBuffer;
	ssize_t   ReturnCount = (ssize_t)Size;

	do
	{
		if(Size < BUFFER_SIZE)
		{
			Bytes = Size;
		}
		
		if(pFileIO -> DataFormat == Raw)
		{
			Header.NumBytes = Bytes * 2;

			write(Uart, &Header, sizeof(sHeader));

			ioctl(Uart, SCI_DATAFORMAT_RAW, NULL);

			write (Uart, pBuffer, Bytes * sizeof(char));

			ioctl(Uart, SCI_DATAFORMAT_EIGHTBITCHARS, NULL);
		}
		else
		{
			Header.NumBytes = Bytes;
		
			write(Uart, &Header, sizeof(sHeader));
			write(Uart, pBuffer, Bytes);
		}
		
		pBuffer += Bytes;
		
	}while((Size -= Bytes) != 0);

	pFileIO -> loc  += ReturnCount;
	pFileIO -> size += ReturnCount;
	
	return ReturnCount;
}

/*****************************************************************************/
UWord16 fileioIoctl(int FileDesc, UWord16 Cmd, void * pParams, ...)
{
	va_list    Args;
	sFileIO * pFileIO = (sFileIO *) FileDesc;
	UWord32 * out = (UWord32*)pParams;

	switch(Cmd)
	{
		case FILE_IO_DATAFORMAT_RAW:
			pFileIO -> DataFormat = Raw;
			break;

		case FILE_IO_DATAFORMAT_EIGHTBITCHARS:
			pFileIO -> DataFormat = EightBitChars;
			break;

		case FILE_IO_GET_SIZE:
			*out = pFileIO -> size;
			break;

		case FILE_IO_LOC:
			*out = pFileIO -> loc;
			break;
				
		default:
			break;
	}

	return 0;
}

/*****************************************************************************/
UWord16 fileioDevCreat(const char * pName, UWord16 OFlags)
{
	ioDrvInstall(fileioOpen);

	return 1;
}

