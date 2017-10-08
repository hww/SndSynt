#include "port.h"
#include "periph.h"
#include "arch.h"
#include "timer.h"
#include "stdlib.h"

UInt16 kbd_matrix[4];
UInt16 led_matrix[4];
static UInt16 kbd_pos;

void kbd_rfsh(void);
void kbdled_init(void);	

#define LED_ENA 0x40
#define KBD_ENA 0x80

void kbd_rfsh(void)
{
	kbd_pos&=3;
	led_matrix[kbd_pos]=kbd_matrix[kbd_pos];
	periphMemWrite(KBD_ENA | (kbd_pos<<4) ,&ArchIO.PortB.DataReg);			// Set Bits
	periphMemWrite(0xf0,&ArchIO.PortB.DataDirectionReg);// Input pins
	kbd_matrix[kbd_pos]=periphMemRead(&ArchIO.PortB.DataReg) & 0xf;	
	periphMemWrite(0xff,&ArchIO.PortB.DataDirectionReg);// All output
	periphMemWrite(LED_ENA | (kbd_pos<<4) | (led_matrix[kbd_pos] & 0xf),&ArchIO.PortB.DataReg);			// Set Bits
	kbd_pos++;	
}
	
void kbdled_init(void)	
{

	struct sigevent     Timer1Event; 
	timer_t Timer1;
	struct itimerspec Timer1Settings; 
	
	periphMemWrite(0x00,&ArchIO.PortB.PeripheralReg);	// GPIO
	periphMemWrite(0xc0,&ArchIO.PortB.DataReg);			// Set Bits
	periphMemWrite(0xff,&ArchIO.PortB.DataDirectionReg);// All output
	kbd_pos = 0;
	


	Timer1Event.sigev_notify_function = kbd_rfsh; 
	timer_create(CLOCK_AUX1, &Timer1Event, &Timer1);
	 
	Timer1Settings.it_interval.tv_sec   = 0; 
	Timer1Settings.it_interval.tv_nsec = 2000000; 
	Timer1Settings.it_value.tv_sec = 0; 
	Timer1Settings.it_value.tv_nsec = 2000000; 
	
	timer_settime(Timer1, 0, &Timer1Settings, NULL);
}