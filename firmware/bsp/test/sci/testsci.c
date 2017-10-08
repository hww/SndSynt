
#include "stdio.h"
#include "string.h"


#include "io.h"
#include "fcntl.h"
#include "bsp.h"

#include "test.h"
#include "assert.h"

#include "sci.h"

/******************************************************************************/

#define ECHO_LENGTH 4


UWord16 EchoBuffer[ECHO_LENGTH];

#define MSG_START    0
#define MSG_END      1
#define MSG_ERROR    2

char * SerialMsg[] = {  "Echo Started",
                        "The End",
                        "Error"
                     };

volatile bool     EchoCompleted;
volatile bool     WriteCompleted;
volatile UWord16  EchoErrorValue;

int               SciFD;

char message[256];

/******************************************************************************/
void EchoReceive ( void );
void EchoSend    ( void );
void EchoError   ( UWord16 error );

void LoopReceive ( void );
void LoopSend    ( void );
void LoopError   ( UWord16 error );

UWord16  EchoTest(test_sRec  * pTestRec, const char * pName);
UWord16  LoopTest(test_sRec  * pTestRec, const char * pName);

UWord16  SimpleLoopTest(test_sRec  * pTestRec, const char * pName);
UWord16  SimpleTest(test_sRec  * pTestRec, const char * pName);

/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

/******************************************************************************/
void EchoReceive(void)
{
   UWord16  Length;
   int      I;

   Length = read(SciFD,EchoBuffer,ECHO_LENGTH);

   for (I = 0; I<Length; I++ )
   {
      if (EchoBuffer[I] == 'X')
      { 
         EchoCompleted = true;
      }
   }
   
   Length = write(SciFD,EchoBuffer,Length);

}

/******************************************************************************/
void EchoSend(void)
{
   WriteCompleted = true;
}

/******************************************************************************/
void EchoError(UWord16 error)
{
   EchoErrorValue |= error;
}

/******************************************************************************/
UWord16  EchoTest(test_sRec  * pTestRec, const char * pName)
{
   UWord16        I;
   UWord16        j;
   UWord16        Lenght;
   UWord16        MsgLength;
   sci_sConfig    SciConfig;
   UWord16        res;   

   EchoCompleted  = false;
   WriteCompleted = false;
   EchoErrorValue = 0;
   res            = 0;
   
   j=0;
      
   if (pName == BSP_DEVICE_NAME_SERIAL_0)
   {
      sprintf(message, "Echo test sci0", pName);
   } 
#if defined(BSP_DEVICE_NAME_SERIAL_1)
   else if (pName == BSP_DEVICE_NAME_SERIAL_1)
   {
      sprintf(message, "Echo test sci1", pName);
   } 
#endif /* defined(BSP_DEVICE_NAME_SERIAL_1) */
#if defined(BSP_DEVICE_NAME_SERIAL_2)
   else if (pName == BSP_DEVICE_NAME_SERIAL_2)
   {
      sprintf(message, "Echo test sci2", pName);
   } 
#endif /* defined(BSP_DEVICE_NAME_SERIAL_2) */


   testStart (pTestRec, message);

   SciConfig.SciCntl    =  SCI_CNTL_WORD_9BIT | SCI_CNTL_PARITY_ODD;
   SciConfig.SciHiBit   =  SCI_HIBIT_0;
   SciConfig.BaudRate   =  SCI_BAUD_57600; // SCI_BAUD_115200;

   SciFD = open(pName, O_RDWR | O_NONBLOCK, &(SciConfig)); /* open device in Non Blocking mode */

   if ( SciFD  == -1 )
   {
      assert(!" Open device failed.");
   }

   sprintf(message, "Send Start message %d", j++);
   testComment(pTestRec, message);   

   ioctl( SciFD, SCI_DATAFORMAT_EIGHTBITCHARS, NULL );
   ioctl( SciFD, SCI_CALLBACK_TX, EchoSend );
   
   MsgLength = strlen(SerialMsg[MSG_START]);
   
   for ( Lenght = MsgLength; Lenght > 0; )
   {
      Lenght -= write( SciFD, SerialMsg[MSG_START] + MsgLength - Lenght, Lenght);
      
      while (WriteCompleted == false) 
      {
      }
      WriteCompleted = false;
   }

   ioctl( SciFD, SCI_CALLBACK_EXCEPTION, EchoError );
   ioctl( SciFD, SCI_CALLBACK_RX, EchoReceive );
   ioctl( SciFD, SCI_CMD_READ_CLEAR, NULL );

   Lenght = ECHO_LENGTH;

   ioctl( SciFD, SCI_SET_READ_LENGTH, &Lenght );

   while(EchoCompleted == false)
   {
   }

   ioctl( SciFD, SCI_CALLBACK_RX, NULL );
   ioctl( SciFD, SCI_CALLBACK_TX, NULL );
   ioctl( SciFD, SCI_CALLBACK_EXCEPTION, NULL );

   MsgLength = strlen(SerialMsg[MSG_END]);

   for ( Lenght = MsgLength; Lenght > 0; )
   {
      Lenght -= write( SciFD, SerialMsg[MSG_END] + MsgLength - Lenght, Lenght);      

   }

   while (ioctl(SciFD, SCI_GET_STATUS, NULL) & SCI_STATUS_WRITE_INPROGRESS )
   {
   }


   if (EchoErrorValue != 0)
   {
      printf("The following errors has been detected: %d\n", j++);

      if (EchoErrorValue & SCI_EXCEPTION_OVERRUN_ERROR)
      {
         printf("SCI_EXCEPTION_OVERRUN_ERROR\n");
      }
      if (EchoErrorValue & SCI_EXCEPTION_NOISE_ERROR)
      {
         printf("SCI_EXCEPTION_NOISE_ERROR\n");
      }
      if (EchoErrorValue & SCI_EXCEPTION_FRAME_ERROR)
      {
         printf("SCI_EXCEPTION_FRAME_ERROR\n");
      }
      if (EchoErrorValue & SCI_EXCEPTION_PARITY_ERROR)
      {
         printf("SCI_EXCEPTION_PARITY_ERROR\n");
      }
      if (EchoErrorValue & SCI_EXCEPTION_BUFFER_OVERFLOW)
      {
         printf("SCI_EXCEPTION_BUFFER_OVERFLOW\n");
      }
      if (EchoErrorValue & SCI_EXCEPTION_ADDRESS_MARK)
      {
         printf("SCI_EXCEPTION_ADDRESS_MARK\n");
      }
      if (EchoErrorValue & SCI_EXCEPTION_BREAK_SYMBOL)
      {
         printf("SCI_EXCEPTION_BREAK_SYMBOL\n");
      }   
   
      if (EchoErrorValue & ~( SCI_EXCEPTION_OVERRUN_ERROR   | 
                              SCI_EXCEPTION_NOISE_ERROR     | 
                              SCI_EXCEPTION_FRAME_ERROR     | 
                              SCI_EXCEPTION_PARITY_ERROR    |
                              SCI_EXCEPTION_BUFFER_OVERFLOW |
                              SCI_EXCEPTION_ADDRESS_MARK    |
                              SCI_EXCEPTION_BREAK_SYMBOL ))
      {
         printf("Unhandled exseption, EchoErrorValue  = %x\n", EchoErrorValue );
      }
   }

   res = close(SciFD);

   testEnd (pTestRec);
   
   return res;
}



/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

#define LOOP_LENGTH  7

UWord16 LoopSendBuffer[LOOP_LENGTH];
UWord16 LoopReceiveBuffer[LOOP_LENGTH];

UWord16 volatile LoopReceiveCompleted;
UWord16 volatile LoopReceiveLength;
UWord16 volatile LoopSendCompleted;
UWord16 volatile LoopSendLength;
UWord16 volatile LoopErrorValue;

/******************************************************************************/
void LoopReceive(void)
{

   LoopReceiveLength    = read(SciFD,LoopReceiveBuffer,LOOP_LENGTH);

   LoopReceiveCompleted = true;
}

/******************************************************************************/
void LoopSend(void)
{
   LoopSendCompleted = true;
}

/******************************************************************************/
void LoopError(UWord16 error)
{
   LoopErrorValue |= error;
}


/******************************************************************************/
/******************************************************************************/
UWord16  LoopTest(test_sRec  * pTestRec, const char * pName)
{
   sci_sConfig     SciConfig;
   UWord16        res;
   int            i;
   int            j;
   UWord16        PreviosReadSize;
   UWord16        NextReadSize;
   UWord16        SizeCounter;
   
   LoopReceiveCompleted = 0;
   LoopReceiveLength    = 0;
   LoopSendCompleted    = 0;
   LoopSendLength       = false;
   LoopErrorValue       = false;

   res            = 0;   
   
   if (pName == BSP_DEVICE_NAME_SERIAL_0)
   {
      sprintf(message, "Test Loop mode sci0", pName);
   } 
#if defined(BSP_DEVICE_NAME_SERIAL_1)
   else if (pName == BSP_DEVICE_NAME_SERIAL_1)
   {
      sprintf(message, "Test Loop mode sci1", pName);
   } 
#endif /* defined(BSP_DEVICE_NAME_SERIAL_1) */
#if defined(BSP_DEVICE_NAME_SERIAL_2)
   else if (pName == BSP_DEVICE_NAME_SERIAL_2)
   {
      sprintf(message, "Test Loop mode sci2", pName);
   } 
#endif /* defined(BSP_DEVICE_NAME_SERIAL_2) */

	testStart (pTestRec, message);

   SciConfig.SciCntl    =  SCI_CNTL_WORD_8BIT | SCI_CNTL_PARITY_EVEN | SCI_CNTL_LOOP;
   SciConfig.SciHiBit   =  SCI_HIBIT_0;
   SciConfig.BaudRate   =  SCI_BAUD_115200;

   for (i=0;i<LOOP_LENGTH;i++)
   {
      LoopSendBuffer[i] = i;
      LoopReceiveBuffer[i] = 0xffff;
   }

   SciFD = open(pName, O_RDWR | O_NONBLOCK, &(SciConfig)); /* open device in Non Blocking mode */

   if ( SciFD  == -1 )
   {
  		testFailed(pTestRec, " Open device failed");
      return FAIL;
   }

   /* NonBlocking Read and Write */

   ioctl( SciFD, SCI_CALLBACK_EXCEPTION, LoopError );
   ioctl( SciFD, SCI_CALLBACK_RX, LoopReceive );
   ioctl( SciFD, SCI_CALLBACK_TX, LoopSend );
   
   LoopSendLength = LOOP_LENGTH;

   ioctl( SciFD, SCI_SET_READ_LENGTH, (void *)&LoopSendLength );

   LoopSendLength = write( SciFD, LoopSendBuffer, LOOP_LENGTH);

   while((LoopReceiveCompleted == false) || (LoopSendCompleted == false))
   {      
   }
      
   for (i=0;i<LOOP_LENGTH;i++)
   {
      if ( LoopSendBuffer[i] !=  LoopReceiveBuffer[i])
      {
   		testFailed(pTestRec, "write/read error");
         return FAIL;
      } 
   }

   if (LoopErrorValue != 0)
   {
   	testFailed(pTestRec, "Exseption while w/r");
      return FAIL;   
   }

   LoopErrorValue = 0;

   /* Change configuration */

   SciConfig.SciCntl    =  SCI_CNTL_WORD_9BIT | SCI_CNTL_PARITY_NONE | SCI_CNTL_LOOP_SINGLE_WIRE;
   SciConfig.SciHiBit   =  SCI_HIBIT_1;
   SciConfig.BaudRate   =  SCI_BAUD_76800;

   ioctl( SciFD, SCI_DEVICE_RESET, &SciConfig );

   /* Test Break symbol sending and receiving */

   ioctl( SciFD, SCI_CMD_SEND_BREAK, NULL );

   while((LoopErrorValue & SCI_EXCEPTION_BREAK_SYMBOL) == 0)
   {
   }

   if (LoopErrorValue & ~(SCI_EXCEPTION_BREAK_SYMBOL | SCI_EXCEPTION_FRAME_ERROR))
   {
   	testFailed(pTestRec, "Exseption while Break Send");
      return FAIL;   
   }

   LoopErrorValue = 0;

   /* Test Address Exseption mode */

   ioctl( SciFD, SCI_DATAFORMAT_EIGHTBITCHARS, NULL );

   LoopSendBuffer[0] = 0x00AA;

   LoopSendLength = write( SciFD, LoopSendBuffer, 1);

   while((LoopErrorValue & SCI_EXCEPTION_ADDRESS_MARK) == 0)
   {
   }

   LoopReceiveLength = read( SciFD, LoopReceiveBuffer, 1);

   if ( LoopReceiveBuffer[0] != LoopSendBuffer[0])
   {
   	testFailed(pTestRec, "Address mode");
      return FAIL;         
   }

   if (LoopErrorValue & ~SCI_EXCEPTION_ADDRESS_MARK)
   {
   	testFailed(pTestRec, "Exseption while Address Send");
      return FAIL;   
   }

   /* Test Sleep and wakeup */
   
   ioctl( SciFD, SCI_CMD_WAIT, NULL );
   
   ioctl( SciFD, SCI_CMD_WAKEUP, NULL );
   

   /* Test Device Off and On */

   ioctl( SciFD, SCI_DEVICE_OFF, NULL );
   
   ioctl( SciFD, SCI_DEVICE_ON, NULL );

   /* Test Buffer overflow */
   
   LoopErrorValue = 0;
   
   ioctl( SciFD, SCI_DATAFORMAT_RAW, NULL );
   ioctl( SciFD, SCI_CALLBACK_RX, NULL);
   
   for (j=2;j>0;j--)
   {
      for (i=0;i<LOOP_LENGTH;i++)
      {
         LoopSendBuffer[i] = (j << 8) + i;
      }
      LoopSendCompleted = false;
      LoopSendLength = write(SciFD, LoopSendBuffer, LOOP_LENGTH);

      if (LoopSendLength != LOOP_LENGTH)
      {
      	testFailed(pTestRec, "Write length incorrect");
         return FAIL;   
      }
      
      while(LoopSendCompleted == false)
      {
      }
   }
   
   if (LoopErrorValue != SCI_EXCEPTION_BUFFER_OVERFLOW)
   {
   	testFailed(pTestRec, "Exseption while write");
      return FAIL;   
   }

   LoopReceiveLength = read(SciFD, LoopReceiveBuffer, LOOP_LENGTH);

   if (LoopReceiveLength != LOOP_LENGTH)
   {
    	testFailed(pTestRec, "Read length incorrect");
      return FAIL;   
   }
   

   /* test GET_READ_SIZE */

   ioctl(SciFD,SCI_CMD_WRITE_CANCEL,0);
   ioctl(SciFD,SCI_CMD_READ_CLEAR,0);
   
   PreviosReadSize =  ioctl( SciFD, SCI_GET_READ_SIZE, 0 );

   if ( PreviosReadSize != 0 )
   {
       testFailed(pTestRec, "Get Read size eroor #1");
       return FAIL;   
   }
   
   SizeCounter = 0;
   
   LoopSendLength = write( SciFD, LoopSendBuffer, LOOP_LENGTH);

   do 
   {
       NextReadSize = ioctl( SciFD, SCI_GET_READ_SIZE, 0 );
       if (NextReadSize == (PreviosReadSize + 1))
       {
           PreviosReadSize = NextReadSize; /* in case of error never return */
           SizeCounter++;
       }       
   }
   while ((PreviosReadSize != LOOP_LENGTH) || (ioctl(SciFD, SCI_GET_STATUS, 0) & SCI_STATUS_WRITE_INPROGRESS));
   
   NextReadSize =  ioctl( SciFD, SCI_GET_READ_SIZE, 0 );

   if ( NextReadSize != LOOP_LENGTH )
   {
       testFailed(pTestRec, "Get Read size eroor #2");
       return FAIL;   
   }

   if (( SizeCounter < LOOP_LENGTH - 1) || ( SizeCounter > LOOP_LENGTH ))
   {
       testFailed(pTestRec, "Get Read size eroor #3");
       return FAIL;   
   }

   LoopReceiveLength = read(SciFD, LoopReceiveBuffer, LOOP_LENGTH);
       
   PreviosReadSize =  ioctl( SciFD, SCI_GET_READ_SIZE, 0 );

   if ( PreviosReadSize != 0 )
   {
       testFailed(pTestRec, "Get Read size eroor #4");
       return FAIL;   
   }

   res = close(SciFD);

   testEnd (pTestRec);
   
   return PASS;
}




/******************************************************************************/
int main(void)
{
   UWord16        res = 0;
   test_sRec      testRec;
   
#if 0
   /* To perform Echo test run Windows HyperTerminal           */
   /* on 57600 baud, 8N1, Odd Parity. Type something in        */
   /* terminal window and see the buffered echo from board.    */
   /* The buffer size is determinated by ECHO_LENGTH constant  */ 
   /* To exit from test type 'X' character                     */
   res |= EchoTest(&testRec,BSP_DEVICE_NAME_SERIAL_0);
#endif 

   res |= LoopTest(&testRec,BSP_DEVICE_NAME_SERIAL_0);

#if defined(BSP_DEVICE_NAME_SERIAL_1)
   res |= LoopTest(&testRec,BSP_DEVICE_NAME_SERIAL_1);
#endif /* defined(BSP_DEVICE_NAME_SERIAL_1) */
#if defined(BSP_DEVICE_NAME_SERIAL_2)
   res |= LoopTest(&testRec,BSP_DEVICE_NAME_SERIAL_2);
#endif /* defined(BSP_DEVICE_NAME_SERIAL_2) */
}
