module testSoC_tiny4k();

    reg clk = 0;

`include "assert.vh"
`include "alu.vh"
`include "states.vh"
`include "sfr.vh"

task cpuStep;
    begin
        @(negedge clk);
    end
endtask


`include "check_commands.vh"

    wire sync;
    wire pixel;

    SoC_tiny4k uut(
        .clk(clk),
        .reset(1'b0),
        .videoSync(sync),
        .videoPixel(pixel)
    );

    always
        #1 clk = ~clk;

    initial begin
        `assert(uut.proc.autoReset, 1);
        cpuStep();
        `assert(uut.proc.autoReset, 0);
        `assertPc(16'h000C);
        chk_fetch();

`include "checks.vh"
        cpuStep();
        $display("%m: SUCCESS");
        $finish(0);
    end

    initial begin
        $dumpfile("SoC.vcd");
        $dumpvars(0, uut);
    end
endmodule
