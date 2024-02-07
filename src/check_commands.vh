`define assertPc(value)            if (uut.proc.pc             !== (value)) begin $display("ASSERTION FAILED in %m: pc(%h) != %h"            , uut.proc.pc, (value)        ); $finish(2); end
`define assertFetchState(value)    if (uut.proc.fetchState     !== (value)) begin $display("ASSERTION FAILED in %m: fetchState(%h) != value" , uut.proc.fetchState         ); $finish(2); end
`define assertOpState(value)       if (uut.proc.opState        !== (value)) begin $display("ASSERTION FAILED in %m: opState(%h) != value"    , uut.proc.opState            ); $finish(2); end
`define assertOpType(value)        if (uut.proc.opType         !== (value)) begin $display("ASSERTION FAILED in %m: opType(%h) != value(%h)" , uut.proc.opType, (value)    ); $finish(2); end
`define assertInstr(value)         if (uut.proc.instruction    !== (value)) begin $display("ASSERTION FAILED in %m: instr(%h) != %h"         , uut.proc.instruction, (value)); $finish(2); end
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
            `assertFetchState(FETCH_DECODE);
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
            `assertFetchState(FETCH_DECODE);
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
            `assertFetchState(FETCH_DECODE);
        @(negedge clk);
    end
endtask
task assertCommandFinished;
    begin
        `assertFetchState(FETCH_INSTR_WAIT);
    end
endtask

task assertRegister;
    input[7:0] register;
    input[7:0] value;
    begin
        if (register == P01M) begin
            `assert(uut.proc.p01m, value);
        end
        else if (register == P3M) begin
            `assert(uut.proc.p3m, value);
        end
        else if (register == SPH) begin
            `assert(uut.proc.sp[15:8], value);
        end
        else if (register == SPL) begin
            `assert(uut.proc.sp[7:0], value);
        end
        else begin
            `assertRegister(register, value);
        end
    end
endtask

task chk_srp;
    input[3:0] upper;
    begin
        chk_2byteOp(8'h31, {upper, 4'h0});
            `assertOpType(OP_LD);
        @(negedge clk);
            assertCommandFinished();
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
            assertCommandFinished();
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
            assertCommandFinished();
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
            `assertOpType(OP_LD);
        @(negedge clk);
            `assert(uut.proc.register, register);
            assertCommandFinished();
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
            `assertOpType(OP_LD);
        @(negedge clk);
            `assert(uut.proc.aluA, value);
            `assert(uut.proc.register, register);
            assertCommandFinished();
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
            `assertOpType(OP_LD);
        @(negedge clk);
            `assert(uut.proc.aluA, value);
            assertCommandFinished();
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
            `assertOpType(OP_LD);
        @(negedge clk);
            `assert(uut.proc.aluA, value);
            `assert(uut.proc.register, register);
            assertCommandFinished();
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
            `assertOpType(OP_LD);
        @(negedge clk);
            `assert(uut.proc.aluA, value);
            `assert(uut.proc.aluMode, ALU1_LD);
            `assert(uut.proc.register, register);
            `assert(uut.proc.writeRegister, 1);
            assertCommandFinished();
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
            `assertOpType(OP_LD);
        @(negedge clk);
            `assert(uut.proc.aluA, value);
            `assert(uut.proc.aluMode, ALU1_LD);
            `assert(uut.proc.register, register);
            `assert(uut.proc.writeRegister, 1);
            assertCommandFinished();
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
            `assertOpType(OP_LD);
        @(negedge clk);
            `assert(uut.proc.aluMode, ALU1_LD);
            `assert(uut.proc.register, register);
            `assert(uut.proc.writeRegister, 1);
            assertCommandFinished();
        @(negedge clk);
            `assertRegister(register, value);
    end
endtask
task chk_ld_R_IM;
    input[7:0] dst;
    input[7:0] value;
    begin
        chk_3byteOp(8'hE6, dst, value);
            `assertOpType(OP_LD);
        @(negedge clk);
            `assert(uut.proc.writeRegister, 1);
            `assert(uut.proc.writeFlags, 0);
            assertCommandFinished();
        @(negedge clk);
            assertRegister(dst, value);
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
            `assertOpType(OP_LD);
        @(negedge clk);
            `assert(uut.proc.register, register);
            `assert(uut.proc.aluA, value);
            `assert(uut.proc.writeRegister, 1);
            assertCommandFinished();
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
            `assertOpType(OP_LD);
        @(negedge clk);
            `assert(uut.proc.register, register);
            `assert(uut.proc.aluA, value);
            `assert(uut.proc.writeRegister, 1);
            assertCommandFinished();
        @(negedge clk);
            `assertRegister(register, value);
    end
endtask

task chk_ldc_r_Irr;
    input [3:0] dst;
    input [3:0] src;
    input [7:0] register;
    input[15:0] addr;
    input [7:0] value;
    begin
        chk_2byteOp(8'hC2, {dst, src});
            `assert(uut.proc.register, register);
            `assertOpType(OP_LDC);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assert(uut.proc.register, register);
            `assert(uut.proc.addr[15:8], addr[15:8]);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            `assert(uut.proc.register, register);
            `assert(uut.proc.addr, addr);
            `assertOpState(OPSTATE2);
        @(negedge clk);
            `assert(uut.proc.register, register);
            `assert(uut.proc.addr, addr);
            `assertOpState(OPSTATE3);
        @(negedge clk);
            `assert(uut.proc.aluA, value);
            `assert(uut.proc.aluMode, ALU1_LD);
            `assert(uut.proc.writeRegister, 1);
            assertCommandFinished();
        @(negedge clk);
            `assertRegister(register, value);
    end
endtask
task chk_ldc_Irr_r;
    input [3:0] dst;
    input [3:0] src;
    input [7:0] register;
    input[15:0] addr;
    input [7:0] value;
    begin
        chk_2byteOp(8'hD2, {src, dst});
            `assert(uut.proc.register, register);
            `assertOpType(OP_LDC);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assert(uut.proc.register, register);
            `assert(uut.proc.addr[15:8], addr[15:8]);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            `assert(uut.proc.register, register);
            `assert(uut.proc.addr, addr);
            `assertOpState(OPSTATE2);
        @(negedge clk);
            `assert(uut.proc.register, register);
            `assert(uut.proc.aluA, value);
            `assert(uut.proc.addr, addr);
            `assertOpState(OPSTATE3);
        @(negedge clk);
            assertCommandFinished();
        @(negedge clk);
    end
endtask
task chk_ldci_Ir_Irr;
    input [3:0] dst;
    input [3:0] src;
    input [7:0] dstReg;
    input [7:0] srcRegs;
    input [7:0] target;
    input[15:0] addr;
    input [7:0] value;
    input[15:0] addrPlus1;
    begin
        chk_2byteOp(8'hC3, {dst, src});
            `assert(uut.proc.register, target);
            `assertOpType(OP_LDC);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assert(uut.proc.addr[15:8], addr[15:8]);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            `assert(uut.proc.addr, addr);
            `assertOpState(OPSTATE2);
        @(negedge clk);
            `assertOpState(OPSTATE3);
        @(negedge clk);
            `assert(uut.proc.aluA, value);
            `assert(uut.proc.aluMode, ALU1_LD);
            `assert(uut.proc.writeRegister, 1);
            `assertOpState(OPSTATE4);
        @(negedge clk);
            `assertRegister(target, value);

            `assert(uut.proc.aluA, target);
            `assert(uut.proc.register, dstReg);
            `assert(uut.proc.aluMode, ALU1_INC);
            `assert(uut.proc.writeRegister, 1);
            `assertOpState(OPSTATE5);
        @(negedge clk);
            `assertRegister(dstReg, target + 1);

            `assert(uut.proc.aluA, addr[7:0]);
            `assert(uut.proc.register, srcRegs | 1);
            `assert(uut.proc.aluMode, ALU1_INC);
            `assert(uut.proc.writeRegister, 1);
            `assertOpState(OPSTATE6);
        @(negedge clk);
            `assertRegister(srcRegs | 1, addrPlus1[7:0]);

            `assert(uut.proc.aluA, addr[15:8]);
            `assert(uut.proc.register, srcRegs & ~1);
            `assert(uut.proc.aluMode, ALU1_INCW);
            `assert(uut.proc.writeRegister, 1);
            assertCommandFinished();
        @(negedge clk);
            `assertRegister(srcRegs & ~1, addrPlus1[15:8]);
    end
endtask
task chk_ldci_Irr_Ir;
    input [3:0] dst;
    input [3:0] src;
    input [7:0] dstRegs;
    input [7:0] srcReg;
    input [7:0] source;
    input[15:0] addr;
    input [7:0] value;
    input[15:0] addrPlus1;
    begin
        chk_2byteOp(8'hD3, {src, dst});
            `assert(uut.proc.register, source);
            `assertOpType(OP_LDC);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assert(uut.proc.addr[15:8], addr[15:8]);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            `assert(uut.proc.addr, addr);
            `assertOpState(OPSTATE2);
        @(negedge clk);
            `assertOpState(OPSTATE3);
        @(negedge clk);
            `assertOpState(OPSTATE4);
        @(negedge clk);
            `assertRegister(source, value);

            `assert(uut.proc.aluA, source);
            `assert(uut.proc.register, srcReg);
            `assert(uut.proc.aluMode, ALU1_INC);
            `assert(uut.proc.writeRegister, 1);
            `assertOpState(OPSTATE5);
        @(negedge clk);
            `assertRegister(srcReg, source + 1);

            `assert(uut.proc.aluA, addr[7:0]);
            `assert(uut.proc.register, dstRegs | 1);
            `assert(uut.proc.aluMode, ALU1_INC);
            `assert(uut.proc.writeRegister, 1);
            `assertOpState(OPSTATE6);
        @(negedge clk);
            `assertRegister(dstRegs | 1, addrPlus1[7:0]);

            `assert(uut.proc.aluA, addr[15:8]);
            `assert(uut.proc.register, dstRegs & ~1);
            `assert(uut.proc.aluMode, ALU1_INCW);
            `assert(uut.proc.writeRegister, 1);
            assertCommandFinished();
        @(negedge clk);
            `assertRegister(dstRegs & ~1, addrPlus1[15:8]);
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
            `assertOpType(OP_JP);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            `assertOpState(OPSTATE2);
        @(negedge clk);
            `assertPc(addr);
            assertCommandFinished();
        @(negedge clk);
    end
endtask
task chk_jp_false;
	input[3:0] cc;
    input[15:0] addr;
    begin
        chk_3byteOp({cc, 4'hD}, addr[15:8], addr[7:0]);
            `assert(uut.proc.takeBranch, 1'b0);
            assertCommandFinished();
        @(negedge clk);
    end
endtask
task chk_jp_IRR;
	input[7:0] src;
    input[15:0] addr;
    begin
        chk_2byteOp(8'h30, src);
            `assertOpType(OP_JP);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assert(uut.proc.addr[15:8], addr[15:8]);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            `assert(uut.proc.addr, addr);
            `assertOpState(OPSTATE2);
        @(negedge clk);
            `assertPc(addr);
            assertCommandFinished();
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
            assertCommandFinished();
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
            assertCommandFinished();
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
            `assert(uut.proc.register, register);
            `assertOpType(OP_DJNZ);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assert(uut.proc.aluMode, ALU1_DEC);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            `assertOpState(OPSTATE2);
        @(negedge clk);
            assertCommandFinished();
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
            `assert(uut.proc.register, register);
            `assertOpType(OP_DJNZ);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assert(uut.proc.aluMode, ALU1_DEC);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            assertCommandFinished();
            `assertRegister(register, 8'h0);
            `assertPc(addr);
        @(negedge clk);
    end
endtask

task _chk_decw;
    input [7:0] register;
    input[15:0] expValue;
    input [7:0] expFlags;
    begin
            `assertOpType(OP_ALU1WORD);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assert(uut.proc.aluMode, ALU1_DEC);
            `assert(uut.proc.register, register);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            // lower byte:
            `assert(uut.proc.register, register | 1);
            `assertOpState(OPSTATE2);
        @(negedge clk);
            `assert(uut.proc.aluMode, ALU1_DEC);
            `assert(uut.proc.writeRegister, 1);
            `assert(uut.proc.writeFlags, 0);
            `assertOpState(OPSTATE3);
        @(negedge clk);
            `assertRegister(register | 1, expValue[7:0]);
            `assertOpState(OPSTATE4);
        @(negedge clk);
            // upper byte:
            `assert(uut.proc.aluMode, ALU1_DECW);
            `assert(uut.proc.register, register & ~1);
            `assert(uut.proc.writeRegister, 1);
            `assert(uut.proc.writeFlags, 1);
            assertCommandFinished();
        @(negedge clk);
            `assertRegister(register & ~1, expValue[15:8]);
            `assertFlags(expFlags);
    end
endtask
task chk_decw;
    input [7:0] dst;
    input [7:0] register;
    input[15:0] expValue;
    input [7:0] expFlags;
    begin
        chk_2byteOp(8'h80, dst);
        _chk_decw(register, expValue, expFlags);
    end
endtask
task chk_decw_IR;
    input [7:0] dst;
    input [7:0] register;
    input[15:0] expValue;
    input [7:0] expFlags;
    begin
        chk_2byteOp(8'h81, dst);
        _chk_decw(register, expValue, expFlags);
    end
endtask
task _chk_incw;
    input [7:0] register;
    input[15:0] expValue;
    input [7:0] expFlags;
    begin
            `assertOpType(OP_ALU1WORD);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assert(uut.proc.aluMode, ALU1_INC);
            `assert(uut.proc.register, register);
            `assertOpState(OPSTATE1);
            // lower byte:
        @(negedge clk);
            `assert(uut.proc.register, register | 1);
            `assertOpState(OPSTATE2);
        @(negedge clk);
            `assert(uut.proc.aluMode, ALU1_INC);
            `assert(uut.proc.writeRegister, 1);
            `assert(uut.proc.writeFlags, 0);
            `assertOpState(OPSTATE3);
        @(negedge clk);
            `assertRegister(register | 1, expValue[7:0]);
            `assertOpState(OPSTATE4);
        @(negedge clk);
            // upper byte:
            `assert(uut.proc.aluMode, ALU1_INCW);
            `assert(uut.proc.register, register & ~1);
            `assert(uut.proc.writeRegister, 1);
            `assert(uut.proc.writeFlags, 1);
            assertCommandFinished();
        @(negedge clk);
            `assertRegister(register & ~1, expValue[15:8]);
            `assertFlags(expFlags);
    end
endtask
task chk_incw;
    input [7:0] dst;
    input [7:0] register;
    input[15:0] expValue;
    input [7:0] expFlags;
    begin
        chk_2byteOp(8'hA0, register);
        _chk_incw(register, expValue, expFlags);
    end
endtask
task chk_incw_IR;
    input [7:0] dst;
    input [7:0] register;
    input[15:0] expValue;
    input [7:0] expFlags;
    begin
        chk_2byteOp(8'hA1, dst);
        _chk_incw(register, expValue, expFlags);
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
            `assertOpType(OP_ALU1);
            `assert(uut.proc.register, register);
        @(negedge clk);
            assertCommandFinished();
        @(negedge clk);
            assertRegister(register, value);
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
            `assertOpType(OP_ALU1);
            `assert(uut.proc.register, register);
        @(negedge clk);
            assertCommandFinished();
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
            `assertOpType(OP_ALU1);
            `assert(uut.proc.register, register);
        @(negedge clk);
            assertCommandFinished();
        @(negedge clk);
            `assertRegister(register, value);
            `assertFlags(flags);
    end
endtask
task chk_da;
    input[7:0] dst;
    input[7:0] register;
    input[7:0] value;
    input[7:0] flags;
    begin
        chk_2byteOp(8'h40, dst);
            `assert(uut.proc.aluMode, ALU1_DA);
            `assert(uut.proc.register, register);
            `assertOpType(OP_ALU1);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assert(uut.proc.aluMode, ALU1_DA);
            `assert(uut.proc.register, register);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            `assert(uut.proc.aluMode, ALU1_DA_H);
            `assert(uut.proc.writeRegister, 1);
            `assert(uut.proc.writeFlags, 1);
            `assert(uut.proc.register, register);
            assertCommandFinished();
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
            `assertOpType(OP_ALU2);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            `assertOpState(OPSTATE2);
        @(negedge clk);
            assertCommandFinished();
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
            `assertOpType(OP_ALU2);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            `assertOpState(OPSTATE2);
        @(negedge clk);
            assertCommandFinished();
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
            `assertOpType(OP_ALU2);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            `assertOpState(OPSTATE2);
        @(negedge clk);
            assertCommandFinished();
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
            `assertOpType(OP_ALU2);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            `assertOpState(OPSTATE2);
        @(negedge clk);
            assertCommandFinished();
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
            `assertOpType(OP_ALU2);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assert(uut.proc.aluB, value);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            `assertOpState(OPSTATE2);
        @(negedge clk);
            assertCommandFinished();
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
            `assertOpType(OP_ALU2);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assert(uut.proc.aluB, value);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            `assertOpState(OPSTATE2);
        @(negedge clk);
            assertCommandFinished();
        @(negedge clk);
            `assertRegister({expDst}, {expResult});
            `assertFlags({expFlags});
    end
endtask

task chk_nop;
    begin
        chk_1byteOp(8'hFF);
            assertCommandFinished();
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
            `assertOpType(OP_POP);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            `assertOpState(OPSTATE2);
        @(negedge clk);
            `assert(uut.proc.aluA, value);
            `assertOpState(OPSTATE3);
        @(negedge clk);
            `assert(uut.proc.aluMode, ALU1_LD);
            `assert(uut.proc.sp, sp);
            `assert(uut.proc.register, register);
            `assert(uut.proc.writeRegister, 1);
            assertCommandFinished();
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
            `assertOpType(OP_POP);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assert(uut.proc.addr, sp - 1);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            `assertOpState(OPSTATE2);
        @(negedge clk);
            `assert(uut.proc.aluA, value);
            `assertOpState(OPSTATE3);
        @(negedge clk);
            `assert(uut.proc.aluMode, ALU1_LD);
            `assert(uut.proc.sp, sp);
            `assert(uut.proc.register, register);
            `assert(uut.proc.writeRegister, 1);
            assertCommandFinished();
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
            `assertOpType(OP_PUSH_I);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            assertCommandFinished();
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
            `assertOpType(OP_PUSH_E);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            `assertOpState(OPSTATE2);
        @(negedge clk);
            assertCommandFinished();
        @(negedge clk);
            `assert(uut.proc.sp, sp);
            `assertRam(sp, value);
    end
endtask
task chk_push_IRR_intern;
    input [7:0] src;
    input [7:0] register;
    input [7:0] value;
    input [7:0] sp;
    begin
        chk_2byteOp(8'h71, src);
            `assert(uut.proc.register, register);
            `assertOpType(OP_PUSH_I);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            assertCommandFinished();
        @(negedge clk);
            `assert(uut.proc.sp, sp);
            `assertRegister(sp, value);
    end
endtask

task chk_call_intern;
    input[15:0] addr;
    input[15:0] pc;
    input[7:0]  sp;
    begin
        chk_3byteOp(8'hD6, addr[15:8], addr[7:0]);
            `assert(uut.proc.sp, sp + 16'h2);
            `assertOpType(OP_CALL);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assert(uut.proc.sp, sp + 1);
            `assert(uut.proc.aluA, pc[7:0]);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            `assert(uut.proc.aluMode, ALU1_LD);
            `assert(uut.proc.register, sp + 1);
            `assert(uut.proc.writeRegister, 1);
            `assertOpState(OPSTATE2);
        @(negedge clk);
            `assertRegister(sp + 1, pc[7:0]);

            `assert(uut.proc.sp, sp);
            `assert(uut.proc.aluA, pc[15:8]);
            `assertOpState(OPSTATE3);
        @(negedge clk);
            `assert(uut.proc.aluMode, ALU1_LD);
            `assert(uut.proc.register, sp);
            `assert(uut.proc.writeRegister, 1);
            `assertOpState(OPSTATE4);
        @(negedge clk);
            `assertRegister(sp, pc[15:8]);

            `assert(uut.proc.addr[15:8], addr[15:8]);
            `assertOpState(OPSTATE5);
        @(negedge clk);
            `assert(uut.proc.addr[7:0], addr[7:0]);
            `assertOpState(OPSTATE6);
        @(negedge clk);
            `assertPc(addr);

            assertCommandFinished();
        @(negedge clk);
    end
endtask
task chk_call_extern;
    input[15:0] addr;
    input[15:0] pc;
    input[15:0] sp;
    begin
        chk_3byteOp(8'hD6, addr[15:8], addr[7:0]);
            `assert(uut.proc.sp, sp + 16'h2);
            `assertOpType(OP_CALL);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assert(uut.proc.sp, sp + 1);
            `assert(uut.proc.aluA, pc[7:0]);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            `assert(uut.proc.addr, sp + 1);
            `assert(uut.proc.writeMem, 1);
            `assertOpState(OPSTATE2);
        @(negedge clk);
            `assertRam(sp+1, pc[7:0]);

            `assert(uut.proc.sp, sp);
            `assert(uut.proc.aluA, pc[15:8]);
            `assertOpState(OPSTATE3);
        @(negedge clk);
            `assert(uut.proc.addr, sp);
            `assert(uut.proc.writeMem, 1);
            `assertOpState(OPSTATE4);
        @(negedge clk);
            `assertRam(sp, pc[15:8]);

            `assert(uut.proc.addr[15:8], addr[15:8]);
            `assertOpState(OPSTATE5);
        @(negedge clk);
            `assert(uut.proc.addr[7:0], addr[7:0]);
            `assertOpState(OPSTATE6);
        @(negedge clk);
            `assertPc(addr);

            assertCommandFinished();
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
            `assert(uut.proc.sp, sp + 16'h2);
            `assertOpType(OP_CALL);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assert(uut.proc.sp, sp + 1);
            `assert(uut.proc.aluA, pc[7:0]);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            `assert(uut.proc.aluMode, ALU1_LD);
            `assert(uut.proc.register, sp + 1);
            `assert(uut.proc.writeRegister, 1);
            `assertOpState(OPSTATE2);
        @(negedge clk);
            `assertRegister(sp + 1, pc[7:0]);

            `assert(uut.proc.sp, sp);
            `assert(uut.proc.aluA, pc[15:8]);
            `assertOpState(OPSTATE3);
        @(negedge clk);
            `assert(uut.proc.aluMode, ALU1_LD);
            `assert(uut.proc.register, sp);
            `assert(uut.proc.writeRegister, 1);
            `assertOpState(OPSTATE4);
        @(negedge clk);
            `assertRegister(sp, pc[15:8]);

            `assert(uut.proc.addr[15:8], addr[15:8]);
            `assertOpState(OPSTATE5);
        @(negedge clk);
            `assert(uut.proc.addr[7:0], addr[7:0]);
            `assertOpState(OPSTATE6);
        @(negedge clk);
            `assertPc(addr);

            assertCommandFinished();
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
            `assert(uut.proc.sp, sp + 16'h2);
            `assertOpType(OP_CALL);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assert(uut.proc.sp, sp + 1);
            `assert(uut.proc.aluA, pc[7:0]);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            `assert(uut.proc.addr, sp + 1);
            `assert(uut.proc.writeMem, 1);
            `assertOpState(OPSTATE2);
        @(negedge clk);
            `assertRam(sp + 1, pc[7:0]);

            `assert(uut.proc.sp, sp);
            `assert(uut.proc.aluA, pc[15:8]);
            `assertOpState(OPSTATE3);
        @(negedge clk);
            `assert(uut.proc.addr, sp);
            `assert(uut.proc.writeMem, 1);
            `assertOpState(OPSTATE4);
        @(negedge clk);
            `assertRam(sp, pc[15:8]);

            `assert(uut.proc.addr[15:8], addr[15:8]);
            `assertOpState(OPSTATE5);
        @(negedge clk);
            `assert(uut.proc.addr[7:0], addr[7:0]);
            `assertOpState(OPSTATE6);
        @(negedge clk);
            `assertPc(addr);

            assertCommandFinished();
        @(negedge clk);
    end
endtask

task chk_ret_intern;
    input [15:0] pc;
    input  [7:0] sp;
    begin
        chk_1byteOp(8'hAF);
            `assert(uut.proc.sp, sp - 2);
            `assertOpType(OP_RET);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assert(uut.proc.addr, sp - 2);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            `assert(uut.proc.sp, sp - 1);
            `assertOpState(OPSTATE2);
        @(negedge clk);
            `assert(uut.proc.aluA, pc[15:8]);
            `assert(uut.proc.addr, sp - 1);
            `assertOpState(OPSTATE3);
        @(negedge clk);
            `assert(uut.proc.sp, sp);
            `assertOpState(OPSTATE4);
        @(negedge clk);
            `assert(uut.proc.addr, pc);
            `assertOpState(OPSTATE5);
        @(negedge clk);
            assertCommandFinished();
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
            `assertOpType(OP_RET);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            `assert(uut.proc.addr, sp - 16'h2);
            `assert(uut.proc.sp, sp - 16'h1);
            `assertOpState(OPSTATE2);
        @(negedge clk);
            `assertOpState(OPSTATE3);
        @(negedge clk);
            `assert(uut.proc.aluA, pc[15:8]);
            `assert(uut.proc.addr, sp - 16'h1);
            `assert(uut.proc.sp, sp);
            `assertOpState(OPSTATE4);
        @(negedge clk);
            `assert(uut.proc.addr, pc);
            `assertOpState(OPSTATE5);
        @(negedge clk);
            assertCommandFinished();
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
            `assert(uut.proc.sp, sp - 3);
            `assertOpType(OP_IRET);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assert(uut.proc.addr, sp - 3);
            `assert(uut.proc.sp, sp - 2);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            `assert(uut.proc.aluMode, ALU1_LD);
            `assert(uut.proc.aluA, flags);
            `assert(uut.proc.register, 'hFC);
            `assert(uut.proc.writeRegister, 1);
            `assertOpType(OP_RET);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assertFlags(flags);

            `assert(uut.proc.addr, sp - 2);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            `assert(uut.proc.sp, sp - 1);
            `assertOpState(OPSTATE2);
        @(negedge clk);
            `assert(uut.proc.aluA, pc[15:8]);
            `assert(uut.proc.addr, sp - 1);
            `assertOpState(OPSTATE3);
        @(negedge clk);
            `assert(uut.proc.sp, sp);
            `assertOpState(OPSTATE4);
        @(negedge clk);
            `assert(uut.proc.addr, pc);
            `assertOpState(OPSTATE5);
        @(negedge clk);
            assertCommandFinished();
            `assertPc(pc);
    end
endtask
task chk_iret_extern;
    input [15:0] pc;
    input [15:0] sp;
    input  [7:0] flags;
    begin
        chk_1byteOp(8'hBF);
            `assert(uut.proc.sp, sp - 16'h3);
            `assertOpType(OP_IRET);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assert(uut.proc.addr, sp - 16'h3);
            `assert(uut.proc.sp, sp - 16'h2);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            `assert(uut.proc.aluMode, ALU1_LD);
            `assert(uut.proc.aluA, flags);
            `assert(uut.proc.register, 'hFC);
            `assert(uut.proc.writeRegister, 1);
            `assertOpType(OP_RET);
            `assertOpState(OPSTATE0);
        @(negedge clk);
            `assertFlags(flags);
            `assert(uut.proc.addr, sp - 16'h2);
            `assertOpState(OPSTATE1);
        @(negedge clk);
            `assert(uut.proc.sp, sp - 16'h1);
            `assertOpState(OPSTATE2);
        @(negedge clk);
            `assert(uut.proc.aluA, pc[15:8]);
            `assert(uut.proc.addr, sp - 16'h1);
            `assertOpState(OPSTATE3);
        @(negedge clk);
            `assert(uut.proc.sp, sp);
            `assertOpState(OPSTATE4);
        @(negedge clk);
            `assert(uut.proc.addr, pc);
            `assertOpState(OPSTATE5);
        @(negedge clk);
            `assertPc(pc);
            assertCommandFinished();
    end
endtask

task chk_rcf;
    begin
        chk_1byteOp(8'hCF);
            assertCommandFinished();
            `assert(uut.proc.flags[FLAG_INDEX_C], 1'b0);
        @(negedge clk);
    end
endtask

task chk_scf;
    begin
        chk_1byteOp(8'hDF);
            assertCommandFinished();
            `assert(uut.proc.flags[FLAG_INDEX_C], 1'b1);
        @(negedge clk);
    end
endtask

task chk_ccf;
    input carry;
    begin
        chk_1byteOp(8'hEF);
            assertCommandFinished();
            `assert(uut.proc.flags[FLAG_INDEX_C], carry);
        @(negedge clk);
    end
endtask
