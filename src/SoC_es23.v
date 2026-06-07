`include "Debouncer.v"
`include "Memory.v"
`include "Processor.v"
`include "Ps2Decoder.v"

`default_nettype none

module SoC_es23(
    input  wire        clk,
    input  wire        reset,
    input  wire        rawPs2Clk,
    input  wire        rawPs2Data,
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
    wire [7:0]  memDataRead, rom00Read, rom08Read, rom10Read, ramRead;
    wire [7:0]  memDataWrite;
    wire        memWrite;
    wire        memStrobe, rom00Strobe, rom08Strobe, rom10Strobe, ramStrobe;
    wire        rom00Enable, rom08Enable, rom10Enable, ramEnable, keyboardEnable;
    wire        vramRead;
    wire        isIsr;
    reg         cpuPhase = 0;
    reg         clkDivider = 0;
    reg [7:0]   pixels;
    wire        cpuCe = cpuPhase;

    always @(posedge clk) begin
        cpuPhase <= ~cpuPhase;
    end

    ROM2k #(
        .initFile("rom00.mem")
    ) rom00(
        .clk(clk),
        .clkEnable(cpuCe),
        .addr(memAddr[10:0]),
        .dataOut(rom00Read),
        .strobe(rom00Strobe)
    );

    ROM2k #(
        .initFile("jtc4k-es23-rom08.mem")
    ) rom08(
        .clk(clk),
        .clkEnable(cpuCe),
        .addr(memAddr[10:0]),
        .dataOut(rom08Read),
        .strobe(rom08Strobe)
    );

    ROM2k #(
        .initFile("jtc4k-es23-rom10.mem")
    ) rom10(
        .clk(clk),
        .clkEnable(cpuCe),
        .addr(memAddr[10:0]),
        .dataOut(rom10Read),
        .strobe(rom10Strobe)
    );

    RAM8k ram(
        .clk(clk),
        .clkEnable(cpuCe),
        .addr(memAddr[12:0]),
        .dataOut(ramRead),
        .dataIn(memDataWrite),
        .write(memWrite),
        .strobe(ramStrobe)
    );

    wire       ps2Clk;
    wire       ps2Data;
    Debouncer2 ps2debouncer(
        .clk(clk),
        .clkEnable(cpuCe),
        .in1(rawPs2Clk),
        .in2(rawPs2Data),
        .out1(ps2Clk),
        .out2(ps2Data)
    );

    wire       ps2Error;
    wire       softReset;
    wire [7:0] keybits;
    Ps2DecoderMulti #(
        .counterBits(8),
        .minClk(120),
        .maxClk(220),
        .readAt(50)
    ) ps2(
        .clk(clk),
        .clkEnable(cpuCe),
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

    // 15 14 13 12   11 10 9 8   7 6 5 4   3 2 1 0
    assign rom00Enable    = memAddr[15:11] == 5'b0000_0;  // 0000-07FF
    assign rom08Enable    = memAddr[15:11] == 5'b0000_1;  // 0800-0FFF
    assign rom10Enable    = memAddr[15:11] == 5'b0001_0;  // 1000-17FF
    assign keyboardEnable = memAddr[15:4]  == 12'h7F0;    // 6000-7FFF; only 7F0x are used
    assign ramEnable      = memAddr[15:13] == 5'b111;     // E000-FFFF;
    assign vramRead = (memAddr[15:11] == 5'b1111_1) & memStrobe & ~memWrite & isIsr;
    assign videoSync = ~port3[3];
    assign videoPixel = videoSync & ~pixels[7];
    assign rom00Strobe = memStrobe & rom00Enable;
    assign rom08Strobe = memStrobe & rom08Enable;
    assign rom10Strobe = memStrobe & rom10Enable;
    assign ramStrobe   = memStrobe & ramEnable;
    assign memDataRead = keyboardEnable ? keybits :
                         rom00Enable    ? rom00Read :
                         rom08Enable    ? rom08Read :
                         rom10Enable    ? rom10Read :
                         ramEnable      ? ramRead : 0;
    assign addr = memAddr;

    reg loadDelay = 0;

    always @(posedge clk) begin
        if (cpuCe) begin
            if (vramRead & ~loadDelay) begin
                loadDelay <= 1;
                clkDivider <= 1;
            end
            else begin
                loadDelay <= 0;
                clkDivider <= ~clkDivider;
            end


            if (loadDelay) begin
                pixels <= memDataRead;
            end
            else if (clkDivider) begin
                pixels <= { pixels[6:0], 1'b1 };
            end
        end
    end

    Processor proc(
        .clk(clk),
        .clkEnable(cpuCe),
        .reset(reset | softReset),
        .memAddr(memAddr),
        .memDataRead(memDataRead),
        .memDataWrite(memDataWrite),
        .memWrite(memWrite),
        .memStrobe(memStrobe),
        .serialIn(serialIn),
        .serialOut(serialOut),
        .isIsr(isIsr),
        .port2Out(port2),
        .port3Out(port3)
    );
endmodule
