/***************************************************************************
*
*   Motorola India Electronics Ltd. (MIEL).
*
*   PROJECT  ID     -   V.8 bis
*   
*   FILENAME        -   modeselect.c
*
*   COMPILER        -   m568c: Tartan compiler SPARC Version 1.0
*
*   ORIGINAL AUTHOR -   B.S Shivashankar
*
****************************************************************************
*
*   DESCRIPTION
*
*   This file consists modules which selects modes. It goes through the 
*   priority list of modes indicated by host and finds the highest priority 
*   mode that is present in the remote capabilities list. It indicates that 
*   as a desired mode in MS message.
*
*   Functions in this file :
*
*   Mode_Select
*   Mode_Select_Npar1_2_3
*   Mode_Select_Spar1
*   Mode_Select_Spar2
*   Update_Rem_Cap_Ptr_Priority_Index
*   Ms_Bit_Count
*
***************************************************************************/

/*  #includes   */

#include "v8bis_defines.h"
#include "v8bis_typedef.h"
#include "v8bis_globext.h"
#include "v8bis_prototypes.h"

/*  #defines    */

#define LEVEL1                0
#define LEVEL2                1
#define NUM_SPAR_LEVELS       2
#define NUM_SPAR1_BITS_SET    7
#define NUM_SPAR1_2_BITS_SET  13 

/*  static variables  */

static W16 *s_rem_cap_ptr;   /* pointer to g_remote_cap[]  */
static W16 *s_ms_buf_ptr;    /* pointer to g_ms_buffer[]   */
static W16 s_priority_index; /* first index to g_prior[][] */
static W16 s_count;          /* counter for max octets     */

/*
*  These two arrays stores the count of PAR/NPAR3 blocks to be skipped, to
*  go to particular PAR/NPAR3 block corresponding to particular SPAR1/SPAR2 
*  bit. The first 7 locations are used to store counts corresponding to 
*  SPAR1 bits, and next 6 locations corresponding to SPAR2 bits. The counts
*  will be stored consecutively for SPAR1/SPAR2 bits, which are set.
*/  

static W16 s_rem_cap_blocks_skip_count[NUM_SPAR1_2_BITS_SET];
static W16 s_local_cap_blocks_skip_count[NUM_SPAR1_2_BITS_SET];

/*
*  These two arrays are used to store count of bits set in remote and 
*  local capability SPAR1/SPAR2 octet. 
*/

static W16 s_rem_cap_bits_count[NUM_SPAR_LEVELS];
static W16 s_local_cap_bits_count[NUM_SPAR_LEVELS];


/***************************************************************************
*
*   FUNCTION NAME   -   Mode_Select
*
*   INPUT           -   None
*
*   OUTPUT          -   None
*
*   GLOBALS         -   g_remote_cap[]    
*   REFERENCED          g_host_config
*                   
*   GLOBALS         -   g_ms_buffer[]
*   MODIFIED            s_ms_buf_ptr
*                       s_rem_cap_ptr
*                       s_priority_index
*                       g_v8bis_flags
*                       s_count
*                      
*   FUNCTIONS       -   Mode_Select_Npar1_2_3
*   CALLED              Mode_Select_Spar1
*               
****************************************************************************
*
*   CHANGE HISTORY
*   
*   dd/mm/yy    Code Ver    Description         Author
*   --------    --------    -----------         ------
*
*   05/03/98    0.00        Module Created      B.S Shivashankar
*   19/06/98    0.00        Incorporated        B.S Shivashankar
*                           Review comments 
*   03:07:2000  0.10        Ported on to MW     N R Prasad
****************************************************************************
*
*   DESCRIPTION      
*
*   This module initializes global pointers and calls functions to select 
*   NPAR1 and SPAR1 octets of identification field and standard information 
*   field. 
*
***************************************************************************/

void Mode_Select()
{

    /*
    *  Initialize the remote and local capability pointers, and the priority 
    *  index to first octet of NPAR1 block of identification field.
    *  Initialize max octets counter and set the message validity flag.
    */

    s_rem_cap_ptr = &g_remote_cap[ID_NPAR1_INDEX];
    s_ms_buf_ptr = &g_ms_buffer[ID_NPAR1_INDEX];
    s_priority_index = 0;
    s_count = MAX_OCTETS_COUNT;
    g_v8bis_flags.message_validity = TRUE;

    /*
    *  Call functions to select NPAR1, SPAR1 and corresponding PAR blocks
    *  of identification field. 
    */

    Mode_Select_Npar1_2_3(NPAR1_DELIMIT);
    Mode_Select_Spar1();

    /*
    *  Now s_ms_buf_ptr will be pointing to first octet of NPAR1 block of 
    *  standard information field, and s_rem_cap_ptr and s_priority index 
    *  will be pointing to first octet of first PAR block of identification
    *  field. 
    *  Call the function to update s_rem_cap_ptr and s_priority_index to 
    *  point to first octet of NPAR1 block of standard information field.
    *  s_rem_cap_bits_count[0] and s_local_cap_bits_count[0] will be 
    *  containing the count of PAR blocks in identification field.
    */

    s_rem_cap_blocks_skip_count[0] = s_rem_cap_bits_count[0];
    s_local_cap_blocks_skip_count[0] = s_local_cap_bits_count[0];
    Update_Rem_Cap_Ptr_Priority_Index(PAR_DELIMIT, 0);

    /*
    *  Call functions to select NPAR1, SPAR1 and corresponding PAR blocks of
    *  standard information field.
    */

    Mode_Select_Npar1_2_3(NPAR1_DELIMIT);
    Mode_Select_Spar1();

    /*
    *  Encode revision number, message type fields of identification field.
    */

    g_ms_buffer[1] = MSG_TYPE_MS | (g_host_config.revision_number << 4);

    /*
    *  Set Transmit Ack1 bit of NPAR1 octet of identification field, if it 
    *  is configured by host. It is not taken care in the priority list as
    *  it is dependent on local host only.
    */

    if (g_host_config.set_transmit_ack1)
    {
        g_ms_buffer[ID_NPAR1_INDEX] |= TRANSMIT_ACK1;      
    }    

    /*
    *   Store message octets count at the first location of MS array.
    */

    g_ms_buffer[0] = s_ms_buf_ptr - &g_ms_buffer[MSG_START_INDEX];

    /*
    *  If the counter is expired, reset the message validity flag.
    */

    if (s_count <= 0)
    {
        g_v8bis_flags.message_validity = FALSE;
    }

    return;
}


/***************************************************************************
*
*   FUNCTION NAME   -   Mode_Select_Npar1_2_3
*
*   INPUT           -   delimit :  octet with delimiting bit set 
*                                  corresponding to either NPAR1,NPAR2 or 
*                                  NPAR3 blocks.
*                        
*   OUTPUT          -   flag    :  FALSE if all selected capability bits 
*                                        are set to zero in the NPAR block. 
*                               :  TRUE  otherwise 
*
*   GLOBALS         -   g_remote_cap[]    
*   REFERENCED          g_prior[][]  
*                   
*   GLOBALS         -   g_ms_buffer[]
*   MODIFIED            s_ms_buf_ptr
*                       s_rem_cap_ptr  
*                       s_priority_index 
*                       s_count
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
*   05/03/98    0.00        Module Created      B.S Shivashankar
*   19/06/98    0.00        Incorporated        B.S Shivashankar
*                           Review comments 
*   03:07:2000  0.10        Ported on to MW     N R Prasad
*
****************************************************************************
*
*   DESCRIPTION      
*
*   This module selects Npar1,Npar2, or Npar3 octets. It goes through the
*   priority list of modes indicated by host and finds the highest priority 
*   mode that is present in the remote capabilities list. It indicates that  
*   as a desired mode in MS message.
*
***************************************************************************/

BOOLEAN Mode_Select_Npar1_2_3(W16 delimit)
{

    W16 j, local_prior;
    W16 *l_rem_cap_ptr, *l_ms_buf_ptr, l_priority_index;
    BOOLEAN nz_flag, sel_flag;

    /*
    *  Initialize the local variables.
    */  

    j = 0;
    l_priority_index = s_priority_index;
    l_ms_buf_ptr = s_ms_buf_ptr;
    l_rem_cap_ptr = s_rem_cap_ptr;

    do
    {
        /*
        *  Restore the flags and static pointers
        */

        nz_flag = FALSE;
        sel_flag = TRUE;
        s_priority_index = l_priority_index;
        s_ms_buf_ptr = l_ms_buf_ptr;
        s_rem_cap_ptr = l_rem_cap_ptr;

        /*
        *  Check, whether priority capabilities are present in remote 
        *  capability list. If it is not available, take the next priority
        *  octet for checking. If it is available, copy the priority octet
        *  to MS buffer. The last priority assumed to be zero, so the
        *  DO - WHILE loop will not end up with infinite loop. 
        */  

        do
        {
    
            local_prior = g_prior[s_priority_index][j];

            if ((local_prior & *s_rem_cap_ptr) != local_prior)
            {
                sel_flag = FALSE;
            }
            else
            {
                *s_ms_buf_ptr++ = local_prior;
                s_priority_index++;
            }

            /*
            *  If the selected octet is non zero, set the flag to indicate 
            *  that.
            */  

            if (local_prior & BITS_1_6_SET) 
            {
                nz_flag = TRUE;
            }

        /*
        *  Continue the above mode selection procedure, for all 
        *  NPAR1/NPAR2/NPAR3 octets.
        */  

        } while (!(*s_rem_cap_ptr++ & delimit) && (s_count-- > 0));       

        /*
        *  Increment the priority index.
        */  

        j++;

    } while (sel_flag == FALSE);

    /*
    *  Set the delimiting bit
    */  

    *(s_ms_buf_ptr - 1) |= delimit;

    /*
    *  Update priority index to point to next parameter block.
    */

    while ((!(g_local_cap[ID_NPAR1_INDEX + s_priority_index-1] & delimit)) 
           && (s_count-- > 0))
    {
        s_priority_index++;
    }

    return nz_flag;
}


/***************************************************************************
*
*   FUNCTION NAME   -   Mode_Select_Spar1
*
*   INPUT           -   None
*
*   OUTPUT          -   None
*
*   GLOBALS         -   g_remote_cap[]    
*   REFERENCED          g_prior[][]
*                   
*   GLOBALS         -   g_ms_buffer[]
*   MODIFIED            s_ms_buf_ptr
*                       s_rem_cap_ptr
*                       s_priority_index
*                       s_rem_cap_bits_count[]
*                       s_local_cap_bits_count[]
*                       s_count
*
*   FUNCTIONS       -   Mode_Select_Npar1_2_3
*   CALLED              Mode_Select_Spar2
*                       Ms_Bit_Count
*                       Update_Rem_Cap_Ptr_Priority_Index
*
****************************************************************************
*
*   CHANGE HISTORY
*   
*   dd/mm/yy    Code Ver    Description         Author
*   --------    --------    -----------         ------
*
*   05/03/98    0.00        Module Created      B.S Shivashankar
*   19/06/98    0.00        Incorporated        B.S Shivashankar
*                           Review comments 
*   03:07:2000  0.10        Ported on to MW     N R Prasad
*
****************************************************************************
*
*   DESCRIPTION      
*
*   This module selects SPAR1 octets and calls the functions to select 
*   NPAR2 and SPAR2 octets. It goes through the priority list of modes 
*   indicated by host and finds the highest priority  mode that is present
*   in the remote capabilities list. It indicates that as a desired mode in 
*   MS message. 
*
***************************************************************************/

void Mode_Select_Spar1()
{

    W16 i, j, k, index, flag, local_priority; 
    W16 rem_bits_count, local_bits_count, count;
    W16 *ms_spar1_ptr, *cap_ptr, *ms_ptr;

    /*
    *  Initialize the bits count variables corresponding to SPAR1 to zero.
    */  

    s_rem_cap_bits_count[0] = 0;
    s_local_cap_bits_count[0] = 0;

    /*
    *  Copy the global pointers. ms_spar1_ptr will be used for SPAR1 block,
    *  as all SPAR1 octets are stored sequentially.
    */

    ms_spar1_ptr = s_ms_buf_ptr;
    cap_ptr = s_rem_cap_ptr;
    count = s_count;

    /*  
    *   Update s_ms_buf_ptr to point to NPar2 octet
    */

    do
    {
        s_ms_buf_ptr++;

    } while ((!(*cap_ptr++ & SPAR1_DELIMIT)) && (count-- > 0)); 

    /*
    *  Start mode selection procedure for SPAR1 block, and corresponding
    *  PAR blocks.
    */  

    do
    {

       /*
       *  Store the global variables. The pointers will be restored back
       *  at the end of PAR block selection procedure.
       */

        count = s_count;
        index = s_priority_index;
        cap_ptr  = s_rem_cap_ptr;
        rem_bits_count = s_rem_cap_bits_count[0];
        local_bits_count = s_local_cap_bits_count[0];

        /*
        *  Check, whether priority capabilities are present in remote 
        *  capability list. If it is not available, take the next priority
        *  octet for checking. If it is available, copy the priority octet
        *  to MS buffer.
        */  

        for (j = 0; j < PRIORITIES_PER_OCTET; j++)
        {
            flag = TRUE;
            local_priority = g_prior[s_priority_index][j];

            if ((local_priority & *s_rem_cap_ptr) == local_priority)
            {
                *ms_spar1_ptr = local_priority;

                /*
                *   Get the count of bits set in the selected SPAR1 octet.
                */

                k = Ms_Bit_Count(local_priority, LEVEL1);

                for (i = 0; i < k; i++)
                {

                    /*
                    *   Update the remote capability pointer and the 
                    *   priority index to point to first octet of PAR
                    *   block corresponding selected SPAR1 bit.
                    */

                    Update_Rem_Cap_Ptr_Priority_Index(PAR_DELIMIT, i);

                    /*
                    *  Store the global ms buf pointer.
                    */

                    ms_ptr = s_ms_buf_ptr;

                    /*
                    *  Call the function to select NPAR2 block. 
                    */  

                    flag = Mode_Select_Npar1_2_3(NPAR2_DELIMIT);

                    /*
                    *  If the PAR delimit bit is not set in the remote
                    *  capability array, call the function to select SPar2
                    *  octets.
                    */

                    if (!(*(s_rem_cap_ptr - 1) & PAR_DELIMIT))
                    {
                        flag = TRUE;
                        Mode_Select_Spar2();
                    }

                    /*
                    *  Else, if all capability bits are set to zero in the 
                    *  NPAR2 block, restore the global pointers and break 
                    *  from inner FOR i loop, and continue the mode selection 
                    *  procedure by taking next spar1 priority octet.
                    */  

                    else if (flag == FALSE)
                    {
                        s_count = count;
                        s_ms_buf_ptr = ms_ptr;
                        s_priority_index = index;
                        s_rem_cap_ptr = cap_ptr;
                        s_local_cap_bits_count[0] = local_bits_count;
                        s_rem_cap_bits_count[0] = rem_bits_count;
                        break;
                    }

                    /*
                    *  Set the delimiting bit.
                    */  

                    *(s_ms_buf_ptr-1) |= PAR_DELIMIT;

                    /*
                    *  Restore the global pointers.
                    */  

                    s_count = count;
                    s_priority_index = index;
                    s_rem_cap_ptr = cap_ptr;

                } /* end of FOR i loop */

                /*
                *  If the selected NPAR2 block is non zero, break from FOR j
                *  loop, else take the next priority octet (continue the FOR
                *  j loop)
                */

                if (flag == TRUE)
                {
                    break;
                }

            } /* end of IF loop */

        } /* end of FOR j loop */

        /*
        *  Increment the pointers to point to next SPAR1 octet.
        */

        s_priority_index++;
        ms_spar1_ptr++;

    /*
    *  Continue the above mode selection procedure, for all SPAR1 octets.
    */  

    } while ((!(*s_rem_cap_ptr++ & SPAR1_DELIMIT)) && (s_count-- > 0));

    /*end of DO-WHILE loop*/

    /*
    *  Set the delimiting bit.
    */

    *(ms_spar1_ptr - 1) |= SPAR1_DELIMIT;

    /*
    *  Store the remote cap bits count.
    */

    rem_bits_count = s_rem_cap_bits_count[0];

    /*
    *  Update the priority index. Call the module Ms_Bit_Count
    *  to update local cap bits count.
    */

    while ((!(g_local_cap[ID_NPAR1_INDEX + s_priority_index-1] 
              & SPAR1_DELIMIT)) && (s_count-- > 0))
    {
        k = Ms_Bit_Count(0,0);
        s_priority_index++;
    }

    /*
    *  Restore the remote cap bits count.
    */  

    s_rem_cap_bits_count[0] = rem_bits_count;

   return;
}   


/***************************************************************************
*
*   FUNCTION NAME   -   Mode_Select_Spar2
*
*   INPUT           -   None
*
*   OUTPUT          -   None
*
*   GLOBALS         -   g_remote_cap[]    
*   REFERENCED          g_prior[][]  
*                   
*   GLOBALS         -   g_ms_buffer[]
*   MODIFIED            s_ms_buf_ptr
*                       s_rem_cap_ptr
*                       s_priority_index
*                       s_rem_cap_bits_count[]
*                       s_local_cap_bits_count[]
*                       s_count
*                            
*   FUNCTIONS       -   Mode_Select_Npar1_2_3
*   CALLED              Ms_Bit_Count
*                       Update_Rem_Cap_Ptr_Prior_index
*               
****************************************************************************
*
*   CHANGE HISTORY
*   
*   dd/mm/yy    Code Ver    Description         Author
*   --------    --------    -----------         ------
*
*   05/03/98    0.00        Module Created      B.S Shivashankar
*   19/06/98    0.00        Incorporated        B.S Shivashankar
*                           Review comments 
*   03:07:2000  0.10        Ported on to MW     N R Prasad
*
****************************************************************************
*
*   DESCRIPTION      
*
*   This module selects SPAR2 octets and calls the functions to select 
*   NPAR3 octets. It goes through the priority list of modes indicated by 
*   host and finds the highest priority  mode that is present in the remote 
*   capabilities list. It indicates that as a desired mode in MS message. 
*
***************************************************************************/

void Mode_Select_Spar2()
{

    W16 i, j, k, index, flag, local_priority;
    W16 rem_bits_count, local_bits_count, count;
    W16 *ms_spar2_ptr, *cap_ptr, *ms_ptr;

    /*
    *  Initialize the bits count variables corresponding to SPAR2 to zero.
    */  

    s_rem_cap_bits_count[1] = 0;
    s_local_cap_bits_count[1] = 0;

    /*
    *  Copy the global pointers. ms_spar2_ptr will be used for SPAR2 block.
    */

    ms_spar2_ptr = s_ms_buf_ptr;
    cap_ptr = s_rem_cap_ptr;
    count = s_count;

    /*  
    *   Update s_ms_buf_ptr to point to first octet of NPar3 block. 
    */

    do
    {
        s_ms_buf_ptr++;

    } while ((!(*cap_ptr++ & SPAR2_DELIMIT)) && (count-- > 0)); 

    /*
    *  Start mode selection procedure for SPAR2 block, and corresponding
    *  NPAR3 blocks.
    */  

    do
    {
        /*
        *  Store the global variables. The pointers will be restored back
        *  at the end of PAR block selection procedure.
        */

        count = s_count;
        index = s_priority_index;
        cap_ptr = s_rem_cap_ptr;
        rem_bits_count = s_rem_cap_bits_count[1];
        local_bits_count = s_local_cap_bits_count[1];


        /*
        *  Check, whether priority capabilities are present in remote 
        *  capability list. If it is not available, take the next priority
        *  octet for checking. If it is available, copy the priority octet
        *  to MS buffer.
        */  

        for (j = 0; j < PRIORITIES_PER_OCTET; j++)
        {
            flag = TRUE;
            local_priority = g_prior[s_priority_index][j];
            if ((local_priority & *s_rem_cap_ptr) == local_priority)
            {
                *ms_spar2_ptr = local_priority;

                /*
                *  Get the count of bits set in the selected SPAR2 octet
                *  plus NUM_SPAR1_BITS_SET.
                */  

                k = Ms_Bit_Count(local_priority, LEVEL2);
                for (i = NUM_SPAR1_BITS_SET; i < k; i++)
                {   

                    /*
                    *   Update the remote capability pointer and the 
                    *   priority index to point to first octet of NPAR3
                    *   block corresponding selected SPAR2 bit.
                    */

                    Update_Rem_Cap_Ptr_Priority_Index(NPAR3_DELIMIT, i);

                    /*
                    *  Store the global ms buf pointer.
                    */  

                    ms_ptr = s_ms_buf_ptr;

                    /*
                    *  Call the function to select NPAR3 block. 
                    */  

                    flag = Mode_Select_Npar1_2_3(NPAR3_DELIMIT);
                    s_priority_index = index;
                    s_rem_cap_ptr = cap_ptr;
                    s_count = count;

                    /*
                    *  If all capability bits are set to zero in the NPAR2 
                    *  block, restore global variables and break from inner 
                    *  FOR i loop and continue the mode selection procedure
                    *  by taking the next spar2 priority octet.
                    */  

                    if (flag == FALSE)
                    {
                        s_ms_buf_ptr = ms_ptr;
                        s_local_cap_bits_count[1] = local_bits_count;
                        s_rem_cap_bits_count[1] = rem_bits_count;
                        break;
                    }
    
                } /* end of FOR i loop */

                /*
                *  If the selected NPAR3 block is non zero, break from FOR j
                *  loop, else take the next priority octet (continue the FOR
                *  j loop)
                */

                if (flag == TRUE)  
                {
                    break;
                }

            } /* end of IF loop */

        } /* end of FOR j loop */

        /*
        *  Increment the pointers to point to next SPAR2 octet.
        */

        s_priority_index++;
        ms_spar2_ptr++;

    /*
    *  Continue the above mode selection procedure, for all SPAR2 octets.
    */  

    } while ((!(*s_rem_cap_ptr++ & SPAR2_DELIMIT)) && (s_count-- > 0)); 

    /*end of DO-WHILE loop*/

    /*
    *  Set the delimiting bit.
    */

    *(ms_spar2_ptr - 1) |= SPAR2_DELIMIT;

    return;
}   


/***************************************************************************
*
*   FUNCTION NAME   -   Update_Rem_Cap_Ptr_Priority_Index
*
*   INPUT           -   delimit : octet with delimiting bit set corresponding 
*                                 to PAR block or NPAR3 block.
*
*                       index   : index of array s_rem_cap_blocks_skip_count 
*                                 and s_local_cap_blocks_skip_count, which 
*                                 contains the count of blocks to be skipped
*                                 to go to particular PAR/NPAR3 block 
*                                 corresponding to selected SPAR1/SPAR2 bit.
*
*   OUTPUT          -   None
*
*   GLOBALS         -   g_remote_cap[]    
*   REFERENCED          g_local_cap[]
*                       s_rem_cap_blocks_skip_count[]
*                       s_local_cap_blocks_skip_count[]
*                       s_count
*                       g_v8bis_flags
*                       
*   GLOBALS         -   s_rem_cap_ptr
*   MODIFIED            s_priority_index 
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
*   05/03/98    0.00        Module Created      B.S Shivashankar
*   19/06/98    0.00        Incorporated        B.S Shivashankar
*                           Review comments 
*   03:07:2000  0.10        Ported on to MW     N R Prasad
*
****************************************************************************
*
*   DESCRIPTION      
*
*   This module updates the remote capability pointer and priority index to
*   point to corresponding PAR or NPAR3 block.
*
***************************************************************************/

void Update_Rem_Cap_Ptr_Priority_Index(W16 delimit, 
                                       W16 index)
{
    W16 i, count;

    count = s_count;

    /*
    *  Update the remote capability pointer to point to first octet of 
    *  PAR/NPAR3 block corresponding to selected SPAR1/SPAR2 bit.
    */

    for (i = 0; i < s_rem_cap_blocks_skip_count[index]; i++)
    {

        while ((!(*s_rem_cap_ptr++ & delimit)) && (count-- > 0));

    } 


    /*
    *  Update the priority index to point to first octet of PAR/NPAR3 block
    *  corresponding to selected SPAR1/SPAR2 bit.
    */

    for (i = 0; i < s_local_cap_blocks_skip_count[index]; i++)
    {
        while ((!(g_local_cap[ID_NPAR1_INDEX + s_priority_index] & delimit)) 
               && (s_count-- > 0))
        {
            s_priority_index++;
        } 

        s_priority_index++;

    }  

    /*
    *  If the counter is expired, reset the message validity flag.
    */

    if (count <= 0) 
    {
        g_v8bis_flags.message_validity = FALSE;
    }

    return;
}


/***************************************************************************
*
*   FUNCTION NAME   -   Ms_Bit_Count
*
*   INPUT           -   mode_selected_octet : selected MS SPAR1/SPAR2 octet
*   
*                       level               : it indicates whether selected
*                                             MS octet is SPAR1 or SPAR2.
*                                             
*
*   OUTPUT          -   k      : Count of bits set in mode_selected_octet, 
*                                if mode_selected_octet is a SPAR1 octet.
*
*                              : Count of bits set in mode_selected_octet +
*                                NUM_SPAR1_BITS_SET, if mode_selected_octet 
*                                is SPAR2 octet. 
*
*   GLOBALS         -   s_rem_cap_ptr     
*   REFERENCED          g_local_cap[]
*                   
*   GLOBALS         -   s_rem_cap_bits_count[] 
*   MODIFIED            s_local_cap_bits_count[]
*                       s_local_cap_blocks_skip_count[]
*                       s_rem_cap_blocks_skip_count[]
*
*   FUNCTIONS       -   None
*   CALLED                    
*               
****************************************************************************
*   CHANGE HISTORY
*   
*   dd/mm/yy    Code Ver    Description         Author
*   --------    --------    -----------         ------
*
*   05/03/98    0.00        Module Created      B.S Shivashankar
*   19/06/98    0.00        Incorporated        B.S Shivashankar
*                           Review comments 
*   03:07:2000  0.10        Ported on to MW     N R Prasad
*
****************************************************************************
*
*   DESCRIPTION     
*
*   This module finds the number of bits set in the selected octet. For 
*   each selected bit, it finds and stores the count of PAR/NPAR3 blocks 
*   to be skipped in local and remote capability array to go to the PAR
*   or NPAR3 block corresponding to the selected SPAR1/SPAR2 bit.
*
***************************************************************************/

W16 Ms_Bit_Count(W16 mode_selected_octet,
                 W16 level)
                 
{   
    W16 bit_pos, k, i;


    k = NUM_SPAR1_BITS_SET * level;
    bit_pos = 0x01;

    for (i = level; i <= NUM_BITS_PER_OCTET-2; i++)
    {

    /*
    * Check each bit of remote and local capability octet 
    * if it is set, increment the counter
    */
    
        if (*s_rem_cap_ptr & bit_pos)
        {
            s_rem_cap_bits_count[level]++;
        } 

        if (g_local_cap[ID_NPAR1_INDEX + s_priority_index] & bit_pos)
        {
            s_local_cap_bits_count[level]++;
        }

    /*
    * If a bit is set in MS octet, then store the count of bits set from 
    * LSB to a checked bit for remote and local capability list
    */

        if (mode_selected_octet & bit_pos) 
        {
            s_rem_cap_blocks_skip_count[k] = s_rem_cap_bits_count[level];
            s_local_cap_blocks_skip_count[k] = s_local_cap_bits_count[level];
            k++;
        }

        bit_pos <<= 1;

    } /* end of FOR i loop */
    
    return k;
}


/* 
*  End of file
*/

