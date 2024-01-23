module testAlu();

`include "assert.vh"
`include "alu.vh"
`define assertOut(value)     if (out      !== value) begin $display("ASSERTION FAILED in %m: out(%h) != value"  , out     ); $finish(2); end
`define assertFlags(value)   if (outFlags !== value) begin $display("ASSERTION FAILED in %m: flags(%b) != value", outFlags); $finish(2); end

    reg clk = 0;
    reg [4:0] mode;
    reg [7:0] a, b, flags;
    wire [7:0] out, outFlags;

    Alu uut(
        .mode(mode),
        .a(a),
        .b(b),
        .flags(flags),
        .out(out),
        .outFlags(outFlags)
    );

    always
        #1 clk = ~clk;

    initial begin
        flags <= 0;
        mode <= ALU2_ADD;
        a <= 'h15;
        b <= 'h27;
        @(negedge clk);
        `assertOut('h3c);
        `assertFlags(8'b0000_0000);

        mode <= ALU1_DA;
        a <= out;
        flags <= outFlags;
        @(negedge clk);
        `assertOut('h42);
        `assertFlags(8'b0000_0000);
        mode <= ALU1_DA_H;
        a <= out;
        flags <= outFlags;
        @(negedge clk);
        `assertOut('h42);
        `assertFlags(8'b0000_0000);

        mode <= ALU2_SUB;
        a <= 'h15;
        b <= 'h27;
        @(negedge clk);
        `assertOut('hEE);
        // c_sv dh__
        `assertFlags(8'b1011_1100);

        mode <= ALU1_DA;
        a <= out;
        flags <= outFlags;
        @(negedge clk);
        `assertOut('hE8);
        `assertFlags(8'b1011_1100);
        mode <= ALU1_DA_H;
        a <= out;
        flags <= outFlags;
        @(negedge clk);
        `assertOut('h88);
        `assertFlags(8'b1011_1100);

        $display("%m: SUCCESS");
        $finish(0);
    end

    initial begin
        $dumpfile("Alu.vcd");
        $dumpvars(0, uut);
    end
endmodule
