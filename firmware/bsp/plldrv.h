/* File: plldrv.h */

#ifndef __PLLDRV_H
#define __PLLDRV_H

#include "port.h"

#ifdef __cplusplus
extern "C" {
#endif


/* PLL CONTROL REGISTER FLAGS */

#define PLL_INT1_ENABLE_ANY_EDGE        0xC000
#define PLL_INT1_ENABLE_FALLING_EDGE    0x8000
#define PLL_INT1_ENABLE_RISING_EDGE     0x4000

#define PLL_INT0_ENABLE_ANY_EDGE        0x3000
#define PLL_INT0_ENABLE_FALLING_EDGE    0x2000
#define PLL_INT0_ENABLE_RISING_EDGE     0x1000

#define PLL_LOSS_OF_CLOCK_INT           0x0800

#define PLL_LOCK_DETECTOR               0x0080

#define PLL_FORCE_LOCK                  0x0020

#define PLL_PWRDONW                     0x0010

#define PLL_ZCLOCK_PRESCALER            0x0001
#define PLL_ZCLOCK_POSTSCALER           0x0002

/* PLL DIVIDE-BY REGISTER FLAGS */

#define PLL_CLOCK_OUT_DIVIDE_BY_1       0x0000
#define PLL_CLOCK_OUT_DIVIDE_BY_2       0x0400
#define PLL_CLOCK_OUT_DIVIDE_BY_4       0x0800
#define PLL_CLOCK_OUT_DIVIDE_BY_8       0x0C00

#define PLL_CLOCK_IN_DIVIDE_BY_1        0x0000
#define PLL_CLOCK_IN_DIVIDE_BY_2        0x0100
#define PLL_CLOCK_IN_DIVIDE_BY_4        0x0200
#define PLL_CLOCK_IN_DIVIDE_BY_8        0x0300

/* PLL CLKO SELECT REGISTER FLAGS */

#define PLL_CLKO_SELECT_ZCLK            0x0000
#define PLL_CLKO_SELECT_NO_CLK          0x0010

/* PLL TEST REGISTER FLAGS */

#define PLL_TEST_FEEDBACK_CLOCK         0x0020
#define PLL_TEST_REF_FREQ_CLOCK         0x0010
#define PLL_TEST_FORCE_LOSS_OF_CLOCK    0x0008
#define PLL_TEST_FORCE_LOSS_OF_CLOCK1   0x0004
#define PLL_TEST_FORCE_LOSS_OF_CLOCK0   0x0002
#define PLL_TEST_MODE                   0x0001

/* PLL STATUS REGISTER FLAGS */

#define PLL_STATUS_LOCK_LOST_INT1       0x8000
#define PLL_STATUS_LOCK_LOST_INT0       0x4000
#define PLL_STATUS_CLOCK_LOST           0x2000
#define PLL_STATUS_LOCK_1               0x0040
#define PLL_STATUS_LOCK_0               0x0020
#define PLL_STATUS_POWERED_DOWN         0x0010
#define PLL_STATUS_ZCLOCK_PRESCALER     0x0001
#define PLL_STATUS_ZCLOCK_POSTSCALER    0x0002

EXPORT void plldrvInitialize  ( UWord16 ControlReg, 
								UWord16 DivideReg,
								UWord16 TestReg,
								UWord16 SelectReg);

#ifdef __cplusplus
}
#endif

#endif
