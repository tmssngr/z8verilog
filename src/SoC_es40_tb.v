module testSoC_es40();

    reg clk = 0;

`include "assert.vh"
`include "alu.vh"
`include "states.vh"
`include "sfr.vh"
`include "check_commands.vh"

    wire sync;
    wire pixel;

    SoC_es40 uut(
        .clk(clk),
        .reset(1'b0),
        .videoSync(sync),
        .videoPixel(pixel)
    );

    always
        #1 clk = ~clk;

    initial begin
        #1000000
        $display("%m: SUCCESS");
        $finish(0);
    end

    initial begin
        $dumpfile("SoC.vcd");
        $dumpvars(0, uut);
    end
endmodule
