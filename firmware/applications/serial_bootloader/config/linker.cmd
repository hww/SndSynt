# Linker.cmd file for DSP56805EVM & DSP56803EVM
#        using internal data memory only ( EX = 0, Boot Mode 0A )

MEMORY {

	.pdelay (RX)  : ORIGIN = 0x0084, LENGTH = 0x0002  # 
	.pflash (RX)  : ORIGIN = 0x0004, LENGTH = 0x7DFC  # program flash memory
	.pram   (RWX) : ORIGIN = 0x7E00, LENGTH = 0x0200  # program ram memory
	.reset  (RX)  : ORIGIN = 0x8000, LENGTH = 0x0004  # boot flash memory reset isr
	.bflash (RX)  : ORIGIN = 0x8004, LENGTH = 0x07FC  # boot flash memory
	.phole1 (RX)  : ORIGIN = 0x8800, LENGTH = 0x7800  # reserved program memory
	.pmirror(RWX) : ORIGIN = 0x0040, LENGTH = 0x0660  # data mirror in program memory to put 
	                                                  # initialization data into Program memory.
	                                                  # NB: This section contains no data,
	                                                  # program code refers to .data segment
	                                                  # in reality.

	.avail    (RW)  : ORIGIN = 0x0000, LENGTH = 0x0030  # available
	.cwregs   (RW)  : ORIGIN = 0x0030, LENGTH = 0x0010  # C temp registrs in CodeWarrior
	.data	  (RW)  : ORIGIN = 0x0040, LENGTH = 0x0E60  # data
	.stack    (RW)  : ORIGIN = 0x0EA0, LENGTH = 0x0160  # stack
	.regs	  (RW)  : ORIGIN = 0x1000, LENGTH = 0x0400  # periperal registers
	.reserved (R)   : ORIGIN = 0x1400, LENGTH = 0x0400  # the first internal memory hole
	.xflash   (R)   : ORIGIN = 0x1800, LENGTH = 0x0800  # data flash memory to place constant 
	                                                    # and initialized values for .data
	.dhole2   (R)   : ORIGIN = 0x2000, LENGTH = 0xDF80  # the second internal memory hole
	.onchip   (RW)  : ORIGIN = 0xFF80, LENGTH = 0x0080  # on-chip core configuration registers

}


KEEP_SECTION {resetvec.text}

SECTIONS {

   # loaded applcation start address	

      _START_APPLICATION   = 0x0080;

   # loaded applcation COP Reset vector address	

      _COP_APPLICATION_VECTOR   = 0x0082;

   # Address of application start delay variable

      _START_DELAY_ADDRESS = ADDR(.pdelay) + 1;

   # ISR vectors section

	.interrupt_vector :
	{
		# .text sections
		
		* (resetvec.text)
	} > .reset

   .delay_data :
   {
      #
      # Set application start delay to the infinite, 
      # NB: The below  operation erase also all interrupt vector table. 
      #
      
      WRITEH(0xffff);
      WRITEH(0xffff);
      
   } > .pdelay
   
   # code section
   
	.main_application_program :
	{
		# .text sections
		
		* (.text)
		
	} > .bflash
   
   .main_application_data : AT (ADDR(.bflash) + SIZEOF(.bflash) / 2 + 1)
	{
      # Sections contains initialized variables

		# Define variables for C initialization code
		
		F_Xdata_start_addr_in_ROM = (ADDR(.bflash) + SIZEOF(.bflash) / 2  + 1);
		F_StackAddr               = ADDR(.stack);
		F_StackEndAddr            = ADDR(.stack) + SIZEOF(.stack) / 2  - 1;
		
		F_Xdata_start_addr_in_RAM = .;
		_DATA_ADDR = .;
							 		
      # .data sections 

		* (.data)
		* (strings.data)

		F_Xdata_ROMtoRAM_length = . - _DATA_ADDR;

	} > .pmirror
   
	.main_application_bss : 
	{

      # sections contains uninitialized variables
      
      # allocates space for .data section
      
      . = (ADDR(.pmirror) + SIZEOF(.pmirror) / 2);

		# Define variables for C initialization code      
      
		F_bss_start_addr = .;
		_BSS_ADDR = .;

      # .bss sections 
      
		* (.bss)
		
		F_bss_length = . - _BSS_ADDR;
				
	} > .data

	FArchIO   = ADDR(.regs);
	FArchCore = ADDR(.onchip);

	FarchStart              = _START_APPLICATION;
	FarchCOPVector          = _COP_APPLICATION_VECTOR;
	FarchStartDelayAddress  = _START_DELAY_ADDRESS;

}
