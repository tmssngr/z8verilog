`ifndef ALU_V
`define ALU_V

// see https://github.com/Time0o/z80-verilog/blob/master/source/rtl/alu.v
module Alu(
    input [4:0] mode,
    input [7:0] a,
    input [7:0] b,
    input [7:0] flags,
    output reg [7:0] out,
    output reg [7:0] outFlags
);
    `include "alu.vh"
    `include "flags.vh"

    reg cL, cH;
    reg [7:0] a_and;

    always @(*) begin
        outFlags = flags;

        casez (mode)
        ALU1_DEC: begin
            out = a - 8'b01;
            outFlags[FLAG_INDEX_V] = a[7] & ~out[7];
        end
        ALU1_DECW: begin // lower byte in b
            cL = b == 8'hFF;
            out = a - cL;
            outFlags[FLAG_INDEX_V] = a[7] & ~out[7];
        end
        ALU1_RLC: begin
            out = { a[6:0], flags[FLAG_INDEX_C] };
            outFlags[FLAG_INDEX_C] = a[7];
        end
        ALU1_INC: begin
            out = a + 8'b01;
            outFlags[FLAG_INDEX_V] = ~a[7] & out[7];
        end
        ALU1_INCW: begin // lower byte in b
            cL = b == 0;
            out = a + cL;
            outFlags[FLAG_INDEX_V] = ~a[7] & out[7];
        end
        ALU1_DA: begin
            if (flags[FLAG_INDEX_D] == 1'b0) begin
                // after add
                { cL, out } = { 1'b0, a } + 
                    (flags[FLAG_INDEX_H] || (a[3] && (a[2] || a[1])) ? 9'h6 : 9'h0);
                outFlags[FLAG_INDEX_C] = cL;
            end
            else begin
                // after sub
                { cL, out } = { 1'b0, a } -  
                    (flags[FLAG_INDEX_H] ? 9'h6 : 9'h0);
                outFlags[FLAG_INDEX_C] = cL | flags[FLAG_INDEX_C];
            end
        end
        ALU1_DA_H: begin
            if (flags[FLAG_INDEX_D] == 1'b0) begin
                // after add
                { cH, out[7:4] } = { 1'b0, a[7:4] } + {
                    1'h0,
                    ((flags[FLAG_INDEX_C] || (a[7] && (a[6] || a[5]))) ? 4'h6 : 4'h0)
                };
                outFlags[FLAG_INDEX_C] = cH;
            end
            else begin
                // after sub
                { cL, out[7:4] } = { 1'b0, a[7:4] } -  
                    (flags[FLAG_INDEX_C] ? 5'h6 : 5'h0);
                outFlags[FLAG_INDEX_C] = cL | flags[FLAG_INDEX_C];
            end
        end
        ALU1_COM: begin
            out = ~a;
            outFlags[FLAG_INDEX_V] = 0;
        end
        ALU1_RL: begin
            out = { a[6:0], a[7] };
            outFlags[FLAG_INDEX_C] = a[7];
        end
        ALU1_RRC: begin
            out = { flags[FLAG_INDEX_C], a[7:1] };
            outFlags[FLAG_INDEX_C] = a[0];
        end
        ALU1_SRA: begin
            out = { a[7], a[7:1] };
            outFlags[FLAG_INDEX_C] = a[0];
        end
        ALU1_RR: begin
            out = { a[0], a[7:1] };
            outFlags[FLAG_INDEX_C] = a[0];
        end
        ALU1_SWAP: begin
            out = { a[3:0], a[7:4] };
        end
        ALU2_ADD,
        ALU2_ADC: begin
            { cL, out[3:0] } = { 1'b0, a[3:0] } + { 1'b0, b[3:0] } + { 8'b0, flags[FLAG_INDEX_C] & mode[0] };
            outFlags[FLAG_INDEX_H] = cL;
            { cH, out[7:4] } = { 1'b0, a[7:4] } + { 1'b0, b[7:4] } + { 4'b0000, cL };
            outFlags[FLAG_INDEX_C] = cH;
            outFlags[FLAG_INDEX_D] = 0;
            outFlags[FLAG_INDEX_V] = (a[7] == b[7]) & (a[7] != out[7]);
        end
        ALU2_SUB,
        ALU2_SBC,
        ALU2_CP: begin
            { cL, out[3:0] } = { 1'b0, a[3:0] } - { 1'b0, b[3:0] } - { 8'b0, flags[FLAG_INDEX_C] & mode[0] };
            outFlags[FLAG_INDEX_H] = cL;
            { cH, out[7:4] } = { 1'b0, a[7:4] } - { 1'b0, b[7:4] } - { 4'b0000, cL };
            outFlags[FLAG_INDEX_C] = cH;
            // keep D vor CP
            outFlags[FLAG_INDEX_D] = flags[FLAG_INDEX_D] | ~mode[3];
            outFlags[FLAG_INDEX_V] = (a[7] == b[7]) & (a[7] != out[7]);
        end
        ALU2_OR: begin
            out = a | b;
            outFlags[FLAG_INDEX_V] = 0;
        end
        ALU2_AND,
        ALU2_TCM,
        ALU2_TM: begin
            a_and = mode[0] ? a : ~a;
            out = a_and & b;
            outFlags[FLAG_INDEX_V] = 0;
        end
        ALU2_XOR: begin
            out = a ^ b;
            outFlags[FLAG_INDEX_V] = 0;
        end
        ALU1_LD: begin
            out <= a;
        end
        // ALU1_CLR
        default : begin
            out = 0;
        end
        endcase

        case (mode)
        ALU1_CLR,  // keep it
        ALU1_LD  : outFlags[FLAG_INDEX_Z] = flags[FLAG_INDEX_Z];

        ALU1_DECW, // set only if set from the lower-byte operation, too
        ALU1_INCW: outFlags[FLAG_INDEX_Z] = (b == 0) & (out == 0);

        default  : outFlags[FLAG_INDEX_Z] = (out == 0);
        endcase

        case (mode)
        ALU1_CLR, // keep it
        ALU1_LD : outFlags[FLAG_INDEX_S] = flags[FLAG_INDEX_S];

        default : outFlags[FLAG_INDEX_S] = out[7];
        endcase
    end
endmodule

`endif