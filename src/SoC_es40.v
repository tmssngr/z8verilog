`default_nettype none

`include "Memory.v"
`include "Processor.v"
`include "Ps2Decoder.v"
`include "VideoRAM.v"

module SoC_es40(
    input  wire        clk,
    input  wire        reset,
    input  wire        ps2Clk,
    input  wire        ps2Data,
    input  wire        serialIn,
    output wire        serialOut,
    output wire [15:0] addr,
    output wire  [7:0] port2,
    output wire  [3:0] port3,
    output wire        debugShift,
    output wire        debugCtrl,
    output wire        debugAlt,
    output wire        debugE0,
    output wire        debugF0,

    input wire         hdmi_clk,
    input wire         hdmi_clk_5x,
    input wire         hdmi_clk_lock,
    output wire [3:0]  hdmi_tx_n,
    output wire [3:0]  hdmi_tx_p
);
    wire [15:0] memAddr;
    wire [7:0]  memDataRead, rom00Read, rom08Read, rom10Read, rom18Read, ramRead;
    wire [7:0]  memDataWrite;
    wire        memWrite;
    wire        memStrobe, rom00Strobe, rom08Strobe, rom10Strobe, rom18Strobe, ramStrobe;
    wire        rom00Enable, rom08Enable, rom10Enable, rom18Enable, ramEnable, keyboardEnable;
    wire        isIsr;
    reg         clkDivider = 0;
    reg [7:0]   pixels;

    ROM2k #(
        .initFile("rom00.mem")
    ) rom00(
        .clk(clk),
        .addr(memAddr[10:0]),
        .dataOut(rom00Read),
        .strobe(rom00Strobe)
    );

    ROM2k #(
        .initFile("rom08.mem")
    ) rom08(
        .clk(clk),
        .addr(memAddr[10:0]),
        .dataOut(rom08Read),
        .strobe(rom08Strobe)
    );

    ROM2k #(
        .initFile("rom10.mem")
    ) rom10(
        .clk(clk),
        .addr(memAddr[10:0]),
        .dataOut(rom10Read),
        .strobe(rom10Strobe)
    );

    ROM2k #(
        .initFile("rom18.mem")
    ) rom18(
        .clk(clk),
        .addr(memAddr[10:0]),
        .dataOut(rom18Read),
        .strobe(rom18Strobe)
    );

    RAM8k ram(
        .clk(clk),
        .addr(memAddr[12:0]),
        .dataOut(ramRead),
        .dataIn(memDataWrite),
        .write(memWrite),
        .strobe(ramStrobe)
    );

    wire       ps2Error;
    wire       softReset;
    wire [7:0] keybits;
    Ps2Decoder #(
        .counterBits(8),
        .minClk(120),
        .maxClk(220),
        .readAt(50)
    ) ps2(
        .clk(clk),
        .ps2Clk(ps2Clk),
        .ps2Data(ps2Data),
        .reset(reset),
        .address(memAddr[3:0]),
        .keybits(keybits),
        .error(ps2Error),
        .softReset(softReset),

        .debugShift(debugShift),
        .debugCtrl(debugCtrl),
        .debugAlt(debugAlt),
        .debugE0(debugE0),
        .debugF0(debugF0)
    );

    reg[3:0] color = 0;
    wire videoPane = color[3];
    wire vramStrobe, vramEnable;
    wire [7:0] vramRead;

    reg [12:0] x, y;
    reg [2:0] hve_sync;

    display_signal #(
/*  640x480@60Hz*/   .H_RESOLUTION( 640),.V_RESOLUTION( 480),.H_FRONT_PORCH(16),.H_SYNC( 96),.H_BACK_PORCH( 48),.V_FRONT_PORCH(10),.V_SYNC(2),.V_BACK_PORCH(33),.H_SYNC_POLARITY(0),.V_SYNC_POLARITY(0)
///*  800x600@60Hz*/   .H_RESOLUTION( 800),.V_RESOLUTION( 600),.H_FRONT_PORCH(40),.H_SYNC(128),.H_BACK_PORCH( 88),.V_FRONT_PORCH( 1),.V_SYNC(4),.V_BACK_PORCH(23),.H_SYNC_POLARITY(1),.V_SYNC_POLARITY(1)
///*  768x576@73Hz*/   .H_RESOLUTION( 768),.V_RESOLUTION( 576),.H_FRONT_PORCH(32),.H_SYNC( 80),.H_BACK_PORCH(112),.V_FRONT_PORCH( 1),.V_SYNC(3),.V_BACK_PORCH(21),.H_SYNC_POLARITY(0),.V_SYNC_POLARITY(1)
///*  768x576@75Hz*/   .H_RESOLUTION( 768),.V_RESOLUTION( 576),.H_FRONT_PORCH(40),.H_SYNC( 80),.H_BACK_PORCH(120),.V_FRONT_PORCH( 1),.V_SYNC(3),.V_BACK_PORCH(22),.H_SYNC_POLARITY(0),.V_SYNC_POLARITY(1)
///*  800x600@72Hz*/   .H_RESOLUTION( 800),.V_RESOLUTION( 600),.H_FRONT_PORCH(56),.H_SYNC(120),.H_BACK_PORCH( 64),.V_FRONT_PORCH(37),.V_SYNC(6),.V_BACK_PORCH(23),.H_SYNC_POLARITY(1),.V_SYNC_POLARITY(1)
///* 1024x600@75Hz*/   .H_RESOLUTION(1024),.V_RESOLUTION( 600),.H_FRONT_PORCH(24),.H_SYNC(136),.H_BACK_PORCH(160),.V_FRONT_PORCH( 3),.V_SYNC(6),.V_BACK_PORCH(29),.H_SYNC_POLARITY(0),.V_SYNC_POLARITY(0)
///* 1024x768@60Hz*/   .H_RESOLUTION(1024),.V_RESOLUTION( 768),.H_FRONT_PORCH(24),.H_SYNC(136),.H_BACK_PORCH(160),.V_FRONT_PORCH( 3),.V_SYNC(6),.V_BACK_PORCH(29),.H_SYNC_POLARITY(0),.V_SYNC_POLARITY(0)
///* 1280x800@60Hz*/   .H_RESOLUTION(1280),.V_RESOLUTION( 800),.H_FRONT_PORCH(64),.H_SYNC(136),.H_BACK_PORCH(200),.V_FRONT_PORCH( 1),.V_SYNC(3),.V_BACK_PORCH(24),.H_SYNC_POLARITY(0),.V_SYNC_POLARITY(1)
///*1280x1024@60Hz*/   .H_RESOLUTION(1280),.V_RESOLUTION(1024),.H_FRONT_PORCH(48),.H_SYNC(112),.H_BACK_PORCH(248),.V_FRONT_PORCH( 1),.V_SYNC(3),.V_BACK_PORCH(38),.H_SYNC_POLARITY(1),.V_SYNC_POLARITY(1)
///*1600x1200@57.4Hz*/ .H_RESOLUTION(1600),.V_RESOLUTION(1200),.H_FRONT_PORCH( 8),.H_SYNC( 32),.H_BACK_PORCH( 40),.V_FRONT_PORCH(19),.V_SYNC(8),.V_BACK_PORCH( 6),.H_SYNC_POLARITY(1),.V_SYNC_POLARITY(0)
    ) ds(
        .clk(hdmi_clk),
        .o_hve(hve_sync),
        .o_x(x),
        .o_y(y)
    );
    hdmi hdmi_out(
        .reset(~hdmi_clk_lock),
        .hdmi_clk(hdmi_clk),
        .hdmi_clk_5x(hdmi_clk_5x),
        .hve_sync(hve_sync),
    //24'h9fdf61; // green
    //24'hFFC000; // amber
        .rgb(videoData & videoValid ? 24'hFFC000 : 24'h0),
        .hdmi_tx_n(hdmi_tx_n),
        .hdmi_tx_p(hdmi_tx_p)
    );

    reg videoVisible = 1;
    wire videoData;
    wire videoValid;
    VideoRAM vram(
        .cClk(clk),
        .cAddr(memAddr[12:0]),
        .cDataIn(memDataWrite),
        .cDataOut(vramRead),
        .cStrobe(vramStrobe & videoPane),
        .cWrite(vramStrobe & memWrite & videoPane),

        .vClk(hdmi_clk),
        .x(x),
        .y(y),
        .visible(1'b1),
        .valid(videoValid),
        .pixel(videoData)
    );

    // 15 14 13 12   11 10 9 8   7 6 5 4   3 2 1 0
    assign rom00Enable    = memAddr[15:11] == 5'b0000_0;  // 0000-07FF
    assign rom08Enable    = memAddr[15:11] == 5'b0000_1;  // 0800-0FFF
    assign rom10Enable    = memAddr[15:11] == 5'b0001_0;  // 1000-17FF
    assign rom18Enable    = memAddr[15:11] == 5'b0001_1;  // 1800-1FFF
    wire   colorEnable    = memAddr[15:10] == 6'b0110_00; // 6000-63FF
    assign keyboardEnable = memAddr[15:4]  == 12'h7F0;    // 7F0x
    assign ramEnable      = memAddr[15:13] == 5'b111;     // E000-FFFF;
    assign vramEnable     = memAddr[15:13] == 3'b010;     // 4000-5fff
    assign rom00Strobe = memStrobe & rom00Enable;
    assign rom08Strobe = memStrobe & rom08Enable;
    assign rom10Strobe = memStrobe & rom10Enable;
    assign rom18Strobe = memStrobe & rom18Enable;
    assign vramStrobe  = memStrobe & vramEnable;
    assign ramStrobe   = memStrobe & ramEnable & ~vramEnable;
    assign memDataRead = keyboardEnable ? keybits :
                         rom00Enable    ? rom00Read :
                         rom08Enable    ? rom08Read :
                         rom10Enable    ? rom10Read :
                         rom18Enable    ? rom18Read :
                         vramEnable     ? vramRead :
                         ramEnable      ? ramRead : 0;
    assign addr = memAddr;

    always @(posedge clk) begin
        if (colorEnable & memStrobe & memWrite) begin
            color <= memDataWrite[7:4];
        end
    end

    Processor proc(
        .clk(clk),
        .reset(reset | softReset),
        .memAddr(memAddr),
        .memDataRead(memDataRead),
        .memDataWrite(memDataWrite),
        .memWrite(memWrite),
        .memStrobe(memStrobe),
        .isIsr(isIsr),
        .port2Out(port2),
        .port3Out(port3)
    );
endmodule
