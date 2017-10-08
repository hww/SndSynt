/* File: periph.h */

#ifndef __PERIPH_H
#define __PERIPH_H

#include "port.h"


#ifdef __cplusplus
extern "C" {
#endif


/*******************************************************
* Routines for Peripheral Memory Access
********************************************************
*  Parameter usage:
*   Addr - architecture structure field 
*   Mask - bit to manipulate 
*   Data - 16 bit word to assign or access  
********************************************************/


/* void periphBitSet(UWord16 Mask, volatile UWord16 * Addr); */
#define periphBitSet(Mask, Addr)        *(Addr) |= Mask
                                        /* asm(bfset Mask,Addr) */

/* void periphBitClear(UWord16 Mask, volatile UWord16 * Addr); */
#define periphBitClear(Mask, Addr)      *(Addr) &= ~(Mask)
                                         /* asm(bfclr    Mask,Addr) */

/* void periphBitChange(UWord16 Mask, volatile UWord16 * Addr); */
#define periphBitChange(Mask, Addr)     *(Addr) ^= Mask
                                        /* asm(bfchg    Mask,Addr) */

/* bool periphBitTest(UWord16 Mask, volatile UWord16 * Addr); */
#define periphBitTest(Mask, Addr)       ( *(Addr) & (Mask) )


/* void periphBitWordSet(UWord16 Mask, volatile UWord16 * Addr); */
#define periphBitWordSet(Mask, Addr)   (*Addr = Mask | *Addr)

/* void periphBitWordClear(UWord16 Mask, volatile UWord16 * Addr); */
#define periphBitWordClear(Mask, Addr) (*Addr = Mask & *Addr)



/* UWord16 periphMemRead(volatile UWord16 * Addr); */
#define periphMemRead(Addr) ((UWord16)(*Addr))

/* void periphMemWrite(UWord16 Data, volatile UWord16 * Addr); */
#define periphMemWrite(Data, Addr) ( (*(Addr)) = Data )




#ifdef __cplusplus
}
#endif

#endif
