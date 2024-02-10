module testSoC();

`include "assert.vh"
`include "alu.vh"
`include "states.vh"
`include "sfr.vh"
`include "check_commands.vh"

    reg clk = 0;

    SoC uut(
        .clk(clk)
    );

    always
        #1 clk = ~clk;

    initial begin
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
