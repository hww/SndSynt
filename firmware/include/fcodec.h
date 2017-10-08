/*******************************************************************************
*
* Motorola Inc.
* (c) Copyright 2001 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
********************************************************************************
*
* FILE NAME:   codec.h
*
* DESCRIPTION: header file for the Crystal CS4218 16-bit Stereo Audio
*              Codec device driver
*
*******************************************************************************/

#ifndef __FCODEC_H
#define __FCODEC_H

#include "port.h"
#include "io.h"
#include "gpio.h"

#ifdef __cplusplus
extern "C" {
#endif

/*****************************************************************************
*
* Èםעונפויס ÊÎÄÅÊÀ PCM 1717E 
*
*****************************************************************************/

/* REGISTRES OF PCM PCM1717 */

#define CODEC_REG(n) (n<<9)

/* REGISTERS ATTENUATION OF PCM1717 */

#define CODEC_ATTENUATION_MAX 255
#define CODEC_ATTENUATION_MIN 0
#define CODEC_ENA_ATT 256
#define CODEC_ATTEN_LEFT(v) (CODEC_REG(0) | (v & CODEC_ATTENUATION_MAX) | CODEC_ENA_ATT)
#define CODEC_ATTEN_RIGHT(v) (CODEC_REG(1) | (v & CODEC_ATTENUATION_MAX) | CODEC_ENA_ATT)
#define CODEC_ATTENUATION_DEF (CODEC_ATTENUATION_MAX)
/* REGISTER 2 OF PCM1717 */

#define CODEC_MUTE 1
#define CODEC_DM_DIS 0<<1
#define CODEC_DM_480 1<<1
#define CODEC_DM_441 2<<1
#define CODEC_DM_320 3<<1
#define CODEC_OPE_OFF 1<<3  
#define CODEC_IZD 1<<4
#define CODEC_REG2_INI (CODEC_REG(2) | CODEC_DM_320 )

/* REGISTER 3 OF PCM1717 */

#define CODEC_I2S 1
#define CODEC_LRC_IS_RIGHT 1<<1
#define CODEC_IW_16 0<<2
#define CODEC_IW_18 1<<2
#define CODEC_ATC_MONO 1<<3
#define CODEC_PL_MUTE 0<<4
#define CODEC_PL_STEREO 9<<4
#define CODEC_PL_REVERSE 6<<4
#define CODEC_PL_MONO 15<<4
#define CODEC_REG3_INI (CODEC_REG(3) | CODEC_IW_16 | CODEC_PL_STEREO)

void	fcodecMute( bool mute );

#ifdef __cplusplus
}
#endif


#include "fcodecdrv.h"

#endif
