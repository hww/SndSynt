/* File: bit.h */

#ifndef __BIT_H
#define __BIT_H

#include "port.h"

#ifdef __cplusplus
extern "C" {
#endif


/*******************************************************
* Bit Manipulation Operations
*******************************************************/

/* void bitSet(Mask, Addr); */
#define bitSet(Mask, Addr)              asm(bfset    Mask,Addr)

/* void bitClear(Mask, Addr); */
#define bitClear(Mask, Addr)            asm(bfclr    Mask,Addr)

/* void bitChange(Mask, Addr); */
#define bitChange(Mask, Addr)           asm(bfchg    Mask,Addr)

/* void bitTestHigh(Mask, Addr); */
#define bitTestHigh(Mask, Addr)         asm(bftsth   Mask,Addr)

/* void bitTestLow(Mask, Addr); */
#define bitTestLow(Mask, Addr)          asm(bftstl   Mask,Addr)


/* void bitWordSet(Mask, Addr); */
#define bitWordSet(Mask, Addr)   (*Addr = Mask | *Addr)

/* void bitWordClear(Mask, Addr); */
#define bitWordClear(Mask, Addr) (*Addr = Mask & *Addr)


#ifdef __cplusplus
}
#endif

#endif
