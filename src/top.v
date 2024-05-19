`default_nettype none

`include "debouncer.v"

module top(
    input  wire       clk,
    input  wire       btn,
    input  wire       rawPs2Clk,
    input  wire       rawPs2Data,
    input  wire       serialIn,
    output wire       serialOut,
    output wire [5:0] leds,
    output wire [3:0] hdmi_tx_n,
    output wire [3:0] hdmi_tx_p
);
    wire clkOut_unused;
    wire clkDiv;
    Gowin_rPLL pll(
        .clkin(clk),
        .clkout(clkOut_unused),
        .clkoutd(clkDiv)
    );

    wire hdmi_clk;
    wire hdmi_clk_5x;
    wire hdmi_clk_lock;

    rPLL #(
        .FCLKIN("27"),
        .FBDIV_SEL(13), .IDIV_SEL(2), .ODIV_SEL(4) // 126.00 MHz:   640x480@60Hz @  25.20 MHz pixel clock: does not lose video sync, but produces (infrequent) single pixel flickering color glitches
//        .FBDIV_SEL(36), .IDIV_SEL(4), .ODIV_SEL(4) // 199.80 MHz:   800x600@60Hz @  39.96 MHz pixel clock: does not lose video sync, but produces (moderate) single pixel flickering color glitches
//        .FBDIV_SEL(7),  .IDIV_SEL(0), .ODIV_SEL(2) // 216.00 MHz:   768x576@73Hz @  43.20 MHz pixel clock: does not lose video sync, no(!) observed single pixel flickering
//        .FBDIV_SEL(58), .IDIV_SEL(6), .ODIV_SEL(2) // 227.57 MHz:   768x576@75Hz @  45.51 MHz pixel clock: no video sync
//        .FBDIV_SEL(36), .IDIV_SEL(3), .ODIV_SEL(2) // 249.75 MHz:   800x600@72Hz @  49.95 MHz pixel clock: no video sync
//        .FBDIV_SEL(11), .IDIV_SEL(0), .ODIV_SEL(2) // 324.00 MHz:  1024x768@60Hz @  64.80 MHz pixel clock: no video sync
//        .FBDIV_SEL(30), .IDIV_SEL(1), .ODIV_SEL(2) // 418.50 MHz:  1280x800@60Hz @  83.70 MHz pixel clock: no video sync
//        .FBDIV_SEL(19), .IDIV_SEL(0), .ODIV_SEL(2) // 540.00 MHz: 1280x1024@60Hz @ 108.00 MHz pixel clock: no video sync
//        .FBDIV_SEL(21), .IDIV_SEL(0), .ODIV_SEL(2) // 594.00 MHz: 1600x1200@57Hz @ 118.80 MHz pixel clock: no video sync, not even if using adder_clk[8] above, but must edit src/flipflop_drainer.v
    ) hdmi_pll(
        .CLKIN(clk),
        .CLKOUT(hdmi_clk_5x),
        .LOCK(hdmi_clk_lock),
        /*unused*/.CLKOUTP(), .CLKOUTD(), .CLKOUTD3(), .RESET(1'b0), .RESET_P(1'b0), .CLKFB(1'b0), .FBDSEL(6'b0), .IDSEL(6'b0), .ODSEL(6'b0), .PSDA(4'b0), .DUTYDA(4'b0), .FDLY(4'b0)
    );

    // Divide 5:1 serdes clock by five for HDMI pixel clock signal.
    CLKDIV #(
        .DIV_MODE("5"), 
        .GSREN("false")
    ) hdmi_clock_div(
        .CLKOUT(hdmi_clk), 
        .HCLKIN(hdmi_clk_5x), 
        .RESETN(hdmi_clk_lock), 
        .CALIB(1'b1)
    );

    wire serialInData;
    Debouncer #(
        .counterBits(4)
    ) serialInDebouncer(
        .clk(clk),
        .in(serialIn),
        .out(serialInData)
    );

    wire       ps2Clk;
    wire       ps2Data;
    Debouncer2 #(
        .counterBits(5)
    ) ps2debouncer(
        .clk(clk),
        .in1(rawPs2Clk),
        .in2(rawPs2Data),
        .out1(ps2Clk),
        .out2(ps2Data)
    );

    wire [7:0] port2;
    wire [3:0] port3;
    wire [15:0] addr;

    wire      debugShift;
    wire      debugCtrl;
    wire      debugAlt;
    wire      debugE0;
    wire      debugF0;

    SoC_es40 soC(
        .clk(clkDiv),
        .reset(~btn),
        .addr(addr),
        .port2(port2),
        .port3(port3),
        .ps2Clk(ps2Clk),
        .ps2Data(ps2Data),
        .serialIn(serialInData),
        .serialOut(serialOut),

        .debugShift(debugShift),
        .debugCtrl(debugCtrl),
        .debugAlt(debugAlt),
        .debugE0(debugE0),
        .debugF0(debugF0),

        .hdmi_clk(hdmi_clk),
        .hdmi_clk_5x(hdmi_clk_5x),
        .hdmi_clk_lock(hdmi_clk_lock),
        .hdmi_tx_n(hdmi_tx_n),
        .hdmi_tx_p(hdmi_tx_p)
    );

    assign leds[5] = ps2Data;//port2[5];
    assign leds[4] = ps2Clk;//port2[4];
    /*
    assign leds[3] = ~debugShift;
    assign leds[2] = ~debugCtrl;
    assign leds[1] = ~debugAlt;
    */
    assign leds[3] = ~port2[3];
    assign leds[2] = ~port2[2];
    assign leds[1] = ~port2[1];
    assign leds[0] = ~port2[0];
endmodule
