`default_nettype none

module top(
    input  wire      clk,
    input  wire      btn,
    output wire[5:0] leds,
    output wire      videoSync,
    output wire      videoPixel
);
    wire clkOut_unused;
    wire clkDiv;
    Gowin_rPLL pll(
        .clkin(clk),
        .clkout(clkOut_unused),
        .clkoutd(clkDiv)
    );

    wire [7:0] port2;
    wire [3:0] port3;
    wire [15:0] addr;
    wire sync;
    wire pixel;

    SoC soC(
        .clk(clkDiv),
        .reset(~btn),
        .addr(addr),
        .port2(port2),
        .port3(port3),
        .videoSync(sync),
        .videoPixel(pixel)
    );

    assign leds[5] = addr[15];
    assign leds[4] = addr[4];
    assign leds[3] = addr[3];
    assign leds[2] = addr[2];
    assign leds[1] = addr[1];
    assign leds[0] = addr[0];

    assign videoSync = sync;
    assign videoPixel = pixel;
endmodule
