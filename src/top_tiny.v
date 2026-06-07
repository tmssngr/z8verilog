`default_nettype none

`include "Debouncer.v"

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
    Gowin_rPLL_4MHz pll(
        .clkin(clk),
        .clkout(clkOut_unused),
        .clkoutd(clkDiv)
    );

    wire serialInData;
    Debouncer #(
        .counterBits(4)
    ) serialInDebouncer(
        .clk(clk),
        .in(serialIn),
        .out(serialInData)
    );

    wire [7:0] port2;
    wire [3:0] port3;
    wire [15:0] addr;
    wire sync;
    wire pixel;

    wire      debugShift;
    wire      debugCtrl;
    wire      debugAlt;
    wire      debugE0;
    wire      debugF0;

    SoC_tiny soC(
        .clk(clkDiv),
        .reset(~btn),
        .addr(addr),
        .port2(port2),
        .port3(port3),
        .rawPs2Clk(rawPs2Clk),
        .rawPs2Data(rawPs2Data),
        .serialIn(serialInData),
        .serialOut(serialOut),

        .debugShift(debugShift),
        .debugCtrl(debugCtrl),
        .debugAlt(debugAlt),
        .debugE0(debugE0),
        .debugF0(debugF0),

        .videoSync(sync),
        .videoPixel(pixel)
    );

    assign leds[5] = rawPs2Data;//port2[5];
    assign leds[4] = rawPs2Clk;//port2[4];
    /*
    assign leds[3] = ~debugShift;
    assign leds[2] = ~debugCtrl;
    assign leds[1] = ~debugAlt;
    */
    assign leds[3] = ~port2[3];
    assign leds[2] = ~port2[2];
    assign leds[1] = ~port2[1];
    assign leds[0] = ~port2[0];

    assign videoSync = sync;
    assign videoPixel = pixel;
endmodule
