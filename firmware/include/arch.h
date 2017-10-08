/* File: arch.h */

#ifndef __ARCH_H
#define __ARCH_H

#include "port.h"

#ifdef __cplusplus
extern "C" {
#endif


/*******************************************************
* Architecture Dependent Declarations
*******************************************************/

typedef volatile struct{
	UWord16 ControlReg;
	UWord16 StatusReg;
	UWord16 Reserved[14];
} arch_sSIM;

typedef volatile struct{
	UWord16 TransmitReg;
	UWord16 ReceiveReg;
	UWord16 ControlStatusReg;
	UWord16 Control2Reg;
	UWord16 TxControlReg;
	UWord16 RxControlReg;
	UWord16 TimeSlotReg;
	UWord16 FifoCntlStatReg;
	UWord16 TestReg;
	UWord16 OptionReg;
	UWord16 Reserved[6];
} arch_sSSI;

typedef volatile struct{
	UWord16 CompareReg1;
	UWord16 CompareReg2;
	UWord16 CaptureReg;
	UWord16 LoadReg;
	UWord16 HoldReg;
	UWord16 CounterReg;
	UWord16 ControlReg;
	UWord16 StatusControlReg;
} arch_sTimerChannel;

typedef volatile struct{
	arch_sTimerChannel Channel0;
	arch_sTimerChannel Channel1;
	arch_sTimerChannel Channel2;
	arch_sTimerChannel Channel3;
} arch_sTimer;

typedef volatile struct{
	UWord16 GroupPriorityReg[16];
	UWord16 IntRequestReg[4];
	UWord16 Reserved1[4];
	UWord16 IntSourceReg[4];
	UWord16 ControlReg;
	UWord16 Reserved2[3];
} arch_sIntCntrl;

typedef volatile struct{
	UWord16 BaudRateReg;
	UWord16 ControlReg;
	UWord16 StatusReg;
	UWord16 DataReg;
	UWord16 Reserved[12];
} arch_sSCI;

typedef volatile struct{
	UWord16 ControlReg;
	UWord16 DataSizeReg;
	UWord16 DataRxReg;
	UWord16 DataTxReg;
	UWord16 Reserved[12];
} arch_sSPI;

typedef volatile struct{
	UWord16 ControlReg;
	UWord16 ClockScalerReg;
	UWord16 SecondsReg;
	UWord16 SecondsAlarmReg;
	UWord16 MinutesReg;
	UWord16 MinutesAlarmReg;
	UWord16 HoursReg;
	UWord16 HoursAlarmReg;
	UWord16 DaysReg;
	UWord16 DaysAlarmReg;
	UWord16 Reserved[6];
} arch_sTOD;

typedef volatile struct{
	UWord16 ControlReg;
	UWord16 TimeoutReg;
	UWord16 ServiceReg;
	UWord16 Reserved[13];
} arch_sCOP;

typedef volatile struct{
	UWord16 ControlReg;
	UWord16 ProgramReg;
	UWord16 EraseReg;
	UWord16 AddressReg;
	UWord16 DataReg;
	UWord16 IntReg;
	UWord16 IntSourceReg;
	UWord16 IntPendingReg;
	UWord16 DivisorReg;
	UWord16 TimerEraseReg;
	UWord16 TimerMassEraseReg;
	UWord16 TimerNVStorageReg;
	UWord16 TimerProgramSetupReg;
	UWord16 TimerProgramReg;
	UWord16 TimerNVHoldReg;
	UWord16 TimerNVHold1Reg;
	UWord16 TimerRecoveryReg;
	UWord16 Reserved[15];
} arch_sFlash;

typedef volatile struct{
	UWord16 ControlReg;
	UWord16 DivideReg;
	UWord16 StatusReg;
	UWord16 TestReg;
	UWord16 SelectReg;
	UWord16 Reserved[11];
} arch_sPLL;

typedef volatile struct{
	UWord16 PullUpReg;
	UWord16 DataReg;
	UWord16 DataDirectionReg;
	UWord16 PeripheralReg;
	UWord16 IntAssertReg;
	UWord16 IntEnableReg;
	UWord16 IntPolarityReg;
	UWord16 IntPendingReg;
	UWord16 IntEdgeSensReg;
	UWord16 Reserved[7];
} arch_sPort;

typedef volatile struct{
	arch_sSIM      Sim;
	UWord16        Reserved[0x10];
	arch_sFlash    ProgramFlash;
	UWord16        Reserved1[0x20];
	arch_sFlash    DataFlash;
	arch_sFlash    BootFlash;
	arch_sTimer    TimerA;
	arch_sTOD      Tod;
	UWord16        Reserved2[0x10];
	arch_sSSI      Ssi;
	arch_sPLL      Pll;
	arch_sIntCntrl IntController;
	arch_sCOP      Cop;
	UWord16        Reserved3[0x10];
	arch_sSPI      Spi0;
	arch_sSPI      Spi1;
	arch_sSCI      Sci0;
	arch_sSCI      Sci1;
	UWord16        Reserved4[0x20];
	arch_sPort     PortA;
	arch_sPort     PortB;
	arch_sPort     PortC;
	arch_sPort     PortD;
	arch_sPort     PortE;
	arch_sPort     PortF;
	UWord16        Reserved5[0x200];
} arch_sIO;

typedef volatile struct{
	UWord16        Reserved1[0x79];
	UWord16        BusControlReg;
	UWord16        Reserved2;
	UWord16        InterruptPriorityReg;
	UWord16        Reserved3[3];
	UWord16        BusTransferReg;	
} arch_sCore;


typedef struct{
	UWord32 Channel0;
	UWord32 Channel1;
	UWord32 Channel2;
	UWord32 Channel3;
} arch_sIntTimer;

typedef struct{
	UWord32 TransmitterComplete;
	UWord32 TransmitterReady;
	UWord32 ReceiverError;
	UWord32 ReceiverFull;
} arch_sIntSCI;

typedef struct{
	UWord32        HardwareReset;
	UWord32        COPReset;
	UWord32        Reserved1;
	UWord32        IllegalInstruction;
	UWord32        Software;
	UWord32        HWStackOverflow;
	UWord32        OnCEInstruction;
	UWord32        Reserved2;
	UWord32        IrqA;
	UWord32        IrqB;
	UWord32        Reserved3;
	UWord32        BootFlash;
	UWord32        ProgramFlash;
	UWord32        DataFlash;
	UWord32        Reserved4;
	UWord32        Reserved5;
	UWord32        Reserved6;
	UWord32        Reserved7;
	UWord32        MpioF;
	UWord32        MpioE;
	UWord32        MpioD;
	UWord32        MpioC;
	UWord32        MpioB;
	UWord32        MpioA;
	UWord32        Spi1TransmitterEmpty;
	UWord32        Spi1ReceiverFullError;
	UWord32        Spi0TransmitterEmpty;
	UWord32        Spi0ReceiverFullError;
	UWord32        Reserved8;
	UWord32        Reserved9;
	UWord32        Reserved10;
	UWord32        Reserved11;
	UWord32        TODOneSecondInterrupt;
    UWord32        TODAlarmInterrupt;
	arch_sIntTimer TimerA;
	UWord32        Reserved12;
	UWord32        Reserved13;
	UWord32        Reserved14;
	UWord32        Reserved15;
	UWord32        Reserved16;
	UWord32        Reserved17;
	UWord32        Reserved18;
	UWord32        Reserved19;
	arch_sIntSCI   Sci1;
	arch_sIntSCI   Sci0;
	UWord32        Reserved20;
	UWord32        Reserved21;
	UWord32        Reserved22;
	UWord32        SSITransmitData;
	UWord32        SSITransmitDataException;
	UWord32        SSIReceiveData;
	UWord32        SSIReceiveDataException;
	UWord32        SSITRERR;
	UWord32        PllNoLock;
	UWord32        LowVoltage;
} arch_sInterrupts;

#define ARCH_IO_REGISTERS 0x1000
#define ARCH_INTERRUPTS   0x0000


/*******************************************************
* Architecture Dependent Routines
*******************************************************/

EXPORT Flag archGetLimitBit (void);

/* void archResetLimitBit (void); */
#define archResetLimitBit() asm(bfclr  #0x40,SR)

/* void archSetNoSat (void); */
#define archSetNoSat() asm(bfclr #0x10,OMR)

/* void archSetSat32 (void); */
#define archSetSat32() asm(bfset #0x10,OMR)

/* Get, then set saturation mode */
EXPORT bool archGetSetSaturationMode (bool bSatMode);

/* void archSet2CompRound (void); */
#define archSet2CompRound() asm(bfset #0x20,OMR)

/* void archSetConvRound (void); */
#define archSetConvRound() asm(bfclr #0x20,OMR)

/* void archStop (void); */
#define archStop() asm(stop)

/* void archTrap (void); */
#define archTrap() asm(swi)

/* void archWait (void); */
#define archWait() asm(wait)

/* void archEnableInt (void); */
#define archEnableInt() asm(bfset #0x0100,SR); asm(bfclr #0x0200,SR)

/* void archDisableInt (void); */
#define archDisableInt() asm(bfset #0x0300,SR)

#define archMemRead(Local, Remote, Bytes) *(Local) = *(Remote)
#define archMemWrite(Remote, Local, Bytes) *(Remote) = *(Local)

#define archCoreRegisterBitSet(Mask, Reg)      asm(bfset    Mask,Reg)
#define archCoreRegisterBitClear(Mask, Reg)    asm(bfclr    Mask,Reg)
#define archCoreRegisterBitChange(Mask, Reg)   asm(bfchg    Mask,Reg)
#define archCoreRegisterBitTestHigh(Mask, Reg) asm(bftsth   Mask,Reg)
#define archCoreRegisterBitTestLow(Mask, Reg)  asm(bftstl   Mask,Reg)

#define archMemBitSet(Mask, Addr)              asm(bfset    Mask,Addr)
#define archMemBitClear(Mask, Addr)            asm(bfclr    Mask,Addr)
#define archMemBitChange(Mask, Addr)           asm(bfchg    Mask,Addr)
#define archMemBitTestHigh(Mask, Addr)         asm(bftsth   Mask,Addr)
#define archMemBitTestLow(Mask, Addr)          asm(bftstl   Mask,Addr)


EXPORT void archStart(void);

EXPORT void archDelay(UWord16 Ticks);

/*
	Interrupt Support
*/
EXPORT UWord16 archInstallISR      (UWord32 * pIntStartAddr, void (*pISR)(void));
EXPORT UWord16 archInstallFastISR  (UWord32 * pIntStartAddr, void (*pISR)(void));
EXPORT UWord16 archInstallSFastISR (UWord32 * pIntStartAddr, void (*pISR)(void));

EXPORT void    archPushAllRegisters (void);
EXPORT void    archPopAllRegisters  (void);

EXPORT void    archPushFastInterruptRegisters (void);
EXPORT void    archPopFastInterruptRegisters  (void);

/* EXPORT void    archEnterNestedInterrupt (const int InterruptNumber); */
#define archEnterNestedInterrupt(InterruptNumber) \
			asm (lea   (SP)+); \
			asm (move  N,X:(SP)+); \
			asm (move  #InterruptNumber,N); \
			asm (jsr   archEnterNestedInterruptCommon)

/* EXPORT void    archExitNestedInterrupt (void); */
#define archExitNestedInterrupt() \
			asm (jsr   archExitNestedInterruptCommon); \
			asm (pop   N); \
			asm (rti)
			
EXPORT void archEnterNestedInterruptCommon (void); /* for internal use only */
EXPORT void archExitNestedInterruptCommon  (void); /* for internal use only */
			
EXPORT UWord16 archRemoveISR       (UWord32 * pIntStartAddr);
/* EXPORT UWord16 archRemoveFastISR   (UWord32 * pIntStartAddr); */
#define archRemoveFastISR  archRemoveISR
EXPORT UWord16 archRemoveSFastISR (UWord32 * pIntStartAddr);

EXPORT arch_sInterrupts * pArchInterrupts;

typedef struct{
	void (*pUserISR)(void);
} sUserISR;

extern UWord16 archISRType[(sizeof(arch_sInterrupts) / sizeof(UWord32) + 15) / 16];
/* ISRType is an array of bits for each interrupt
		0 => Normal interrupt
		1 => Fast interrupt
*/

extern sUserISR archUserISRTable[sizeof(arch_sInterrupts) / sizeof(UWord32)];

extern void archUnhandledInterrupt (void);

/* The location of the following structures is defined in linker.cmd */
EXPORT arch_sIO           ArchIO;
EXPORT arch_sCore         ArchCore;

#ifdef __cplusplus
}
#endif

#endif
