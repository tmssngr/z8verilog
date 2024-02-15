`default_nettype none

module top(
    input wire clk,
    output wire[5:0] leds
);
    wire clkOut_unused;
    wire clkDiv;
    Gowin_rPLL pll(
        .clkin(clk),
        .clkout(clkOut_unused),
        .clkoutd(clkDiv)
    );

    wire[7:0] port2;
    wire[3:0] port3;

    SoC soC(
        .clk(clkDiv),
        .port2(port2),
        .port3(port3)
    );

    assign leds[0] = ~port2[0];
    assign leds[1] = ~port2[1];
    assign leds[2] = ~port2[2];
    assign leds[3] = ~port2[3];
    assign leds[4] = ~port2[4];
    assign leds[5] = ~port2[5];

endmodule
