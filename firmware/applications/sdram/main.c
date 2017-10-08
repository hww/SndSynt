/* File: main.c */

#include "port.h"
#include "sdramdrv.h"
#include <stdio.h>

/*******************************************************
* Skeleton C main program for use with Embedded SDK
*******************************************************/
#define SIZETST 0x100000L
#define L2W(v) (Int16)(v>>16),(Int16)v
#define ERR16 
#define ERR32 

void main (void)
{
	/* 
		This program serves as a quick start guide to
		writing either C or ASM programs using the
		Embedded SDK.  Modify it at will
	*/
int vers;
UInt32 ad;
Int32 d,td;
Int16 d16,td16;
	
	vers =	sdram_init();
	
	printf("Start data 32 bits test\n");
	
	for( ad = 1; ad != 0; ad= ad<<1)
	{
		sdram_write32( 0, ad );
		d = sdram_read32(0);
		if(d != ad ) 
		{
			  printf("Err: W=%04x%04x R=%04x%04x\n",L2W(ad),L2W(d)); 
			  d16 = sdram_read16(ad); 
			  td16 = sdram_read16(ad+1); 
			  printf("                R=%04x%04x\n",td16,d16); 
		}
	}
	printf(" Ok\nEnd 32\n");
	
	printf("Start of 16 bits test!\n");
	printf(" Write to mem\n");
	
	td16=0x0;
	for( ad = 0; ad < SIZETST; ad+=1)
	{
		sdram_write16(ad, td16);
		td16++;
	}
	
	printf(" Writen\n Veify now\n");
	
	td16=0x0;
	for( ad = 0; ad < SIZETST; ad+=1)
	{
		d16 = sdram_read16(ad);
		if(d16 != td16)	printf("Err: A=%04x%04x W=%04x R=%04x\n",L2W(ad),td16,d16);
		td16++;
	}
	printf(" Ok\nEnd test\n");
	
	printf("Start of 32 bits test\n");
	printf(" Write to mem\n");
	
	td = 0;
	for( ad = 0; ad < SIZETST; ad+=2)
	{
		sdram_write32(ad, td);
		td+=2;
	}
	
	printf(" Writen\n Veify now\n");
	
	td = 0;
	for( ad = 0; ad < SIZETST; ad+=2)
	{
		d = sdram_read32(ad);
		if(d != td ) 
		{
			  printf("Err: A=%04x%04x W=%04x%04x R=%04x%04x\n",L2W(ad),L2W(td),L2W(d)); 
			  d16 = sdram_read16(ad); 
			  td16 = sdram_read16(ad+1); 
			  printf("                           R=%04x%04x\n",td16,d16); 
		}
		td+=2;
	}
	printf(" Ok\nEnd 32\n");
	return;          /* C statements */
}
