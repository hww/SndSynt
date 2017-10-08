/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name:         appconst.c
*
* Description:       Description of Application constant
*
* Modules Included:  
*                    
* 
*****************************************************************************/

const char ArchTestStartMsg[] = "Test arch.h file";

const char ArchResetLimitFailedMsg[] = "archResetLimitBit did not reset the limit bit";

const char ArchGetLimitFailedMsg[] = "archGetLimitBit did not return the correct value";

const char IntTestStartMsg[]     = "Test interrupts";
const char IntSWIFailedMsg[]     = "SWI Interrupt failed";
const char IntDispatcherFailed[] = "Dispatcher failed";
const char IntPushAllFailed[]    = "archPushAllRegisters failed";
const char IntPushFastInterruptFailed[]    = "archPushFastInterruptRegisters failed";
const char IntFastDispatcherFailed[]    = "Fast Dispatcher failed";

const int LocalPData16 [] = {
		0x1234,
		0x5678,
		0x4321,
		0x8765
		};
		
const long LocalPData32 [] = {
		0x12345678,
		0x23456789,
		0x3456789A,
		0x456789AB,
		0x56789ABC,
		0x6789ABCD,
		0x789ABCDE,
		0x89ABCDEF
		};

const char MemTestStartMsg[] = "Test mem.* files";
const char MemTestingMemset[] = "Testing memset";
const char MemMemMemsetOverrun[] = "memMemset overrun";

const char MemMemMemsetDidNotWork[] = "memMemset did not work";
const char MemMemsetOverrun[] = "memset overrun";
const char MemMemsetDidNotWork[] = "memset did not work";
const char MemTestingMemcpy[] = "Testing memcpy";
const char MemMemMemcpyOverrun[] = "memMemcpy overrun";
const char MemMemMemcpyDidNotWork[] = "memMemcpy did not work";
const char MemMemcpyDidNotWork[] = "memcpy did not work";
const char MemTestingPMemRoutines[] = "Testing P mem routines on data allocated in ASM";
const char MemMemReadP16Failed[] = "memReadP16 failed";
const char MemMemReadP32Failed[] = "memReadP32 failed";
const char MemMemWriteP16Failed[] = "memWriteP16 failed";
const char MemMemWriteP32[] = "memWriteP32 failed";
const char MemMemCpyFromPUpdate[] = "memCpyFromP pointer update";
const char MemMemCpyFromP[] = "memCpyFromP failed";
const char MemMemCpyToPUpdate[] = "memCpyToP pointer update";
const char MemMemCpyToP[] = "memCpyToP failed";
const char MemMemTestingPMem[] = "Testing P mem routines on data allocated in C";
const char MemTestingPMemASMRoutines[] = "Testing P mem routines on data allocated in C";

const char ProtoTestStartMsg[] = "Test prototype.h";
const char ProtoAddFailed[] = "add failed";
const char ProtoSubFailed[] = "sub failed";
const char ProtoAbsFailed[] = "abs_s failed";
const char ProtoShlFailed[] = "shl failed";
const char ProtoShrFailed[] = "shr failed";
const char ProtoMultFailed[] = "mult failed";
const char ProtoMultRFailed[] = "mult_r failed";
const char ProtoNegateFailed[] = "negate failed";
const char ProtoExtractHFailed[] = "extract_h failed";
const char ProtoExtractLFailed[] = "extract_l failed";
const char ProtoRoundFailed[] = "round failed";
const char ProtoDivsFailed[] = "div_s failed";
const char ProtoLAddFailed[] = "L_add failed";
const char ProtoLSubFailed[] = "L_sub failed";
const char ProtoLabsFailed[] = "L_abs failed";
const char ProtoLshlFailed[] = "L_shl failed";
const char ProtoLshrFailed[] = "L_shr failed";
const char ProtoLmultFailed[] = "L_mult failed";
const char ProtoLmultlsFailed[] = "L_mult_ls failed";
const char ProtoLnegateFailed[] = "L_negate failed";
const char ProtoDivlsFailed[] = "div_ls failed";
const char ProtoMacrFailed[] = "mac_r failed";
const char ProtoMsurFailed[] = "msu_r failed";
const char ProtoLmacFailed[] = "L_mac failed";
const char ProtoLmsuFailed[] = "L_msu failed";
const char ProtoLdeposithFailed[] = "L_deposit_h failed";
const char ProtoLdepositlFailed[] = "L_deposit_l failed";
const char ProtoNormsFailed[] = "norm_s failed";
const char ProtoNormlFailed[] = "norm_l failed";

const char TimeSpecTestStartMsg[] = "Test timespec.h";
const char TimeSpecTestAdd1Msg[] = "Add #1 failed";
const char TimeSpecTestAdd2Msg[] = "Add #2 failed";
const char TimeSpecTestAdd3Msg[] = "Add #3 failed";
const char TimeSpecTestAdd4Msg[] = "Add #4 failed";
const char TimeSpecTestAdd5Msg[] = "Add #5 failed";
const char TimeSpecTestSub1Msg[] = "Sub #1 failed";
const char TimeSpecTestSub2Msg[] = "Sub #2 failed";
const char TimeSpecTestSub3Msg[] = "Sub #3 failed";
const char TimeSpecTestSub4Msg[] = "Sub #4 failed";
const char TimeSpecTestSub5Msg[] = "Sub #5 failed";
const char TimeSpecTestGE1Msg[]  = "GE #1 failed";
const char TimeSpecTestGE2Msg[]  = "GE #2 failed";
const char TimeSpecTestGE3Msg[]  = "GE #3 failed";
const char TimeSpecTestGE4Msg[]  = "GE #4 failed";
const char TimeSpecTestGE5Msg[]  = "GE #5 failed";

