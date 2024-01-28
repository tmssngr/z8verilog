localparam STATES_MAX_BIT = 5;
localparam STATE_FETCH_INSTR  = 0;
localparam STATE_READ_INSTR   = STATE_FETCH_INSTR + 1;
localparam STATE_WAIT_2       = STATE_READ_INSTR + 1;
localparam STATE_READ_2       = STATE_WAIT_2 + 1;
localparam STATE_WAIT_3       = STATE_READ_2 + 1;
localparam STATE_READ_3       = STATE_WAIT_3 + 1;
localparam STATE_DECODE       = STATE_READ_3 + 1;
localparam STATE_ALU1_WORD1   = STATE_DECODE + 1;
localparam STATE_ALU1_WORD2   = STATE_ALU1_WORD1 + 1;
localparam STATE_ALU1_OP      = STATE_ALU1_WORD2 + 1;
localparam STATE_ALU1_DA      = STATE_ALU1_OP + 1;
localparam STATE_ALU2_IR      = STATE_ALU1_DA + 1;
localparam STATE_ALU2_OP      = STATE_ALU2_IR + 1;
localparam STATE_PUSH_I1      = STATE_ALU2_OP + 1;
localparam STATE_PUSH_I2      = STATE_PUSH_I1 + 1;
localparam STATE_PUSH_E1      = STATE_PUSH_I2 + 1;
localparam STATE_PUSH_E2      = STATE_PUSH_E1 + 1;
localparam STATE_PUSH_E3      = STATE_PUSH_E2 + 1;
localparam STATE_POP_I        = STATE_PUSH_E3 + 1;
localparam STATE_POP_E1       = STATE_POP_I + 1;
localparam STATE_POP_E2       = STATE_POP_E1 + 1;
localparam STATE_POP_E3       = STATE_POP_E2 + 1;
localparam STATE_DJNZ1        = STATE_POP_E3 + 1;
localparam STATE_DJNZ2        = STATE_DJNZ1 + 1;
localparam STATE_LDC_READ1    = STATE_DJNZ2 + 1;
localparam STATE_LDC_READ2    = STATE_LDC_READ1 + 1;
localparam STATE_LDC_WRITE1   = STATE_LDC_READ2 + 1;
localparam STATE_LDC_WRITE2   = STATE_LDC_WRITE1 + 1;
localparam STATE_LDC_WRITE3   = STATE_LDC_WRITE2 + 1;
localparam STATE_READ_MEM1    = STATE_LDC_WRITE3 + 1;
localparam STATE_READ_MEM2    = STATE_READ_MEM1 + 1;
localparam STATE_WRITE_MEM    = STATE_READ_MEM2 + 1;
localparam STATE_INC_R_RR1    = STATE_WRITE_MEM + 1;
localparam STATE_INC_R_RR2    = STATE_INC_R_RR1 + 1;
localparam STATE_INC_R_RR3    = STATE_INC_R_RR2 + 1;
localparam STATE_CALL_I1      = STATE_INC_R_RR3 + 1;
localparam STATE_CALL_I2      = STATE_CALL_I1 + 1;
localparam STATE_CALL_E1      = STATE_CALL_I2 + 1;
localparam STATE_CALL_E2      = STATE_CALL_E1 + 1;
localparam STATE_CALL_E3      = STATE_CALL_E2 + 1;
localparam STATE_JP1          = STATE_CALL_E3 + 1;
localparam STATE_JP2          = STATE_JP1 + 1;
localparam STATE_JP3          = STATE_JP2 + 1;
localparam STATE_IRET_I       = STATE_JP3 + 1;
localparam STATE_RET_I1       = STATE_IRET_I + 1;
localparam STATE_RET_I2       = STATE_RET_I1 + 1;
localparam STATE_RET_I3       = STATE_RET_I2 + 1;
localparam STATE_IRET_E1      = STATE_RET_I3 + 1;
localparam STATE_IRET_E2      = STATE_IRET_E1 + 1;
localparam STATE_RET_E1       = STATE_IRET_E2 + 1;
localparam STATE_RET_E2       = STATE_RET_E1 + 1;
localparam STATE_RET_E3       = STATE_RET_E2 + 1;
localparam STATE_RET_E4       = STATE_RET_E3 + 1;
localparam STATE_RET_E5       = STATE_RET_E4 + 1;
localparam STATE_RET_E6       = STATE_RET_E5 + 1;
