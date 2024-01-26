`ifndef ALU_V
`define ALU_V

`default_nettype none

// see https://github.com/Time0o/z80-verilog/blob/master/source/rtl/alu.v
module Alu(
    input wire [4:0] mode,
    input wire [7:0] a,
    input wire [7:0] b,
    input wire [7:0] flags,
    output reg [7:0] out,
    output reg [7:0] outFlags
);
    `include "alu.vh"
    `include "flags.vh"

    reg cL, cH;
    wire cin = flags[FLAG_INDEX_C];
    wire isB00 = b == 8'h00;
    wire isBFF = b == 8'hFF;
    reg [7:0] a_;
    reg [7:0] b_;

    always @(*) begin
        outFlags = flags;
        cL = 0;
        cH = 0;

        case (mode)
        ALU1_COM,
        ALU2_TCM:
            a_ = ~a;
        default:
            a_ = a;
        endcase

        case (mode)
        ALU1_DEC:
            b_ = 8'hFF;
        ALU1_DECW: // lower byte in b
            b_ = isBFF ? b : 8'h00;
        ALU1_INC:
            b_ = 8'h01;
        ALU1_INCW: // lower byte in b
            b_ = isB00 ? 8'h01 : 8'h00;
        default:
            b_ = b;
        endcase

        case (mode)
        ALU1_DEC,
        ALU1_DECW,
        ALU1_INC,
        ALU1_INCW: begin
            out = a_ + b_;
        end
        ALU1_RLC: begin
            out = { a_[6:0], cin };
            outFlags[FLAG_INDEX_C] = a_[7];
        end
        ALU1_DA: begin
            if (flags[FLAG_INDEX_D] == 1'b0) begin
                // after add
                { cL, out } = { 1'b0, a_ } +
                    (flags[FLAG_INDEX_H] || (a_[3] && (a_[2] || a_[1])) ? 9'h6 : 9'h0);
                outFlags[FLAG_INDEX_C] = cL;
            end
            else begin
                // after sub
                { cL, out } = { 1'b0, a_ } +
                    (flags[FLAG_INDEX_H] ? 9'h1FA : 9'h0);
                outFlags[FLAG_INDEX_C] = cL | cin;
            end
        end
        ALU1_DA_H: begin
            if (flags[FLAG_INDEX_D] == 1'b0) begin
                // after add
                out[3:0] = a[3:0];
                { cH, out[7:4] } = { 1'b0, a_[7:4] } + {
                    1'h0,
                    ((flags[FLAG_INDEX_C] || (a_[7] && (a_[6] || a_[5]))) ? 4'h6 : 4'h0)
                };
                outFlags[FLAG_INDEX_C] = cH;
            end
            else begin
                // after sub
                out[3:0] = a[3:0];
                { cL, out[7:4] } = { 1'b0, a_[7:4] } +
                    (cin ? 5'h1A : 5'h0);
                outFlags[FLAG_INDEX_C] = cL | cin;
            end
        end
        ALU1_COM: begin
            out = a_;
        end
        ALU1_RL: begin
            out = { a_[6:0], a_[7] };
            outFlags[FLAG_INDEX_C] = a_[7];
        end
        ALU1_RRC: begin
            out = { cin, a_[7:1] };
            outFlags[FLAG_INDEX_C] = a_[0];
        end
        ALU1_SRA: begin
            out = { a_[7], a_[7:1] };
            outFlags[FLAG_INDEX_C] = a_[0];
        end
        ALU1_RR: begin
            out = { a_[0], a_[7:1] };
            outFlags[FLAG_INDEX_C] = a_[0];
        end
        ALU1_SWAP: begin
            out = { a_[3:0], a_[7:4] };
        end
        ALU2_ADD,
        ALU2_ADC: begin
            { cL, out[3:0] } = { 1'b0, a_[3:0] } + { 1'b0, b_[3:0] } + { 4'b0, cin & mode[0] };
            outFlags[FLAG_INDEX_H] = cL;
            { cH, out[7:4] } = { 1'b0, a_[7:4] } + { 1'b0, b_[7:4] } + { 4'b0000, cL };
            outFlags[FLAG_INDEX_C] = cH;
            outFlags[FLAG_INDEX_D] = 0;
        end
        ALU2_SUB,
        ALU2_SBC,
        ALU2_CP: begin
            { cL, out[3:0] } = { 1'b0, a_[3:0] } - { 1'b0, b_[3:0] } - { 4'b0, cin & mode[0] };
            outFlags[FLAG_INDEX_H] = cL;
            { cH, out[7:4] } = { 1'b0, a_[7:4] } - { 1'b0, b_[7:4] } - { 4'b0000, cL };
            outFlags[FLAG_INDEX_C] = cH;
            // keep D vor CP
            outFlags[FLAG_INDEX_D] = flags[FLAG_INDEX_D] | ~mode[3];
        end
        ALU2_OR: begin
            out = a_ | b_;
        end
        ALU2_AND,
        ALU2_TCM,
        ALU2_TM: begin
            out = a_ & b_;
        end
        ALU2_XOR: begin
            out = a_ ^ b_;
        end
        ALU1_LD: begin
            out = a_;
        end
        // ALU1_CLR
        default : begin
            out = 0;
        end
        endcase

		// Flags ======================================================
        case (mode)
        ALU1_INC,
        ALU1_INCW:
            outFlags[FLAG_INDEX_V] = ~a_[7] & out[7];
        ALU1_DEC,
        ALU1_DECW:
            outFlags[FLAG_INDEX_V] = a_[7] & ~out[7];
        ALU2_ADD,
        ALU2_ADC,
        ALU2_SUB,
        ALU2_SBC,
        ALU2_CP:
            outFlags[FLAG_INDEX_V] = (a_[7] == b_[7]) & (a_[7] != out[7]);
        ALU1_COM,
        ALU2_OR,
        ALU2_AND,
        ALU2_TCM,
        ALU2_TM,
        ALU2_XOR:
            outFlags[FLAG_INDEX_V] = 0;
        default:
            outFlags[FLAG_INDEX_V] = flags[FLAG_INDEX_V];
        endcase

        case (mode)
        ALU1_CLR,  // keep it
        ALU1_LD  : outFlags[FLAG_INDEX_Z] = flags[FLAG_INDEX_Z];

        ALU1_DECW, // set only if set from the lower-byte operation, too
        ALU1_INCW: outFlags[FLAG_INDEX_Z] = isB00 & (out == 0);

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
