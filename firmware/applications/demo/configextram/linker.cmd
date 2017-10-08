# Linker.cmd file for DSP56826EVM External RAM
#        using both internal and external data memory (EX = 0)
#    and using external program memory (Mode = 3)

#*******************************************************************************
MEMORY {
	
	.pInterruptVector   (RX)  : ORIGIN = 0x0000, LENGTH = 0x0086 
	.pExtRAM            (RWX) : ORIGIN = 0x0086, LENGTH = 0xFF7A

	.xAvailable         (RW)  : ORIGIN = 0x0000, LENGTH = 0x0030
	.xCWRegisters       (RW)  : ORIGIN = 0x0030, LENGTH = 0x0010
	.xIntRAM_DynamicMem (RW)  : ORIGIN = 0x0040, LENGTH = 0x0FC0
	.xPeripherals       (RW)  : ORIGIN = 0x1000, LENGTH = 0x0400
	.xReserved          (R)   : ORIGIN = 0x1400, LENGTH = 0x0400 
	.xFlash             (R)   : ORIGIN = 0x1800, LENGTH = 0x0800  
	.xExtRAM            (RW)  : ORIGIN = 0x2000, LENGTH = 0xC000 
	.xExtRAM_DynamicMem (RW)  : ORIGIN = 0xE000, LENGTH = 0x1200
	.xStack             (RW)  : ORIGIN = 0xF200, LENGTH = 0x0D80   
	.xCoreRegisters     (RW)  : ORIGIN = 0xFF80, LENGTH = 0x0080 
}
#*******************************************************************************


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
	

#*******************************************************************************
	.ApplicationInterruptVector :
	{
		vector.c (.text)
		
	} > .pInterruptVector
#*******************************************************************************
	.ApplicationCode :
	{
      # Place all code into External Program RAM
		
		* (.text)
		* (rtlib.text)
		* (fp_engine.text)
		* (user.text)
		

		# SDK data to be placed into Program RAM

		F_Pdata_start_addr_in_ROM = 0;
		F_Pdata_start_addr_in_RAM = .;
      pramdata.c (.data)
		F_Pdata_ROMtoRAM_length = 0;
   	F_Pbss_start_addr = .;
		_P_BSS_ADDR = .;
		pramdata.c (.bss)
		F_Pbss_length = . - _P_BSS_ADDR;
		
	} > .pExtRAM	
#*******************************************************************************
	.ApplicationData :
	{
		# Define variables for C initialization code

		F_Xdata_start_addr_in_ROM = ADDR(.xFlash) + SIZEOF(.xFlash) / 2;
		F_StackAddr               = ADDR(.xStack);
		F_StackEndAddr            = ADDR(.xStack) + SIZEOF(.xStack) / 2  - 1;
		F_Xdata_start_addr_in_RAM = .;
		

		# Define variables for SDK mem library

		FmemEXbit = .;
			WRITEH(_EX_BIT);
		FmemNumIMpartitions = .;
			WRITEH(_NUM_IM_PARTITIONS);
		FmemNumEMpartitions = .;
			WRITEH(_NUM_EM_PARTITIONS);
		FmemIMpartitionList = .;
			WRITEH(ADDR(.xIntRAM_DynamicMem));
			WRITEH(SIZEOF(.xIntRAM_DynamicMem) / 2);
		FmemEMpartitionList = .;
			WRITEH(ADDR(.xExtRAM_DynamicMem));
			WRITEH(SIZEOF(.xExtRAM_DynamicMem) /2);


					 
		# Place rest of the data into External RAM
		
		* (.data)
		* (fp_state.data)
		* (rtlib.data)
		
		F_Xdata_ROMtoRAM_length = 0;
		
		F_Xbss_start_addr = .;
		_X_BSS_ADDR = .;
		
	  	* (rtlib.bss.lo)
		* (.bss)
		
		F_Xbss_length = . - _X_BSS_ADDR;  # Copy DATA

	} > .xExtRAM
#*******************************************************************************


	FArchIO   = ADDR(.xPeripherals);
	FArchCore = ADDR(.xCoreRegisters);
}
