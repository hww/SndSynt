#include "v8bis_typedef.h"
#include "v8bis_defines.h"

W16 g_ms_buffer[MS_BUF_LENGTH];
W16 g_local_cap[LOCAL_CAP_BUF_LENGTH];
W16 g_remote_cap[REMOTE_CAP_BUF_LENGTH];
W16 g_prior[PRIORITY_BUF_LENGTH][PRIORITIES_PER_OCTET];

W16 g_msg_tx_buffer[TRANSMIT_BUF_LENGTH];
W16 g_msg_rx_buffer[RECEIVE_BUF_LENGTH];

W16 g_sig_samples_buffer[SIG_SAMPLES_BUF_LENGTH];
W16 g_msg_samples_buffer[MSG_SAMPLES_BUF_LENGTH];

W16 *g_samples_buf_ptr;

W16 g_dual_offset;         /* offset for the dual_tone */ 
W16 g_single_offset;      /* offset for single_tone */
W16 g_signal_amp;         /* amplitude of tone to be generated */ 
W16 g_v8bis_control;
W16 g_signal_counter;     /* counter used for signal generation */ 
W16 g_current_decision;    /* variable to store the current decision
                              of signal detected. */ 
W16 g_single_tone_detected;/* type of single tone detected */ 
SIGNALS_MESSAGES g_sig_msg;
SIGNALS_MESSAGES g_command_data;
SIGNALS_MESSAGES g_signal_type;
SIGNALS_MESSAGES g_response_data;
V8BIS_STATES g_v8bis_state;
FLAGS g_v8bis_flags;
HOST_CONFIG g_host_config;
COMMANDS g_command_type;
RESPONSES g_response_type;

SIGNAL_GENERATION_STATES g_signal_gen_state;
SIGNAL_DETECT_STATES g_signal_det_state; 
MESSAGE_GENERATION_STATES g_message_gen_state;
MESSAGE_RECEPTION_STATES g_message_rx_state;

TX_HOST_MESSAGES g_tx_host_msg_type;
RX_HOST_MESSAGES g_rx_host_msg_type;
W16 *g_tx_host_data_ptr;
W16 *g_rx_host_data_ptr;

volatile BOOLEAN v_v8bis_start_or_stop;
volatile U16 v_timeout_counter;
W16 g_current_msg_gen_byte;

W16 g_v21_rx_decision_length;

W16 g_flag_gen_counter;

W16 g_v21_rxdemod_bits;


