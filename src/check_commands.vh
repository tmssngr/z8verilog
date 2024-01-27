`define assertPc(value)            if (uut.proc.pc             !== value) begin $display("ASSERTION FAILED in %m: pc(%h) != value"         , uut.proc.pc                 ); $finish(2); end
`define assertState(value)         if (uut.proc.state          !== value) begin $display("ASSERTION FAILED in %m: state(%h) != value"      , uut.proc.state              ); $finish(2); end
`define assertInstr(value)         if (uut.proc.instruction    !== value) begin $display("ASSERTION FAILED in %m: instruction(%h) != value", uut.proc.instruction        ); $finish(2); end
`define assertSecond(value)        if (uut.proc.second         !== value) begin $display("ASSERTION FAILED in %m: second(%h) != %h"        , uut.proc.second, value      ); $finish(2); end
`define assertThird(value)         if (uut.proc.third          !== value) begin $display("ASSERTION FAILED in %m: third(%h) != value"      , uut.proc.third              ); $finish(2); end
`define assertFlags(value)         if (uut.proc.flags          !== value) begin $display("ASSERTION FAILED in %m: flags != value"          , uut.proc.flags              ); $finish(2); end
`define assertRegister(num, value) if (uut.proc.registers[num] !== (value)) begin $display("ASSERTION FAILED in %m: reg[%h] = %h != %h"      , num, uut.proc.registers[num], (value)); $finish(2); end
`define assertRom(addr, value)     if (uut.rom.memory[addr % uut.rom.size] !== (value)) begin $display("ASSERTION FAILED in %m: reg[%h] = %h != %h", addr, uut.rom.memory[addr % uut.rom.size], (value)); $finish(2); end
`define assertRam(addr, value)     if (uut.ram.memory[addr % uut.ram.size] !== (value)) begin $display("ASSERTION FAILED in %m: reg[%h] = %h != %h", addr, uut.ram.memory[addr % uut.ram.size], (value)); $finish(2); end

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
        @(negedge clk);
            `assertRegister(dst, value);
    end
endtask

task chk_jp;
    input[15:0] addr;
    begin
        repeat (5) @(negedge clk);
            `assertInstr(8'h8D);
            `assertSecond(addr[15:8]);
            `assertThird(addr[7:0]);
        repeat (1) @(negedge clk);
            `assertPc(addr);
    end
endtask