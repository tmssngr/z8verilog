`define assertPc(value)            if (uut.proc.pc             !== (value)) begin $display("ASSERTION FAILED in %m: pc(%h) != %h"            , uut.proc.pc, (value)        ); $finish(2); end
`define assertState(value)         if (uut.proc.state          !== (value)) begin $display("ASSERTION FAILED in %m: state(%h) != value"      , uut.proc.state              ); $finish(2); end
`define assertInstr(value)         if (uut.proc.instruction    !== (value)) begin $display("ASSERTION FAILED in %m: instruction(%h) != value", uut.proc.instruction        ); $finish(2); end
`define assertSecond(value)        if (uut.proc.second         !== (value)) begin $display("ASSERTION FAILED in %m: second(%h) != %h"        , uut.proc.second, (value)    ); $finish(2); end
`define assertThird(value)         if (uut.proc.third          !== (value)) begin $display("ASSERTION FAILED in %m: third(%h) != value"      , uut.proc.third              ); $finish(2); end
`define assertFlags(value)         if (uut.proc.flags          !== (value)) begin $display("ASSERTION FAILED in %m: flags(%b) != %b"         , uut.proc.flags, (value)     ); $finish(2); end
`define assertRegister(num, value) if (uut.proc.registers[num] !== (value)) begin $display("ASSERTION FAILED in %m: reg[%h] = %h != %h"      , num, uut.proc.registers[num], (value)); $finish(2); end
`define assertRom(addr, value)     if (uut.rom.memory[addr % uut.rom.size] !== (value)) begin $display("ASSERTION FAILED in %m: reg[%h] = %h != %h", addr, uut.rom.memory[addr % uut.rom.size], (value)); $finish(2); end
`define assertRam(addr, value)     if (uut.ram.memory[addr % uut.ram.size] !== (value)) begin $display("ASSERTION FAILED in %m: reg[%h] = %h != %h", addr, uut.ram.memory[addr % uut.ram.size], (value)); $finish(2); end
`include "jump_conditions.vh"
`include "flags.vh"

task chk_1byteOp;
    input[7:0] op;
    begin
        repeat (2) @(negedge clk);
            `assertInstr(op);
            `assertState(STATE_DECODE);
    end
endtask

task chk_srp;
    input[3:0] upper;
    begin
        repeat (3) @(negedge clk);
            `assertInstr(8'h31);
            `assertSecond({upper, 4'h0});
            `assertState(STATE_DECODE);
        @(negedge clk);
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
        repeat (3) @(negedge clk);
            `assertInstr({dst, 4'h8});
            `assertSecond(src);
            `assertState(STATE_DECODE);
        @(negedge clk);
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
        repeat (3) @(negedge clk);
            `assertInstr({src, 4'h9});
            `assertSecond(dst);
            `assertState(STATE_DECODE);
        @(negedge clk);
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
        repeat (3) @(negedge clk);
            `assertInstr({dst, 4'hC});
            `assertSecond(value);
            `assertState(STATE_DECODE);
        @(negedge clk);
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
        repeat (3) @(negedge clk);
            `assertInstr(8'hE3);
            `assertSecond({dst, src});
            `assertState(STATE_DECODE);
        @(negedge clk);
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
        repeat (3) @(negedge clk);
            `assertInstr(8'hF3);
            `assertSecond({dst, src});
            `assertState(STATE_DECODE);
        @(negedge clk);
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
        repeat (5) @(negedge clk);
            `assertInstr('hE4);
            `assertSecond(src);
            `assertThird(dst);
            `assertState(STATE_DECODE);
        @(negedge clk);
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
        repeat (5) @(negedge clk);
            `assertInstr('hE5);
            `assertSecond(src);
            `assertThird(dst);
            `assertState(STATE_DECODE);
        @(negedge clk);
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
        repeat (5) @(negedge clk);
            `assertInstr('hE7);
            `assertSecond(dst);
            `assertThird(value);
            `assertState(STATE_DECODE);
        @(negedge clk);
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
        repeat (5) @(negedge clk);
            `assertInstr('hF5);
            `assertSecond(src);
            `assertThird(dst);
            `assertState(STATE_DECODE);
        @(negedge clk);
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
        repeat (5) @(negedge clk);
            `assertInstr(8'hE6);
            `assertSecond(dst);
            `assertThird(value);
            `assertState(STATE_DECODE);
        @(negedge clk);
            `assert(uut.proc.writeRegister, 1);
            `assert(uut.proc.writeFlags, 0);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
            if (dst == 8'hF8) begin
                `assert(uut.proc.p01m, value);
            end
            else begin
                if (dst == 8'hFF) begin
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
        repeat (5) @(negedge clk);
            `assertInstr(8'hC7);
            `assertSecond({dst, src});
            `assertThird(offset);
            `assertState(STATE_DECODE);
        @(negedge clk);
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
        repeat (5) @(negedge clk);
            `assertInstr(8'hD7);
            `assertSecond({src, dst});
            `assertThird(offset);
            `assertState(STATE_DECODE);
        @(negedge clk);
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
        repeat (5) @(negedge clk);
            `assertInstr({cc, 4'hD});
            `assertSecond(addr[15:8]);
            `assertThird(addr[7:0]);
            `assert(uut.proc.takeBranch, 1'b1);
            `assertState(STATE_DECODE);
        @(negedge clk);
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
        repeat (5) @(negedge clk);
            `assertInstr({cc, 4'hD});
            `assertSecond(addr[15:8]);
            `assertThird(addr[7:0]);
            `assert(uut.proc.takeBranch, 1'b0);
            `assertState(STATE_DECODE);
        @(negedge clk);
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
        repeat (3) @(negedge clk);
            `assertInstr({cc, 4'hB});
            `assertSecond(ra);
            `assert(uut.proc.takeBranch, 1'b1);
            `assertState(STATE_DECODE);
        @(negedge clk);
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
        repeat (3) @(negedge clk);
            `assertInstr({cc, 4'hB});
            `assertSecond(ra);
            `assert(uut.proc.takeBranch, 1'b0);
            `assertState(STATE_DECODE);
        @(negedge clk);
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
        repeat (3) @(negedge clk);
            `assertInstr({dst, 4'hA});
            `assertSecond(ra);
            `assertState(STATE_DECODE);
        @(negedge clk);
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
        repeat (3) @(negedge clk);
            `assertInstr({dst, 4'hA});
            `assertSecond(ra);
            `assertState(STATE_DECODE);
        @(negedge clk);
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
        repeat (3) @(negedge clk);
            `assertInstr(8'h80);
            `assertSecond(register);
            `assertState(STATE_DECODE);
        @(negedge clk);
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
        repeat (3) @(negedge clk);
            `assertInstr(8'hA0);
            `assertSecond(register);
            `assertState(STATE_DECODE);
        @(negedge clk);
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
        repeat (3) @(negedge clk);
            `assertInstr({op[3:0], 4'h0});
            `assertSecond(dst);
            `assertState(STATE_DECODE);
        @(negedge clk);
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
        repeat (3) @(negedge clk);
            `assertInstr({op[3:0], 4'h1});
            `assertSecond(dst);
            `assertState(STATE_DECODE);
        @(negedge clk);
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
        @(negedge clk);
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
        repeat (3) @(negedge clk);
            `assertInstr({op[3:0], 4'h2});
            `assertSecond({dst, src});
            `assertState(STATE_DECODE);
        @(negedge clk);
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
        repeat (3) @(negedge clk);
            `assertInstr({op[3:0], 4'h3});
            `assertSecond({dst, src});
            `assertState(STATE_DECODE);
        @(negedge clk);
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
        repeat (5) @(negedge clk);
            `assertInstr({op[3:0], 4'h4});
            `assertSecond(src);
            `assertThird(dst);
            `assertState(STATE_DECODE);
        @(negedge clk);
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
        repeat (5) @(negedge clk);
            `assertInstr({op[3:0], 4'h5});
            `assertSecond(src);
            `assertThird(dst);
            `assertState(STATE_DECODE);
        @(negedge clk);
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
        repeat (5) @(negedge clk);
            `assertInstr({op[3:0], 4'h6});
            `assertSecond(dst);
            `assertThird(value);
            `assertState(STATE_DECODE);
        @(negedge clk);
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
        repeat (5) @(negedge clk);
            `assertInstr({op[3:0], 4'h7});
            `assertSecond(dst);
            `assertThird(value);
            `assertState(STATE_DECODE);
        @(negedge clk);
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
        @(negedge clk);
            `assertState(STATE_FETCH_INSTR);
        @(negedge clk);
    end
endtask