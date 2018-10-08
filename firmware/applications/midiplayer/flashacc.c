/*****************************************************************************
 * @project SndSynt
 * @info Sound synthesizer library and MIDI file player.
 * @platform DSP
 * @autor Valery P. (https://github.com/hww)
 *****************************************************************************/

#include "port.h"
#include "io.h"
#include "fcntl.h"
#include "bsp.h"
#include "sdram.h"
#include "serialdataflash.h"
#include "flashacc.h"
#include "mem.h"

#define BUFFER_SIZE 528
#define FLASH_MAX_ADDR 0x20ffff

void SaveToFlash()
{
    int Flash;
    Int16 * membuf;
    UInt32  addr = 0;

    membuf = malloc(BUFFER_SIZE);

    Flash = open(BSP_DEVICE_NAME_SERIAL_DATAFLASH_0, 0, NULL);

    while (addr < FLASH_MAX_ADDR)
    {
        sdram_save(addr, membuf, BUFFER_SIZE);
        write(Flash, membuf, BUFFER_SIZE);
        addr += BUFFER_SIZE;
    }
    close(Flash);
    free(membuf);
}

void LoadFromFlash()
{
    int Flash;
    Int16 * membuf;
    UInt32  addr = 0;

    membuf = malloc(BUFFER_SIZE);

    Flash = open(BSP_DEVICE_NAME_SERIAL_DATAFLASH_0, 0, NULL);

    while (addr < FLASH_MAX_ADDR)
    {
        read(Flash, membuf, BUFFER_SIZE);
        sdram_load(addr, membuf, BUFFER_SIZE);
        addr += BUFFER_SIZE;
    }
    close(Flash);
    free(membuf);
}