`define assertPc(value)            if (uut.proc.pc             !== (value)) begin $display("ASSERTION FAILED in %m: pc(%h) != %h"            , uut.proc.pc, (value)        ); $finish(2); end
`define assertState(value)         if (uut.proc.state          !== (value)) begin $display("ASSERTION FAILED in %m: state(%h) != value"      , uut.proc.state              ); $finish(2); end
`define assertInstr(value)         if (uut.proc.instruction    !== (value)) begin $display("ASSERTION FAILED in %m: instruction(%h) != value", uut.proc.instruction        ); $finish(2); end
`define assertSecond(value)        if (uut.proc.second         !== (value)) begin $display("ASSERTION FAILED in %m: second(%h) != %h"        , uut.proc.second, (value)    ); $finish(2); end
`define assertThird(value)         if (uut.proc.third          !== (value)) begin $display("ASSERTION FAILED in %m: third(%h) != value"      , uut.proc.third              ); $finish(2); end
`define assertFlags(value)         if (uut.proc.flags          !== (value)) begin $display("ASSERTION FAILED in %m: flags(%b) != %b"         , uut.proc.flags, (value)     ); $finish(2); end
`define assertRegister(num, value) if (uut.proc.registers[num] !== (value)) begin $display("ASSERTION FAILED in %m: reg[%h] = %h != %h"      , num, uut.proc.registers[num], (value)); $finish(2); end
`define assertRom(addr, value)     if (uut.rom.memory[(addr) % uut.rom.size] !== (value)) begin $display("ASSERTION FAILED in %m: reg[%h] = %h != %h", addr, uut.rom.memory[(addr) % uut.rom.size], (value)); $finish(2); end
`define assertRam(addr, value)     if (uut.ram.memory[(addr) % uut.ram.size] !== (value)) begin $display("ASSERTION FAILED in %m: reg[%h] = %h != %h", addr, uut.ram.memory[(addr) % uut.ram.size], (value)); $finish(2); end
`include "jump_conditions.vh"
`include "flags.vh"

task chk_1byteOp;
    input[7:0] instruction;
    begin
        repeat (2) @(negedge clk);
            `assertInstr(instruction);
            `assertState(STATE_DECODE);
        @(negedge clk);
    end
endtask
task chk_2byteOp;
    input[7:0] instruction;
    input[7:0] second;
    begin
        repeat (3) @(negedge clk);
            `assertInstr(instruction);
            `assertSecond(second);
            `assertState(STATE_DECODE);
        @(negedge clk);
    end
endtask
task chk_3byteOp;
    input[7:0] instruction;
    input[7:0] second;
    input[7:0] third;
    begin
        repeat (5) @(negedge clk);
            `assertInstr(instruction);
            `assertSecond(second);
            `assertThird(third);
            `assertState(STATE_DECODE);
        @(negedge clk);
    end
endtask

task chk_srp;
    input[3:0] upper;
    begin
        chk_2byteOp(8'h31, {upper, 4'h0});
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
            `assert(uut.proc.rp, upper);
    end
endtask

task chk_ld_r_R;
    input[3:0] dst;
    input[7:0] src;
    input[7:0] register;
    input[7:0] value;
    begin
        chk_2byteOp({dst, 4'h8}, src);
            `assert(uut.proc.register, register);
            `assert(uut.proc.aluA, value);
            `assert(uut.proc.writeRegister, 1);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
            `assertRegister(register, value);
    end
endtask
task chk_ld_R_r;
    input[7:0] dst;
    input[3:0] src;
    input[7:0] register;
    input[7:0] value;
    begin
        chk_2byteOp({src, 4'h9}, dst);
            `assert(uut.proc.register, register);
            `assert(uut.proc.aluA, value);
            `assert(uut.proc.writeRegister, 1);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
            `assertRegister(register, value);
    end
endtask
task chk_ld_r_IM;
    input[3:0] dst;
    input[7:0] value;
    input[7:0] register;
    begin
        chk_2byteOp({dst, 4'hC}, value);
            `assert(uut.proc.register, register);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
            `assertRegister(register, value);
    end
endtask
task chk_ld_r_Ir;
    input[3:0] dst;
    input[3:0] src;
    input[7:0] register;
    input[7:0] value;
    begin
        chk_2byteOp(8'hE3, {dst, src});
            `assertState(STATE_LD);
        @(negedge clk);
            `assert(uut.proc.aluA, value);
            `assert(uut.proc.register, register);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
            `assertRegister(register, value);
    end
endtask
task chk_ld_Ir_r;
    input[3:0] dst;
    input[3:0] src;
    input[7:0] register;
    input[7:0] value;
    begin
        chk_2byteOp(8'hF3, {dst, src});
            `assert(uut.proc.register, register);
            `assertState(STATE_LD);
        @(negedge clk);
            `assert(uut.proc.aluA, value);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
            `assertRegister(register, value);
    end
endtask
task chk_ld_R_R;
    input[7:0] dst;
    input[7:0] src;
    input[7:0] register;
    input[7:0] value;
    begin
        chk_3byteOp('hE4, src, dst);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
            `assertRegister(register, value);
    end
endtask
task chk_ld_R_IR;
    input[7:0] dst;
    input[7:0] src;
    input[7:0] register;
    input[7:0] value;
    begin
        chk_3byteOp('hE5, src, dst);
            `assertState(STATE_LD);
        @(negedge clk);
            `assert(uut.proc.aluA, value);
            `assert(uut.proc.aluMode, ALU1_LD);
            `assert(uut.proc.register, register);
            `assert(uut.proc.writeRegister, 1);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
            `assertRegister(register, value);
    end
endtask
task chk_ld_IR_IM;
    input[7:0] dst;
    input[7:0] value;
    input[7:0] register;
    begin
        chk_3byteOp('hE7, dst, value);
            `assertState(STATE_LD);
        @(negedge clk);
            `assert(uut.proc.aluA, value);
            `assert(uut.proc.aluMode, ALU1_LD);
            `assert(uut.proc.register, register);
            `assert(uut.proc.writeRegister, 1);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
            `assertRegister(register, value);
    end
endtask
task chk_ld_IR_R;
    input[7:0] dst;
    input[7:0] src;
    input[7:0] register;
    input[7:0] value;
    begin
        chk_3byteOp('hF5, src, dst);
            `assert(uut.proc.aluA, value);
            `assertState(STATE_LD);
        @(negedge clk);
            `assert(uut.proc.aluMode, ALU1_LD);
            `assert(uut.proc.register, register);
            `assert(uut.proc.writeRegister, 1);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
            `assertRegister(register, value);
    end
endtask
task chk_ld_R_IM;
    input[7:0] dst;
    input[7:0] value;
    begin
        chk_3byteOp(8'hE6, dst, value);
            `assert(uut.proc.writeRegister, 1);
            `assert(uut.proc.writeFlags, 0);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
            if (dst == P01M) begin
                `assert(uut.proc.p01m, value);
            end
            else if (dst == P3M) begin
                `assert(uut.proc.p3m, value);
            end
            else begin
                if (dst == SPL) begin
                    `assert(uut.proc.sp[7:0], value);
                end
                else begin
                    `assertRegister(dst, value);
                end
            end
    end
endtask
task chk_ld_r_IrX;
    input[3:0] dst;
    input[3:0] src;
    input[7:0] offset;
    input[7:0] srcReg;
    input[7:0] register;
    input[7:0] value;
    begin
        chk_3byteOp(8'hC7, {dst, src}, offset);
            `assert(uut.proc.register, srcReg);
            `assertState(STATE_LD);
        @(negedge clk);
            `assert(uut.proc.register, register);
            `assert(uut.proc.aluA, value);
            `assert(uut.proc.writeRegister, 1);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
            `assertRegister(register, value);
    end
endtask
task chk_ld_IrX_r;
    input[3:0] dst;
    input[7:0] offset;
    input[3:0] src;
    input[7:0] register;
    input[7:0] value;
    begin
        chk_3byteOp(8'hD7, {src, dst}, offset);
            `assertState(STATE_LD);
        @(negedge clk);
            `assert(uut.proc.register, register);
            `assert(uut.proc.aluA, value);
            `assert(uut.proc.writeRegister, 1);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
            `assertRegister(register, value);
    end
endtask

task chk_jp;
    input[15:0] addr;
    begin
        chk_jp_true(JC_ALWAYS, addr);
    end
endtask
task chk_jp_true;
	input[3:0] cc;
    input[15:0] addr;
    begin
        chk_3byteOp({cc, 4'hD}, addr[15:8], addr[7:0]);
            `assert(uut.proc.takeBranch, 1'b1);
            `assertState(STATE_JP1);
        @(negedge clk);
            `assertState(STATE_JP2);
        @(negedge clk);
            `assertState(STATE_JP3);
        @(negedge clk);
            `assertPc(addr);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
    end
endtask
task chk_jp_false;
	input[3:0] cc;
    input[15:0] addr;
    begin
        chk_3byteOp({cc, 4'hD}, addr[15:8], addr[7:0]);
            `assert(uut.proc.takeBranch, 1'b0);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
    end
endtask
task chk_jp_IRR;
	input[7:0] src;
    input[15:0] addr;
    begin
        chk_2byteOp(8'h30, src);
            `assertState(STATE_JP1);
        @(negedge clk);
            `assert(uut.proc.addr[15:8], addr[15:8]);
            `assertState(STATE_JP2);
        @(negedge clk);
            `assert(uut.proc.addr, addr);
            `assertState(STATE_JP3);
        @(negedge clk);
            `assertPc(addr);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
    end
endtask
task chk_jr;
    input[7:0] ra;
    input[15:0] addr;
    begin
        chk_jr_true(JC_ALWAYS, ra, 
                    addr);
    end
endtask
task chk_jr_true;
	input[3:0] cc;
    input[7:0] ra;
    input[15:0] addr;
    begin
        chk_2byteOp({cc, 4'hB}, ra);
            `assert(uut.proc.takeBranch, 1'b1);
            `assertPc(addr);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
    end
endtask
task chk_jr_false;
	input[3:0] cc;
    input[7:0] ra;
    input[15:0] addr;
    begin
        chk_2byteOp({cc, 4'hB}, ra);
            `assert(uut.proc.takeBranch, 1'b0);
            `assertPc(addr);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
    end
endtask
task chk_djnz_true;
    input[3:0] dst;
    input[7:0] ra;
    input[7:0] register;
    input[7:0] value;
    input[7:0] addr;
    begin
        chk_2byteOp({dst, 4'hA}, ra);
            `assertState(STATE_DJNZ1);
            `assert(uut.proc.register, register);
        @(negedge clk);
            `assert(uut.proc.aluMode, ALU1_DEC);
            `assertState(STATE_DJNZ2);
        @(negedge clk);
            `assertState(STATE_FETCH_INSTR);
            `assertRegister(register, value);
            `assertPc(addr);
        @(negedge clk);
    end
endtask
task chk_djnz_false;
    input[3:0] dst;
    input[7:0] ra;
    input[7:0] register;
    input[7:0] addr;
    begin
        chk_2byteOp({dst, 4'hA}, ra);
            `assertState(STATE_DJNZ1);
            `assert(uut.proc.register, register);
        @(negedge clk);
            `assert(uut.proc.aluMode, ALU1_DEC);
            `assertState(STATE_DJNZ2);
        @(negedge clk);
            `assertState(STATE_FETCH_INSTR);
            `assertRegister(register, 8'h0);
            `assertPc(addr);
        @(negedge clk);
    end
endtask

task chk_decw;
    input[7:0] register;
    input[15:0] expValue;
    input[7:0] expFlags;
    begin
        chk_2byteOp(8'h80, register);
            `assert(uut.proc.aluMode, ALU1_DEC);
            `assert(uut.proc.register, register);
            `assertState(STATE_ALU1_WORD1);
        @(negedge clk);
            // lower byte:
            `assert(uut.proc.aluMode, ALU1_DEC);
            `assert(uut.proc.register, register | 1);
            `assert(uut.proc.writeRegister, 1);
            `assert(uut.proc.writeFlags, 0);
            `assertState(STATE_ALU1_WORD2);
        @(negedge clk);
            `assertRegister(register | 1, expValue[7:0]);
            // upper byte:
            `assert(uut.proc.aluMode, ALU1_DECW);
            `assert(uut.proc.register, register & ~1);
            `assert(uut.proc.writeRegister, 1);
            `assert(uut.proc.writeFlags, 1);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
            `assertRegister(register & ~1, expValue[15:8]);
            `assertFlags(expFlags);
    end
endtask
task chk_incw;
    input[7:0] register;
    input[15:0] expValue;
    input[7:0] expFlags;
    begin
        chk_2byteOp(8'hA0, register);
            `assert(uut.proc.aluMode, ALU1_INC);
            `assert(uut.proc.register, register);
            `assertState(STATE_ALU1_WORD1);
            // lower byte:
        @(negedge clk);
            `assert(uut.proc.aluMode, ALU1_INC);
            `assert(uut.proc.register, register | 1);
            `assert(uut.proc.writeRegister, 1);
            `assert(uut.proc.writeFlags, 0);
            `assertState(STATE_ALU1_WORD2);
        @(negedge clk);
            `assertRegister(register | 1, expValue[7:0]);
            // upper byte:
            `assert(uut.proc.aluMode, ALU1_INCW);
            `assert(uut.proc.register, register & ~1);
            `assert(uut.proc.writeRegister, 1);
            `assert(uut.proc.writeFlags, 1);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
            `assertRegister(register & ~1, expValue[15:8]);
            `assertFlags(expFlags);
    end
endtask

task chk_alu1;
    input[5:0] op;
    input[7:0] dst;
    input[7:0] register;
    input[7:0] value;
    input[7:0] flags;
    begin
        chk_2byteOp({op[3:0], 4'h0}, dst);
            `assertState(STATE_ALU1_OP);
            `assert(uut.proc.register, register);
        @(negedge clk);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
            `assertRegister(register, value);
            `assertFlags(flags);
    end
endtask
task chk_alu1_IR;
    input[5:0] op;
    input[7:0] dst;
    input[7:0] register;
    input[7:0] value;
    input[7:0] flags;
    begin
        chk_2byteOp({op[3:0], 4'h1}, dst);
            `assertState(STATE_ALU1_OP);
            `assert(uut.proc.register, register);
        @(negedge clk);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
            `assertRegister(register, value);
            `assertFlags(flags);
    end
endtask
task chk_inc_r;
    input[3:0] dst;
    input[7:0] register;
    input[7:0] value;
    input[7:0] flags;
    begin
        chk_1byteOp({dst, 4'hE});
            `assertState(STATE_ALU1_OP);
            `assert(uut.proc.register, register);
        @(negedge clk);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
            `assertRegister(register, value);
            `assertFlags(flags);
    end
endtask

task chk_alu2_r_r;
    input[5:0] op;
    input[3:0] dst;
    input[3:0] src;
    input[7:0] expDst;
    input[7:0] expResult;
    input[7:0] expFlags;
    begin
        chk_2byteOp({op[3:0], 4'h2}, {dst, src});
            `assertState(STATE_ALU2_OP1);
        @(negedge clk);
            `assertState(STATE_ALU2_OP2);
        @(negedge clk);
            `assertState(STATE_ALU2_OP3);
        @(negedge clk);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
            `assertRegister({expDst}, {expResult});
            `assertFlags({expFlags});
    end
endtask
task chk_alu2_r_Ir;
    input[5:0] op;
    input[3:0] dst;
    input[3:0] src;
    input[7:0] expDst;
    input[7:0] expResult;
    input[7:0] expFlags;
    begin
        chk_2byteOp({op[3:0], 4'h3}, {dst, src});
            `assertState(STATE_ALU2_OP1);
        @(negedge clk);
            `assertState(STATE_ALU2_OP2);
        @(negedge clk);
            `assertState(STATE_ALU2_OP3);
        @(negedge clk);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
            `assertRegister({expDst}, {expResult});
            `assertFlags({expFlags});
    end
endtask
task chk_alu2_R_R;
    input[5:0] op;
    input[7:0] dst;
    input[7:0] src;
    input[7:0] expDst;
    input[7:0] expResult;
    input[7:0] expFlags;
    begin
        chk_3byteOp({op[3:0], 4'h4}, src, dst);
            `assertState(STATE_ALU2_OP1);
        @(negedge clk);
            `assertState(STATE_ALU2_OP2);
        @(negedge clk);
            `assertState(STATE_ALU2_OP3);
        @(negedge clk);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
            `assertRegister({expDst}, {expResult});
            `assertFlags({expFlags});
    end
endtask
task chk_alu2_R_IR;
    input[5:0] op;
    input[7:0] dst;
    input[7:0] src;
    input[7:0] expDst;
    input[7:0] expResult;
    input[7:0] expFlags;
    begin
        chk_3byteOp({op[3:0], 4'h5}, src, dst);
            `assertState(STATE_ALU2_OP1);
        @(negedge clk);
            `assertState(STATE_ALU2_OP2);
        @(negedge clk);
            `assertState(STATE_ALU2_OP3);
        @(negedge clk);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
            `assertRegister({expDst}, {expResult});
            `assertFlags({expFlags});
    end
endtask
task chk_alu2_R_IM;
    input[5:0] op;
    input[7:0] dst;
    input[7:0] value;
    input[7:0] expDst;
    input[7:0] expResult;
    input[7:0] expFlags;
    begin
        chk_3byteOp({op[3:0], 4'h6}, dst, value);
            `assert(uut.proc.register, expDst);
            `assertState(STATE_ALU2_OP1);
        @(negedge clk);
            `assert(uut.proc.aluB, value);
            `assertState(STATE_ALU2_OP2);
        @(negedge clk);
            `assertState(STATE_ALU2_OP3);
        @(negedge clk);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
            `assertRegister({expDst}, {expResult});
            `assertFlags({expFlags});
    end
endtask
task chk_alu2_IR_IM;
    input[5:0] op;
    input[7:0] dst;
    input[7:0] value;
    input[7:0] expDst;
    input[7:0] expResult;
    input[7:0] expFlags;
    begin
        chk_3byteOp({op[3:0], 4'h7}, dst, value);
            `assert(uut.proc.register, expDst);
            `assertState(STATE_ALU2_OP1);
        @(negedge clk);
            `assert(uut.proc.aluB, value);
            `assertState(STATE_ALU2_OP2);
        @(negedge clk);
            `assertState(STATE_ALU2_OP3);
        @(negedge clk);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
            `assertRegister({expDst}, {expResult});
            `assertFlags({expFlags});
    end
endtask

task chk_nop;
    begin
        chk_1byteOp(8'hFF);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
    end
endtask

task chk_pop;
    input[7:0] dst;
    input[7:0] register;
    input[7:0] value;
    input[15:0] sp;
    begin
        chk_2byteOp(8'h50, dst);
            `assert(uut.proc.register, register);
            `assertState(STATE_POP_1);
        @(negedge clk);
            `assertState(STATE_POP_2);
        @(negedge clk);
            `assertState(STATE_POP_3);
        @(negedge clk);
            `assert(uut.proc.aluA, value);
            `assertState(STATE_POP_4);
        @(negedge clk);
            `assert(uut.proc.aluMode, ALU1_LD);
            `assert(uut.proc.sp, sp);
            `assert(uut.proc.register, register);
            `assert(uut.proc.writeRegister, 1);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
            `assertRegister(register, value);
    end
endtask
task chk_pop_IR;
    input[7:0] dst;
    input[7:0] register;
    input[7:0] value;
    input[15:0] sp;
    begin
        chk_2byteOp(8'h51, dst);
            `assert(uut.proc.register, register);
            `assertState(STATE_POP_1);
        @(negedge clk);
            `assert(uut.proc.addr, sp - 1);
            `assertState(STATE_POP_2);
        @(negedge clk);
            `assertState(STATE_POP_3);
        @(negedge clk);
            `assert(uut.proc.aluA, value);
            `assertState(STATE_POP_4);
        @(negedge clk);
            `assert(uut.proc.aluMode, ALU1_LD);
            `assert(uut.proc.sp, sp);
            `assert(uut.proc.register, register);
            `assert(uut.proc.writeRegister, 1);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
            `assertRegister(register, value);
    end
endtask

task chk_push_intern;
    input [7:0] src;
    input [7:0] register;
    input [7:0] value;
    input [7:0] sp;
    begin
        chk_2byteOp(8'h70, src);
            `assert(uut.proc.register, register);
            `assertState(STATE_PUSH_I1);
        @(negedge clk);
            `assertState(STATE_PUSH_I2);
        @(negedge clk);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
            `assert(uut.proc.sp, sp);
            `assertRegister(sp, value);
    end
endtask
task chk_push_extern;
    input  [7:0] src;
    input  [7:0] register;
    input  [7:0] value;
    input [15:0] sp;
    begin
        chk_2byteOp(8'h70, src);
            `assert(uut.proc.register, register);
            `assertState(STATE_PUSH_E1);
        @(negedge clk);
            `assertState(STATE_PUSH_E2);
        @(negedge clk);
            `assertState(STATE_PUSH_E3);
        @(negedge clk);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
            `assert(uut.proc.sp, sp);
            `assertRam(sp, value);
    end
endtask

task chk_call_intern;
    input[15:0] addr;
    input[15:0] pc;
    input[7:0]  sp;
    begin
        chk_3byteOp(8'hD6, addr[15:8], addr[7:0]);
            `assert(uut.proc.sp, sp + 1);
            `assertState(STATE_CALL_I1);
        @(negedge clk);
            `assert(uut.proc.sp, sp);
            `assert(uut.proc.aluMode, ALU1_LD);
            `assert(uut.proc.aluA, pc[7:0]);
            `assert(uut.proc.register, sp+1);
            `assert(uut.proc.writeRegister, 1);
            `assertState(STATE_CALL_I2);
        @(negedge clk);
            `assertRegister(sp+1, pc[7:0]);

            `assert(uut.proc.aluMode, ALU1_LD);
            `assert(uut.proc.aluA, pc[15:8]);
            `assert(uut.proc.register, sp);
            `assert(uut.proc.writeRegister, 1);
            `assertState(STATE_JP1);
        @(negedge clk);
            `assert(uut.proc.addr[15:8], addr[15:8]);
            `assertState(STATE_JP2);
        @(negedge clk);
            `assert(uut.proc.addr[7:0], addr[7:0]);
            `assertState(STATE_JP3);
        @(negedge clk);
            `assertRegister(sp, pc[15:8]);
            `assertPc(addr);

            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
    end
endtask
task chk_call_extern;
    input[15:0] addr;
    input[15:0] pc;
    input[15:0] sp;
    begin
        chk_3byteOp(8'hD6, addr[15:8], addr[7:0]);
            `assert(uut.proc.sp, sp + 1);
            `assertState(STATE_CALL_E1);
        @(negedge clk);
            `assert(uut.proc.addr, sp+1);
            `assert(uut.proc.sp, sp);
            `assert(uut.proc.aluA, pc[7:0]);
            `assertState(STATE_CALL_E2);
        @(negedge clk);
            `assertRam(sp+1, pc[7:0]);

            `assert(uut.proc.addr, sp);
            `assert(uut.proc.aluA, pc[15:8]);
            `assertState(STATE_CALL_E3);
        @(negedge clk);
            `assertRam(sp, pc[15:8]);
            `assertState(STATE_JP1);
        @(negedge clk);
            `assert(uut.proc.addr[15:8], addr[15:8]);
            `assertState(STATE_JP2);
        @(negedge clk);
            `assert(uut.proc.addr[7:0], addr[7:0]);
            `assertState(STATE_JP3);
        @(negedge clk);
            `assertPc(addr);

            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
    end
endtask
task chk_call_IRR_intern;
    input [7:0] src;
    input[15:0] addr;
    input[15:0] pc;
    input [7:0] sp;
    begin
        chk_2byteOp(8'hD4, src);
            `assert(uut.proc.sp, sp + 1);
            `assertState(STATE_CALL_I1);
        @(negedge clk);
            `assert(uut.proc.sp, sp);
            `assert(uut.proc.aluMode, ALU1_LD);
            `assert(uut.proc.aluA, pc[7:0]);
            `assert(uut.proc.register, sp + 1);
            `assert(uut.proc.writeRegister, 1);
            `assertState(STATE_CALL_I2);
        @(negedge clk);
            `assertRegister(sp + 1, pc[7:0]);

            `assert(uut.proc.aluMode, ALU1_LD);
            `assert(uut.proc.aluA, pc[15:8]);
            `assert(uut.proc.register, sp);
            `assert(uut.proc.writeRegister, 1);
            `assertState(STATE_JP1);
        @(negedge clk);
            `assert(uut.proc.addr[15:8], addr[15:8]);
            `assertState(STATE_JP2);
        @(negedge clk);
            `assert(uut.proc.addr[7:0], addr[7:0]);
            `assertState(STATE_JP3);
        @(negedge clk);
            `assertRegister(sp, pc[15:8]);
            `assertPc(addr);

            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
    end
endtask
task chk_call_IRR_extern;
    input [7:0] src;
    input[15:0] addr;
    input[15:0] pc;
    input[15:0] sp;
    begin
        chk_2byteOp(8'hD4, src);
            `assert(uut.proc.sp, sp + 1);
            `assertState(STATE_CALL_E1);
        @(negedge clk);
            `assert(uut.proc.addr, sp + 1);
            `assert(uut.proc.sp, sp);
            `assert(uut.proc.aluA, pc[7:0]);
            `assertState(STATE_CALL_E2);
        @(negedge clk);
            `assertRam(sp + 1, pc[7:0]);

            `assert(uut.proc.addr, sp);
            `assert(uut.proc.aluA, pc[15:8]);
            `assertState(STATE_CALL_E3);
        @(negedge clk);
            `assertRam(sp, pc[15:8]);
            `assertState(STATE_JP1);
        @(negedge clk);
            `assert(uut.proc.addr[15:8], addr[15:8]);
            `assertState(STATE_JP2);
        @(negedge clk);
            `assert(uut.proc.addr[7:0], addr[7:0]);
            `assertState(STATE_JP3);
        @(negedge clk);
            `assertPc(addr);

            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
    end
endtask

task chk_ret_intern;
    input [15:0] pc;
    input  [7:0] sp;
    begin
        chk_1byteOp(8'hAF);
            `assert(uut.proc.sp, sp - 2);
            `assertState(STATE_RET_I1);
        @(negedge clk);
            `assert(uut.proc.addr[15:8], pc[15:8]);
            `assert(uut.proc.sp, sp - 1);
            `assertState(STATE_RET_I2);
        @(negedge clk);
            `assert(uut.proc.addr, pc);
            `assert(uut.proc.sp, sp);
            `assertState(STATE_RET_I3);
        @(negedge clk);
            `assertState(STATE_FETCH_INSTR);
            `assertPc(pc);
        @(negedge clk);
    end
endtask
task chk_ret_extern;
    input [15:0] pc;
    input [15:0] sp;
    begin
        chk_1byteOp(8'hAF);
            `assert(uut.proc.sp, sp - 16'h2);
            `assertState(STATE_RET_E1);
        @(negedge clk);
            `assertState(STATE_RET_E2);
        @(negedge clk);
            `assert(uut.proc.addr, sp - 16'h2);
            `assert(uut.proc.sp, sp - 16'h1);
            `assertState(STATE_RET_E3);
        @(negedge clk);
            `assertState(STATE_RET_E4);
        @(negedge clk);
            `assert(uut.proc.aluA, pc[15:8]);
            `assert(uut.proc.addr, sp - 16'h1);
            `assert(uut.proc.sp, sp);
            `assertState(STATE_RET_E5);
        @(negedge clk);
            `assert(uut.proc.addr, pc);
            `assertState(STATE_RET_E6);
        @(negedge clk);
            `assertState(STATE_FETCH_INSTR);
            `assertPc(pc);
        @(negedge clk);
    end
endtask
task chk_iret_intern;
    input [15:0] pc;
    input  [7:0] sp;
    input  [7:0] flags;
    begin
        chk_1byteOp(8'hBF);
            `assertState(STATE_IRET_I);
        @(negedge clk);
            `assert(uut.proc.aluMode, ALU1_LD);
            `assert(uut.proc.aluA, flags);
            `assert(uut.proc.sp, sp - 2);
            `assert(uut.proc.register, 'hFC);
            `assert(uut.proc.writeRegister, 1);
            `assertState(STATE_RET_I1);
        @(negedge clk);
            `assertFlags(flags);
            `assert(uut.proc.addr[15:8], pc[15:8]);
            `assert(uut.proc.sp, sp - 1);
            `assertState(STATE_RET_I2);
        @(negedge clk);
            `assert(uut.proc.addr, pc);
            `assert(uut.proc.sp, sp);
            `assertState(STATE_RET_I3);
        @(negedge clk);
            `assertState(STATE_FETCH_INSTR);
            `assertPc(pc);
    end
endtask
task chk_iret_extern;
    input [15:0] pc;
    input [15:0] sp;
    input  [7:0] flags;
    begin
        chk_1byteOp(8'hBF);
            `assertState(STATE_IRET_E1);
        @(negedge clk);
            `assert(uut.proc.addr, sp - 16'h3);
            `assertState(STATE_IRET_E2);
        @(negedge clk);
            `assert(uut.proc.aluMode, ALU1_LD);
            `assert(uut.proc.aluA, flags);
            `assert(uut.proc.sp, sp - 16'h2);
            `assert(uut.proc.register, 'hFC);
            `assert(uut.proc.writeRegister, 1);
            `assertState(STATE_RET_E1);
        @(negedge clk);
            `assertFlags(flags);
            `assert(uut.proc.addr, sp - 16'h2);
            `assert(uut.proc.sp, sp - 16'h1);
            `assertState(STATE_RET_E2);
        @(negedge clk);
            `assertState(STATE_RET_E3);
        @(negedge clk);
            `assert(uut.proc.aluA, pc[15:8]);
            `assert(uut.proc.addr, sp - 16'h1);
            `assert(uut.proc.sp, sp);
            `assertState(STATE_RET_E4);
        @(negedge clk);
            `assertState(STATE_RET_E5);
        @(negedge clk);
            `assert(uut.proc.addr, pc);
            `assertState(STATE_RET_E6);
        @(negedge clk);
            `assertPc(pc);
            `assertState(STATE_FETCH_INSTR);
    end
endtask
