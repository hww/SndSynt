/***************************************************************************/ 

#include "port.h" 
#include "fcntl.h" 
#include "fileio.h" 
#include "mem.h" 
#include "gpio.h"
#include "bsp.h" 

#define BUFFER 0x1000

void main(void) 
{ 
int Fd; 
int I; 
int PortD;

	UWord16 * pBuffer = malloc(BUFFER * sizeof(UWord16)); 
	UWord16 * pTemp; 

loop:

	pTemp = pBuffer; 
	for( I=0 ; I<BUFFER; I++)
	{
		*pTemp++=(UWord16)I;	
	}
	
	Fd = open("\\\\PC\\D\\in.txt", O_WRONLY);

	/* set data mode for 16 bits */ 

	ioctl(Fd, FILE_IO_DATAFORMAT_RAW,NULL); 

	/* write buffer to test.txt */ 

	write(Fd, pBuffer, BUFFER * sizeof(UWord16)); 
	
	close(Fd); 
	
	pTemp = pBuffer; 
	for( I=0 ; I<BUFFER; I++)
	{
		*pTemp++=(UWord16)0;	
	}
	
	Fd = open("\\\\PC\\D\\in.txt", O_RDONLY);

	/* set data mode for 16 bits */ 

	ioctl(Fd, FILE_IO_DATAFORMAT_RAW,NULL); 

	/* write buffer to test.txt */ 

	read(Fd, pBuffer, BUFFER * sizeof(UWord16)); 
	
	close(Fd); 

	Fd = open("\\\\PC\\D\\out.txt", O_WRONLY);

	/* set data mode for 16 bits */ 

	ioctl(Fd, FILE_IO_DATAFORMAT_RAW,NULL); 

	/* write buffer to test.txt */ 

	write(Fd, pBuffer, BUFFER * sizeof(UWord16)); 
	
	close(Fd); 

	goto loop;
} 

/***************************************************************************/

