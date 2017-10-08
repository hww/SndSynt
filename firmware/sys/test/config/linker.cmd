# Linker.cmd file for DSP56826EVM External RAM
#        using both internal and external data memory (EX = 0)
#    and using external program memory (Mode = 3)

MEMORY {
	
	.pvec   (RX)  : ORIGIN = 0x0000, LENGTH = 0x0086  # interrupt vector table ( (64 + 1) * 2 + 2)
	.pram   (RWX) : ORIGIN = 0x0086, LENGTH = 0xFF7A  # external program memory

	.avail  (RW)  : ORIGIN = 0x0000, LENGTH = 0x0030  # available
	.cwregs (RW)  : ORIGIN = 0x0030, LENGTH = 0x0010  # C temp registrs in CodeWarrior
	.im     (RW)  : ORIGIN = 0x0040, LENGTH = 0x0FC0  # data
	.regs   (RW)  : ORIGIN = 0x1000, LENGTH = 0x0400  # periperal registers
	.hole   (R)   : ORIGIN = 0x1400, LENGTH = 0x0400  # hole
	.xflash (R)   : ORIGIN = 0x1800, LENGTH = 0x0800  # data flash memory to place constant 
	.xram   (RW)  : ORIGIN = 0x2000, LENGTH = 0xC000  # external data ram
	.em     (RW)  : ORIGIN = 0xE000, LENGTH = 0x1000  # external data ram
	.stack  (RW)  : ORIGIN = 0xF000, LENGTH = 0x0F80  # stack   
	.onchip (RW)  : ORIGIN = 0xFF80, LENGTH = 0x0080  # on-chip core configuration registers
}


FORCE_ACTIVE {FconfigInterruptVector}

SECTIONS {

	#
	# Data (X) Memory Layout
	#
		_EX_BIT     = 0;

		# Internal Memory Partitions (for mem.h partitions)

		_NUM_IM_PARTITIONS = 1;  # IM_ADDR_1 (no IM_ADDR_2 )

		# External Memory Partition (for mem.h partitions)

		_NUM_EM_PARTITIONS = 1;   # EM_ADDR_1
	

	.main_application_vector :
	{
		# .text sections
		
		#  vector.c MUST be placed into .pvec, otherwise the Interrupt Vector
		#  configInterruptVector will not be located at the correct address, P:0x0000
		
		vector.c (.text)
		
	} > .pvec

	.main_application_code :
	{
		# .text sections
		
		* (.text)
		* (rtlib.text)
		* (fp_engine.text)
		* (user.text)

                PmemData.c (.data)
		
		# SDK .data section for Program RAM

		F_Pdata_start_addr_in_ROM = 0;
		
		F_Pdata_start_addr_in_RAM = .;

                pramdata.c (.data)

		F_Pdata_ROMtoRAM_length = 0;
   
      # SDK .bss sections for Program RAM
      
   	F_Pbss_start_addr = .;
		_P_BSS_ADDR = .;
      
		pramdata.c (.bss)
                PmemData.c (.bss)
		
		F_Pbss_length = . - _P_BSS_ADDR;
		
	} > .pram	

	.main_application_data :
	{
		# 
		# Define variables for C initialization code
		#
		F_Xdata_start_addr_in_ROM = ADDR(.xflash) + SIZEOF(.xflash) / 2;
		F_StackAddr               = ADDR(.stack);
		F_StackEndAddr            = ADDR(.stack) + SIZEOF(.stack) / 2  - 1;
		
		F_Xdata_start_addr_in_RAM = .;
		
		#
		# Memory layout data for SDK INCLUDE_MEMORY (mem.h) support
		#
# ???

		FmemEXbit = .;
			WRITEH(_EX_BIT);
		FmemNumIMpartitions = .;
			WRITEH(_NUM_IM_PARTITIONS);
		FmemNumEMpartitions = .;
			WRITEH(_NUM_EM_PARTITIONS);
		FmemIMpartitionList = .;
			WRITEH(ADDR(.im));
			WRITEH(SIZEOF(.im) / 2);
		FmemEMpartitionList = .;
			WRITEH(ADDR(.em));
			WRITEH(SIZEOF(.em) /2);


					 
		# .data sections
		
		* (.data)
		* (fp_state.data)
		* (rtlib.data)
		
		F_Xdata_ROMtoRAM_length = 0;
		
		F_Xbss_start_addr = .;
		_X_BSS_ADDR = .;
		
	  	* (rtlib.bss.lo)
		* (.bss)
		
		F_Xbss_length = . - _X_BSS_ADDR;  # Copy DATA

	} > .xram


	FArchIO   = ADDR(.regs);
	FArchCore = ADDR(.onchip);
}
