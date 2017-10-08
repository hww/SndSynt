#include "v8bis_defines.h"
extern W16 g_ms_buffer[];
extern W16 g_local_cap[];
extern W16 g_remote_cap[];
extern W16 g_prior[][PRIORITIES_PER_OCTET];

extern W16 g_msg_tx_buffer[];
extern W16 g_msg_rx_buffer[];

extern W16 g_sig_samples_buffer[];
extern W16 g_msg_samples_buffer[];

extern W16 *g_samples_buf_ptr;
extern W16 *g_codec_tx_buf_ptr;
extern W16 *g_codec_rx_buf_ptr;
extern W16 *codec_tx_rptr;
extern W16 *codec_rx_wptr;

extern W16 g_single_offset;
extern W16 g_dual_offset;
extern W16 g_signal_amp;
extern W16 g_single_tone_detected;
extern W16 g_current_decision;
extern W16 g_v8bis_control;
extern W16 g_signal_counter;
extern SIGNALS_MESSAGES g_sig_msg;
extern SIGNALS_MESSAGES g_command_data;
extern SIGNALS_MESSAGES g_signal_type;
extern SIGNALS_MESSAGES g_response_data;
extern V8BIS_STATES g_v8bis_state;
extern FLAGS g_v8bis_flags;
extern HOST_CONFIG g_host_config;
extern COMMANDS g_command_type;
extern RESPONSES g_response_type;


extern SIGNAL_GENERATION_STATES g_signal_gen_state;
extern SIGNAL_DETECT_STATES g_signal_det_state;
extern MESSAGE_GENERATION_STATES g_message_gen_state;
extern MESSAGE_RECEPTION_STATES g_message_rx_state;

extern TX_HOST_MESSAGES g_tx_host_msg_type;
extern RX_HOST_MESSAGES g_rx_host_msg_type;
extern W16 *g_tx_host_data_ptr;
extern W16 *g_rx_host_data_ptr;

extern volatile BOOLEAN v_v8bis_start_or_stop;
extern volatile U16 v_timeout_counter;
extern W16 g_current_msg_gen_byte;

extern W16 g_v21_rx_decision_length;
extern W16 g_flag_gen_counter;
extern W16 g_v21_rxdemod_bits;

extern W16 codec_tx_buffer[];
extern W16 codec_rx_buffer[];
extern W16 v8_ssi_txctr;
extern W16 v8_ssi_rxctr;
extern U16 v8_txgain;



