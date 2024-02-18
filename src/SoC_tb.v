module testSoC();

`include "assert.vh"
`include "alu.vh"
`include "states.vh"
`include "sfr.vh"
`include "check_commands.vh"

    reg clk = 0;
    wire sync;
    wire pixel;

    SoC uut(
        .clk(clk),
        .reset(1'b0),
        .videoSync(sync),
        .videoPixel(pixel)
    );

    always
        #1 clk = ~clk;

    initial begin
        `assert(uut.proc.autoReset, 1);
        @(negedge clk);
        `assert(uut.proc.autoReset, 0);
        `assertPc(16'h000C);
        chk_fetch();

`include "checks.vh"
        @(negedge clk);
        $display("%m: SUCCESS");
        $finish(0);
    end

    initial begin
        $dumpfile("SoC.vcd");
        $dumpvars(0, uut);
    end
endmodule
