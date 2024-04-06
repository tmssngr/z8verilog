`default_nettype none

`include "debouncer2.v"

module top(
    input  wire      clk,
    input  wire      btn,
    input  wire      rawPs2Clk,
    input  wire      rawPs2Data,
    input  wire      serialIn,
    output wire      serialOut,
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

    wire       ps2Clk;
    wire       ps2Data;
    Debouncer2 ps2debouncer(
        .clk(clk),
        .in1(rawPs2Clk),
        .in2(rawPs2Data),
        .out1(ps2Clk),
        .out2(ps2Data)
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
        .ps2Clk(ps2Clk),
        .ps2Data(ps2Data),
        .serialIn(serialIn),
        .serialOut(serialOut),
        .videoSync(sync),
        .videoPixel(pixel)
    );

    assign leds[5] = port2[5];
    assign leds[4] = port2[4];
    assign leds[3] = port2[3];
    assign leds[2] = port2[2];
    assign leds[1] = port2[1];
    assign leds[0] = port2[0];

    assign videoSync = sync;
    assign videoPixel = pixel;
endmodule
