#include "port.h"
#include "arch.h"

#include "config.h"

EXPORT void UserPreMain(void);
EXPORT void UserPostMain(void);
EXPORT void fflush (void);

/*****************************************************************************/
EXPORT void UserPreMain(void)
{
}

/*****************************************************************************/
EXPORT void UserPostMain(void)
{
	/* Flush all output */
	fflush();               /* Delete this to save space 
										if you do not use stdio   */
	
#ifdef INCLUDE_STACK_CHECK
	if (stackcheckSizeUsed() >= stackcheckSizeAllocated())
	{
		/* Stack Overflow */
		asm(debug);
	}
#endif
	
	while (1) 
	{
		/* End of debugging session */
		asm(debug);           
	}
}

