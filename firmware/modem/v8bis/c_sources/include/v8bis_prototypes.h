/* Function prototypes for v8bis_statte_machine.c */

void V8bis_State_Machine();
void Send_Msg_Clr();
void Send_Msg_Cl();
void Send_Msg_Ms();
void Send_Msg_Nak1();
void Send_Msg_Ack1_Or_Nak3();
void Send_Sig_Crd();
void Goto_Initial_State();
void Detect_Modem_Hs_Signal();
BOOLEAN Detect_ShortV8();
BOOLEAN Detect_V8();
BOOLEAN Detect_V25();

void V8bis_Init();
void ssi_setup();
void Dsp_Core_Control();
void Rx_Host_Message();
void Rx_Dsp_Response();
void Tx_Host_Message_V8bis_Success();
void Tx_Host_Message_Error(ERROR_IDS error_id);
void Check_Timeout_Counter();

/* Function prototypes for modeselect.c */

void Mode_Select();
void Mode_Select_Spar1();
void Mode_Select_Spar2();
BOOLEAN Mode_Select_Npar1_2_3(W16 delimit);
void Update_Rem_Cap_Ptr_Priority_Index(W16 delimit, W16 index);
W16 Ms_Bit_Count(W16 mode_selected_octet, W16 level);

/* Function prototypes for checkmode.c */

BOOLEAN Check_Mode();
BOOLEAN Check_Message_Block(W16 delimit);
BOOLEAN Check_Spar1(PAR_FIELDS par_field);
BOOLEAN Check_Spar2();

void Rx_Ctrl_Command();
void Tx_Dsp_Response();

void Signal_Gen_Init();
void Signal_Detect_Init();
void Message_Gen_Init();
void Msg_Receive_Init();

void Messsage_Generation();
void V21_Mod_Init(W16 init_or_resp);
void V21_Mod(W16 bit);
W16  Calc_Crc_Ccitt();
W16  Crc_BitReversed();



/* Function Prototypes  for signal_det.c */

void Signal_Detect();
void Dtmf_Det_Init();
void Dtmf_Det();
void Stf_Det_Init();
void Stf_Det();
 
 
/* Function Prototypes for signal_gen.c*/
 
void Signal_Gen();
void Dtmf_Init();
void Dtmf_Buff_Gen();
void Stf_Init();
void Stf_Buff_Gen();
void Silence_Gen();
 
/* Function Prototypes for mesg_reception.c */
 
void Msg_Receive_Ctrl();
void Msg_Receive();
void Rm_Bit_Stuff();
void End_Of_Message();
void V21_RxDemod_Init();
void V21_Rxctrl();
W16 Calc_Crc_Ccitt();

