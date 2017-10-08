#ifndef __SDRAMDRV_H
#define __SDRAMDRV_H

#include "port.h"
#include "sdram.h"
#include "size_t.h"

#ifdef __cplusplus
extern "C" {
#endif

Int16 sdram_init(void);
Int16 sdram_read16( UInt32 addr );
Int32 sdram_read32( UInt32 addr );
void sdram_write16( UInt32 addr, Int16 data );
void sdram_write32( UInt32 addr, Int32 data );
UInt32 sdram_save( UInt32 addr, UWord16 * dst, size_t size );
UInt32 sdram_load( UInt32 addr, UWord16 * src, size_t size );
void sdram_load_64( UInt32 addr, UWord16 * dst, size_t size );
int sdram_load_file( int Fd, UInt32 addr, UInt32 nWords );

#ifdef __cplusplus
}
#endif

#endif