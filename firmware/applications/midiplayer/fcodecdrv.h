/*****************************************************************************
 * @project SndSynt
 * @info Sound synthesizer library and MIDI file player.
 * @platform DSP
 * @autor Valery P. (https://github.com/hww)
 *****************************************************************************/
/*****************************************************************************
 *
 * FILE NAME:   codecdrv.h
 *
 * DESCRIPTION: header file for the Crystal CS4218 16-bit Stereo Audio
 *              Codec device driver
 *
 *****************************************************************************/

#ifndef __FCODECDRV_H
#define __FCODECDRV_H

#include "port.h"
#include "arch.h"

#ifndef SDK_LIBRARY
#include "configdefines.h"

#ifndef INCLUDE_FCODEC
#error INCLUDE_FCODEC must be defined in appconfig.h to initialize the Codec Library
#endif
#endif

#include "io.h"
#include "gpio.h"
#include "fcodec.h"
#include "types.h"

#ifdef __cplusplus
extern "C" {
#endif


/* THE FOLLOWING LABELS CAN BE USED IN appconfig.h TO CONFIGURE THE CODEC.
   config.h CONTAINS THE DEFAULT SETTINGS FOR THE CODEC. */

#define CODEC_INTERRUPT_MASKED         0x0000
#define CODEC_INTERRUPT_UNMASKED       0x0800

#define CODEC_DIGITAL_OUTPUT_1_LOW     0x0000
#define CODEC_DIGITAL_OUTPUT_1_HIGH    0x0400

#define CODEC_MUTE_DISABLED            0x0000
#define CODEC_MUTE_ENABLED             0x0400

#define CODEC_LEFT_INPUT_LINE_1        0x0000
#define CODEC_LEFT_INPUT_LINE_2        0x0200

#define CODEC_RIGHT_INPUT_LINE_1       0x0000
#define CODEC_RIGHT_INPUT_LINE_2       0x0100

    EXPORT void 	fcodecOpen(void);
    EXPORT void     fcodecClose(void);
    EXPORT Int16 *  fcodecWaitBuf(void);
    EXPORT void 	fcodecStereoISR(void);
    EXPORT void 	fcodecSendCfg(UWord16 data);

    EXPORT UWord16 fsimple_ssiInitialize(arch_sSSI * pInitialState);

#ifdef __cplusplus
}
#endif

#endif
