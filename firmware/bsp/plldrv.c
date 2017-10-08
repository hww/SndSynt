#include "port.h"
#include "arch.h"

#include "plldrv.h"
#include "periph.h"


/*****************************************************************************/
void plldrvInitialize ( UWord16 ControlReg, 
						UWord16 DivideReg,
						UWord16 TestReg,
						UWord16 SelectReg)
{
	UWord16  PLLStatus;
	UInt16   i, j;
	
	/* Disable PLL */
	periphMemWrite((PLL_LOCK_DETECTOR | PLL_ZCLOCK_PRESCALER), &ArchIO.Pll.ControlReg);
	
	/* Write configuration values into PLL registers */
	periphMemWrite(TestReg,   &ArchIO.Pll.TestReg);
	periphMemWrite(SelectReg, &ArchIO.Pll.SelectReg);
	periphMemWrite(DivideReg, &ArchIO.Pll.DivideReg);

	if ((ControlReg & 0x00FF) 
			== (PLL_LOCK_DETECTOR | PLL_ZCLOCK_POSTSCALER)) 
	{
		/* Wait for PLL to lock */
		for (i=0; i<0x4000; i++)
		{
			PLLStatus = periphMemRead(&ArchIO.Pll.StatusReg);
			if ((PLLStatus & PLL_STATUS_LOCK_0) == PLL_STATUS_LOCK_0)
			{
				break;  /* PLL locked, so exit now */
			}
		}
		/* PLL did not lock, but proceed anyway */
	}
		
	/* Program PLL to user defined value */
	periphMemWrite(ControlReg, &ArchIO.Pll.ControlReg);
}
