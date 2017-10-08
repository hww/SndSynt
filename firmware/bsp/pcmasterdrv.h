/******************************************************************************
*
* Motorola Inc.
* (c) Copyright 2000 Motorola, Inc.
* ALL RIGHTS RESERVED.
*
*******************************************************************************
*
* FILE NAME: pcmasterdrv.h
*
*******************************************************************************/

#ifndef _PCMASTERDRV_H_
#define _PCMASTERDRV_H_

/*-----------------
  standard commands
  -----------------*/
#define PCMDRV_CMD_READMEM			0x01	/* read block of memory */
#define PCMDRV_CMD_WRITEMEM			0x02	/* write block of memory */
#define PCMDRV_CMD_WRITEMEMMASK		0x03	/* write block of memory with mask */
#define PCMDRV_CMD_SETUPSCOPE		0x08	/* setup scope */
#define PCMDRV_CMD_SETUPREC			0x09	/* setup recorder */
#define PCMDRV_CMD_CALLAPPCMD		0x10	/* call user application command */

/*-----------------
   special commands
  -----------------*/
/* no data part */
#define PCMDRV_CMD_GETINFO		0xC0		/* get system information */
#define PCMDRV_CMD_GETINFOBRIEF	0xC8		/* get brief system information */
#define PCMDRV_CMD_STARTREC		0xC1		/* start recorder */
#define PCMDRV_CMD_STOPREC		0xC2		/* stop recorder */
#define PCMDRV_CMD_GETRECSTS	0xC3		/* get recorder status */
#define PCMDRV_CMD_GETRECBUFF	0xC4		/* get recorder buffer information */
#define PCMDRV_CMD_READSCOPE	0xC5		/* read scope variables */
#define PCMDRV_CMD_GETAPPCMDSTS	0xC6		/* get user application command status */
/* 2 bytes data part */
#define PCMDRV_CMD_READVAR8		0xD0		/* read 8-bit variable from 16-bit address */
#define PCMDRV_CMD_READVAR16	0xD1		/* read 16-bit variable from 16-bit address */
#define PCMDRV_CMD_READVAR32	0xD2		/* read 32-bit variable from 16-bit address */
/* 4 bytes data part */
#define PCMDRV_CMD_READVAR8EX	0xE0		/* read 8-bit variable from 32-bit address */
#define PCMDRV_CMD_READVAR16EX	0xE1		/* read 16-bit variable from 32-bit address */
#define PCMDRV_CMD_READVAR32EX	0xE2		/* read 32-bit variable from 32-bit address */

/*-------------
  status bytes
  -------------*/
#define PCMDRV_STC_OK 			0x00	/* operation succesful */
#define PCMDRV_STC_RECRUN		0x01	/* recorder running */
#define PCMDRV_STC_RECDONE		0x02	/* recorder finished */
/* error codes */
#define PCMDRV_STC_INVCMD		0x81	/* invalid command */
#define PCMDRV_STC_CMDSERR		0x82	/* checksum error */
#define PCMDRV_STC_CMDBUFFOVF	0x83	/* command too long */
#define PCMDRV_STC_RSPBUFFOVF	0x84	/* response would be too long */
#define PCMDRV_STC_INVBUFF		0x85	/* invalid buffer length specified */
#define PCMDRV_STC_INVSIZE		0x86	/* invalid size */
#define PCMDRV_STC_SERVBUSY		0x87	/* service is busy */
#define PCMDRV_STC_NOTINIT		0x88	/* scope/recorder not configured */
#define PCMDRV_STC_UNKNOWN		0xFF	/* reserved */

/* recorder trigger modes */
#define PCMDRV_REC_TRIGOFF		0		/* manual mode (trigger disabled) */
#define PCMDRV_REC_TRIGRIS		1		/* rising edge */
#define PCMDRV_REC_TRIGFAL		2		/* falling edge */

#define PCMDRV_IDT_STRING_LEN	25		/* length of identification string */

/* get info command parameters */
#define PCMDRV_PROT_VER			2		/* PC Master protocol version */
#define PCMDRV_DATABUSWDT		2		/* data bud width */
#define PCMDRV_CFG_FLAFGS		0x0004	/* little endian data format + no fast writes */


/* structure with SCI communication settings */
typedef struct {
	UWord16 *p_dataBuff;			/* pointer to input/output communication buffer */
	UWord16 dataBuffSize;			/* size of input/output communication buffer */
	UWord16 *p_recBuff;				/* pointer to recorder buffer */
	UWord16 recSize;				/* recorder buffer size */
	UWord16 *p_recorder;			/* structure with recorder settings 
										and temporary variables */
	UWord16 *p_scope;				/* structure with scope settings */
	UWord16 timeBase;				/* period of Recorder Routine launch */
	UWord16 *p_appCmdBuff;			/* pointer to application command buffer */
	UWord16 appCmdSize;				/* application command buffer size */
	UWord16 globVerMajor;			/* board firmware version major number */
	UWord16 globVerMinor;			/* board firmware version minor number */
	UWord16 idtString[PCMDRV_IDT_STRING_LEN];		/* device identification string */
} sPCMasterComm;

/* recorder settings structure (recorder settings and 
temporary variables are stored in this structure) */
typedef struct{
	int trgMode;				/* 0x00 - manual, 0x01 - rising edge, 
												  0x02 - falling edge */
	unsigned int totalSmps;		/* number of samples required */
	unsigned int postTrigger;	/* samples after trigger */
	unsigned int timeDiv;		/* time div */
	int 		 trgVarAddr;	/* address of trigger variable */
	unsigned int trgVarSize;	/* size of variable (bytes) */
	unsigned int trgVarSigned;	/* 0x00 - unsigned, 0x01 - signed */
	
	union{						
	/* union is used to access various types of treshold */
		unsigned int	uw;
		unsigned long	ud;
		signed int 		sw;
		signed long		sd;
	} trgTreshold;				/* trigger treshold */
	
	int varCnt;					/* number of variables */
	struct{
		int varSize;			/* size of variable */
		int varAddr;			/* address of variable */
	} varDef[8];
	
	/* position in recorder buffer - position of the next samples 
	(incremented with RecSetLen) */
	unsigned int recPos;		
	/* length of required set of variables (in words) */
	unsigned int recSetLen;	
	/* position to end of buffer (the variable is decremented after trigger 
	and recorder stops at 0) */
	unsigned int recToEnd;
	/* time div of Recorder */
	unsigned int recTime;

	/* recorder last value (last value the triggering variable 
	is stored after launch of Recorder routine)  */
	union{
		unsigned int	uw;
		unsigned long	ud;
		signed int 		sw;
		signed long		sd;
	} recLastVal;				/* last value of synchronizing variable */
	
} pcmdrv_sRecorder;

/* scope settings buffer (scope settings are stored in this structure) */
typedef struct{
int	varCnt;
struct{
	int varSize;				/* size of scope variable */
	int varAddr;				/* address of scope variable */
	} varDef[8];				/* maximum number of variables is 8 */
} pcmdrv_sScope;


/* if no level is defined set Level1 -> full configuration of PC Master */
#if !( defined(PCMDRV_LEVEL_1) || defined(PCMDRV_LEVEL_2) || defined(PCMDRV_LEVEL_3) )
	#define PCMDRV_LEVEL_1
#endif

/* select function related to selected level */
#ifdef PCMDRV_LEVEL_1
	#define messageDecodeLevelx() {messageDecodeLevel1();}
	#undef PCMDRV_LEVEL_2
	#undef PCMDRV_LEVEL_3
#endif

#ifdef PCMDRV_LEVEL_2
	#define messageDecodeLevelx() {messageDecodeLevel2();}			
	#undef PCMDRV_LEVEL_1
	#undef PCMDRV_LEVEL_3
#endif

#ifdef PCMDRV_LEVEL_3
	#define messageDecodeLevelx() {messageDecodeLevel3();}		
	#undef PCMDRV_LEVEL_1
	#undef PCMDRV_LEVEL_2
#endif

 
/* 
Initialization of PC Master Communication Algorithm	
This function must be called first, before start of communication.
Parameter passed to this function is variable of sPCMasterComm type
*/
Word16 pcmasterdrvInit(sPCMasterComm *p_sPCMasterComm);

/*
Get Application Command Status
This function is used to check if an application command has been received from PC
*/
UWord16 inline pcmasterdrvGetAppCmdSts(void);			

/*
Write Application Command Status
This function clears the flags in application command status word
and it says to PC that the last application command was served and 
new application command from PC will be accepted
*/
Word16 inline pcmasterdrvWriteAppCmdSts(UWord16 state);	

/*
Main PC Master Communication routine which provide receiving,
decoding of incoming message and sending response to PC
*/
void pcmasterdrvIsr(void);							

/*
Recorder Routine
It performs sampling of data into buffer which is located
on the address p_recBuff item is pointing and its length 
is determined by recSize item in the initialization structure
of sPCMasterComm type
*/
#ifdef PCMDRV_LEVEL_1
   void pcmasterdrvRecorder(void);						
#endif
#ifndef PCMDRV_LEVEL_1
   #define pcmasterdrvRecorder() {;}
#endif


#endif