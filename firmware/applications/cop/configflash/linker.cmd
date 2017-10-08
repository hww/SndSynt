# Linker.cmd file for DSP56826EVM 
#            using internal data memory only ( EX = 0, Boot Mode 0A )
   
#*******************************************************************************
MEMORY {

	.pInterruptVector   (RX)  : ORIGIN = 0x0000, LENGTH = 0x0086 
	.pFlash             (RX)  : ORIGIN = 0x0086, LENGTH = 0x7D7A  
	.pIntRAM            (RWX) : ORIGIN = 0x7E00, LENGTH = 0x0200  
	.pIntRAM_Mirror     (RWX) : ORIGIN = 0x7E00, LENGTH = 0x0200 
	.pBootFlash         (RX)  : ORIGIN = 0x8000, LENGTH = 0x0800 
	.pReserved          (RX)  : ORIGIN = 0x8800, LENGTH = 0x7800 

	.xAvailable         (RW)  : ORIGIN = 0x0000, LENGTH = 0x0030  
	.xCWRegisters       (RW)  : ORIGIN = 0x0030, LENGTH = 0x0010 
	.xIntRAM            (RW)  : ORIGIN = 0x0040, LENGTH = 0x0E60
	.xIntRAM_Mirror     (RWX) : ORIGIN = 0x0040, LENGTH = 0x0E60  
	.xStack             (RW)  : ORIGIN = 0x0EA0, LENGTH = 0x0160
	.xPeripherals       (RW)  : ORIGIN = 0x1000, LENGTH = 0x0400 
   .xReserved          (R)   : ORIGIN = 0x1400, LENGTH = 0x0400  
	.xFlash             (R)   : ORIGIN = 0x1800, LENGTH = 0x0800  
	.xExtRAM            (R)   : ORIGIN = 0x2000, LENGTH = 0xDF80 
	.xCoreRegisters     (RW)  : ORIGIN = 0xFF80, LENGTH = 0x0080

}
#*******************************************************************************

FORCE_ACTIVE {FconfigInterruptVector}

SECTIONS {
	
#*******************************************************************************
	.ApplicationInterruptVector :
	{
		vector.c (.text)
		
	} > .pInterruptVector
#*******************************************************************************
	.ApplicationCode :
	{
		# Place all code into Program Flash
		
		* (.text)
		* (rtlib.text)
		* (fp_engine.text)
		* (user.text)
		
	} > .pFlash
#*******************************************************************************
	.InitializedDataForProgramRAM : AT (ADDR(.pFlash) + 1 + SIZEOF(.pFlash) / 2)
	{
		# Define variables for C initialization code of Program RAM data
		
		F_Pdata_start_addr_in_ROM = ADDR(.pFlash) + 1 + SIZEOF(.pFlash) / 2;
		
		F_Pdata_start_addr_in_RAM = .;
		_P_DATA_ADDR = .;
							 		
      # SDK initialized data to be placed into Program RAM

		pramdata.c (.data)
		F_Pdata_ROMtoRAM_length = . - _P_DATA_ADDR;

   }  > .pIntRAM_Mirror
#*******************************************************************************
	.InitializedConstData :
	{
		const.c (.data)
		appconst.c (.data)
		
	} > .xFlash
#*******************************************************************************
   .ApplicationInitializedData : AT (ADDR(.pFlash) + 1 + SIZEOF(.pFlash) / 2 + SIZEOF(.pIntRAM_Mirror) / 2 + 1 )
	{

		# Define variables for C initialization code
		
		F_Xdata_start_addr_in_ROM = ADDR(.pFlash) + 1 + SIZEOF(.pFlash) / 2 + SIZEOF(.pIntRAM_Mirror) / 2 + 1;
		F_StackAddr               = ADDR(.xStack);
		F_StackEndAddr            = ADDR(.xStack) + SIZEOF(.xStack) / 2  - 1;
		
		F_Xdata_start_addr_in_RAM = .;
		_X_DATA_ADDR = .;
							 		
      # Place rest of the data into Internal Data RAM

		* (.data)
		* (fp_state.data)
		* (rtlib.data)

		F_Xdata_ROMtoRAM_length = . - _X_DATA_ADDR;

	} > .xIntRAM_Mirror
#*******************************************************************************
	.DataForProgramRAM : 
	{
      # allocates space for .InitializedDataForPRogramRAM section
      
      . = (ADDR(.pIntRAM_Mirror) + SIZEOF(.pIntRAM_Mirror) / 2) + 1;

      # Define variables for C initialization code

		F_Pbss_start_addr = .;
		_P_BSS_ADDR = .;

      # SDK uninitialized data to be placed into Program RAM
      
	  	pramdata.c (.bss)
		
		F_Pbss_length = . - _P_BSS_ADDR;
				
	} > .pIntRAM
#*******************************************************************************
	.DataForDataRAM : 
	{
      # allocates space for .ApplicationInitializedData section
      
      . = (ADDR(.xIntRAM_Mirror) + SIZEOF(.xIntRAM_Mirror) / 2);

		# Define variables for C initialization code      
      
		F_Xbss_start_addr = .;
		_X_BSS_ADDR = .;

      # .bss sections 
      
	  	* (rtlib.bss.lo)
		* (.bss)
		
		F_Xbss_length = . - _X_BSS_ADDR;
				
	} > .xIntRAM
#*******************************************************************************

	FArchIO   = ADDR(.xPeripherals);
	FArchCore = ADDR(.xCoreRegisters);
}
