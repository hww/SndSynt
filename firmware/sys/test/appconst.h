/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name:         appconst.h
*
* Description:       Description of Application constant for appconst.c file
*
* Modules Included:  
*                    
* 
*****************************************************************************/

#ifndef __APPCONST_H
#define __APPCONST_H

extern const char ArchTestStartMsg[];

extern const char ArchResetLimitFailedMsg[];

extern const char ArchGetLimitFailedMsg[];

const char IntTestStartMsg[];
const char IntSWIFailedMsg[];
const char IntDispatcherFailed[];
const char IntPushAllFailed[];
const char IntPushFastInterruptFailed[];
const char IntFastDispatcherFailed[];

extern const int LocalPData16 [4];
		
extern const long LocalPData32 [8];

extern const char MemTestStartMsg[];
extern const char MemTestingMemset[];
extern const char MemMemMemsetOverrun[];
extern const char MemMemMemsetDidNotWork[];
extern const char MemMemsetOverrun[];
extern const char MemMemsetDidNotWork[];
extern const char MemTestingMemcpy[];
extern const char MemMemMemcpyOverrun[];
extern const char MemMemMemcpyDidNotWork[];
extern const char MemMemcpyDidNotWork[];
extern const char MemTestingPMemRoutines[];
extern const char MemMemReadP16Failed[];
extern const char MemMemReadP32Failed[];
extern const char MemMemWriteP16Failed[];
extern const char MemMemWriteP32[];
extern const char MemMemCpyFromPUpdate[];
extern const char MemMemCpyFromP[];
extern const char MemMemCpyToPUpdate[];
extern const char MemMemCpyToP[];
extern const char MemMemTestingPMem[];
extern const char MemTestingPMemASMRoutines[];

extern const char ProtoTestStartMsg[];
extern const char ProtoAddFailed[];
extern const char ProtoSubFailed[];
extern const char ProtoAbsFailed[];
extern const char ProtoShlFailed[];
extern const char ProtoShrFailed[];
extern const char ProtoMultFailed[];
extern const char ProtoMultRFailed[];
extern const char ProtoNegateFailed[];
extern const char ProtoExtractHFailed[];
extern const char ProtoExtractLFailed[];
extern const char ProtoRoundFailed[];
extern const char ProtoDivsFailed[];
extern const char ProtoLAddFailed[];
extern const char ProtoLSubFailed[];
extern const char ProtoLabsFailed[];
extern const char ProtoLshlFailed[];
extern const char ProtoLshrFailed[];
extern const char ProtoLmultFailed[];
extern const char ProtoLmultlsFailed[];
extern const char ProtoLnegateFailed[];
extern const char ProtoDivlsFailed[];
extern const char ProtoMacrFailed[];
extern const char ProtoMsurFailed[];
extern const char ProtoLmacFailed[];
extern const char ProtoLmsuFailed[];
extern const char ProtoLdeposithFailed[];
extern const char ProtoLdepositlFailed[];
extern const char ProtoNormsFailed[];
extern const char ProtoNormlFailed[];

extern const char TimeSpecTestStartMsg[];
extern const char TimeSpecTestAdd1Msg[];
extern const char TimeSpecTestAdd2Msg[];
extern const char TimeSpecTestAdd3Msg[];
extern const char TimeSpecTestAdd4Msg[];
extern const char TimeSpecTestAdd5Msg[];
extern const char TimeSpecTestSub1Msg[];
extern const char TimeSpecTestSub2Msg[];
extern const char TimeSpecTestSub3Msg[];
extern const char TimeSpecTestSub4Msg[];
extern const char TimeSpecTestSub5Msg[];
extern const char TimeSpecTestGE1Msg[];
extern const char TimeSpecTestGE2Msg[];
extern const char TimeSpecTestGE3Msg[];
extern const char TimeSpecTestGE4Msg[];
extern const char TimeSpecTestGE5Msg[];

#endif /* __APPCONST_H */