
/*            delimit bits                 */

#define    NPAR1_DELIMIT                   0x80
#define    SPAR1_DELIMIT                   0x80
#define    PAR_DELIMIT                     0x80
#define    NPAR2_DELIMIT                   0x40
#define    NPAR3_DELIMIT                   0x40
#define    NPAR2_3_DELIMIT                 0x40
#define    SPAR2_DELIMIT                   0x40




/*                Indexes                  */   

#define    MSG_START_INDEX                 1
#define    ID_NPAR1_INDEX                  2




/*              Bits set                   */

#define    BITS_1_6_SET                    0x3f
#define    BITS_1_7_SET                    0x7f



/*    Identification field, NPAR1 octet    */

#define    V8                              0x01
#define    SHORT_V8                        0x02
#define    ADDITIONAL_INFO_AVAILABLE       0x04 
#define    TRANSMIT_ACK1                   0x08
#define    RESERVED5                       0x10
#define    RESERVED6                       0x20
#define    NON_STANDARD_FIELD              0x40 




/*         buffer lengths                  */  

#define    MS_BUF_LENGTH                   26
#define    LOCAL_CAP_BUF_LENGTH            26
#define    REMOTE_CAP_BUF_LENGTH           26
#define    PRIORITY_BUF_LENGTH             24
#define    PRIORITIES_PER_OCTET            8
#define    TRANSMIT_BUF_LENGTH             50
#define    RECEIVE_BUF_LENGTH              50
#define    SIG_SAMPLES_BUF_LENGTH          144+8
#define    MSG_SAMPLES_BUF_LENGTH          24 
#define    CODEC_BUFFER_LENGTH             288


/*           counters                      */

#define    FIVE_SECONDS_COUNT              0x8ca0 
#define    TWELVE_BAUD_COUNT               0x8ca0 

/*       intrrupt masks                    */

#define    INTERRUPT_MASK                  0300  

#define    HDLC_FLAG                       0x7e
#define    NUM_OF_START_MSG_HDLC_FLAGS     5
#define    NUM_OF_END_MSG_HDLC_FLAGS       1


#define    NUM_BITS_PER_OCTET              8
#define    INIT                            0
#define    RESP                            2
#define    DUAL_TONE_TIME                  20 
#define    SINGLE_TONE_TIME                5
#define    SILENCE_TIME                    75
#define    AMP_H                           0x7fff
#define    AMP_L                           0x0e52
#define    SIGNAL_OFFSET                   20
#define    MAX_OCTETS_COUNT                26

/*     v.21 center frequencies             */

#define    INIT_FC                         1080
#define    RESP_FC                         1750

#define    INIT_OFFSET                     0
#define    RESP_OFFSET                     2

#define    SAMPLES_PER_BAUD                24
#define    SAMPLES_PER_FRAME               144

