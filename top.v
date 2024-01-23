module top(
    input wire clk,
    output wire[5:0] leds
);

    SoC soC(
        .clk(clk)
    );

endmodule