/******************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
*******************************************************************************
*
* FILE NAME: pcmasterdrv.c
*
*******************************************************************************/

#include "bsp.h"
#include "bit.h"
#include "sci.h"
#include "fcntl.h"
#include "dspfunc.h"
#include "pcmasterdrv.h"

/*--------------------------------------------------
	define which commands will be compiled 
  --------------------------------------------------*/
#define PCMDRV_INCLUDE_CMD_SCOPE			/* read scope, setup scope */
#define PCMDRV_INCLUDE_CMD_RECORDER			/* setup recorder, 
											   get recorder buffer info,
											   start recorder, stop recorder
											   get recorder status */

#define PCMDRV_INCLUDE_CMD_APPCMD			/* call app comd,
										       app comd get status */

/* call user application command status */
/* no application command called (board after reset) */
#define PCMDRV_APPCMD_NOCMD		0xFF	
/* application command not finished */
#define PCMDRV_APPCMD_RUNNING	0xFE	

/* status byte masks (used with 'status' variable) */
/* receiving started, beginning of message already detected ('+') */
#define ST_STARTED				0x0010		
/* last received char was '+' */
#define ST_ST_CHAR_REC			0x0020		
/* received message is standard command (for length decoding) */
#define ST_STD_CMD				0x0040		
/* recorder is running (trigger already detected) */
#define ST_RECRUNNING			0x0100		
/* recorder is activated (waiting for trigger) */
#define ST_RECACTIVATED			0x0200		
/* response is being send to PC */
#define ST_SENDING				0x1000		
/* last sent char was '+' */
#define ST_ST_SENT				0x2000		
/* checksum already added to the message */
#define ST_CS_ADDED				0x4000		

#define START 	'+'			/* start of message */

/*--------------------------------------
    Macros
  --------------------------------------*/

/* write byte to SCI */
#define scidrvWrite(what) 		{write(SciFD, &what, sizeof(UWord16));}		
/* read byte from SCI */
#define scidrvRead(what) 		{read(SciFD, &what, sizeof(UWord16));}		
/* save data for response to PC */
#define respPrepare(sts, len) 	{response.status = sts;	\
								 response.length = len;}	

/* application command call status */
static unsigned int pcmdrvAppCmdSts;

/*---------------------------------------
  SCI driver variables 
  --------------------------------------- */
static Word16 SciFD;				/* SCI driver file descriptor */
static sci_sConfig SciConfig;		/* SCI driver configuration structure */

/*---------------------------------------
  SCI communication algotithm variables
  --------------------------------------- */
static unsigned int status;					/* status word of receiver */


/* currently read input char (it contains checksum at the end of message) */
static unsigned int inChar;		
/* position in buffer (0,1,2,...) */
static unsigned int pos;		
/* length of data in a message used for receiving and transmitting 
												(includes checksum) */
static unsigned int length;		

/* variable for checksum accumulation */
static unsigned int checkSum;					

/* pointer to sciComm structure passed in initialization */
static sPCMasterComm *PCMasterComm;	

/* response structure type (this structure is used to save 
	the parameters of response to be sent to PC) */
typedef struct{
	unsigned int status;		/* status byte of response */
	unsigned int length;		/* length of the whole response */
} sResponse;

static sResponse response;		/* variable with response data */


/*------------------------------------------------------------------------------
   static functions
  ------------------------------------------------------------------------------*/

/* send one byte from output buffer */
static void 	sendBuffer(void);								
/* prepare data for transmitting 
(response.status -> status code, len -> length of data) */
static void		sendResponse(sResponse *resp) ;					
/* sample recorder data */
static asm void readSample(int *Addr, int *DestAddr);			
/* decoding of incoming message after the last byte was received */
static void 	messageDecodeLevel1(void);		/* PC MASTER of Level 1 */
static void 	messageDecodeLevel2(void);		/* PC MASTER of Level 2 */
static void 	messageDecodeLevel3(void);		/* PC MASTER of Level 3 */
/* routine callled after filtering doubled SOM */
static void 	messageData(UWord16 startOfMessage);

/* all functions that begins with Cmd execute 
   the command and place the right data in dataBuff */
   
/* command - read block of memory from address *Addr to *DestAddr */
static asm void cmdReadMem(int *Addr, int *DestAddr);			
/* command - get info */
static void 	cmdGetInfo(void);								
/* command - get brief info */
static void 	cmdGetInfoBrief(void);								
/* command - write block of memory */
static asm void cmdWriteMem(int *Addr, int *Data);				
/* command - scope setup */
static asm 		cmdScopeInit(int *Addr,int *DestAddr);			
/* command - read scope data */
static asm void cmdReadScope(int *Addr, int *DestAddr);			
/* command - call application command */
static asm void cmdCallAppCmd(int *Addr, int *Data);			
/* command - write block of memory with mask */
static asm void cmdWriteMemMask(int *AddrData, int *AddrMask);	
/* command - recorder setup */
static asm void cmdRecInit(int *Addr, int *DestAddr);			
/* performs clearing exception flags */
static     void sciException(void);								

/*------------------------------------------------------------------------------*/
static void sciException(void)
{
	ioctl(SciFD, SCI_CMD_READ_CLEAR, NULL);			/* clear read buffer */
}

/*------------------------------------------------------------------------------*/

Word16 pcmasterdrvInit(sPCMasterComm *p_sPCMasterComm)
{
	/* store sPCMasterComm structure address */
	PCMasterComm=(sPCMasterComm *)p_sPCMasterComm;		

	/* 8 bit words, no parity */
	SciConfig.SciCntl = SCI_CNTL_WORD_8BIT | SCI_CNTL_PARITY_NONE;	
	/* do not use 9th bit */
	SciConfig.SciHiBit = SCI_HIBIT_0;								
	/* set baud rate to 9600 (PLL_MUL must be 40) */
	SciConfig.BaudRate = SCI_BAUD_9600;								

	/* open SCI0 in Non Blocking mode */
	SciFD = open(BSP_DEVICE_NAME_SERIAL_0, O_NONBLOCK, &(SciConfig));	
	
	if (SciFD == -1) return(-1);

	inChar=1;
	/* call interrupt service routine every interrupt */
	ioctl(SciFD, SCI_SET_READ_LENGTH, &inChar);			
	/* set data format as 8 bit */
	ioctl(SciFD, SCI_DATAFORMAT_EIGHTBITCHARS, NULL);	
	/* install interrupt routine (SCI receiver interrupt) */
	ioctl(SciFD, SCI_CALLBACK_RX, pcmasterdrvIsr);		
	/* install interrupt routine (SCI transmitter interrupt) */
	ioctl(SciFD, SCI_CALLBACK_TX, pcmasterdrvIsr);		
	/* install interrupt routine (SCI exception interrupt) */
	ioctl(SciFD, SCI_CALLBACK_EXCEPTION, sciException);	
	/* enable SCI */
	ioctl(SciFD, SCI_DEVICE_ON, NULL);					
	
	status=0;						/* reset receiver */

	#ifdef PCMDRV_INCLUDE_CMD_SCOPE
	/* reset scope */
	((pcmdrv_sScope *)(PCMasterComm->p_scope))->varCnt=0;	
	#endif

	#ifdef PCMDRV_INCLUDE_CMD_RECORDER
	/* reset recorder */
	((pcmdrv_sScope *)(PCMasterComm->p_recorder))->varCnt=0;
	#endif
	
	#ifdef PCMDRV_INCLUDE_CMD_APPCMD
	/* initialize application command status */
	pcmdrvAppCmdSts = PCMDRV_APPCMD_NOCMD; 
	#endif
	
	return(0);
}

/*------------------------------------------------------------------------------*/

#ifdef PCMDRV_INCLUDE_CMD_APPCMD
UWord16 inline pcmasterdrvGetAppCmdSts(void)
/* return state of application command call */
{
	if (pcmdrvAppCmdSts == PCMDRV_APPCMD_RUNNING)
		return(1);		/* new application command received */
	else
		return(0);		/* no new application command */
}
#endif

/*------------------------------------------------------------------------------*/

#ifdef PCMDRV_INCLUDE_CMD_APPCMD
Word16 inline pcmasterdrvWriteAppCmdSts(UWord16 state)
/* write state of application command call */
{
	pcmdrvAppCmdSts = state;
	return(0);			/* OK */
}
#endif

/*------------------------------------------------------------------------------*/
	/* beginning of assembly functions */
		#undef add
		#undef sub
/*------------------------------------------------------------------------------*/

static asm void cmdReadMem(int *Addr, int *DestAddr)
/* read 16bit data from 16bit address and send it to PC 
	(length is length of data block) 
 Addr - address of address 
 DestAddr - start address of data in buffer 
 using length */
{
	move x:(r2)+,y1				/* low byte of address */
	move x:(r2)+,y0				/* high byte of address */
	move #8,x0					/* shifting value */
	lsll y0,x0,y0				/* high byte shifted in Y0 */
	add y0,y1					/* complete address */

	/* read data */
	move y1,r2					/* initialize R2 register */
	move x0,y0					/* shifting value */

	move length,x0				/* use length of message */
	lsr x0

	do x0,EndRead
	move x:(r2)+,a1				/* read the requested variable */
	
	/* disassemble in two bytes */
	move a1,a0
	bfclr #0xff00,a0			/* low byte -> a0 */
	move a0,x:(r3)+				/* write low byte into memory */
	bfclr #0x00ff,a1			/* high byte -> a1 */
	lsrr a1,y0,a
	move a1,x:(r3)+				/* write high byte into memory */

EndRead:
	rts
}	

/*------------------------------------------------------------------------------*/

inline static asm cmdScopeInit(int *Addr,int *DestAddr)
/* initialize scope/recorder (copy data from dataBuff to Scope or 
	Recorder structure)
 Addr - address of data in input buffer
 DestAddr - address of Scope/Recorder buffer with settings */
{
	move x:(r2)+,lc				/* number of scope channels */
	move lc,x:(r3)+				/* write number of channels */
	move #8,x0					/* shifting value */

	do lc,EndDo
	move x:(r2)+,a1				/* size of scope variable */
	move a1,x:(r3)+				/* write size of scope variable */
	move x:(r2)+,y1				/* low byte of address */
	move x:(r2)+,y0				/* high byte of address */
	lsll y0,x0,y0				/* high byte shifted in Y0 */
	add y1,y0					/* complete address */
	move y0,x:(r3)+				/* write address */
EndDo:

	rts
}

/*------------------------------------------------------------------------------*/

inline static asm void cmdReadScope(int *Addr, int *DestAddr)
/* read scope data (data will be copied to dataBuff, 
					length is computed during copying and will contain 
					number of bytes of scope data)
 Addr - address of scope settings buffer
 DestAddr - address of io buffer
 modifying length */
{
	move x:(r2)+,lc				/* number of channels */
	clr y1 

	do lc,EndChannel			/* loop for channels */
	move x:(r2)+,x0				/* read length of variable */
	add x0,y1					/* compute length */
	lsr x0						/* number of words */
	move x:(r2)+,r1				/* address of scope variable */
	move #8,y0					/* shifting value */
	push x0						/* loop counter */

Word:
	move x:(r1)+,a1				/* read scope variable */
	move a1,a0
	bfclr #0x00ff,a1			/* high byte of scope variable -> a1 */
	bfclr #0xff00,a0			/* low byte of scope variable -> a0 */
	move a0,x:(r3)+				/* low byte */
	lsrr a1,y0,a
	move a1,x:(r3)+				/* high byte */

	pop a						/* loop for all variables */
	dec a
	tst a
	push a
	bgt Word
	pop a
	nop							/* needed for correct DO execution */

EndChannel:

	inc y1
	move y1,length				/* store length */
	rts
}

/*------------------------------------------------------------------------------*/

inline static asm void cmdWriteMem(int *Addr, int *Data)
/* write data in data memory
 Addr - address of address
 Data - address of data to be written
 using length (number of bytes to be written) */
{
	move x:(r2)+,y1				/* low byte */
	move x:(r2)+,y0				/* high byte */
	move #8,x0
	lsll y0,x0,y0				/* high byte shifted in Y0 */
	add y0,y1					/* complete address */
	move y1,r2					/* use R2 */

	move length,y0
	lsr y0

	do y0,EndDo
	move x:(r3)+,y0				/* low byte of data */
	move x:(r3)+,y1				/* high byte of data */
	lsll y1,x0,y1				/* shift high byte */
	add y1,y0					/* complete data */
	move y0,x:(r2)+				/* write data to destination */
EndDo:
	rts
}

/*------------------------------------------------------------------------------*/

inline static asm void cmdWriteMemMask(int *AddrData, int *AddrMask)
/* write data in data memory using mask
 Addr - address of address
 Data - address of data to be written
 using length (number of bytes to be written) */
{
	move x:(r2)+,y1				/* low byte */
	move x:(r2)+,y0				/* high byte */
	move #8,x0
	lsll y0,x0,y0				/* high byte shifted in Y0 */
	add y0,y1					/* complete address */
	move y1,r1					/* use R1 */

	move length,y0
	lsr y0

	do y0,EndDo
	move x:(r2)+,y0				/* low byte of data */
	move x:(r2)+,y1				/* high byte of data */
	lsll y1,x0,y1				/* shift upper byte */
	add y1,y0					/* complete data -> Y0 */
	move y0,a1					/* store data -> A1 */
	move x:(r3)+,y0				/* low byte of mask */
	move x:(r3)+,y1				/* high byte of mask */
	lsll y1,x0,y1				/* shift high byte */
	add y1,y0					/* complete mask -> Y0 */
	move y0,b1					/* store mask -> B1 */
	and a1,y0					/* data & mask -> Y0 */
	neg b						/* negate mask */
	dec b
	move b1,y1
	
	move x:(r1),a1				/* read memory -> A1 */
	and a1,y1					/* origdata & neg(mask) -> Y1 */
	or y1,y0					/* (data & mask) or (origdata & neg(mask)) -> Y0 */
	move y0,x:(r1)+				/* write back */

EndDo:
	rts
}

/*------------------------------------------------------------------------------*/

inline static asm void cmdCallAppCmd(int *Addr, int *Data)
/* write data in application command buffer
 Addr - address of beginning of Application Command data in the message (dataBuff)
 Data - address of Application Command buffer */
{
	move x:(r2)+,a				/* length */
	lsr a

	jeq NoData					/* jump if command contains no data */

	move x:(r2)+,x0
	move x0,x:(r3)+				/* write application command code */
	
	move #8,x0					/* shift value */
	
	do a,EndDo
	move x:(r2)+,y0				/* low byte of data */
	move x:(r2)+,y1				/* high byte of data */
	lsll y1,x0,y1				/* shift high byte */
	add y1,y0					/* complete data */
	move y0,x:(r3)+				/* write data to destination */
EndDo:
	rts
	
NoData:
	move x:(r2)+,x0
	move x0,x:(r3)+				/* write application command code */
	rts
}

/*------------------------------------------------------------------------------*/

inline static asm void cmdRecInit(int *Addr, int *DestAddr)
/* initialize recorder (copy data from dataBuff to Recorder structure)
 Addr - address of Recorder settings data in the message (dataBuff)
 DestAddr - address of Recorder structure with settings (Recorder) */
{
	/* trigger mode */
	move x:(r2)+,a
	move a,x:(r3)+			
	move #8,x0

	/*  total samples
	 	post trigger
	 	timediv
	 	trigger variable address */
	do #4,EndDo
	move x:(r2)+,y1				/* low byte */
	move x:(r2)+,y0				/* high byte */
	lsll y0,x0,y0
	add y1,y0					/* complete word */
	move y0,x:(r3)+				/* write word to memory */
	EndDo:
	
	/* trigger variable size */
	move x:(r2)+,a				/* read */
	move a,x:(r3)+				/* write to memory */

	/* trigger variable signed */
	move x:(r2)+,a				/* read */
	move a,x:(r3)+				/* write to memory */
	
	/* trigger treshold */
	do #2,EndSize
	move x:(r2)+,y1				/* low byte */
	move x:(r2)+,y0				/* high byte */
	lsll y0,x0,y0
	add y1,y0					/* complete word */
	move y0,x:(r3)+				/* write word to memory */
EndSize:
	rts
}

/*------------------------------------------------------------------------------*/

inline static asm void readSample(int *Addr, int *DestAddr)
/* read recorder data (data will be copied to dataBuff)
 Addr - address of recorder settings buffer
 DestAddr - address of recorder data buffer */
{
	move x:(r2)+,lc				/* number of channels */

	do lc,EndChannel			
	move x:(r2)+,x0
	lsr x0						/* number of words */
	move x:(r2)+,r1				/* address of scope variable */
	move #8,y0
	push x0						/* loop counter */
	Word:
	move x:(r1)+,a1
	move a1,x:(r3)+				/* write value to buffer */
	
	pop a
	dec a
	tst a
	push a
	bgt Word
	pop a
	nop
	EndChannel:

	rts
}

/*------------------------------------------------------------------------------*/
	/* end of assembly functions */
		#define add
		#define sub
/*------------------------------------------------------------------------------*/

inline static void cmdGetInfo(void)
/* get information about hardware 
	(initialization sequence before any other communication)
 data are transfered to dataBuff */
{
	int i;				/* temporary variable for string copy */
	
	(PCMasterComm)->p_dataBuff[1] = 1;									/* protocol version	*/
	(PCMasterComm)->p_dataBuff[2] = PCMDRV_CFG_FLAFGS;					/* CFG_FLAFGS */
	(PCMasterComm)->p_dataBuff[3] = 2;									/* dataBusWdt */
	(PCMasterComm)->p_dataBuff[4] = PCMasterComm->globVerMajor; 			/* version */
	(PCMasterComm)->p_dataBuff[5] = PCMasterComm->globVerMinor;			/* version */
	(PCMasterComm)->p_dataBuff[6] = ((PCMasterComm)->dataBuffSize) - 2;	/* size of input buffer 
														(without CMD, LENGTH) */
	(PCMasterComm)->p_dataBuff[7] = (PCMasterComm->recSize) & 0x00ff;		/* size of 
															recorder buffer */
	(PCMasterComm)->p_dataBuff[8] = (PCMasterComm->recSize) >> 8;
	(PCMasterComm)->p_dataBuff[9] = (PCMasterComm->timeBase) & 0x00ff;	/* period of Recorder 
																routine launch */
	(PCMasterComm)->p_dataBuff[10]=(PCMasterComm->timeBase) >> 8;
	
	for (i=0 ; i < PCMDRV_IDT_STRING_LEN ; i++)
	{
		(PCMasterComm)->p_dataBuff[11 + i] = PCMasterComm->idtString[i];/* copy identification 
																		string */
	}
}

/*------------------------------------------------------------------------------*/

inline static void cmdGetInfoBrief(void)
/* get brief information about hardware
	(initialization sequence before any other communication)
 data are transfered to dataBuff */
{
	(PCMasterComm)->p_dataBuff[1]=PCMDRV_PROT_VER;					/* protocol version	*/
	(PCMasterComm)->p_dataBuff[2]=PCMDRV_CFG_FLAFGS;				/* CFG_FLAFGS */
	(PCMasterComm)->p_dataBuff[3]=PCMDRV_DATABUSWDT;				/* dataBusWdt */
	(PCMasterComm)->p_dataBuff[4]=PCMasterComm->globVerMajor; 		/* version */
	(PCMasterComm)->p_dataBuff[5]=PCMasterComm->globVerMinor;		/* version */
	
	/* size of input buffer	(without CMD, LENGTH) */
	(PCMasterComm)->p_dataBuff[6]=((PCMasterComm)->dataBuffSize)-2;	
}

/*------------------------------------------------------------------------------*/

inline static void sendBuffer(void)
/* sends '+', data of message (dataBuff) and checksum (dataBuff)
 using length */
{
	if (pos <= length)						/* is it end of message ? */
	{
		scidrvWrite((PCMasterComm)->p_dataBuff[pos]);	/* send one char to SCI */
			
		if ((PCMasterComm)->p_dataBuff[pos] != '+') 		/* current character is not '+' */
		{
			checkSum += (PCMasterComm)->p_dataBuff[pos];	/* accumulate checksum */
			pos++;
		}
		else 								/* current character is '+' */
		{
			if (status & ST_ST_SENT)		/* the last sent char was '+' */
			{
				bitClear(ST_ST_SENT,status);
				checkSum += (PCMasterComm)->p_dataBuff[pos];	/* accumulate checksum */
				pos++;
			}
			else							/* the last sent byte was not '+' */
			{
				bitSet(ST_ST_SENT,status);	
			}
		}
		
		if ((pos == length) && !(status & ST_CS_ADDED))		/* the last byte 
								before cs was sent, now add the checksum */
		{
			checkSum = (-checkSum) & 0x00FF;	/* compute checksum */
			(PCMasterComm)->p_dataBuff[pos] = checkSum;
			bitSet(ST_CS_ADDED,status);			/* set flag */
		}
	}
	else		/* end of transmitting */
	{
		bitClear(ST_SENDING | ST_CS_ADDED,status);		/* reset transmitter 
												(switch to receiving mode) */
	}
}

/*------------------------------------------------------------------------------*/

static void sendResponse(sResponse *resp) 
/* put all data to dataBuff, computes a checksum and transmit '+' as 
	beginning of message */
{
	bitSet(ST_SENDING,status);			/* set flag */
	(PCMasterComm)->p_dataBuff[0]=resp->status;		/* status of trasmitted message */
	length=resp->length;				/* length of message */
	pos=0;								/* position in the message */
	
	/* send start of message */
	inChar = '+';
	scidrvWrite(inChar);				/* send start character */
	checkSum = 0;						/* reset checksum */
}

/*------------------------------------------------------------------------------*/

/* this defines basic configuration of the following PC Master Levelx function */
#define LEVEL1_CMD_READVAR16
#define LEVEL1_CMD_READVAR32
#define LEVEL1_CMD_READMEM
#define LEVEL1_CMD_WRITEMEM
#define LEVEL1_CMD_WRITEMEMMASK
#undef LEVEL1_CMD_GETINFOBRIEF
#define LEVEL1_CMD_SCOPE
#define LEVEL1_CMD_APPCMD
#define LEVEL1_CMD_RECORDER

inline static void messageDecodeLevel1(void)
/* decoding of received message
 proper command will be executed and response sent to PC */
{
int *varaddr;
unsigned int i;

	switch((PCMasterComm)->p_dataBuff[0])
	{
		/* -------------------------
		    special format commands
		   ------------------------- */
		#ifdef LEVEL1_CMD_READVAR16
		case PCMDRV_CMD_READVAR16:					/* read 16-bit variable */
		{
			length=2;
			/* execute command */
			cmdReadMem((int *)(&(PCMasterComm)->p_dataBuff[1]),(int *)(&(PCMasterComm)->p_dataBuff[1]));	
			respPrepare(PCMDRV_STC_OK,3);			/* OK */
		}break;
		#endif
		#ifdef LEVEL1_CMD_READVAR32
		case PCMDRV_CMD_READVAR32:					/* read 32-bit variable */
		{
			length=4;
			/* execute command */
			cmdReadMem((int *)(&(PCMasterComm)->p_dataBuff[1]),(int *)(&(PCMasterComm)->p_dataBuff[1]));	
			respPrepare(PCMDRV_STC_OK,5);			/* OK */
		}break;
		#endif
		#ifdef LEVEL1_CMD_SCOPE
		case PCMDRV_CMD_READSCOPE:					/* read scope variables */
		{
			/* scope not configured */
			if (((pcmdrv_sScope *)(PCMasterComm->p_scope))->varCnt==0)			
			{
				respPrepare(PCMDRV_STC_NOTINIT,1);	/* scope not initialized */
			}		
			else									/* scope configured */
			{
				/* execute command */
				cmdReadScope((int *)(&(((pcmdrv_sScope *)(PCMasterComm->p_scope))->varCnt)),\
									(int *)(&(PCMasterComm)->p_dataBuff[1])); 
				respPrepare(PCMDRV_STC_OK,length);	/* OK */
			}
		}break;
		#endif
		#ifdef LEVEL1_CMD_RECORDER
		case PCMDRV_CMD_GETRECSTS:					/* get recorder status */
		{
			if (PCMasterComm->recSize==0)			/* recorder not implemented */
			{
				respPrepare(PCMDRV_STC_INVCMD,1);	/* invalid command */
				return;
			}
			/* recorder is initialized */
			if (((pcmdrv_sScope *)(PCMasterComm->p_recorder))->varCnt)			
			{
				if (!(status & ST_RECACTIVATED))
				{
					respPrepare(PCMDRV_STC_RECDONE,1);	/* recorder finished */
				}
				else
				{
					respPrepare(PCMDRV_STC_RECRUN,1);	/* recorder running */
				}
			}
			else								/* recorder is not initialized */
			{
				respPrepare(PCMDRV_STC_NOTINIT,1);	/* recorder not initialized */
			}
		}break;
		case PCMDRV_CMD_STARTREC:					/* start recorder */
		{
			if (PCMasterComm->recSize==0)			/* recorder not implemented */
			{
				respPrepare(PCMDRV_STC_INVCMD,1);	/* invalid command */
				return;
			}
			/* recorder initialized */
			if (((pcmdrv_sScope *)(PCMasterComm->p_recorder))->varCnt)			
			{
				if (!(status & ST_RECRUNNING))		/* recorder not running */
				{
					bitClear(ST_RECRUNNING,status);		/* stop recorder if it 
																	is running */
					/* initialize time div */
					(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recTime) = \
					(unsigned)(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->timeDiv);	
					/* address of triggering variable */
					varaddr=(int *) \
						(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgVarAddr);	
					switch (status & 0x000f)			
					/* initialize last rcorder value 
						with current value of triggering variable */
					{
						case 0x0004: ((pcmdrv_sRecorder *)(PCMasterComm->\
							p_recorder))->recLastVal.uw=(unsigned int)*varaddr; break;
						case 0x0005: ((pcmdrv_sRecorder *)(PCMasterComm->\
							p_recorder))->recLastVal.sw=(int)*varaddr; break;
						case 0x0008: ((pcmdrv_sRecorder *)(PCMasterComm->\
							p_recorder))->recLastVal.ud=(unsigned long)*varaddr; break;
						case 0x0009: ((pcmdrv_sRecorder *)(PCMasterComm->\
							p_recorder))->recLastVal.sd=(long)*varaddr; break;
					}
					/* activate recorder to wait for trigger */
					bitSet(ST_RECACTIVATED,status);	
					respPrepare(PCMDRV_STC_OK,1);	/* OK */
				}
				else
				{
					respPrepare(PCMDRV_STC_RECRUN,1);	/* recorder running */
				}
			}
			else								/* recorder is not initialized */
			{
				respPrepare(PCMDRV_STC_NOTINIT,1);	/* recorder not initialized */
			}
		}break;
		case PCMDRV_CMD_STOPREC:					/* stop recorder */
		{
			if (PCMasterComm->recSize==0)			/* recorder not implemented */
			{
				respPrepare(PCMDRV_STC_INVCMD,1);	/* invalid command */
				return;
			}
			/* recorder initialized */
			if (((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->varCnt)			
			{
				if (status & ST_RECACTIVATED)		/* recorder activated */
				{	
					if (status & ST_RECRUNNING)		/* recorder running */
					{
						respPrepare(PCMDRV_STC_RECDONE,1);	/* recorder finished */
					}
					else								/* recorder not running */
					{	
						/* initialize posttrigger value */
						(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recToEnd)\
						 = (((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->postTrigger);	
						bitSet(ST_RECRUNNING,status);	/* manually trigger 
																the recorder */
						respPrepare(PCMDRV_STC_OK,1);	/* OK */
					}
				}
				else								/* recorder not activated */
				{
					respPrepare(PCMDRV_STC_RECDONE,1);	/* recorder finished */
				}
			}						
			else									/* recorder not initialized */
			{
				respPrepare(PCMDRV_STC_NOTINIT,1);
			}
		}break;				
		case PCMDRV_CMD_GETRECBUFF:					/* get recorder buffer */
		{
			if (PCMasterComm->recSize==0)			/* recorder not implemented */
			{
				respPrepare(PCMDRV_STC_INVCMD,1);
				return;
			}
			/* recorder initialized */
			if ((((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->varCnt) != 0)	
			{
				if (!(status & ST_RECRUNNING))		/* recorder not running */
				{
					/* recorder buffer address */
					(PCMasterComm)->p_dataBuff[1]=(unsigned int)(PCMasterComm->p_recBuff) & 0x00FF;	
					
					/* recorder buffer address */
					(PCMasterComm)->p_dataBuff[2]=(unsigned int)(PCMasterComm->p_recBuff) >> 8;		
					i=(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recPos)\
						/(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recSetLen);
					
					/* position of the last sample in recorder buffer */
					(PCMasterComm)->p_dataBuff[3]=(i) & 0x00FF;		
					
					/* position of the last sample in recorder buffer */
					(PCMasterComm)->p_dataBuff[4]=(i) >> 8;			
					
					respPrepare(PCMDRV_STC_OK,5);	/* OK */
				}
				else								/* recorder running */
				{
					respPrepare(PCMDRV_STC_SERVBUSY,1);	/* service busy */
				}
			} else									/* recorder initialized */
			{
				respPrepare(PCMDRV_STC_NOTINIT,1);	/* recorder not initialized */
			}
		}break;
		#endif
		#ifdef LEVEL1_CMD_APPCMD
		case PCMDRV_CMD_GETAPPCMDSTS:		/* get user application 
													command call status */
		{
		/* buffer is not initialized (zero length) */
			if (PCMasterComm->appCmdSize == 0)		
			{
				respPrepare(PCMDRV_STC_INVCMD,1);	/* invalid command */
				return;
			}
			/* copy status byte in the output buffer */
			(PCMasterComm)->p_dataBuff[1]=pcmdrvAppCmdSts;					
			respPrepare(PCMDRV_STC_OK,2);			/* OK */
		}break;
		#endif
		#ifndef LEVEL1_CMD_GETINFOBRIEF
		case PCMDRV_CMD_GETINFO:					/* get info about hardware */
		{
			cmdGetInfo();							/* execute the command */
			
			respPrepare(PCMDRV_STC_OK,(1 + 10 + PCMDRV_IDT_STRING_LEN)); /* OK */
		}break;
		#endif
		#ifdef LEVEL1_CMD_GETINFOBRIEF
		case PCMDRV_CMD_GETINFOBRIEF:		/* get brief info about hardware */
		{
			cmdGetInfoBrief();						/* execute the command */
			
			respPrepare(PCMDRV_STC_OK,(1 + 6)); /* OK */
		}break;
		#endif
		
		/* --------------------------
		    standard format commands
		   -------------------------- */
		#ifdef LEVEL1_CMD_SCOPE
		case PCMDRV_CMD_SETUPSCOPE:					/* setup scope */
		{
			if ( ((PCMasterComm)->p_dataBuff[2]==0) || ((PCMasterComm)->p_dataBuff[2] > 8) )	
			/* varCnt is zero or greater than 8 */
			{
				respPrepare(PCMDRV_STC_INVBUFF,1);	/* invalid buffer size */
				return;
			}
		
			/* init scope */
			cmdScopeInit((int *)(&(PCMasterComm)->p_dataBuff[2]),\
				&(((pcmdrv_sScope *)(PCMasterComm->p_scope))->varCnt));	
			
			/* check size of variable */
			for(i=0 ; i<(((pcmdrv_sScope *)(PCMasterComm->p_scope))->varCnt) ; i++)	
			{
			/* varSize is 0 or 1,3,5,7,... */
				if ( ((((pcmdrv_sScope *)(PCMasterComm->p_scope))->\
						varDef[i].varSize)==0) || (((((pcmdrv_sScope *)\
						(PCMasterComm->p_scope))->varDef[i].varSize)%2)!=0) )
				{
					/* invalid size of variable */
					respPrepare(PCMDRV_STC_INVSIZE,1);	
					/* reset scope */
					(((pcmdrv_sScope *)(PCMasterComm->p_scope))->varCnt) = 0;					
					return;
				}
			}
			respPrepare(PCMDRV_STC_OK,1);
		}break;
		#endif
		#ifdef LEVEL1_CMD_RECORDER
		case PCMDRV_CMD_SETUPREC:				/* setup recorder */
		{
			if (PCMasterComm->recSize==0)		/* recorder not implemented */
			{
				respPrepare(PCMDRV_STC_INVCMD,1);	/* invalid command */
				return;
			}
			
			/* reset the recorder */
			bitClear(ST_RECRUNNING | ST_RECACTIVATED,status);	

			if ( ((PCMasterComm)->p_dataBuff[17]==0) || ((PCMasterComm)->p_dataBuff[17] > 8) )	
			/* varCnt is zero or greater than 8 */
			{
				respPrepare(PCMDRV_STC_INVBUFF,1);	/* invalid buffer size */
				return;
			}

			/* init recorder */
			cmdRecInit((int *)(&(PCMasterComm)->p_dataBuff[2]),\
				&(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgMode));	

			if (((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgMode)
			{
				if (!( ((((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->\
					trgVarSize)==2) || ((((pcmdrv_sRecorder *)\
					(PCMasterComm->p_recorder))->trgVarSize)==4) ) )		
				/* trigger variable size is not 2 or 4 */
				{
					respPrepare(PCMDRV_STC_INVSIZE,1);	/* invalid buffer size */
					/* reset scope */
					(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->varCnt) = 0;			
					return;
				}
				status = (status & 0xfff0) | (((((pcmdrv_sRecorder *)\
						(PCMasterComm->p_recorder))->trgVarSize) << 1) + \
						(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->\
						trgVarSigned));
			}
			
			/* init scope */
			cmdScopeInit((int *)(&(PCMasterComm)->p_dataBuff[17]),&(((pcmdrv_sRecorder *)\
						(PCMasterComm->p_recorder))->varCnt));	
			
			/* check variable sizes */
			for(i=0 ; i<(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->\
				varCnt) ; i++)	
			{
				if ( ((((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->\
					varDef[i].varSize)==0) || (((((pcmdrv_sRecorder *)\
					(PCMasterComm->p_recorder))->varDef[i].varSize)%2)!=0) )	
				/* varSize is 0 or 1,3,5,7,... */
				{
					respPrepare(PCMDRV_STC_INVSIZE,1); /* invalid buffer size */
					/* reset scope */
					((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->varCnt=0;					
					return;
				}
			}
		
			((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recTime = \
				((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->timeDiv;
			((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recToEnd=1;
			((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recPos=0;
						
			((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recSetLen=0;							
			for (i=0 ; i < ((pcmdrv_sRecorder *)\
				(PCMasterComm->p_recorder))->varCnt ; i++)	
			/* check if recorder buffer size is valid */
			{
				/* length of one set of samples (in bytes) */
				((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recSetLen += \
				((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->varDef[i].varSize;			
			}
			/* length (in words) */
			((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recSetLen = \
			(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recSetLen) >> 1;	
			/* buffer length required (in words) */
			((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->totalSmps = \
			((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->totalSmps * \
			((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recSetLen;	
			
			if ((((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->totalSmps) \
				<= PCMasterComm->recSize)		
			/* buffer length required is smaller than recorder buffer */
			{
				varaddr=(int *)((pcmdrv_sRecorder *)\
					(PCMasterComm->p_recorder))->trgVarAddr;
				switch (status & 0x000f)
				{
					/* unsigned word */
					case 0x0004: ((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))\
									->recLastVal.uw=(unsigned int)*varaddr; break;	
					/* signed word */
					case 0x0005: ((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))\
									->recLastVal.sw=(int)*varaddr; break;			
					/* unsigned double */
					case 0x0008: ((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))\
									->recLastVal.ud=(unsigned long)*varaddr; break;	
					/* unsigned double */
					case 0x0009: ((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))\
									->recLastVal.sd=(long)*varaddr; break;			
				}
				respPrepare(PCMDRV_STC_OK,1);
				bitSet(ST_RECACTIVATED,status);		/* recorder activated */
			} 
			else
			/* invalid buffer size specified */
			{
				((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->varCnt=0;
				respPrepare(PCMDRV_STC_INVBUFF,1);	/* invalid buffer size */
				break;
			}
		}break;
		#endif
		#ifdef LEVEL1_CMD_READMEM
		case PCMDRV_CMD_READMEM:					/* read block of memory */
		{
			length=(PCMasterComm)->p_dataBuff[2];
			if ((length+2) <= ((PCMasterComm)->dataBuffSize))
			/* memory block is too long */	
			{
				/* read memory */
				cmdReadMem((int *)(&(PCMasterComm)->p_dataBuff[3]),(int *)(&(PCMasterComm)->p_dataBuff[1]));	
				respPrepare(PCMDRV_STC_OK,(length+1));	/* OK */
			}
			else						
			/* response greater than buffer */
			{
				/* response buffer overflow */
				respPrepare(PCMDRV_STC_RSPBUFFOVF,1);	
			}
		}break;
		#endif
		#ifdef LEVEL1_CMD_WRITEMEM
		case PCMDRV_CMD_WRITEMEM:				/* write block of memory */
		{
			/* read length of memory block from the message */
			length=(PCMasterComm)->p_dataBuff[2];	
			
			asm{move sr,i};		/* store SR register (store IPL setting) */
			archDisableInt();	/* disable interrupts for this operation */
			/* write to memory */
			cmdWriteMem((int *)(&(PCMasterComm)->p_dataBuff[3]),(int *)(&(PCMasterComm)->p_dataBuff[5]));	
			asm{move i,sr};	/* restore SR register (restore IPL setting ) */
			
			respPrepare(PCMDRV_STC_OK,1);
		}break;
		#endif
		#ifdef LEVEL1_CMD_WRITEMEMMASK		
		case PCMDRV_CMD_WRITEMEMMASK:			/* write to memory with mask */
		{
			/* read length of memory block from the message */
			length=(PCMasterComm)->p_dataBuff[2];	
			
			asm{move sr,i};		/* store SR register (store IPL setting) */
			archDisableInt();	/* disable interrupts for this operation */
			/* write to memory */
			cmdWriteMemMask((int *)(&(PCMasterComm)->p_dataBuff[3]),(int *)(&(PCMasterComm)->p_dataBuff[length+3+2])); 
			asm{move i,sr};	/* restore SR register (restore IPL setting ) */
			
			respPrepare(PCMDRV_STC_OK,1);			/* OK */
		}break;	
		#endif
		#ifdef LEVEL1_CMD_APPCMD
		case PCMDRV_CMD_CALLAPPCMD:			/* call user application command */
		{
			if (PCMasterComm->appCmdSize == 0) 		
			/* buffer is not initialized (zero length) */
			{
				respPrepare(PCMDRV_STC_INVCMD,1);	/* invalid command */
				return;
			}
			if ((PCMasterComm)->p_dataBuff[1] > PCMasterComm->appCmdSize)	
			/* check Application Command length */
			{
				respPrepare(PCMDRV_STC_INVBUFF,1);	/* invalid buffer size */
			}
			else
			{
				if (pcmdrvAppCmdSts==PCMDRV_APPCMD_RUNNING)	
				/* Application Command already called */
				{
					respPrepare(PCMDRV_STC_SERVBUSY,1);	/* service is busy	 */
				}
				else					/* no Application Command was called */
				{
				/* copy Application Command data to Application Command buffer */
					cmdCallAppCmd((int *)(&(PCMasterComm)->p_dataBuff[1]),(int *)(PCMasterComm->p_appCmdBuff));	
					pcmdrvAppCmdSts = PCMDRV_APPCMD_RUNNING;
					respPrepare(PCMDRV_STC_OK,1);	/* OK */
				}
			}
		}break;
		#endif
		default:									/* invalid command */
		{
			respPrepare(PCMDRV_STC_INVCMD,1);		/* invalid command */
		}break; 
	}
}

/*------------------------------------------------------------------------------*/

/* this defines basic configuration of the following PC Master Levelx function */
#define LEVEL2_CMD_READVAR16
#define LEVEL2_CMD_READVAR32
#define LEVEL2_CMD_READMEM
#define LEVEL2_CMD_WRITEMEM
#define LEVEL2_CMD_WRITEMEMMASK
#define LEVEL2_CMD_GETINFOBRIEF
#define LEVEL2_CMD_SCOPE
#define LEVEL2_CMD_APPCMD
#undef LEVEL2_CMD_RECORDER

inline static void messageDecodeLevel2(void)
/* decoding of received message
 proper command will be executed and response sent to PC */
{
int *varaddr;
unsigned int i;

	switch((PCMasterComm)->p_dataBuff[0])
	{
		/* -------------------------
		    special format commands
		   ------------------------- */
		#ifdef LEVEL1_CMD_READVAR16
		case PCMDRV_CMD_READVAR16:					/* read 16-bit variable */
		{
			length=2;
			/* execute command */
			cmdReadMem((int *)(&(PCMasterComm)->p_dataBuff[1]),(int *)(&(PCMasterComm)->p_dataBuff[1]));	
			respPrepare(PCMDRV_STC_OK,3);			/* OK */
		}break;
		#endif
		#ifdef LEVEL1_CMD_READVAR32
		case PCMDRV_CMD_READVAR32:					/* read 32-bit variable */
		{
			length=4;
			/* execute command */
			cmdReadMem((int *)(&(PCMasterComm)->p_dataBuff[1]),(int *)(&(PCMasterComm)->p_dataBuff[1]));	
			respPrepare(PCMDRV_STC_OK,5);			/* OK */
		}break;
		#endif
		#ifdef LEVEL1_CMD_SCOPE
		case PCMDRV_CMD_READSCOPE:					/* read scope variables */
		{
			/* scope not configured */
			if (((pcmdrv_sScope *)(PCMasterComm->p_scope))->varCnt==0)			
			{
				respPrepare(PCMDRV_STC_NOTINIT,1);	/* scope not initialized */
			}		
			else									/* scope configured */
			{
				/* execute command */
				cmdReadScope(&(((pcmdrv_sScope *)(PCMasterComm->p_scope))->varCnt),\
									(int *)(&(PCMasterComm)->p_dataBuff[1])); 
				respPrepare(PCMDRV_STC_OK,length);	/* OK */
			}
		}break;
		#endif
		#ifdef LEVEL1_CMD_RECORDER
		case PCMDRV_CMD_GETRECSTS:					/* get recorder status */
		{
			if (PCMasterComm->recSize==0)			/* recorder not implemented */
			{
				respPrepare(PCMDRV_STC_INVCMD,1);	/* invalid command */
				return;
			}
			/* recorder is initialized */
			if (((pcmdrv_sScope *)(PCMasterComm->p_recorder))->varCnt)			
			{
				if (!(status & ST_RECACTIVATED))
				{
					respPrepare(PCMDRV_STC_RECDONE,1);	/* recorder finished */
				}
				else
				{
					respPrepare(PCMDRV_STC_RECRUN,1);	/* recorder running */
				}
			}
			else								/* recorder is not initialized */
			{
				respPrepare(PCMDRV_STC_NOTINIT,1);	/* recorder not initialized */
			}
		}break;
		case PCMDRV_CMD_STARTREC:					/* start recorder */
		{
			if (PCMasterComm->recSize==0)			/* recorder not implemented */
			{
				respPrepare(PCMDRV_STC_INVCMD,1);	/* invalid command */
				return;
			}
			/* recorder initialized */
			if (((pcmdrv_sScope *)(PCMasterComm->p_recorder))->varCnt)			
			{
				if (!(status & ST_RECRUNNING))		/* recorder not running */
				{
					bitClear(ST_RECRUNNING,status);		/* stop recorder if it 
																	is running */
					/* initialize time div */
					(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recTime) = \
					(unsigned)(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->timeDiv);	
					/* address of triggering variable */
					varaddr=(int *) \
						(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgVarAddr);	
					switch (status & 0x000f)			
					/* initialize last rcorder value 
						with current value of triggering variable */
					{
						case 0x0004: ((pcmdrv_sRecorder *)(PCMasterComm->\
							p_recorder))->recLastVal.uw=(unsigned int)*varaddr; break;
						case 0x0005: ((pcmdrv_sRecorder *)(PCMasterComm->\
							p_recorder))->recLastVal.sw=(int)*varaddr; break;
						case 0x0008: ((pcmdrv_sRecorder *)(PCMasterComm->\
							p_recorder))->recLastVal.ud=(unsigned long)*varaddr; break;
						case 0x0009: ((pcmdrv_sRecorder *)(PCMasterComm->\
							p_recorder))->recLastVal.sd=(long)*varaddr; break;
					}
					/* activate recorder to wait for trigger */
					bitSet(ST_RECACTIVATED,status);	
					respPrepare(PCMDRV_STC_OK,1);	/* OK */
				}
				else
				{
					respPrepare(PCMDRV_STC_RECRUN,1);	/* recorder running */
				}
			}
			else								/* recorder is not initialized */
			{
				respPrepare(PCMDRV_STC_NOTINIT,1);	/* recorder not initialized */
			}
		}break;
		case PCMDRV_CMD_STOPREC:					/* stop recorder */
		{
			if (PCMasterComm->recSize==0)			/* recorder not implemented */
			{
				respPrepare(PCMDRV_STC_INVCMD,1);	/* invalid command */
				return;
			}
			/* recorder initialized */
			if (((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->varCnt)			
			{
				if (status & ST_RECACTIVATED)		/* recorder activated */
				{	
					if (status & ST_RECRUNNING)		/* recorder running */
					{
						respPrepare(PCMDRV_STC_RECDONE,1);	/* recorder finished */
					}
					else								/* recorder not running */
					{	
						/* initialize posttrigger value */
						(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recToEnd)\
						 = (((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->postTrigger);	
						bitSet(ST_RECRUNNING,status);	/* manually trigger 
																the recorder */
						respPrepare(PCMDRV_STC_OK,1);	/* OK */
					}
				}
				else								/* recorder not activated */
				{
					respPrepare(PCMDRV_STC_RECDONE,1);	/* recorder finished */
				}
			}						
			else									/* recorder not initialized */
			{
				respPrepare(PCMDRV_STC_NOTINIT,1);
			}
		}break;				
		case PCMDRV_CMD_GETRECBUFF:					/* get recorder buffer */
		{
			if (PCMasterComm->recSize==0)			/* recorder not implemented */
			{
				respPrepare(PCMDRV_STC_INVCMD,1);
				return;
			}
			/* recorder initialized */
			if ((((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->varCnt) != 0)	
			{
				if (!(status & ST_RECRUNNING))		/* recorder not running */
				{
					/* recorder buffer address */
					(PCMasterComm)->p_dataBuff[1]=(unsigned int)(PCMasterComm->p_recBuff) & 0x00FF;	
					
					/* recorder buffer address */
					(PCMasterComm)->p_dataBuff[2]=(unsigned int)(PCMasterComm->p_recBuff) >> 8;		
					i=(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recPos)\
						/(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recSetLen);
					
					/* position of the last sample in recorder buffer */
					(PCMasterComm)->p_dataBuff[3]=(i) & 0x00FF;		
					
					/* position of the last sample in recorder buffer */
					(PCMasterComm)->p_dataBuff[4]=(i) >> 8;			
					
					respPrepare(PCMDRV_STC_OK,5);	/* OK */
				}
				else								/* recorder running */
				{
					respPrepare(PCMDRV_STC_SERVBUSY,1);	/* service busy */
				}
			} else									/* recorder initialized */
			{
				respPrepare(PCMDRV_STC_NOTINIT,1);	/* recorder not initialized */
			}
		}break;
		#endif
		#ifdef LEVEL1_CMD_APPCMD
		case PCMDRV_CMD_GETAPPCMDSTS:		/* get user application 
													command call status */
		{
		/* buffer is not initialized (zero length) */
			if (PCMasterComm->appCmdSize == 0)		
			{
				respPrepare(PCMDRV_STC_INVCMD,1);	/* invalid command */
				return;
			}
			/* copy status byte in the output buffer */
			(PCMasterComm)->p_dataBuff[1]=pcmdrvAppCmdSts;					
			respPrepare(PCMDRV_STC_OK,2);			/* OK */
		}break;
		#endif
		#ifndef LEVEL1_CMD_GETINFOBRIEF
		case PCMDRV_CMD_GETINFO:					/* get info about hardware */
		{
			cmdGetInfo();							/* execute the command */
			
			respPrepare(PCMDRV_STC_OK,(1 + 10 + PCMDRV_IDT_STRING_LEN)); /* OK */
		}break;
		#endif
		#ifdef LEVEL1_CMD_GETINFOBRIEF
		case PCMDRV_CMD_GETINFOBRIEF:		/* get brief info about hardware */
		{
			cmdGetInfoBrief();						/* execute the command */
			
			respPrepare(PCMDRV_STC_OK,(1 + 6)); /* OK */
		}break;
		#endif
		
		/* --------------------------
		    standard format commands
		   -------------------------- */
		#ifdef LEVEL1_CMD_SCOPE
		case PCMDRV_CMD_SETUPSCOPE:					/* setup scope */
		{
			if ( ((PCMasterComm)->p_dataBuff[2]==0) || ((PCMasterComm)->p_dataBuff[2] > 8) )	
			/* varCnt is zero or greater than 8 */
			{
				respPrepare(PCMDRV_STC_INVBUFF,1);	/* invalid buffer size */
				return;
			}
		
			/* init scope */
			cmdScopeInit((int *)(&(PCMasterComm)->p_dataBuff[2]),\
				&(((pcmdrv_sScope *)(PCMasterComm->p_scope))->varCnt));	
			
			/* check size of variable */
			for(i=0 ; i<(((pcmdrv_sScope *)(PCMasterComm->p_scope))->varCnt) ; i++)	
			{
			/* varSize is 0 or 1,3,5,7,... */
				if ( ((((pcmdrv_sScope *)(PCMasterComm->p_scope))->\
						varDef[i].varSize)==0) || (((((pcmdrv_sScope *)\
						(PCMasterComm->p_scope))->varDef[i].varSize)%2)!=0) )
				{
					/* invalid size of variable */
					respPrepare(PCMDRV_STC_INVSIZE,1);	
					/* reset scope */
					(((pcmdrv_sScope *)(PCMasterComm->p_scope))->varCnt) = 0;					
					return;
				}
			}
			respPrepare(PCMDRV_STC_OK,1);
		}break;
		#endif
		#ifdef LEVEL1_CMD_RECORDER
		case PCMDRV_CMD_SETUPREC:				/* setup recorder */
		{
			if (PCMasterComm->recSize==0)		/* recorder not implemented */
			{
				respPrepare(PCMDRV_STC_INVCMD,1);	/* invalid command */
				return;
			}
			
			/* reset the recorder */
			bitClear(ST_RECRUNNING | ST_RECACTIVATED,status);	

			if ( ((PCMasterComm)->p_dataBuff[17]==0) || ((PCMasterComm)->p_dataBuff[17] > 8) )	
			/* varCnt is zero or greater than 8 */
			{
				respPrepare(PCMDRV_STC_INVBUFF,1);	/* invalid buffer size */
				return;
			}

			/* init recorder */
			cmdRecInit((int *)(&(PCMasterComm)->p_dataBuff[2]),\
				&(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgMode));	

			if (((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgMode)
			{
				if (!( ((((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->\
					trgVarSize)==2) || ((((pcmdrv_sRecorder *)\
					(PCMasterComm->p_recorder))->trgVarSize)==4) ) )		
				/* trigger variable size is not 2 or 4 */
				{
					respPrepare(PCMDRV_STC_INVSIZE,1);	/* invalid buffer size */
					/* reset scope */
					(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->varCnt) = 0;			
					return;
				}
				status = (status & 0xfff0) | (((((pcmdrv_sRecorder *)\
						(PCMasterComm->p_recorder))->trgVarSize) << 1) + \
						(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->\
						trgVarSigned));
			}
			
			/* init scope */
			cmdScopeInit((int *)(&(PCMasterComm)->p_dataBuff[17]),&(((pcmdrv_sRecorder *)\
						(PCMasterComm->p_recorder))->varCnt));	
			
			/* check variable sizes */
			for(i=0 ; i<(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->\
				varCnt) ; i++)	
			{
				if ( ((((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->\
					varDef[i].varSize)==0) || (((((pcmdrv_sRecorder *)\
					(PCMasterComm->p_recorder))->varDef[i].varSize)%2)!=0) )	
				/* varSize is 0 or 1,3,5,7,... */
				{
					respPrepare(PCMDRV_STC_INVSIZE,1); /* invalid buffer size */
					/* reset scope */
					((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->varCnt=0;					
					return;
				}
			}
		
			((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recTime = \
				((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->timeDiv;
			((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recToEnd=1;
			((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recPos=0;
						
			((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recSetLen=0;							
			for (i=0 ; i < ((pcmdrv_sRecorder *)\
				(PCMasterComm->p_recorder))->varCnt ; i++)	
			/* check if recorder buffer size is valid */
			{
				/* length of one set of samples (in bytes) */
				((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recSetLen += \
				((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->varDef[i].varSize;			
			}
			/* length (in words) */
			((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recSetLen = \
			(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recSetLen) >> 1;	
			/* buffer length required (in words) */
			((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->totalSmps = \
			((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->totalSmps * \
			((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recSetLen;	
			
			if ((((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->totalSmps) \
				<= PCMasterComm->recSize)		
			/* buffer length required is smaller than recorder buffer */
			{
				varaddr=(int *)((pcmdrv_sRecorder *)\
					(PCMasterComm->p_recorder))->trgVarAddr;
				switch (status & 0x000f)
				{
					/* unsigned word */
					case 0x0004: ((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))\
									->recLastVal.uw=(unsigned int)*varaddr; break;	
					/* signed word */
					case 0x0005: ((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))\
									->recLastVal.sw=(int)*varaddr; break;			
					/* unsigned double */
					case 0x0008: ((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))\
									->recLastVal.ud=(unsigned long)*varaddr; break;	
					/* unsigned double */
					case 0x0009: ((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))\
									->recLastVal.sd=(long)*varaddr; break;			
				}
				respPrepare(PCMDRV_STC_OK,1);
				bitSet(ST_RECACTIVATED,status);		/* recorder activated */
			} 
			else
			/* invalid buffer size specified */
			{
				((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->varCnt=0;
				respPrepare(PCMDRV_STC_INVBUFF,1);	/* invalid buffer size */
				break;
			}
		}break;
		#endif
		#ifdef LEVEL1_CMD_READMEM
		case PCMDRV_CMD_READMEM:					/* read block of memory */
		{
			length=(PCMasterComm)->p_dataBuff[2];
			if ((length+2) <= ((PCMasterComm)->dataBuffSize))
			/* memory block is too long */	
			{
				/* read memory */
				cmdReadMem((int *)(&(PCMasterComm)->p_dataBuff[3]),(int *)(&(PCMasterComm)->p_dataBuff[1]));	
				respPrepare(PCMDRV_STC_OK,(length+1));	/* OK */
			}
			else						
			/* response greater than buffer */
			{
				/* response buffer overflow */
				respPrepare(PCMDRV_STC_RSPBUFFOVF,1);	
			}
		}break;
		#endif
		#ifdef LEVEL1_CMD_WRITEMEM
		case PCMDRV_CMD_WRITEMEM:				/* write block of memory */
		{
			/* read length of memory block from the message */
			length=(PCMasterComm)->p_dataBuff[2];	
			
			asm{move sr,i};		/* store SR register (store IPL setting) */
			archDisableInt();	/* disable interrupts for this operation */
			/* write to memory */
			cmdWriteMem((int *)(&(PCMasterComm)->p_dataBuff[3]),(int *)(&(PCMasterComm)->p_dataBuff[5]));	
			asm{move i,sr};	/* restore SR register (restore IPL setting ) */
			
			respPrepare(PCMDRV_STC_OK,1);
		}break;
		#endif
		#ifdef LEVEL1_CMD_WRITEMEMMASK		
		case PCMDRV_CMD_WRITEMEMMASK:			/* write to memory with mask */
		{
			/* read length of memory block from the message */
			length=(PCMasterComm)->p_dataBuff[2];	
			
			asm{move sr,i};		/* store SR register (store IPL setting) */
			archDisableInt();	/* disable interrupts for this operation */
			/* write to memory */
			cmdWriteMemMask((int *)(&(PCMasterComm)->p_dataBuff[3]),(int *)(&(PCMasterComm)->p_dataBuff[length+3+2])); 
			asm{move i,sr};	/* restore SR register (restore IPL setting ) */
			
			respPrepare(PCMDRV_STC_OK,1);			/* OK */
		}break;	
		#endif
		#ifdef LEVEL1_CMD_APPCMD
		case PCMDRV_CMD_CALLAPPCMD:			/* call user application command */
		{
			if (PCMasterComm->appCmdSize == 0) 		
			/* buffer is not initialized (zero length) */
			{
				respPrepare(PCMDRV_STC_INVCMD,1);	/* invalid command */
				return;
			}
			if ((PCMasterComm)->p_dataBuff[1] > PCMasterComm->appCmdSize)	
			/* check Application Command length */
			{
				respPrepare(PCMDRV_STC_INVBUFF,1);	/* invalid buffer size */
			}
			else
			{
				if (pcmdrvAppCmdSts==PCMDRV_APPCMD_RUNNING)	
				/* Application Command already called */
				{
					respPrepare(PCMDRV_STC_SERVBUSY,1);	/* service is busy	 */
				}
				else					/* no Application Command was called */
				{
				/* copy Application Command data to Application Command buffer */
					cmdCallAppCmd((int *)(&(PCMasterComm)->p_dataBuff[1]),(int *)(PCMasterComm->p_appCmdBuff));	
					pcmdrvAppCmdSts = PCMDRV_APPCMD_RUNNING;
					respPrepare(PCMDRV_STC_OK,1);	/* OK */
				}
			}
		}break;
		#endif
		default:									/* invalid command */
		{
			respPrepare(PCMDRV_STC_INVCMD,1);		/* invalid command */
		}break; 
	}
}

/*------------------------------------------------------------------------------*/

/* this defines basic configuration of the following PC Master Levelx function */
#define LEVEL3_CMD_READVAR16
#define LEVEL3_CMD_READVAR32
#define LEVEL3_CMD_READMEM
#define LEVEL3_CMD_WRITEMEM
#define LEVEL3_CMD_WRITEMEMMASK
#define LEVEL3_CMD_GETINFOBRIEF
#define LEVEL3_CMD_SCOPE
#undef LEVEL3_CMD_APPCMD
#undef LEVEL3_CMD_RECORDER

inline static void messageDecodeLevel3(void)
/* decoding of received message
 proper command will be executed and response sent to PC */
{
int *varaddr;
unsigned int i;

	switch((PCMasterComm)->p_dataBuff[0])
	{
		/* -------------------------
		    special format commands
		   ------------------------- */
		#ifdef LEVEL1_CMD_READVAR16
		case PCMDRV_CMD_READVAR16:					/* read 16-bit variable */
		{
			length=2;
			/* execute command */
			cmdReadMem((int *)(&(PCMasterComm)->p_dataBuff[1]),(int *)(&(PCMasterComm)->p_dataBuff[1]));	
			respPrepare(PCMDRV_STC_OK,3);			/* OK */
		}break;
		#endif
		#ifdef LEVEL1_CMD_READVAR32
		case PCMDRV_CMD_READVAR32:					/* read 32-bit variable */
		{
			length=4;
			/* execute command */
			cmdReadMem((int *)(&(PCMasterComm)->p_dataBuff[1]),(int *)(&(PCMasterComm)->p_dataBuff[1]));	
			respPrepare(PCMDRV_STC_OK,5);			/* OK */
		}break;
		#endif
		#ifdef LEVEL1_CMD_SCOPE
		case PCMDRV_CMD_READSCOPE:					/* read scope variables */
		{
			/* scope not configured */
			if (((pcmdrv_sScope *)(PCMasterComm->p_scope))->varCnt==0)			
			{
				respPrepare(PCMDRV_STC_NOTINIT,1);	/* scope not initialized */
			}		
			else									/* scope configured */
			{
				/* execute command */
				cmdReadScope(&(((pcmdrv_sScope *)(PCMasterComm->p_scope))->varCnt),\
									(int *)(&(PCMasterComm)->p_dataBuff[1])); 
				respPrepare(PCMDRV_STC_OK,length);	/* OK */
			}
		}break;
		#endif
		#ifdef LEVEL1_CMD_RECORDER
		case PCMDRV_CMD_GETRECSTS:					/* get recorder status */
		{
			if (PCMasterComm->recSize==0)			/* recorder not implemented */
			{
				respPrepare(PCMDRV_STC_INVCMD,1);	/* invalid command */
				return;
			}
			/* recorder is initialized */
			if (((pcmdrv_sScope *)(PCMasterComm->p_recorder))->varCnt)			
			{
				if (!(status & ST_RECACTIVATED))
				{
					respPrepare(PCMDRV_STC_RECDONE,1);	/* recorder finished */
				}
				else
				{
					respPrepare(PCMDRV_STC_RECRUN,1);	/* recorder running */
				}
			}
			else								/* recorder is not initialized */
			{
				respPrepare(PCMDRV_STC_NOTINIT,1);	/* recorder not initialized */
			}
		}break;
		case PCMDRV_CMD_STARTREC:					/* start recorder */
		{
			if (PCMasterComm->recSize==0)			/* recorder not implemented */
			{
				respPrepare(PCMDRV_STC_INVCMD,1);	/* invalid command */
				return;
			}
			/* recorder initialized */
			if (((pcmdrv_sScope *)(PCMasterComm->p_recorder))->varCnt)			
			{
				if (!(status & ST_RECRUNNING))		/* recorder not running */
				{
					bitClear(ST_RECRUNNING,status);		/* stop recorder if it 
																	is running */
					/* initialize time div */
					(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recTime) = \
					(unsigned)(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->timeDiv);	
					/* address of triggering variable */
					varaddr=(int *) \
						(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgVarAddr);	
					switch (status & 0x000f)			
					/* initialize last rcorder value 
						with current value of triggering variable */
					{
						case 0x0004: ((pcmdrv_sRecorder *)(PCMasterComm->\
							p_recorder))->recLastVal.uw=(unsigned int)*varaddr; break;
						case 0x0005: ((pcmdrv_sRecorder *)(PCMasterComm->\
							p_recorder))->recLastVal.sw=(int)*varaddr; break;
						case 0x0008: ((pcmdrv_sRecorder *)(PCMasterComm->\
							p_recorder))->recLastVal.ud=(unsigned long)*varaddr; break;
						case 0x0009: ((pcmdrv_sRecorder *)(PCMasterComm->\
							p_recorder))->recLastVal.sd=(long)*varaddr; break;
					}
					/* activate recorder to wait for trigger */
					bitSet(ST_RECACTIVATED,status);	
					respPrepare(PCMDRV_STC_OK,1);	/* OK */
				}
				else
				{
					respPrepare(PCMDRV_STC_RECRUN,1);	/* recorder running */
				}
			}
			else								/* recorder is not initialized */
			{
				respPrepare(PCMDRV_STC_NOTINIT,1);	/* recorder not initialized */
			}
		}break;
		case PCMDRV_CMD_STOPREC:					/* stop recorder */
		{
			if (PCMasterComm->recSize==0)			/* recorder not implemented */
			{
				respPrepare(PCMDRV_STC_INVCMD,1);	/* invalid command */
				return;
			}
			/* recorder initialized */
			if (((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->varCnt)			
			{
				if (status & ST_RECACTIVATED)		/* recorder activated */
				{	
					if (status & ST_RECRUNNING)		/* recorder running */
					{
						respPrepare(PCMDRV_STC_RECDONE,1);	/* recorder finished */
					}
					else								/* recorder not running */
					{	
						/* initialize posttrigger value */
						(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recToEnd)\
						 = (((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->postTrigger);	
						bitSet(ST_RECRUNNING,status);	/* manually trigger 
																the recorder */
						respPrepare(PCMDRV_STC_OK,1);	/* OK */
					}
				}
				else								/* recorder not activated */
				{
					respPrepare(PCMDRV_STC_RECDONE,1);	/* recorder finished */
				}
			}						
			else									/* recorder not initialized */
			{
				respPrepare(PCMDRV_STC_NOTINIT,1);
			}
		}break;				
		case PCMDRV_CMD_GETRECBUFF:					/* get recorder buffer */
		{
			if (PCMasterComm->recSize==0)			/* recorder not implemented */
			{
				respPrepare(PCMDRV_STC_INVCMD,1);
				return;
			}
			/* recorder initialized */
			if ((((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->varCnt) != 0)	
			{
				if (!(status & ST_RECRUNNING))		/* recorder not running */
				{
					/* recorder buffer address */
					(PCMasterComm)->p_dataBuff[1]=(unsigned int)(PCMasterComm->p_recBuff) & 0x00FF;	
					
					/* recorder buffer address */
					(PCMasterComm)->p_dataBuff[2]=(unsigned int)(PCMasterComm->p_recBuff) >> 8;		
					i=(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recPos)\
						/(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recSetLen);
					
					/* position of the last sample in recorder buffer */
					(PCMasterComm)->p_dataBuff[3]=(i) & 0x00FF;		
					
					/* position of the last sample in recorder buffer */
					(PCMasterComm)->p_dataBuff[4]=(i) >> 8;			
					
					respPrepare(PCMDRV_STC_OK,5);	/* OK */
				}
				else								/* recorder running */
				{
					respPrepare(PCMDRV_STC_SERVBUSY,1);	/* service busy */
				}
			} else									/* recorder initialized */
			{
				respPrepare(PCMDRV_STC_NOTINIT,1);	/* recorder not initialized */
			}
		}break;
		#endif
		#ifdef LEVEL1_CMD_APPCMD
		case PCMDRV_CMD_GETAPPCMDSTS:		/* get user application 
													command call status */
		{
		/* buffer is not initialized (zero length) */
			if (PCMasterComm->appCmdSize == 0)		
			{
				respPrepare(PCMDRV_STC_INVCMD,1);	/* invalid command */
				return;
			}
			/* copy status byte in the output buffer */
			(PCMasterComm)->p_dataBuff[1]=pcmdrvAppCmdSts;					
			respPrepare(PCMDRV_STC_OK,2);			/* OK */
		}break;
		#endif
		#ifndef LEVEL1_CMD_GETINFOBRIEF
		case PCMDRV_CMD_GETINFO:					/* get info about hardware */
		{
			cmdGetInfo();							/* execute the command */
			
			respPrepare(PCMDRV_STC_OK,(1 + 10 + PCMDRV_IDT_STRING_LEN)); /* OK */
		}break;
		#endif
		#ifdef LEVEL1_CMD_GETINFOBRIEF
		case PCMDRV_CMD_GETINFOBRIEF:		/* get brief info about hardware */
		{
			cmdGetInfoBrief();						/* execute the command */
			
			respPrepare(PCMDRV_STC_OK,(1 + 6)); /* OK */
		}break;
		#endif
		
		/* --------------------------
		    standard format commands
		   -------------------------- */
		#ifdef LEVEL1_CMD_SCOPE
		case PCMDRV_CMD_SETUPSCOPE:					/* setup scope */
		{
			if ( ((PCMasterComm)->p_dataBuff[2]==0) || ((PCMasterComm)->p_dataBuff[2] > 8) )	
			/* varCnt is zero or greater than 8 */
			{
				respPrepare(PCMDRV_STC_INVBUFF,1);	/* invalid buffer size */
				return;
			}
		
			/* init scope */
			cmdScopeInit((int *)(&(PCMasterComm)->p_dataBuff[2]),\
				&(((pcmdrv_sScope *)(PCMasterComm->p_scope))->varCnt));	
			
			/* check size of variable */
			for(i=0 ; i<(((pcmdrv_sScope *)(PCMasterComm->p_scope))->varCnt) ; i++)	
			{
			/* varSize is 0 or 1,3,5,7,... */
				if ( ((((pcmdrv_sScope *)(PCMasterComm->p_scope))->\
						varDef[i].varSize)==0) || (((((pcmdrv_sScope *)\
						(PCMasterComm->p_scope))->varDef[i].varSize)%2)!=0) )
				{
					/* invalid size of variable */
					respPrepare(PCMDRV_STC_INVSIZE,1);	
					/* reset scope */
					(((pcmdrv_sScope *)(PCMasterComm->p_scope))->varCnt) = 0;					
					return;
				}
			}
			respPrepare(PCMDRV_STC_OK,1);
		}break;
		#endif
		#ifdef LEVEL1_CMD_RECORDER
		case PCMDRV_CMD_SETUPREC:				/* setup recorder */
		{
			if (PCMasterComm->recSize==0)		/* recorder not implemented */
			{
				respPrepare(PCMDRV_STC_INVCMD,1);	/* invalid command */
				return;
			}
			
			/* reset the recorder */
			bitClear(ST_RECRUNNING | ST_RECACTIVATED,status);	

			if ( ((PCMasterComm)->p_dataBuff[17]==0) || ((PCMasterComm)->p_dataBuff[17] > 8) )	
			/* varCnt is zero or greater than 8 */
			{
				respPrepare(PCMDRV_STC_INVBUFF,1);	/* invalid buffer size */
				return;
			}

			/* init recorder */
			cmdRecInit((int *)(&(PCMasterComm)->p_dataBuff[2]),\
				&(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgMode));	

			if (((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgMode)
			{
				if (!( ((((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->\
					trgVarSize)==2) || ((((pcmdrv_sRecorder *)\
					(PCMasterComm->p_recorder))->trgVarSize)==4) ) )		
				/* trigger variable size is not 2 or 4 */
				{
					respPrepare(PCMDRV_STC_INVSIZE,1);	/* invalid buffer size */
					/* reset scope */
					(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->varCnt) = 0;			
					return;
				}
				status = (status & 0xfff0) | (((((pcmdrv_sRecorder *)\
						(PCMasterComm->p_recorder))->trgVarSize) << 1) + \
						(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->\
						trgVarSigned));
			}
			
			/* init scope */
			cmdScopeInit((int *)(&(PCMasterComm)->p_dataBuff[17]),&(((pcmdrv_sRecorder *)\
						(PCMasterComm->p_recorder))->varCnt));	
			
			/* check variable sizes */
			for(i=0 ; i<(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->\
				varCnt) ; i++)	
			{
				if ( ((((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->\
					varDef[i].varSize)==0) || (((((pcmdrv_sRecorder *)\
					(PCMasterComm->p_recorder))->varDef[i].varSize)%2)!=0) )	
				/* varSize is 0 or 1,3,5,7,... */
				{
					respPrepare(PCMDRV_STC_INVSIZE,1); /* invalid buffer size */
					/* reset scope */
					((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->varCnt=0;					
					return;
				}
			}
		
			((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recTime = \
				((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->timeDiv;
			((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recToEnd=1;
			((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recPos=0;
						
			((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recSetLen=0;							
			for (i=0 ; i < ((pcmdrv_sRecorder *)\
				(PCMasterComm->p_recorder))->varCnt ; i++)	
			/* check if recorder buffer size is valid */
			{
				/* length of one set of samples (in bytes) */
				((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recSetLen += \
				((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->varDef[i].varSize;			
			}
			/* length (in words) */
			((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recSetLen = \
			(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recSetLen) >> 1;	
			/* buffer length required (in words) */
			((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->totalSmps = \
			((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->totalSmps * \
			((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recSetLen;	
			
			if ((((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->totalSmps) \
				<= PCMasterComm->recSize)		
			/* buffer length required is smaller than recorder buffer */
			{
				varaddr=(int *)((pcmdrv_sRecorder *)\
					(PCMasterComm->p_recorder))->trgVarAddr;
				switch (status & 0x000f)
				{
					/* unsigned word */
					case 0x0004: ((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))\
									->recLastVal.uw=(unsigned int)*varaddr; break;	
					/* signed word */
					case 0x0005: ((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))\
									->recLastVal.sw=(int)*varaddr; break;			
					/* unsigned double */
					case 0x0008: ((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))\
									->recLastVal.ud=(unsigned long)*varaddr; break;	
					/* unsigned double */
					case 0x0009: ((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))\
									->recLastVal.sd=(long)*varaddr; break;			
				}
				respPrepare(PCMDRV_STC_OK,1);
				bitSet(ST_RECACTIVATED,status);		/* recorder activated */
			} 
			else
			/* invalid buffer size specified */
			{
				((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->varCnt=0;
				respPrepare(PCMDRV_STC_INVBUFF,1);	/* invalid buffer size */
				break;
			}
		}break;
		#endif
		#ifdef LEVEL1_CMD_READMEM
		case PCMDRV_CMD_READMEM:					/* read block of memory */
		{
			length=(PCMasterComm)->p_dataBuff[2];
			if ((length+2) <= ((PCMasterComm)->dataBuffSize))
			/* memory block is too long */	
			{
				/* read memory */
				cmdReadMem((int *)(&(PCMasterComm)->p_dataBuff[3]),(int *)(&(PCMasterComm)->p_dataBuff[1]));	
				respPrepare(PCMDRV_STC_OK,(length+1));	/* OK */
			}
			else						
			/* response greater than buffer */
			{
				/* response buffer overflow */
				respPrepare(PCMDRV_STC_RSPBUFFOVF,1);	
			}
		}break;
		#endif
		#ifdef LEVEL1_CMD_WRITEMEM
		case PCMDRV_CMD_WRITEMEM:				/* write block of memory */
		{
			/* read length of memory block from the message */
			length=(PCMasterComm)->p_dataBuff[2];	
			
			asm{move sr,i};		/* store SR register (store IPL setting) */
			archDisableInt();	/* disable interrupts for this operation */
			/* write to memory */
			cmdWriteMem((int *)(&(PCMasterComm)->p_dataBuff[3]),(int *)(&(PCMasterComm)->p_dataBuff[5]));	
			asm{move i,sr};	/* restore SR register (restore IPL setting ) */
			
			respPrepare(PCMDRV_STC_OK,1);
		}break;
		#endif
		#ifdef LEVEL1_CMD_WRITEMEMMASK		
		case PCMDRV_CMD_WRITEMEMMASK:			/* write to memory with mask */
		{
			/* read length of memory block from the message */
			length=(PCMasterComm)->p_dataBuff[2];	
			
			asm{move sr,i};		/* store SR register (store IPL setting) */
			archDisableInt();	/* disable interrupts for this operation */
			/* write to memory */
			cmdWriteMemMask((int *)(&(PCMasterComm)->p_dataBuff[3]),(int *)(&(PCMasterComm)->p_dataBuff[length+3+2])); 
			asm{move i,sr};	/* restore SR register (restore IPL setting ) */
			
			respPrepare(PCMDRV_STC_OK,1);			/* OK */
		}break;	
		#endif
		#ifdef LEVEL1_CMD_APPCMD
		case PCMDRV_CMD_CALLAPPCMD:			/* call user application command */
		{
			if (PCMasterComm->appCmdSize == 0) 		
			/* buffer is not initialized (zero length) */
			{
				respPrepare(PCMDRV_STC_INVCMD,1);	/* invalid command */
				return;
			}
			if ((PCMasterComm)->p_dataBuff[1] > PCMasterComm->appCmdSize)	
			/* check Application Command length */
			{
				respPrepare(PCMDRV_STC_INVBUFF,1);	/* invalid buffer size */
			}
			else
			{
				if (pcmdrvAppCmdSts==PCMDRV_APPCMD_RUNNING)	
				/* Application Command already called */
				{
					respPrepare(PCMDRV_STC_SERVBUSY,1);	/* service is busy	 */
				}
				else					/* no Application Command was called */
				{
				/* copy Application Command data to Application Command buffer */
					cmdCallAppCmd((int *)(&(PCMasterComm)->p_dataBuff[1]),(int *)(PCMasterComm->p_appCmdBuff));	
					pcmdrvAppCmdSts = PCMDRV_APPCMD_RUNNING;
					respPrepare(PCMDRV_STC_OK,1);	/* OK */
				}
			}
		}break;
		#endif
		default:									/* invalid command */
		{
			respPrepare(PCMDRV_STC_INVCMD,1);		/* invalid command */
		}break; 
	}
}

/*------------------------------------------------------------------------------*/

#ifdef PCMDRV_INCLUDE_CMD_RECORDER
void pcmasterdrvRecorder(void)
{
int *addr;
union{
	unsigned int	uw;
	unsigned long	ud;
	signed int 		sw;
	signed long		sd;
} actual;

	if (status & ST_RECACTIVATED)	/* recorder activated */
	{
		if (((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recTime == \
			((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->timeDiv)
		/* now is the right time to make samples */
		{
			switch (status & 0x000f)
			{

			case 0x0004:
			/* size=2, unsigned */
			{
				addr=(int *)((pcmdrv_sRecorder *)\
					(PCMasterComm->p_recorder))->trgVarAddr;
				actual.uw=(unsigned int)*addr;			/* read actual value */
				
				/* read new samples */
				readSample(&((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->\
					varCnt,(int *)((&PCMasterComm->p_recBuff[((pcmdrv_sRecorder *)\
					(PCMasterComm->p_recorder))->recPos])));	
				((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recPos += \
				((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recSetLen;
				
				/* wrap around */
				if (((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recPos >= \
					((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->totalSmps) \
					((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recPos=0;	

				if (!(status & ST_RECRUNNING))
				{
					if ((((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgMode\
					== PCMDRV_REC_TRIGRIS) && (actual.uw >= \
					((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgTreshold.uw) && \
					(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recLastVal.uw <\
					((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgTreshold.uw))
					/* recorder is configured to rising edge
					   actual value greater than treshold
					   last value smaller than treshold */
					{
						bitSet(ST_RECRUNNING,status);				
						((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recToEnd = \
						((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->postTrigger-1;
					}
					else if ((((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgMode\
							 == PCMDRV_REC_TRIGFAL) && (actual.uw <= \
							 ((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgTreshold.uw) && \
							(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recLastVal.uw > \
							((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgTreshold.uw))
					/* recorder is configured to falling edge
					   actual value smaller than treshold
					   last value greater than treshold */
					{
						bitSet(ST_RECRUNNING,status);				
						((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recToEnd = \
						((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->postTrigger-1;
					}
				}
				else ((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recToEnd--;
			
				if (((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recToEnd==0)
				/* buffer is full */
				{
					bitClear(ST_RECRUNNING | ST_RECACTIVATED,status);		
					((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recToEnd=1;
				}
				/* remember last value */
				((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recLastVal.uw = actual.uw;	
				/* reset recorder time */
				((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recTime = 0;		
			}break; 
			
			case 0x0005:
			// size=2, signed			
			{
				addr=(int *)((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgVarAddr;
				actual.sw=(int)*addr;					/* read actual value */
				
				/* read new samples */
				readSample(&((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->varCnt,\
						(int *)(&PCMasterComm->p_recBuff[\
						((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recPos]));	
				((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recPos += \
				((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recSetLen;
				/* wrap around */
				if (((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recPos >= \
					((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->totalSmps) \
					((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recPos=0;	
									
				if (!(status & ST_RECRUNNING))
				{
					if ((((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgMode\
						 == PCMDRV_REC_TRIGRIS) && (actual.sw >= \
						 ((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgTreshold.sw) && \
						(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recLastVal.sw < \
						((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgTreshold.sw))
					/* recorder is configured to rising edge
					   actual value greater than treshold
					   last value smaller than treshold */
					{
						bitSet(ST_RECRUNNING,status);				
						((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recToEnd = \
						((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->postTrigger-1;
					}
					else if ((((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgMode\
						 == PCMDRV_REC_TRIGFAL) && (actual.sw <= \
						 ((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgTreshold.sw) && \
						 (((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recLastVal.sw > \
						 ((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgTreshold.sw))
					/* recorder is configured to falling edge
					   actual value smaller than treshold
					   last value greater than treshold */
					{
						bitSet(ST_RECRUNNING,status);				
						((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recToEnd = \
						((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->postTrigger-1;
					}
				}
				else ((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recToEnd--;
			
				if (((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recToEnd==0)
				/* buffer is full */
				{
					bitClear(ST_RECRUNNING | ST_RECACTIVATED,status);			
					((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recToEnd=1;
				}
				/* remember last value */
				((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recLastVal.sw=actual.sw;	
				/* reset recorder time */
				((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recTime=0;		
			}break;
			
			case 0x0008:
			/* size=4, unsigned	*/
			{
				addr=(int *)((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgVarAddr;
				actual.ud=(unsigned long)*addr;			/* read actual value */
				
				/* read new samples */
				readSample(&((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->varCnt,\
					(int *)(&PCMasterComm->p_recBuff[\
					((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recPos]));		
				((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recPos += \
				((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recSetLen;
				/* wrap around */
				if (((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recPos >= \
					((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->totalSmps) \
					((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recPos=0;		
									
				if (!(status & ST_RECRUNNING))
				{
					if ((((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgMode\
						 == PCMDRV_REC_TRIGRIS) && (actual.ud >= \
						 ((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgTreshold.ud) && \
						 (((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recLastVal.ud < \
						 ((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgTreshold.ud))
					/* recorder is configured to rising edge
					   actual value greater than treshold
					   last value smaller than treshold */
					{
						bitSet(ST_RECRUNNING,status);				
						((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recToEnd = \
						((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->postTrigger-1;
					}
					else if ((((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgMode\
						 == PCMDRV_REC_TRIGFAL) && (actual.ud <= \
						 ((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgTreshold.ud) && \
						 (((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recLastVal.ud > \
						 ((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgTreshold.ud))
					/* recorder is configured to falling edge
					   actual value smaller than treshold
					   last value greater than treshold */
					{
						bitSet(ST_RECRUNNING,status);				
						((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recToEnd = \
						((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->postTrigger-1;
					}
				}
				else ((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recToEnd--;
			
				if (((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recToEnd==0)
				/* buffer is full */
				{
					bitClear(ST_RECRUNNING | ST_RECACTIVATED,status);			
					((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recToEnd=1;
				}
				/* remember last value */
				((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recLastVal.ud=actual.ud;	
				/* reset recorder time */
				((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recTime=0;					
			}break;
			
			case 0x0009:
			/* size=4, signed */
			{
				addr=(int *)((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgVarAddr;
				actual.sd=(long)*addr;					/* read actual value */
				
				/* read new samples */
				readSample(&((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->varCnt,\
					(int *)(&PCMasterComm->p_recBuff[\
					((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recPos]));	
				((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recPos += \
				((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recSetLen;
				/* wrap around */
				if (((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recPos >= \
					((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->totalSmps) \
					((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recPos=0;		
									
				if (!(status & ST_RECRUNNING))
				{
					if ((((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgMode\
						 == PCMDRV_REC_TRIGRIS) && (actual.sd >= \
						 ((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgTreshold.sd) && \
						(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recLastVal.sd < \
						((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgTreshold.sd))
					/* recorder is configured to rising edge
					   actual value greater than treshold
					   last value smaller than treshold */
					{
						bitSet(ST_RECRUNNING,status);				
						((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recToEnd = \
						((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->postTrigger-1;
					}
					else if ((((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgMode\
						 == PCMDRV_REC_TRIGFAL) && (actual.sd <= \
						 ((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgTreshold.sd) && \
						(((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recLastVal.sd > \
						((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->trgTreshold.sd))
					/* recorder is configured to falling edge
					   actual value smaller than treshold
					   last value greater than treshold */
					{
						bitSet(ST_RECRUNNING,status);				
						((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recToEnd =\
						((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->postTrigger-1;
					}
				}
				else ((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recToEnd--;
			
				if (((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recToEnd==0)
				/* buffer is full */
				{
					bitClear(ST_RECRUNNING | ST_RECACTIVATED,status);			
					((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recToEnd=1;
				}
				/* remember last value */
				((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recLastVal.sd=actual.sd;	
				/* reset recorder time */
				((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recTime=0;		
			}break;
			}
		}
		/* wait for the right time */
		else ((pcmdrv_sRecorder *)(PCMasterComm->p_recorder))->recTime++;			
	}
}
#endif

/*------------------------------------------------------------------------------*/

static void messageData(UWord16 startOfMessage)
{
	if (startOfMessage == 0)	/* no start of message */
	{
		if (status & ST_STARTED)	/* start of message already detected */
		{
			if (pos != length)		
			{
				/* read byte, accumulate checksum */
				(PCMasterComm)->p_dataBuff[pos] = inChar;		
				checkSum += inChar;			/* checksum accumulation */
				pos++;						/* next position in buffer */

				if (status & ST_STD_CMD)	
				/* inChar contains length of standard format message */
				{
					length = inChar + 2;	/* read length of message */
					bitClear(ST_STD_CMD,status);	/* clear flag */
			
					if (length > ((PCMasterComm)->dataBuffSize))
					/* command is greater than input buffer */
					{
						/* clear flag */
						bitClear(ST_STARTED | ST_ST_CHAR_REC,status);	
						/* input buffer overflow */
						respPrepare(PCMDRV_STC_CMDBUFFOVF,1);	
						/* send response to PC */
						sendResponse(&response);	
					}
				}			
			}
			else	/* end of message */
			{
				checkSum += inChar;			/* accumulate checksum */
				if ((checkSum & 0x00FF) == 0) /* correct checksum */
				{
					messageDecodeLevelx();
				}
				else						/* checksum error */
				{
					/* checksum error response */
					respPrepare(PCMDRV_STC_CMDSERR,1);	
				}
				
				/* clear flag */
				bitClear(ST_STARTED | ST_ST_CHAR_REC,status);	
				sendResponse(&response);	/* send response to PC */
			}
		}
	}
	else			/* start of message */
	{
		/* reset receiver, read first byte of message */
		bitSet(ST_STARTED,status);			/* message receiving */
		/* read byte, start of checksum accumulating */
		checkSum = (PCMasterComm)->p_dataBuff[0] = inChar;	
		/* next position in buffer */
		pos = 1;							
		/* value sufficient for standard format commands */
		length = 2;							
		
		if (inChar >= 0xC0)		/* special format command */
		{
			length=((inChar & 0x30) >> 3) + 1;	/* length decoding */
		}
		else	
		/* standard format command (next byte will be length of the message) */
		{
			bitSet(ST_STD_CMD,status);			/* wait for next character */
		}
		
	}
}

/*------------------------------------------------------------------------------*/

void pcmasterdrvIsr(void)
{
	archEnableInt();	/* enable interrupts to make this routine interruptible */

	if (status & ST_SENDING) 				/* message is transmitting */
	{
		sendBuffer();						/* send data */
		return;								/* response is sending to PC */
	}
	
	scidrvRead(inChar);						/* read received character */

	
	if ((status & ST_ST_CHAR_REC) == 0)	/* last byte was not '+' */
	{
		if (inChar == '+') 			/* '+' received */
		{
			bitSet(ST_ST_CHAR_REC,status);
		}
		else 						/* any byte received */
		{
			messageData(0);			/* byte received */
		}
	}
	else				/* the last byte was '+' */
	{
		if (inChar == '+') 			/* doubled '+' (this is the second one) */
		{
			messageData(0);			/* byte received */
		}
		else					/* start of message */
		{
			messageData(1);		/* byte received */
		}

			bitClear(ST_ST_CHAR_REC,status);	/* clear flag */
	}
}
		
		
				
