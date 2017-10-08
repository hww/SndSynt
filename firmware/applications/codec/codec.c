#include "port.h"
#include "arch.h"
#include "io.h"

#include "fcntl.h"

#include "fcodec.h"
#include "bsp.h"
#include "assert.h"
#include "audiolib.h"

/*****************************************************************************/

void main(void)
{
	Word16 *ptr;
	UWord16 n;
	Int16  v=0;

 	fcodecOpen();
	
	while(true)
	{
		ptr = fcodecWaitBuf();
		for(n=0; n < (FRAME_BUF_SIZE>>2); n++)
		{ 
			*ptr++ =v;
			*ptr++ =v;
			 v    +=256;
		}
	}	

	fcodecClose();
}
