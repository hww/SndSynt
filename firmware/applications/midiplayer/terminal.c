#include "port.h"
#include "periph.h"
#include "arch.h"
#include "stdlib.h"
#include "timer.h"
#include "terminal.h"

static UInt16 kbdState;		//  all keys state
static UInt16 kbdTrig;		//  state 1 for pressed keys
static UInt16 kbdDelay;		//  anti-glitch delay
static UInt16 ledState;		//  LED states (1 enabled)
static UInt16 kbdPhase;		//  current scan position
static const UInt16 *ledAnimation;
static UInt16 curFrame;
UInt16 ledFlash;
UInt16 ledStatic;
UInt16 ledFlashing;

#define LED_ENA 0x40
#define KBD_ENA 0x80

struct sigevent     termTimerEvent; 
timer_t				termTimer;

const UInt16 stdAnimeR[]=
{		5,
		LED_V3,
		LED_V4,
		LED_V5,
		LED_V6,
		LED_TEACHER
};

const UInt16 stdAnimeL[]=
{		5,
		LED_TEACHER,
		LED_V6,
		LED_V5,
		LED_V4,
		LED_V3
};

const UInt16 stdAnimePP[]=
{		8,
		LED_V3,
		LED_V4,
		LED_V5,
		LED_V6,
		LED_TEACHER,
		LED_V6,
		LED_V5,
		LED_V4,
};

const UInt16 stdAnimeM[]=
{		4,
		LED_V3 | LED_TEACHER,
		LED_V4 | LED_V6,
		LED_V5,
		LED_V4 | LED_V6,
};
	
const UInt16 stdLevels[]=
{	0,
	LED_V3,
	LED_V3 | LED_V4,
	LED_V3 | LED_V4 | LED_V5,
	LED_V3 | LED_V4 | LED_V5 | LED_V6,
	LED_V3 | LED_V4 | LED_V5 | LED_V6 | LED_TEACHER  
};	

const UInt16 stdPos[]=
{	0,
	LED_V3,
	LED_V4,
	LED_V5,
	LED_V6,
	LED_TEACHER  
};	
void terminalUpdate(void)
{	UInt16 keys, trig, bit, mask, row;
	row = (kbdPhase & 3)<<4; 
	bit =  row >> 2;
	mask = 0xf << bit;
	periphMemWrite(KBD_ENA | row ,&ArchIO.PortB.DataReg); // Set Bits
	periphMemWrite(0xf0,&ArchIO.PortB.DataDirectionReg);  // Input pins
	keys      = ((~periphMemRead(&ArchIO.PortB.DataReg)) & 0xf)<<bit;	
	trig  	  = kbdState;
	kbdState = (kbdState & ~mask)|(kbdDelay & keys); 
	kbdDelay = (kbdDelay & ~mask)| keys; 
	kbdTrig |= (~trig & kbdState); 
	periphMemWrite(0xff,&ArchIO.PortB.DataDirectionReg);// All output
	periphMemWrite(LED_ENA | row | (~(ledState>>bit) & 0xf),&ArchIO.PortB.DataReg); // Set Bits
	kbdPhase++;	
	if((kbdPhase & 0x3f)==0)	terminalAnimate();
}
	
void terminalOpen(void)	
{
struct itimerspec termTimerSettings; 

	periphMemWrite(0x00,&ArchIO.PortB.PeripheralReg);	// GPIO
	periphMemWrite(0xc0,&ArchIO.PortB.DataReg);			// Set Bits
	periphMemWrite(0xff,&ArchIO.PortB.DataDirectionReg);// All output
	kbdPhase 	= 0;
	ledStatic 	= 0;
	ledFlash 	= 0;
	ledAnimation= NULL;
	termTimerEvent.sigev_notify_function = terminalUpdate; 
	timer_create(CLOCK_AUX1, &termTimerEvent, &termTimer);
	termTimerSettings.it_interval.tv_sec   = 0; 
	termTimerSettings.it_interval.tv_nsec = 2000000; 
	termTimerSettings.it_value.tv_sec = 0; 
	termTimerSettings.it_value.tv_nsec = 2000000; 
	timer_settime(termTimer, 0, &termTimerSettings, NULL);
}

Int16 terminalRead(void)
{
UInt16 i, mask;

	if(kbdTrig == 0) return KEY_NO;
	mask = 1;
	for( i=0; i<16; i++ )
	{	if((mask & kbdTrig) != 0)
		{ 	kbdTrig &= ~mask;
			return i;
		}
		mask<<=1;
	}
}

UInt16 	terminalState(void)
{
	return kbdState;
}

void  terminalAnimate(void)
{
UInt16 	 frame = 0;

	if(ledAnimation != NULL)
	{
		frame = ledAnimation[curFrame+1];
		curFrame++;
		if(curFrame >= *ledAnimation) curFrame = 0;
	}

	ledState = ledFlash ^ (ledStatic | frame);
	ledFlash = 0;
}

void terminalSetAnimate(const UInt16 * animate)
{
	ledAnimation = animate;
	curFrame = 0;
}

