/*****************************************************************************
* @project SndSynt
* @info Sound synthesizer library and MIDI file player.
* @platform DSP
* @autor Valery P. (https://github.com/hww)
*****************************************************************************/

#include "port.h"
#include "audiolib.h"
#include "tfr16.h"
#include "mfr16.h"

/*
 * Number of osc states needed. In worst case will need two for each
 * voice. But if tremelo and vibrato not used on all instruments will
 * need less.
 */
#define  OSC_STATE_COUNT   MAX_VOICES 
oscData  *freeOscStateList;
oscData  oscStates[OSC_STATE_COUNT];

/*****************************************************************************
 *
 *	ALMicroTime initOsc(void **oscState, f32 *initVal,  u8 oscType,
 *                         u8   oscRate,   u8  oscDepth, u8 oscDelay)
 *
 *	oscState	pointer to OSC
 *	initVal		start value
 *	oscType		vibrato type
 *	oscRate		vibrato frequency
 *	oscDepth	vibrato depth
 *	oscDelay	vibrato delay
 *
 *****************************************************************************/

ALMicroTime initOsc(void **oscState, Int32 *initVal,UInt16 oscType,
                    UInt16 oscRate,UInt16 oscDepth,UInt16 oscDelay)
{
    oscData         *statePtr;
    ALMicroTime     deltaTime = 0;
    Int16			frames = oscRate / (FRAME_TIME_US/1000);

    if(freeOscStateList)  /* yes there are oscStates available */
    {
        statePtr = freeOscStateList;
        freeOscStateList = freeOscStateList->next;
        statePtr->type = oscType;
        *oscState = statePtr;

        // Convert delay to microseconds
        deltaTime = (ALMicroTime)(oscDelay+1) * 1000;

        switch(oscType) // reset to initial state
        {
            case VIBRATO_SIN:
                statePtr->data.vsin.depthcents = oscDepth;
                statePtr->curCount = 0;
                statePtr->maxCount = 4+frames; 	    // values 4-259
                *initVal = 0; 						// start pitch 
                break;

            case VIBRATO_SQR:
                {
                    Int16     cents;
                    statePtr->maxCount = frames+1;  // values 1-256
                    statePtr->curCount = statePtr->maxCount;
                    statePtr->stateFlags = OSC_HIGH;
                    cents = oscDepth;
                    statePtr->data.vsqr.loRatio = -cents;
                    statePtr->data.vsqr.hiRatio =  cents;
                    *initVal = statePtr->data.vsqr.hiRatio;
                }
                break;
                    
            case VIBRATO_DSC_SAW:
                {
                    Int16     cents;
                    statePtr->maxCount = frames+1; // values 1-256 
                    statePtr->curCount = statePtr->maxCount;
                    cents = oscDepth;
                    statePtr->data.vdsaw.hicents 	= cents;
                    statePtr->data.vdsaw.centsrange = 2 * cents;
                    *initVal = statePtr->data.vdsaw.hicents;
                }
                break;
                
            case VIBRATO_ASC_SAW:
                {
                    Int16     cents;
                    statePtr->maxCount = frames+1; // values 1-256
                    statePtr->curCount = statePtr->maxCount;
                    cents = oscDepth;
                    statePtr->data.vasaw.locents = -cents;
                    statePtr->data.vasaw.centsrange = 2 * cents;
                    *initVal = statePtr->data.vasaw.locents;
                }
                break;

        }
    }
	/* if there are no oscStates, return zero, but if
	oscState was available, return delay in usecs */
    return(deltaTime); 
}

/*****************************************************************************
 *
 *	ALMicroTime updateOsc(void *oscState, f32 *updateVal)
 *
 *	oscState	pointer to OSC
 *	updateVal	pointer to target value (modified by OSC)
 *
 *****************************************************************************/

ALMicroTime updateOsc(void *oscState, Int32 *updateVal)
{
    Frac32           tmp32;
    Frac16			 tmp16;
    oscData         *statePtr = (oscData*)oscState;
    ALMicroTime     deltaTime = FRAME_TIME_US; // callback every

    switch(statePtr->type)   /* perform update calculations */
    {
        case VIBRATO_SIN:
            /* calculate a sin value (from -1 to 1) and multiply it by depth-cents.
               Then convert cents to ratio. */

            statePtr->curCount++;
            if(statePtr->curCount >= statePtr->maxCount)
                statePtr->curCount = 0;
            tmp16  = div_s(statePtr->curCount , statePtr->maxCount)<<1;
 
            if(tmp16 == 0x4000)tmp16 = 0xc000;
            else if(tmp16 == 0xC000)tmp16 = 0x4000; 

            tmp16  = tfr16SinPIx (tmp16);
            tmp16  = mult(statePtr->data.vsin.depthcents, tmp16);
            *updateVal = tmp16;
            break;
            
        case VIBRATO_SQR:
            if(statePtr->stateFlags == OSC_HIGH)
            {
                statePtr->stateFlags = OSC_LOW;
                *updateVal = statePtr->data.vsqr.loRatio;
            }
            else
            {
                statePtr->stateFlags = OSC_HIGH;
                *updateVal = statePtr->data.vsqr.hiRatio;
            }
            deltaTime *= statePtr->maxCount;
            break;

        case VIBRATO_DSC_SAW:
            statePtr->curCount++;
            if(statePtr->curCount > statePtr->maxCount)
                statePtr->curCount = 0;
            tmp16 = div_s(statePtr->curCount , statePtr->maxCount);
            tmp16 = mult( tmp16, statePtr->data.vdsaw.centsrange);
            tmp16 = statePtr->data.vdsaw.hicents - tmp16;
            *updateVal = tmp16;
            break;
            
        case VIBRATO_ASC_SAW:
            statePtr->curCount++;
            if(statePtr->curCount > statePtr->maxCount)
                statePtr->curCount = 0;
            tmp16  = div_s(statePtr->curCount , statePtr->maxCount);
            tmp16  = mult(tmp16, statePtr->data.vasaw.centsrange);
            tmp16 += statePtr->data.vasaw.locents;
            *updateVal = tmp16;
            break;
    }
    
    return(deltaTime);
}

/*****************************************************************************
 *
 *	void stopOsc(void *oscState)
 *
 *	oscState	pointer to OSC structure
 *
 *****************************************************************************/

void stopOsc(void *oscState)
{
    ((oscData*)oscState)->next = freeOscStateList;
    freeOscStateList = (oscData*)oscState;
}

void createAllOsc( void )
{
oscData * oscStatePtr;
int i;

    freeOscStateList = &oscStates[0];
    oscStatePtr = &oscStates[0];

    for(i=0;i<(OSC_STATE_COUNT-1);i++)
    {   oscStatePtr->next = &oscStates[i+1];
        oscStatePtr = oscStatePtr->next;
    }
    oscStatePtr->next = 0; // last should be 0
}