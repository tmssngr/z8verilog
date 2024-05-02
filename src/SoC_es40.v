`include "Memory.v"
`include "Processor.v"
`include "Ps2Decoder.v"
`include "VbsGenerator.v"

`default_nettype none

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
    output wire        videoSync,
    output wire        videoPixel
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
    reg         clk4Mhz = 0;

    always @(posedge clk) begin
        clk4Mhz <= ~clk4Mhz;
    end

    ROM2k #(
        .initFile("rom00.mem")
    ) rom00(
        .clk(clk4Mhz),
        .addr(memAddr[10:0]),
        .dataOut(rom00Read),
        .strobe(rom00Strobe)
    );

    ROM2k #(
        .initFile("rom08.mem")
    ) rom08(
        .clk(clk4Mhz),
        .addr(memAddr[10:0]),
        .dataOut(rom08Read),
        .strobe(rom08Strobe)
    );

    ROM2k #(
        .initFile("rom10.mem")
    ) rom10(
        .clk(clk4Mhz),
        .addr(memAddr[10:0]),
        .dataOut(rom10Read),
        .strobe(rom10Strobe)
    );

    ROM2k #(
        .initFile("rom18.mem")
    ) rom18(
        .clk(clk4Mhz),
        .addr(memAddr[10:0]),
        .dataOut(rom18Read),
        .strobe(rom18Strobe)
    );

    RAM8k ram(
        .clk(clk4Mhz),
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
        .clk(clk4Mhz),
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
    wire vbsSync, vbsPixel;
    wire vramStrobe, vramEnable;
    wire [7:0] vramRead;
    VbsGenerator vbs(
        .clk(clk),
        .sync(vbsSync),
        .pixel(vbsPixel),
        .cAddr(memAddr[12:0]),
        .cDataIn(memDataWrite),
        .cDataOut(vramRead),
        .cStrobe(vramStrobe & videoPane),
        .cWrite(vramStrobe & memWrite & videoPane)
    );
    assign videoSync = vbsSync;
    assign videoPixel = videoSync & vbsPixel;

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
        .clk(clk4Mhz),
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
