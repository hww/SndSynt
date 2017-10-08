/* File: tfr16.h */

#ifndef __TFR16_H
#define __TFR16_H

#include "port.h"

#ifdef __cplusplus
extern "C" {
#endif

/*******************************************************
* To switch between C and assembly implementations 
*       #if 0  => assembly
*       #if 1  => C
*******************************************************/
#if 0
#define tfr16SineWaveGenIDTL     tfr16SineWaveGenIDTLC
#endif

#if 0
#define tfr16SineWaveGenRDTL     tfr16SineWaveGenRDTLC
#endif

#if 0
#define tfr16SineWaveGenRDITL    tfr16SineWaveGenRDITLC
#endif

#if 0
#define tfr16SineWaveGenRDITLQ    tfr16SineWaveGenRDITLQC
#endif

#if 0
#define tfr16SineWaveGenPAM      tfr16SineWaveGenPAMC
#endif

#if 0
#define tfr16SineWaveGenDOM      tfr16SineWaveGenDOMC
#endif

#if 0
#define tfr16WaveGenRDITLQ       tfr16WaveGenRDITLQC
#endif

#if 0
#define tfr16SinPIxLUT           tfr16SinPIxLUTC
#endif

#if 0
#define tfr16CosPIxLUT           tfr16CosPIxLUTC
#endif

/*******************************************************
* Trigonometric Functions for 16-bit Fractional
*******************************************************/

EXPORT Frac16 tfr16SinPIx      (Frac16 x);

EXPORT Frac16 tfr16CosPIx      (Frac16 x);

EXPORT Frac16 tfr16AsinOverPI  (Frac16 x);

EXPORT Frac16 tfr16AcosOverPI  (Frac16 x);

EXPORT Frac16 tfr16AtanOverPI  (Frac16 x);

EXPORT Frac16 tfr16Atan2OverPI (Frac16 y, Frac16 x);

/*******************************************************
* Sine Wave Generation Functions for 16-bit Fractional 
*******************************************************/

/* Table lookup method via integer delta */
typedef struct tfr16_sSineWaveGenIDTL
{
	Word16 PrivateData[5]; /* Private data for the IDTL sine generation function */
}tfr16_tSineWaveGenIDTL;

EXPORT tfr16_tSineWaveGenIDTL * tfr16SineWaveGenIDTLCreate(Frac16 * pSineTable,
																			  UInt16   SineTableLength,
																			  UInt16   SineFreq,
																			  UInt16   SampleFreq,
																			  Frac16   InitialPhasePIx);

EXPORT void tfr16SineWaveGenIDTLDestroy(tfr16_tSineWaveGenIDTL * pSWG);
													

EXPORT void tfr16SineWaveGenIDTLInit(tfr16_tSineWaveGenIDTL * pSWG,
												 Frac16                 * pSineTable,
												 UInt16                   SineTableLength,
												 UInt16                   SineFreq,
                             			 UInt16                   SampleFreq,
												 Frac16                   InitialPhasePIx);

EXPORT void tfr16SineWaveGenIDTL(tfr16_tSineWaveGenIDTL * pSWG, Frac16 * pValues, UInt16 Nsamples);

/* Table lookup method via real delta */
typedef struct tfr16_sSineWaveGenRDTL
{
	Word16 PrivateData[4]; /* Private data for the RDTL sine generation function */
}tfr16_tSineWaveGenRDTL;

EXPORT tfr16_tSineWaveGenRDTL * tfr16SineWaveGenRDTLCreate(Frac16 * pSineTable,
																			  UInt16   SineTableLength,
																			  UInt16   SineFreq,
																			  UInt16   SampleFreq,
																			  Frac16   InitialPhasePIx);

EXPORT void tfr16SineWaveGenRDTLDestroy(tfr16_tSineWaveGenRDTL * pSWG);


EXPORT void tfr16SineWaveGenRDTLInit(tfr16_tSineWaveGenRDTL * pSWG,
												 Frac16                 * pSineTable,
												 UInt16                   SineTableLength,
												 UInt16                   SineFreq,
                                     UInt16                   SampleFreq,
												 Frac16                   InitialPhasePIx);

EXPORT void tfr16SineWaveGenRDTL(tfr16_tSineWaveGenRDTL * pSWG, Frac16 * pValues, UInt16 Nsamples);


/* Table lookup method via real delta with interpolation */
typedef struct tfr16_sSineWaveGenRDITL
{
	Word16 PrivateData[5]; /* Private data for the RDITL sine generation function */
}tfr16_tSineWaveGenRDITL;

EXPORT tfr16_tSineWaveGenRDITL * tfr16SineWaveGenRDITLCreate(Frac16 * pSineTable,
																				 UInt16   SineTableLength,
																				 UInt16   SineFreq,
																				 UInt16   SampleFreq,
																				 Frac16   InitialPhasePIx);

EXPORT void tfr16SineWaveGenRDITLDestroy(tfr16_tSineWaveGenRDITL * pSWG);


EXPORT void tfr16SineWaveGenRDITLInit(tfr16_tSineWaveGenRDITL * pSWG,
												  Frac16                  * pSineTable,
												  UInt16                    SineTableLength,
												  UInt16                    SineFreq,
												  UInt16                    SampleFreq,
												  Frac16                    InitialPhasePIx);

EXPORT void tfr16SineWaveGenRDITL(tfr16_tSineWaveGenRDITL * pSWG, Frac16 * pValues, UInt16 Nsamples);


/* Table lookup method via real delta with interpolation, quarter of a sine LUT */
typedef struct tfr16_sSineWaveGenRDITLQ
{
	Word16 PrivateData[5]; /* Private data for the RDITLQ sine generation function */
}tfr16_tSineWaveGenRDITLQ;

EXPORT tfr16_tSineWaveGenRDITLQ * tfr16SineWaveGenRDITLQCreate(Frac16 * pSineTable,
																				 UInt16   SineTableLength,
																				 UInt16   SineFreq,
																				 UInt16   SampleFreq,
																				 Frac16   InitialPhasePIx);

EXPORT void tfr16SineWaveGenRDITLQDestroy(tfr16_tSineWaveGenRDITLQ * pSWG);


EXPORT void tfr16SineWaveGenRDITLQInit(tfr16_tSineWaveGenRDITLQ * pSWG,
												  Frac16                    * pSineTable,
												  UInt16                      SineTableLength,
												  UInt16                      SineFreq,
												  UInt16                      SampleFreq,
												  Frac16                      InitialPhasePIx);

EXPORT void tfr16SineWaveGenRDITLQ(tfr16_tSineWaveGenRDITLQ * pSWG, Frac16 * pValues, UInt16 Nsamples);


/* Digital oscillator method */
typedef struct tfr16_sSineWaveGenDOM
{
	Word16 PrivateData[3]; /* Private data for the Digital Oscillator method */
}tfr16_tSineWaveGenDOM;

EXPORT tfr16_tSineWaveGenDOM * tfr16SineWaveGenDOMCreate(UInt16   SineFreq,
																		   UInt16   SampleFreq,
																		   Frac16   InitialPhasePIx,
																		   Frac16   Amplitude);

EXPORT void tfr16SineWaveGenDOMDestroy(tfr16_tSineWaveGenDOM * pSWG);


EXPORT void tfr16SineWaveGenDOMInit(tfr16_tSineWaveGenDOM * pSWG,
												UInt16                  SineFreq,
												UInt16                  SampleFreq,
												Frac16                  InitialPhasePIx,
												Frac16                  Amplitude);

EXPORT void tfr16SineWaveGenDOM(tfr16_tSineWaveGenDOM * pSWG, Frac16 * pValues, UInt16 Nsamples);

/* Polynomial approximation method */ 
typedef struct tfr16_sSineWaveGenPAM
{
	Word16 PrivateData[4]; /* Private data for the polynomial approximation method */ 
}tfr16_tSineWaveGenPAM;

EXPORT tfr16_tSineWaveGenPAM * tfr16SineWaveGenPAMCreate(UInt16   SineFreq,
																		   UInt16   SampleFreq,
																		   Frac16   InitialPhasePIx,
																		   Frac16   Amplitude);

EXPORT void tfr16SineWaveGenPAMDestroy(tfr16_tSineWaveGenPAM * pSWG);


EXPORT void tfr16SineWaveGenPAMInit(tfr16_tSineWaveGenPAM * pSWG,
												UInt16                  SineFreq,
												UInt16                  SampleFreq,
												Frac16                  InitialPhasePIx,
												Frac16                  Amplitude);
	
EXPORT void tfr16SineWaveGenPAM(tfr16_tSineWaveGenPAM * pSWG, Frac16 * pValues, UInt16 Nsamples);


/* Table lookup method via real delta with interpolation, quarter of a sine LUT */
typedef struct tfr16_sWaveGenRDITLQ
{
	Word16 PrivateData[4]; /* Private data for the RDITLQ wave generation function */
}tfr16_tWaveGenRDITLQ;

EXPORT tfr16_tWaveGenRDITLQ * tfr16WaveGenRDITLQCreate(Frac16 * pSineTable,
																		 UInt16   SineTableLength,
																		 Frac16   InitialPhasePIx);

EXPORT void tfr16WaveGenRDITLQDestroy(tfr16_tWaveGenRDITLQ * pSWG);


EXPORT void tfr16WaveGenRDITLQInit(tfr16_tWaveGenRDITLQ * pSWG,
												Frac16              * pSineTable,
												UInt16                SineTableLength,
												Frac16                InitialPhasePIx);

EXPORT Frac16 tfr16WaveGenRDITLQ(tfr16_tWaveGenRDITLQ * pSWG, Frac16 PhaseIncrement);


/* Table lookup method via real delta with interpolation, quarter of a sine LUT */
typedef struct tfr16_sSinPIxLUT
{
	Word16 PrivateData[3]; /* Private data for the SinPIxLUT function */
}tfr16_tSinPIxLUT;

EXPORT tfr16_tSinPIxLUT * tfr16SinPIxLUTCreate(Frac16 * pSineTable,
															 UInt16   SineTableLength);

EXPORT void tfr16SinPIxLUTDestroy(tfr16_tSinPIxLUT * pSWG);


EXPORT void tfr16SinPIxLUTInit(tfr16_tSinPIxLUT * pSWG,
										Frac16            * pSineTable,
										UInt16              SineTableLength);

EXPORT Frac16 tfr16SinPIxLUT(tfr16_tSinPIxLUT * pSWG, Frac16 PhasePIx);


/* Table lookup method via real delta with interpolation, quarter of a sine LUT */
typedef struct tfr16_sCosPIxLUT
{
	Word16 PrivateData[3]; /* Private data for the CosPIxLUT function */
}tfr16_tCosPIxLUT;

EXPORT tfr16_tCosPIxLUT * tfr16CosPIxLUTCreate(Frac16 * pSineTable,
															 UInt16   SineTableLength);

EXPORT void tfr16CosPIxLUTDestroy(tfr16_tCosPIxLUT * pSWG);


EXPORT void tfr16CosPIxLUTInit(tfr16_tCosPIxLUT * pSWG,
										Frac16            * pSineTable,
										UInt16              SineTableLength);

EXPORT Frac16 tfr16CosPIxLUT(tfr16_tCosPIxLUT * pSWG, Frac16 PhasePIx);

#ifdef __cplusplus
}
#endif

#endif
