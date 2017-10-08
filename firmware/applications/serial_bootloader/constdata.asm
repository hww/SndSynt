;*****************************************************************************
;*
;* Motorola Inc.
;* (c) Copyright 2000 Motorola, Inc.
;* ALL RIGHTS RESERVED.
;*
;******************************************************************************
;*
;* File Name:         constdata.asm
;*
;* Description:       Define strings data for bootloader
;*
;* Modules Included:  none
;*                    
;* 
;*****************************************************************************

      SECTION strings
        
   	   GLOBAL  FStrCopyright
   	   GLOBAL  FStrLoaded_1
   	   GLOBAL  FStrLoaded_2
   	   GLOBAL  FStrLoaded_3
   	   GLOBAL  FStrStarted_1
   	   GLOBAL  FStrError_1
   	   GLOBAL  FStrError_2
        
         DEFINE LF '$0A'
         DEFINE CR '$0D'
        
         ORG X:
         
         ; strings are packed as two charcter into single word.
          
FStrCopyright:            
         DCB LF,CR,"(c) 2000-2001 Motorola Inc. S-Record loader. Version 1.1",LF,CR,$00
FStrLoaded_1:            
         DCB LF,CR,"Loaded 0x",$00
FStrLoaded_2:            
         DCB " Program and 0x",$00
FStrLoaded_3:            
         DCB " Data words.",$00
FStrStarted_1:            
         DCB LF,CR,"Application started.",LF,CR,$00
FStrError_1:            
         DCB LF,CR,"Error # ",$00
FStrError_2:            
         DCB LF,CR,"Restarting.",LF,CR,$00
		ENDSEC
		END

