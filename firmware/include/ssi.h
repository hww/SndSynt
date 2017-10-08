/*****************************************************************************
*
* Motorola Inc.
* (c) Copyright 2001 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
******************************************************************************
*
* File Name:         ssi.h
*
* Description:       SSI driver for DSP5682x header file.
*                    Constants, configuration parameters and 
*                    data types definition.
*
* Notes:             
*
*****************************************************************************/

#ifndef __SSI_H
#define __SSI_H

#include "port.h"
#include "arch.h"

#include "ssidrv.h"

#ifdef __cplusplus
extern "C" {
#endif

/***************************************************************************************/
/*                   SSI registers bit's description                                   */
/*                 For old CODEC driver compatibility                                  */
/***************************************************************************************/

/* SCSR - SSI CONTROL/STATUS REGISTER */
#define SSI_TX_FIFO_EMPTY        0x0001
#define SSI_RX_FIFO_FULL         0x0002
#define SSI_RX_FRAME_SYNC        0x0004
#define SSI_TX_FRAME_SYNC        0x0008
#define SSI_TX_UNDERRUN_ERROR    0x0010
#define SSI_RX_OVERRUN_ERROR     0x0020
#define SSI_TX_DATA_REG_EMPTY    0x0040
#define SSI_RX_DATA_READY        0x0080
#define SSI_RX_EARLY_FRAME_SYNC  0x0100
#define SSI_RX_FRAME_SYNC_LENGTH 0x0200
#define SSI_RX_FRAME_SYNC_INVERT 0x0400
#define SSI_TX_DMA_ENABLE        0x0800
#define SSI_RX_DMA_ENABLE        0x1000
#define SSI_RX_CLOCK_POLARITY    0x2000 
#define SSI_RX_SHIFT_DIRECTION   0x4000
#define SSI_DIVIDER_4_DISABLE    0x8000

/* SCR2 - SSI CONTROL REGISTER 2 */
#define SSI_TX_EARLY_FRAME_SYNC  0x0001
#define SSI_TX_FRAME_SYNC_LENGTH 0x0002
#define SSI_TX_FRAME_SYNC_INVERT 0x0004
#define SSI_NETWORK_MODE         0x0008
#define SSI_ENABLE               0x0010
#define SSI_TX_CLOCK_POLARITY    0x0020
#define SSI_TX_SHIFT_DIRECTION   0x0040
#define SSI_SYNCHRONOUS_MODE     0x0080
#define SSI_TX_CLOCK_DIRECTION   0x0100
#define SSI_RX_CLOCK_DIRECTION   0x0200
#define SSI_TX_FIFO_ENABLE       0x0400
#define SSI_RX_FIFO_ENABLE       0x0800
#define SSI_TX_ENABLE            0x1000
#define SSI_RX_ENABLE            0x2000
#define SSI_TX_INTERRUPT_ENABLE  0x4000
#define SSI_RX_INTERRUPT_ENABLE  0x8000

/* SFCSR - SSI FIFO CONTROL/STATUS REGISTER */
#define SSI_TX_FIFO_WATERMARK    0x000F
#define SSI_RX_FIFO_WATERMARK    0x00F0
#define SSI_TX_FIFO_COUNTER      0x0F00
#define SSI_RX_FIFO_COUNTER      0xF000

/* SOR - SSI OPTION REGISTER */
#define SSI_SYNC_RESET           0x0001
#define SSI_STATE_INIT           0x0008
#define SSI_TX_FRAME_SYNC_DIRECTION 0x0010
#define SSI_RX_FRAME_SYNC_DIRECTION 0x0020
    

/* #define SSI_SYNC_MODE           */
#define SSI_SYNC_IN                0
#define SSI_SYNC_OUT               1
#define SSI_GATED_IN               2
#define SSI_GATED_OUT              3

/* #define SSI_FRAME_LENGTH        */
#define SSI_FRAME_LENGTH_2_WORDS   0
#define SSI_FRAME_LENGTH_4_WORDS   1
#define SSI_FRAME_LENGTH_8_WORDS   2

/* #define SSI_WORD_LENGTH         */
#define SSI_WORD_LENGTH_8_BITS     0
#define SSI_WORD_LENGTH_10_BITS    1
#define SSI_WORD_LENGTH_12_BITS    2
#define SSI_WORD_LENGTH_16_BITS    3

/* #define SSI_SHIFT_DIRECTION     */
#define SSI_LSB_FIRST              0 
#define SSI_MSB_FIRST              1 

/* #define SSI_CLOCK_POLARITY      */
#define SSI_CLOCK_RISING_EDGE      0
#define SSI_CLOCK_FALLING_EDGE     1

/* #define SSI_FSYNC_LEVEL         */
#define SSI_FSYNC_LOW_ACTIVE       0
#define SSI_FSYNC_HIGH_ACTIVE      1

/* #define SSI_SYNC_FRAME_LENGTH   */
#define SSI_FSYNC_BIT_LENGTH       0
#define SSI_FSYNC_WORD_LENGTH      1

/* #define SSI_SYNC_FARME_EARLY    */
#define SSI_FSYNC_BIT_BEFORE       0
#define SSI_FSYNC_BIT_FIRST        1

/* #define SSI_PRESCALER_RANGE     */
#define SSI_PRESCALER_1            0
#define SSI_PRESCALER_4            1
#define SSI_PRESCALER_8            2
#define SSI_PRESCALER_64           3

/* #define SSI_PRESCALER_MODULE    */

/* #define SSI_FIFO_DEPTH          */
#define SSI_FIFO_8                 8
#define SSI_FIFO_16                16
#define SSI_FIFO_32                32
#define SSI_FIFO_64                64
#define SSI_FIFO_128               128
#define SSI_FIFO_256               256

#ifdef __cplusplus
}
#endif

#endif

