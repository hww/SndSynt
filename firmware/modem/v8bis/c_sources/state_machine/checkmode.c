/***************************************************************************
*
*   Motorola India Electronics Ltd. (MIEL).
*
*   PROJECT  ID     -   V.8 bis
*   
*   FILENAME        -   checkmode.c
*
*   COMPILER        -   m568c: Tartan compiler SPARC Version 1.0
*
*   ORIGINAL AUTHOR -   B.S Shivashankar
*
****************************************************************************
*
*   DESCRIPTION
*
*   This file consists modules, which checks whether the local station 
*   supports the capabilities selected by the remote station. i.e It checks 
*   whether all the selected capabilities in received MS message are present 
*   in local capabilities list.
*
*   Functions in this file:
*
*   Check_Mode
*   Check_Message_Block
*   Check_Spar1
*   Check_Spar2
*
***************************************************************************/

/*  #includes   */

#include <stdio.h>
#include "v8bis_defines.h"
#include "v8bis_typedef.h"
#include "v8bis_globext.h"
#include "v8bis_prototypes.h"

/*  #defines     */

#define V8_SHORTV8_NONSTANDARDFIELD_BITS_SET  0xc3

/*  static variables   */

static W16 *s_ms_buf_ptr;     /* pointer to g_ms_buffer[] */
static W16 *s_local_cap_ptr;  /* pointer to g_local_cap[] */
static W16 s_par_count;       /* counter for MS octets in a msg block */
static W16 s_cl_par_count;    /* counter for CL octets in a msg block */
static W16 s_count;           /* maximum octet counter */ 
static W16 s_allzero_flag;    /* this flag will be set if all the octets
                                 in a msg block are set to zero */

/***************************************************************************
*
*   FUNCTION NAME   -   Check_Mode 
*
*   INPUT           -   None
*
*   OUTPUT          -   flag : TRUE  if all the selected capabilities in MS
*                                    message are present in local 
*                                    capabilities list.  
*
*                              FALSE otherwise     
*
*   GLOBALS         -   g_local_cap[]    
*   REFERENCED          g_ms_buffer[]
*                   
*   GLOBALS         -   s_ms_buf_ptr
*   MODIFIED            s_local_cap_ptr
*                      
*   FUNCTIONS       -   Check_Message_Block 
*   CALLED              Check_Spar1 
*               
****************************************************************************
*
*   CHANGE HISTORY
*   
*   dd/mm/yy    Code Ver    Description         Author
*   --------    --------    -----------         ------
*
*   04/05/98    0.00        Module Created      B.S Shivashankar
*   03:07:2000  0.10        Ported on to MW     N R Prasad
*
****************************************************************************
*
*   DESCRIPTION      
*
*   This is a main module, which calls other modules to check whether the 
*   local station supports capabilities selected by the remote station. It 
*   returns a flag, which indicates whether local station supports the 
*   capabilities selected by remote station or not.
*
***************************************************************************/


BOOLEAN Check_Mode()
{
    W16 ms_buf;
    BOOLEAN flag;

    /*
    *  Initialize the counter to maximum octets count. this vqriable will
    *  be used for error recovery.
    */

    s_count = MAX_OCTETS_COUNT;

    /*
    *  Set the message validity flag.
    */

    g_v8bis_flags.message_validity = TRUE;

    /*
    *  Initialize MS pointer and local capability pointer to first octet of
    *  NPAR1 block of identification field.
    */

    s_ms_buf_ptr = &g_ms_buffer[ID_NPAR1_INDEX];
    s_local_cap_ptr = &g_local_cap[ID_NPAR1_INDEX];

    /*
    *  Store the first octet of NPAR1 block of identification field of MS 
    *  message, it will be restored back at the end.
    */

    ms_buf = g_ms_buffer[ID_NPAR1_INDEX];

    /*
    *  Parse all bits of first octet of NPAR1 block of bit encoded parameter 
    *  field of identification field of MS message, except V8, SHORT V.8 
    *  parameter bits and the delimiting bit. All other parameter bits are not 
    *  required for this function.
    */

    g_ms_buffer[ID_NPAR1_INDEX] &= V8_SHORTV8_NONSTANDARDFIELD_BITS_SET;


    /*
    *  Call the module to check NPAR1 block of identification field. If all 
    *  the selected capabilities are present in local capabilities list, call
    *  module to select SPAR1 and corresponding PAR blocks of identification 
    *  field, else return the flag to the called function. 
    */

    flag = Check_Message_Block(NPAR1_DELIMIT);
    if (flag == TRUE)  
    {  
        flag = Check_Spar1(ID_FIELD);
        if (flag == TRUE)
        {

            /*
            *  Call the module to check NPAR1 block of standard information 
            *  field. If all the selected capabilities are present in local
            *  capabilities list, call the module to select SPAR1 and  
            *  corresponding PAR blocks of standard information field, else
            *  return the flag to the called function.
            */

            flag = Check_Message_Block(NPAR1_DELIMIT);
            if (flag == TRUE)
            {
                flag = Check_Spar1(SI_FIELD);
            }    
        }
    }   

    /*
    *  Restore back the first octet of NPAR1 block of identification field.
    */

    g_ms_buffer[ID_NPAR1_INDEX] = ms_buf;

    return flag;
}    



/***************************************************************************
*
*   FUNCTION NAME   -   Check_Message_Block
*
*   INPUT           -   delimit : octet with delimiting bit set corresponding
*                                 to NPAR1,NPAR2,NPAR3,SPAR1 or SPAR2 block.  
*
*   OUTPUT          -   flag    : TRUE  if all the selected capabilities 
*                                       of MS message block are present 
*                                       in local capabilities list.
*
*                                 FALSE otherwise      
*
*   GLOBALS         -   s_ms_buf_ptr 
*   REFERENCED          s_local_cap_ptr 
*                   
*   GLOBALS         -   s_local_cap_ptr
*   MODIFIED            s_ms_buf_ptr
*                       s_par_count
*                      
*   FUNCTIONS       -   None 
*   CALLED              
*               
****************************************************************************
*
*   CHANGE HISTORY
*   
*   dd/mm/yy    Code Ver    Description         Author
*   --------    --------    -----------         ------
*
*   04/05/98    0.00        Module Created      B.S Shivashankar
*   03:07:2000  0.10        Ported on to MW     N R Prasad
*
****************************************************************************
*
*   DESCRIPTION      
*  
*   It checks whether all the selected capabilities in MS message block are 
*   present in local capabilities list and returns a flag to indicate that. 
*   It also finds the count of octets in the message block.
*
***************************************************************************/

BOOLEAN Check_Message_Block(W16 delimit)
{
    W16 ms_octet, parse_octet = 0, temp;
    BOOLEAN flag;

    /*
    *  Initialize the octet counter to zero and flag to TRUE
    */  
         
    s_par_count = 0;
    s_cl_par_count = 0;
    flag = TRUE;
    s_allzero_flag = TRUE; 

    /*
    *  Initialize the parse octet. 
    */

    temp = delimit & PAR_DELIMIT;
    if (temp)
    {  
        parse_octet = BITS_1_7_SET;
    }
    else
    {
        parse_octet = BITS_1_6_SET;
    }    

    do
    {
        /*
        *  Parse the delimiting bits of the MS octet, as this
        *  module will check the capability bits only.
        */

        ms_octet = *s_ms_buf_ptr & parse_octet;

        /*
        *  If the MS octet is non zero, reset the allzero flag.
        */

        if (ms_octet != 0)
        {
            s_allzero_flag = FALSE;
        }    
        
        /*  
        *  If the selected capabilities in MS octet are not present in local
        *  capabilities list, set the flag to indicate that,and break from DO
        *  WHILE loop and return to the called function.
        */  

        if ((*s_local_cap_ptr++ & ms_octet) != ms_octet)
        {
            flag = FALSE;
            break;
        }

        /*
        *  Increment the octet counter
        */

        s_par_count++;

        /*
        *  Continue the above procedure for all MS octets of the message 
        *  block.
        */  
                                     
    } while (!(*s_ms_buf_ptr++ & delimit) &&  s_count--); 

    s_count++;

    /*
    *  Update the local capability pointer and the extra octet count.
    */  

    while(!(*(s_local_cap_ptr-1) & delimit) && s_count--)
    {
        s_local_cap_ptr++;
        s_cl_par_count++;
    }   

    /*
    *  If the counter is expired, reset the flag.
    *  Reset the message validity flag.
    */

    if (s_count <= 0)
    {
        g_v8bis_flags.message_validity = FALSE;
        flag = FALSE;
    }   

    return flag;
}    



/***************************************************************************
*
*   FUNCTION NAME   -   Check_Spar1
*
*   INPUT           -   None
*
*   OUTPUT          -   flag : TRUE  if all the selected capabilities in 
*                                    SPAR1 and corresponding PAR blocks 
*                                    of MS message are present in local 
*                                    capabilities list.
*
*                              FALSE otherwise      
*
*
*   GLOBALS         -   s_par_count
*   REFERENCED          
*                   
*   GLOBALS         -   s_local_cap_ptr
*   MODIFIED            s_ms_buf_ptr
*                      
*   FUNCTIONS       -   Check_Message_Block 
*   CALLED              Check_Spar2
*               
****************************************************************************
*
*   CHANGE HISTORY
*   
*   dd/mm/yy    Code Ver    Description         Author
*   --------    --------    -----------         ------
*
*   04/05/98    0.00        Module Created      B.S Shivashankar
*   03:07:2000  0.10        Ported on to MW     N R Prasad
*
****************************************************************************
*
*   DESCRIPTION      
*
*   It checks whether all the selected capabilities in SPAR1 block of MS 
*   message are present in local capabilities list. It also calls modules 
*   to check corresponding PAR blocks of MS message. It returns a flag to  
*   indicate whether local station supports selected capabilities or not.
*
***************************************************************************/


BOOLEAN Check_Spar1(PAR_FIELDS par_field)
{
    W16 i, j, spar1_count, cl_spar1_count, bit_pos, temp_comp;
    W16 *ms_buf_ptr, *local_cap_ptr;
    BOOLEAN flag;

    /*
    *  Now the s_ms_buf_ptr and s_local_cap_ptr will be pointing to first 
    *  octet of SPAR1 block. Copy these global pointers to local pointers, 
    *  and the local pointers will be used to access octets of SPAR1 block 
    *  only.
    */

    ms_buf_ptr = s_ms_buf_ptr;
    local_cap_ptr = s_local_cap_ptr;

    /*
    * Call the module to check SPAR1 message block. If all the selected 
    * capabilities in SPAR1 block are present local capabilities list,call 
    * the module to check corresponding PAR blocks, else return the flag to
    * the called function.
    */ 

    flag = Check_Message_Block(SPAR1_DELIMIT);

    /*
    *  For Standard information field, if all the Spar1 octets are set
    *  to zero, reset the message validity flag.
    */

    if ((s_allzero_flag == TRUE) && (par_field == SI_FIELD))
    {
        g_v8bis_flags.message_validity = FALSE;
        flag = FALSE;
    }

    if (flag == TRUE)
    {
        /*
        * Get the number of octets in SPAR1 block.
        */

        cl_spar1_count = s_cl_par_count;
        spar1_count = s_par_count;
        for (i = 0; i < spar1_count; i++)
        {
            /*
            *  Initialize the variable to consider first bit position
            *  of SPAR1 octet.
            */

            bit_pos = 1;
            for (j = 1; j < NUM_BITS_PER_OCTET; j++)
            {  

                /*
                *  If a particular bit position is set in both mode select
                *  list and local capabilities list SPAR1 octet, call the 
                *  module to check NPAR2 block. If all the selected 
                *  capabilities in NPAR2 block are present in local 
                *  capabilities list, call the module to check SPAR2 and 
                *  corresponding NPAR3 blocks, if PAR delimit bit is not set 
                *  in the last octet of NPAR2 block.
                */

                if (*ms_buf_ptr & *local_cap_ptr & bit_pos)
                {
                    flag = Check_Message_Block(NPAR2_DELIMIT);
                    if (flag == TRUE)
                    {  
                        temp_comp = (*(s_ms_buf_ptr-1) & PAR_DELIMIT);
                        temp_comp = !temp_comp;
                        if (temp_comp)
                        {  
                            flag = Check_Spar2();
                        }    
                        else
                        {
                            temp_comp = (*(s_local_cap_ptr-1) & PAR_DELIMIT);
                            temp_comp = !temp_comp;
                            temp_comp = temp_comp && s_count--;
//                            while (!(*(s_local_cap_ptr-1) & PAR_DELIMIT) && s_count--)
                            while (temp_comp)
                            {
                                s_local_cap_ptr++;
                                temp_comp = (*(s_local_cap_ptr-1) & PAR_DELIMIT);
                                temp_comp = !temp_comp;
                                temp_comp = temp_comp && s_count--;
                            }   
                        }    
                    }    

                    if (s_count <= 0)
                    {
                        g_v8bis_flags.message_validity = FALSE;
                        flag = FALSE;
                    }   

                    /*
                    *  If selected capabilities are not present in local
                    *  capabilities list, break from FOR j loop.
                    */  

                    if (flag == FALSE)
                    {
                        break;
                    }   
                }       

                /*
                *  If the particular bit position is set in capabilities 
                *  list only, (not in MS) skip the PAR block corresponding to
                *  that SPAR1 bit.
                */

                else if (*local_cap_ptr & bit_pos)
                {  
                    temp_comp = (*s_local_cap_ptr++ & PAR_DELIMIT);
                    temp_comp = !temp_comp;
                    temp_comp = temp_comp && s_count--;
//                    while (!(*s_local_cap_ptr++ & PAR_DELIMIT) && s_count--);
                    while (temp_comp)
                    {
                        temp_comp = (*s_local_cap_ptr++ & PAR_DELIMIT);
                        temp_comp = !temp_comp;
                        temp_comp = temp_comp && s_count--;
                    }
                }

 
                if (s_count <= 0)
                {
                    g_v8bis_flags.message_validity = FALSE;
                    flag = FALSE;
                    break;
                }       

                /*
                *  Update the variable to consider the next bit position.
                */

                bit_pos <<= 1;

                /*
                *  Continue the above procedure for all capability bits of 
                *  SPAR1 octet.
                */  

            } /* end of FOR j loop */   

            /*
            *  If selected capabilities are not present in local
            *  capabilities list, break from FOR i loop and return
            *  the flag to the called function.
            */  

            if (flag == FALSE)
            {
                break;
            }    

            /*
            *  Increment the local pointers to access next SPAR1 octet.
            */

            ms_buf_ptr++;
            local_cap_ptr++;


            /*
            *  Continue the above procedure for all octets of SPAR1 block
            */  

        } /* end of FOR i loop */

    } /* end of IF loop */

    /*
    *  Update the local capability pointer. If there are more SPAR1
    *  octets in CL message, skip those PARs corresponding to those
    *  extra SPAR1 octets.
    */

    if (flag == TRUE)
    {   
        for (i = 0; i < cl_spar1_count; i++)
        {
            bit_pos = 1;

            for (j = 1; j < NUM_BITS_PER_OCTET; j++)
            {
                if (*local_cap_ptr & bit_pos)
                {
                    temp_comp = (*s_local_cap_ptr++ & PAR_DELIMIT);
                    temp_comp = !temp_comp;
                    temp_comp = temp_comp && s_count--;
//                    while(!(*s_local_cap_ptr++ & PAR_DELIMIT)  && s_count--);
                    while(temp_comp)
                    {
                        temp_comp = (*s_local_cap_ptr++ & PAR_DELIMIT);
                        temp_comp = !temp_comp;
                        temp_comp = temp_comp && s_count--;
                    }
                }
                bit_pos <<= 1;
            }
            local_cap_ptr++;
        }    
    }   

    return flag;
}    



/***************************************************************************
*
*   FUNCTION NAME   -   Check_Spar2
*
*   INPUT           -   None
*
*   OUTPUT          -   flag : TRUE  if all the selected capabilities in 
*                                    SPAR2 and corresponding NPAR3 blocks 
*                                    of MS message are present in local 
*                                    capabilities list.
*
*                              FALSE otherwise      
*
*
*   GLOBALS         -   s_par_count
*   REFERENCED          
*                   
*   GLOBALS         -   s_local_cap_ptr
*   MODIFIED            s_ms_buf_ptr
*                      
*   FUNCTIONS       -   Check_Message_Block 
*   CALLED              
*               
****************************************************************************
*
*   CHANGE HISTORY
*   
*   dd/mm/yy    Code Ver    Description         Author
*   --------    --------    -----------         ------
*
*   04/05/98    0.00        Module Created      B.S Shivashankar
*   03:07:2000  0.10        Ported on to MW     N R Prasad
*
****************************************************************************
*
*   DESCRIPTION      
*
*   It checks whether all the selected capabilities in SPAR2 block of MS 
*   message are present in local capabilities list. It also calls modules 
*   to check corresponding NPAR3 blocks of MS message. It returns a flag to  
*   indicate whether local station supports selected capabilities or not.
*
***************************************************************************/


BOOLEAN Check_Spar2()
{
    W16 i, j, spar2_count, bit_pos, temp_comp2;
    W16 *ms_buf_ptr, *local_cap_ptr;
    BOOLEAN flag;

    /*
    *  Now the s_ms_buf_ptr and s_local_cap_ptr will be pointing to first 
    *  octet of SPAR2 block. Copy these global pointers to local pointers, 
    *  and the local pointers will be used to access octets of SPAR2 block 
    *  only.
    */

    ms_buf_ptr = s_ms_buf_ptr;
    local_cap_ptr = s_local_cap_ptr;

    /*
    * Call the module to check SPAR2 message block. If all the selected 
    * capabilities in SPAR2 block are present local capabilities list,call 
    * the module to check corresponding NPAR3 blocks, else return the flag 
    * to the called function.
    */ 

    flag = Check_Message_Block(SPAR2_DELIMIT);
    if (flag == TRUE)
    {
        /*
        * Get the number of octets in SPAR2 block.
        */

        spar2_count = s_par_count;
        for (i = 0; i < spar2_count; i++)
        {
           
            /*
            *  Initialize the variable to consider first bit position
            *  of SPAR2 octet.
            */

            bit_pos = 1;

            for (j = 1; j < NUM_BITS_PER_OCTET-1; j++)
            {  
                /*
                *  If a particular bit position is set in both mode select
                *  list and local capabilities list SPAR2 octet, call the 
                *  module to check NPAR3 block. 
                */

                if (*ms_buf_ptr & *local_cap_ptr & bit_pos)
                {
                    flag = Check_Message_Block(NPAR3_DELIMIT);

                    /*
                    *  If selected capabilities in NPAR3 block are not 
                    *  present in local capabilities list, break from 
                    *  FOR j loop.
                    */  

                    if (flag == FALSE)
                    {
                        break;
                    }   
                }       

                /*
                *  If the particular bit position is set in capabilities 
                *  list only, (not in MS) skip the PAR block corresponding to
                *  the SPAR2 bit.
                */

                else if (*local_cap_ptr & bit_pos)
                {
                    temp_comp2 = (*s_local_cap_ptr++ & NPAR3_DELIMIT);
                    temp_comp2 = !temp_comp2;
                    temp_comp2 = temp_comp2 && s_count--;
//                    while (!(*s_local_cap_ptr++ & NPAR3_DELIMIT) && s_count--);
                    while (temp_comp2)
                    {
                        temp_comp2 = (*s_local_cap_ptr++ & NPAR3_DELIMIT);
                        temp_comp2 = !temp_comp2;
                        temp_comp2 = temp_comp2 && s_count--;                    
                    }
                } 

                if (s_count <= 0)
                {
                    g_v8bis_flags.message_validity = FALSE;
                    flag = FALSE;
                    break;
                }       

                /*
                *  Update the variable to consider the next bit position.
                */

                bit_pos <<= 1;

                /*
                *  Continue the above procedure for all capability bits of 
                *  SPAR2 octet.
                */  

            } /* end of FOR j loop */   

            /*
            *  If selected capabilities are not present in local
            *  capabilities list, break from FOR i loop and return
            *  the flag to the called function.
            */  

            if (flag == FALSE)
            {   
                break;
            }    

            /*
            *  Increment the local pointers to access next SPAR2 octet.
            */

            ms_buf_ptr++;
            local_cap_ptr++;

            /*
            *  Continue the above procedure for all octets of SPAR2 block
            */  

        } /* end of FOR i loop */   

    } /* end of IF loop */

    return flag;
}

/*
*  End of file
*/


