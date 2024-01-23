// similar to the upper nibble of the commands
localparam ALU1_DEC = 5'h00;
localparam ALU1_RLC = 5'h01;
localparam ALU1_INC = 5'h02;
// 3
localparam ALU1_DA  = 5'h04;
// 5
localparam ALU1_COM = 5'h06;
// 7
localparam ALU1_DECW = 5'h08;
localparam ALU1_RL   = 5'h09;
localparam ALU1_INCW = 5'h0A;
localparam ALU1_CLR  = 5'h0B;
localparam ALU1_RRC  = 5'h0C;
localparam ALU1_SRA  = 5'h0D;
localparam ALU1_RR   = 5'h0E;
localparam ALU1_SWAP = 5'h0F;

// pseudo commands:
localparam ALU1_LD   = 5'h03;
localparam ALU1_DA_H = 5'h05;


localparam ALU2_ADD = 5'h10;
localparam ALU2_ADC = 5'h11;
localparam ALU2_SUB = 5'h12;
localparam ALU2_SBC = 5'h13;
localparam ALU2_OR  = 5'h14;
localparam ALU2_AND = 5'h15;
localparam ALU2_TCM = 5'h16;
localparam ALU2_TM  = 5'h17;
// 8
// 9
localparam ALU2_CP  = 5'h1A;
localparam ALU2_XOR = 5'h1B;
// c
// d
// e
// f