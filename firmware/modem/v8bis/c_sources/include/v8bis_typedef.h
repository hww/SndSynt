#ifndef _V8BIS_TYPEDEF_H_
#define _V8BIS_TYPEDEF_H_

typedef short int      W16;
typedef unsigned int   U16;

typedef struct
{
    U16 set_transmit_ack1    : 1; /* to set the TRANSMIT ACK1 parameter in 
                                     ID NPAR1 octet */
    U16 telephony_mode       : 1; /* this bit is set, if local supports 
                                     telephony mode */
    U16 auto_answering       : 1; /* this bit is set, if local is a auto 
                                     answering machine */
    U16 rem_v8bis_knowldg    : 1; /* this bit is set, if local knows the 
                                     v8bis capability of remote station */
    U16 local_knows_rcap     : 1; /* this bit is set, if local station knows 
                                     remote capabilities */
    U16 remote_knows_lcap    : 1; /* this bit is set, if remote station 
                                     knows local capabilities */
    U16 local_wants_decision : 1; /* this bit is set, if local wants to 
                                     select modes (MS) */
    U16 local_wants_rcap     : 1; /* this bit is set, if local wants  to 
                                     know remote capabilities */
    U16 revision_number      : 4; /* revision number of V.8 bis */ 
    U16 echo_suppressor      : 1; /* this bit is set, if GSTN includes 
                                     echo suppressor */

} HOST_CONFIG;

typedef struct
{
    U16 ssi_rx_samples_ready     : 1; /* This flag will be set by ssi
                                         module, if 144/24 samples have
                                         been received */
    U16 ssi_tx_samples_rqst      : 1; /* This flag will be set by ssi
                                         routine if the codec has 
                                         transmitted 144/24 samples */
    U16 signal_gen_enable        : 1; /* Enables signal generation */
    U16 message_gen_enable       : 1; /* Enables message generation */
    U16 signal_detect_enable     : 1; /* Enables signal detection */
    U16 message_reception_enable : 1; /* Enables message reception */     
    U16 cdbit                    : 1; /* this bit will be set, when the 
                                         carrier is detected */
    U16 es_detected              : 1; /* This flag will be set if ES is 
                                         detected */
    U16 es_generated             : 1; /* This flag will be set if ES is
                                         generated */
    U16 v8bis_transaction_on     : 1; /* this bit will be set when the 
                                         bis transaction is started */
    U16 initiate_transaction     : 1; /* Initiates v.8 bis transaction */ 
    U16 station                  : 1; /* initiating or responding station */
    U16 signal_detected          : 1; /* set if signal is detected */
    U16 message_received         : 1; /* set if message is received */
    U16 dsp_tx_busy              : 1;
    U16 message_validity         : 1; /* set if valid message is received */

    U16 precede_es               : 1; /* set if msg is to be preceded by ES */
    U16 generate_cl_ms           : 1; /* set if CL_MS msg is to be generated */
    U16 cl_received              : 1; /* set when cl is received in 
                                         sent CLR state */
    U16 cl_ms_expected           : 1; /* set if CL_MS msg is expected */
    U16 start_modem_handshake    : 1; /* set if station sends ACK1 */
    U16 host_config_msg_rxd      : 1; /* set if configuration msg is received
                                         from host */
    U16 host_cap_msg_rxd         : 1; /* set if local capabilities received */
    U16 host_rcap_msg_rxd        : 1; /* set if remote caps received */
    U16 host_priority_msg_rxd    : 1; /* set if priorities received */
    U16 send_nak1                : 1; /* set if nak1 should be sent, if
                                         message validity is reset in
                                         modeselect function. */
    U16 silence_before_signal    : 1; /* set if silence is to be transmitted
                                         before signal. */
    U16 five_seconds_counter     : 1; /* set in ssi_isr if five seconds 
                                         counter is expired */
    U16 hs_signal_detected       : 1; /* set if the handshake signal is
                                         detected */

} FLAGS;


typedef enum 
{

    INITIAL_V8BIS_STATE, 
    SENT_MR_STATE, 
    SENT_MS_STATE, 
    SENT_CR_OR_CLR_STATE, 
    SENT_CL_STATE,      
    SENT_CLR_STATE,
    MSMODE_STATE,
    SENT_NAK_STATE

} V8BIS_STATES;

typedef enum
{
    FALSE,
    TRUE

} BOOLEAN;

typedef enum
{
    ID_FIELD,
    SI_FIELD

} PAR_FIELDS;   

typedef enum
{
    NIL_TX_HOST_MESSAGE,
    ACK_MESSAGE,
    ERROR_MESSAGE,
    V8BIS_SUCCESS_INITIATE_MODEM_HANDSHAKE,
    V8BIS_SUCCESS_LOOK_FOR_MODEM_HANDSHAKE

} TX_HOST_MESSAGES;      

typedef enum
{
    NIL_ID,
    MODE_NOT_SUPPORTED,
    RECEIVED_INVALID_MSG,
    RECEIVED_NAK1_MSG,
    TIMED_OUT,
    V8BIS_TRANSACTION_STARTED,
    INVALID_MSG_FORMAT,
    RECEIVED_NAK2_Or_3_MSG

} ERROR_IDS;      


typedef enum
{
    NIL_RX_HOST_MESSAGE,
    CONFIGURATION_MESSAGE,
    CAPABILITIES_MESSAGE,
    PRIORITIES_MESSAGE,
    REMOTE_CAPABILITIES_MESSAGE,
    INITIATE_TRANSACTION_MESSAGE,
    STOP_V8BIS_TRANSACTION_MESSAGE,
    TX_GAIN_FACTOR_MESSAGE

} RX_HOST_MESSAGES;     

    
typedef enum
{
    RESP_STATION,
    INIT_STATION

} STATION;


typedef enum
{

    NIL_COMMAND,
    SEND_SIGNAL_COMMAND, 
    SEND_MESSAGE_COMMAND,        
    ENABLE_SIG_SEARCH_COMMAND,
    ENABLE_MSG_RECEPTION_COMMAND

} COMMANDS;


typedef enum
{
    NIL_RESPONSE,
    SIGNAL_DETECTED_RESPONSE, 
    MESSAGE_RECEIVED_RESPONSE

} RESPONSES;

typedef enum 
{
    NIL,
    MS = 0x01,       
    CL = 0x02,      
    CLR= 0x03,     
    ACK1=0x04,   
    ACK2=0x05,   
    NAK1=0x08,   
    NAK2=0x09, 
    NAK3=0x0a,           
    NAK4=0x0b,          
    MRe = 20,        
    MRd = 21,        
    CRe = 22,       
    CRd = 23,        
    ESi = 24,
    ESr = 25,
    INVALID_MESSAGE,      
    VALID_MESSAGE,
    INITIATING,
    RESPONDING

} SIGNALS_MESSAGES;

typedef enum
{
    MSG_TYPE_MS = 0x01,       
    MSG_TYPE_CL = 0x02,      
    MSG_TYPE_CLR= 0x03,     
    MSG_TYPE_ACK1=0x04,   
    MSG_TYPE_ACK2=0x05,   
    MSG_TYPE_NAK1=0x08,   
    MSG_TYPE_NAK2=0x09, 
    MSG_TYPE_NAK3=0x0a,           
    MSG_TYPE_NAK4=0x0b          

} MESSAGE_TYPES;


typedef enum
{

    DUAL_TONE_GEN_STATE,
    SINGLE_TONE_GEN_STATE,
    SILENCE_GEN_STATE

} SIGNAL_GENERATION_STATES;

typedef enum 
{

    MARK_GEN_STATE,
    FLAG_GENERATION_STATE,
    DATA_GEN_STATE

} MESSAGE_GENERATION_STATES;

typedef enum
{

    DUAL_TONE_DETECT_STATE,
    SINGLE_TONE_DETECT_STATE

} SIGNAL_DETECT_STATES;

typedef enum 
{

    CARRIER_DETECT_STATE,
    MARK_DETECT_STATE,
    MARK_STATE,
    FLAG_VERIFY_STATE,
    DATA_STATE,
    END_FLAG_STATE

} MESSAGE_RECEPTION_STATES;  

#endif