/*****************************************************************************
*
* quadraturetimer.h - header file for the quadrature timer device driver.
*
*****************************************************************************/

#ifndef __QUADRATURE_TIMER_H
#define __QUADRATURE_TIMER_H


#ifndef SDK_LIBRARY
	#include "configdefines.h"
	#ifndef INCLUDE_TIME_OF_DAY
		#ifndef INCLUDE_QUAD_TIMER
			#error INCLUDE_QUAD_TIMER must be defined in appconfig.h to initialize the QUADRATURE TIMER driver
		#endif
	#endif
#endif


#include "port.h"

#if defined(SDK_LIBRARY) || defined(INCLUDE_IO_QUAD_TIMER)
	#include "io.h"
	#include "fcntl.h"
#endif



#ifdef __cplusplus
extern "C" {
#endif

/******************************************************************************
*
*                      General Interface Description
*
* The Quadrature Timer (QT) driver supports 4 Quadrature Timers, each with 
* 4 channels. Pin availability for the quadrature timers are different for each 
* chip. (Please refer to Chapter 14 of the DSP56F80x User’s Manual for more 
* information on the quadrature timer device).
*
******************************************************************************/


/******************************************************************************
*
*  QUAD TIMER (QT) Interfaces
* 
*     The QT interface can be used at two alternative levels, a low level
*     QT driver interface and the common IO layer interface.  The common IO 
*     layer interface invokes the lower level QT driver interface. 
*
*     The low level QT driver provides a non-standard interface that is
*     potentially more efficient that the IO layer calls, but less portable.  
*     The IO layer calls to the QT interface are standard and more 
*     portable than the low level QT interface, but potentially less efficient.
*    
*     Your application may use either the low level QT driver interface or
*     the IO layer interface to the QT driver, depending on your specific
*     goals for efficiency and portability.
*
*     The low level QT driver interface defines functions as follows:
*  
*          int     qtOpen  (const char *pName, int OFlags, qt_sState * pParams);
*          int     qtClose (int FileDesc);  
*          UWord16 qtIoctl (int FileDesc, UWord16 Cmd, void * pParams, const char *pName);      
*
*     The IO layer interface defines functions as follows:
*
*          int     open  (const char *pName, int OFlags, qt_sState * pParams);
*          int     close (int FileDesc);  
*          UWord16 ioctl (int FileDesc, UWord16 Cmd, void * pParams);      
*
******************************************************************************/

/*****************************************************************************
*
* LOW LEVEL QUAD TIMER DRIVER INTERFACE
*
*   General Description:
*
*      The Low Level QT Driver is configured by the following:
*  
*         1)  The device is created and initialized by selecting it through defining the 
*             INCLUDE_QUAD_TIMER variable in the appconfig.h file associated with the 
*             SDK Embedded Project created in CodeWarrior. 
*
*         2)  An "qtOpen" call is made to open the QT device
*
*         3)  "qtIoctl" calls are made to control the QT device
*
*         4)  After all QT operations are completed, the QT device
*             is closed via a "qtClose" call.
*
*
*   qtOpen
*
*      int qtOpen(const char *pName, int OFlags, qt_sState * pParams);
*
*         Semantics:
*            Opens a particular QT device. Argument pName is the 
*            particular device name. 
*
*         Parameters:
*            pName    - device name. See bsp.h for device names specific to this 
*                       platform.  Typically, the QT device name is
*                          BSP_DEVICE_NAME_QUAD_TIMER_A_0
*                          BSP_DEVICE_NAME_QUAD_TIMER_A_1
*                          ...
*            OFlags   - General parameter to configure the QT driver;  however,
*                       this parameter is not used at this time.
*            pParams  - A pointer to the data structure used  to configure 
*                       the quadrature timer, or NULL if a subsequent qtIoctl
*                       call is made to QT_ENABLE the quadrature timer.
*
*         Return Value: 
*            File descriptor if open is successful.  This file descriptor must be
*            passed to other QT driver functions.
*            -1 value if open failed.
*     
*         Example:
*
*               int qtFD; 
*
*               qtFD = qtOpen(BSP_DEVICE_NAME_QUAD_TIMER_D_0, 0, NULL);
*
*     
*   qtClose
*
*      int qtClose(int FileDesc);  
*
*         Semantics:
*            Close QT device.
*  
*         Parameters:
*            FileDesc    - File descriptor returned by "qtOpen" call.
*
*         Example:
*
*            // Close the QT driver 
*            qtClose(qtFD); 
* 
*         Return Value: 
*            Zero
*
*   qtIoctl
*
*      void qtIoctl (int FileDesc, UWord16 Cmd, UWord16 * pParams, const char * pName); 
*
*         Semantics:
*            Modify QT configuration or control the QT device
*
*         Parameters:
*            FileDesc  - The value returned by the qtOpen call
*
*            Cmd       - command for driver qtIoctl command;  these commands
*                        are listed in the description of the IO Layer ioctl 
*                        interface
*
*            pParams   - parameters to the specific qtIoctl command;  these parameters are 
*                          command dependent.  Please see the list of ioctl commands below
*                          to determine the specific parameter for each command
*
*            pName     - the QT device name from bsp.h;  typically,
*                           BSP_DEVICE_NAME_QUAD_TIMER_A_0
*                           BSP_DEVICE_NAME_QUAD_TIMER_A_1
*
*         Return Value: 
*            void 
*
*         Example:
*
*            // Disable the QT
*            qtIoctl(qtFD, QT_DISABLE, NULL, BSP_DEVICE_NAME_QUAD_TIMER_D_0); 
*     
*****************************************************************************/


/*****************************************************************************
* 
* IO Layer Interface to the QT Driver
*
*   General Description:
*
*      A QT device is configured by the following:
*  
*  		  1)  The device is created and initialized by selecting it by defining
*             both the INCLUDE_QUAD_TIMER variable and the INCLUDE_IO variable in the 
*             appconfig.h file associated with the SDK Embedded Project created 
*             in CodeWarrior. 
*
*         2)  An "open" call is made to initialize the QT device
*
*         3)  "ioctl" calls are made to configuration and control the QT device
*
*         4)  After all QT operations are completed, the QT device
*             is closed via a "close" call.
*
* 
*   OPEN
*
*      int open(const char *pName, int OFlags, qt_sState * pParams);
*
*         Semantics:
*            Open the particular QT peripheral for operations.
*  
*            Argument pName identifies the particular QT device name. See bsp.h
*            for a list of QT devices names for this chip.  Typically, the QT device
*            names include:
*                      BSP_DEVICE_NAME_QUAD_TIMER_A_0
*                      BSP_DEVICE_NAME_QUAD_TIMER_A_1
*                      ...
*
*         Parameters:
*            pName    - device name. (See bsp.h for a list of application QT device names.) 
*            OFlags   - open mode flags.   Not used.
*            pParams  - An optional pointer to the data structure used to configure 
*                       the quadrature timer, or NULL if a subsequent ioctl
*                       call is made to QT_ENABLE the quadrature timer.
* 
*         Return Value: 
*            QT device descriptor if open is successful.
*            -1 value if open failed.
*     
*         Example:
*     
*            /* This example will open timer D channel 0 and return a file descriptor * /
*  
*            int qtFD; 
*
*            qtFD = open(BSP_DEVICE_NAME_QUAD_TIMER_D_0, 0, NULL);
*
*
*   IOCTL
*
*      UWord16 ioctl(int FileDesc, UWord16 Cmd, void * pParams); 
*
*         Semantics:
*            Controls QT operation. 
*
*         Parameters:
*            FileDesc    - QT Device descriptor returned by "open" call.
*            Cmd         - QT command 
*            pParams     - Parameters to the QT command;  these parameters are command
*                          dependent.  Please see the list of ioctl commands below
*                          to determine the specific parameter for each command
*
*         Return Value: The ioctl return value is command dependent 
*                 
*         Example:
*
*            ioctl(qtFD, QT_DISABLE, NULL); 
*
*
*
*   CLOSE
*
*      int close(int FileDesc);  
*
*         Semantics:
*            Close QT device.
*
*         Parameters:
*            FileDesc - QT Device descriptor returned by "open" call.
*
*         Return Value: 
*            Zero
*
*****************************************************************************/


/*******************************************
* Quadrature Timer ioctl Commands/Parameters
********************************************/
#define QT_ENABLE                      (IO_LAST_COMMON_IOCTL_CMD + 1)   /* qt_sState * (or NULL) */
#define QT_DISABLE                     (IO_LAST_COMMON_IOCTL_CMD + 2)   /* NULL             */
#define QT_ENABLE_OUTPUT               (IO_LAST_COMMON_IOCTL_CMD + 3)   /* NULL             */
#define QT_DISABLE_OUTPUT              (IO_LAST_COMMON_IOCTL_CMD + 4)   /* NULL             */
#define QT_FORCE_OUTPUT                (IO_LAST_COMMON_IOCTL_CMD + 5)   /* bool             */
#define QT_GET_STATUS                  (IO_LAST_COMMON_IOCTL_CMD + 6)   /* NULL             */ /* returns UWord16 */
#define QT_DISABLE_CALLBACK            (IO_LAST_COMMON_IOCTL_CMD + 7)   /* qt_eCallbackType */
#define QT_ENABLE_CALLBACK             (IO_LAST_COMMON_IOCTL_CMD + 8)   /* qt_eCallbackType */
#define QT_WRITE_COMPARE_VALUE1        (IO_LAST_COMMON_IOCTL_CMD + 9)   /* UInt16           */
#define QT_WRITE_COMPARE_VALUE2        (IO_LAST_COMMON_IOCTL_CMD + 10)  /* UInt16           */
#define QT_WRITE_INITIAL_LOAD_VALUE    (IO_LAST_COMMON_IOCTL_CMD + 11)  /* UInt16           */
#define QT_ENABLE_CAPTURE_REG          (IO_LAST_COMMON_IOCTL_CMD + 12)  /* NULL             */
#define QT_READ_CAPTURE_REG            (IO_LAST_COMMON_IOCTL_CMD + 13)  /* NULL             */ /* returns UWord16 */
#define QT_READ_HOLD_REG               (IO_LAST_COMMON_IOCTL_CMD + 14)  /* NULL             */ /* returns UWord16 */
#define QT_READ_COUNTER_REG            (IO_LAST_COMMON_IOCTL_CMD + 16)  /* NULL             */ /* returns UWord16 */
#define QT_WRITE_COUNTER_REG           (IO_LAST_COMMON_IOCTL_CMD + 17)  /* UWord16          */
#define QT_GET_INPUT_CLK_FREQ          (IO_LAST_COMMON_IOCTL_CMD + 18)  /* UWord32 * (addr of output value */
#define QT_SET_INPUT_CAPTURE_MODE      (IO_LAST_COMMON_IOCTL_CMD + 19)  /* qt_eCaptureMode  */
#define QT_FAST_RESTART                (IO_LAST_COMMON_IOCTL_CMD + 20)  /* qt_eMode         */          

	
typedef enum
{
    qtCount = 0x01,
    qtCountBothEdges = 0x02,
    qtGatedCount = 0x03,
    qtQuadratureCount = 0x04,
    qtSignedCount = 0x05,
    qtTriggeredCount = 0x06,
    qtCascadeCount = 0x07,
    
    qtOneShot = 0x06,         /* Forces 
                                CountLength    = qtUntilCompare; 
                                OutputMode     = qtDeassertOnSecondary */
                                
    qtPulseOutput = 0x01,     /* Forces 
                                CountFrequency = qtOnce; 
                                OutputMode     = qtAssertOnGatedClock */
    
    qtFixedFreqPWM = 0x01,    /* Forces 
                                CountLength    = qtPastCompare; 
                                ContFrequency  = qtRepeatedly; 
                                OutputMode     = qtDeassertOnCounterRollover */
                                
    qtVariableFreqPWM = 0x01  /* Forces 
                                CountLength    = qtUntilCompare; 
                                ContFrequency  = qtRepeatedly; 
                                OutputMode     = qtToggleUsingAlternateCompare */
} qt_eMode;

typedef enum
{
    qtCounter0Input,
    qtCounter1Input,
    qtCounter2Input,
    qtCounter3Input,
    qtCounter0Output,
    qtCounter1Output,
    qtCounter2Output,
    qtCounter3Output,
    qtPrescalerDiv1,
    qtPrescalerDiv2,
    qtPrescalerDiv4,
    qtPrescalerDiv8,
    qtPrescalerDiv16,
    qtPrescalerDiv32,
    qtPrescalerDiv64,
    qtPrescalerDiv128
} qt_eInputSource;
 
typedef enum
{
    qtSISCounter0Input,
    qtSISCounter1Input,
    qtSISCounter2Input,
    qtSISCounter3Input
} qt_eSecondaryInputSource;

typedef enum
{
    qtNormal,
    qtInverted
}qt_ePolarity;

typedef enum
{
    qtRepeatedly,
    qtOnce
} qt_eCountFrequency;

typedef enum
{
    qtPastCompare,
    qtUntilCompare
} qt_eCountLength;

typedef enum
{
    qtUp,
    qtDown
} qt_eCountDirection;

typedef enum
{
    qtAssertWhileActive,
    qtAssertOnCompare,
    qtDeassertOnCompare,
    qtToggleOnCompare,
    qtToggleUsingAlternateCompare,
    qtDeassertOnSecondary,
    qtDeassertOnCounterRollover,
    qtAssertOnGatedClock
} qt_eOutputMode;

typedef enum
{
    qtCompare,
    qtOverflow,
    qtInputEdge
} qt_eCallbackType;

typedef struct
{
    void    (*pCallback)(qt_eCallbackType CallbackType, void * pCallbackArg);
    void    * pCallbackArg;
} qt_sCallback;

typedef enum
{
    qtDisabled,
    qtRisingEdge,
    qtFallingEdge,
    qtBothEdges
} qt_eCaptureMode;


typedef struct
{
    qt_eMode                   Mode                 : 4;

    qt_eInputSource            InputSource          : 4;
    qt_ePolarity               InputPolarity        : 1;
    qt_eSecondaryInputSource   SecondaryInputSource : 2;
    
    qt_eCountFrequency         CountFrequency       : 1;
    qt_eCountLength            CountLength          : 1;
    qt_eCountDirection         CountDirection       : 1;
    
    qt_eOutputMode             OutputMode           : 3;
    qt_ePolarity               OutputPolarity       : 1;
    bool                       OutputDisabled       : 1;
    
    bool                       Master               : 1;
    bool                       OutputOnMaster       : 1;
    bool                       CoChannelInitialize  : 1;
    bool                       AssertWhenForced     : 1;
    
    qt_eCaptureMode            CaptureMode          : 2;
    
    UInt16                     CompareValue1;
    UInt16                     CompareValue2;
    UInt16                     InitialLoadValue;
    
    qt_sCallback               CallbackOnCompare;
    qt_sCallback               CallbackOnOverflow;
    qt_sCallback               CallbackOnInputEdge;
} qt_sState;



/*********************************************************************
* The driver file is included at the end of this public include
* file instead of the beginning to avoid circular dependency problems.
**********************************************************************/ 
#if defined(SDK_LIBRARY) || defined(INCLUDE_IO_QUAD_TIMER)
	#include "qtimerdrvIO.h"
#endif

#include "qtimerdrv.h"


#ifdef __cplusplus
}
#endif

#endif
