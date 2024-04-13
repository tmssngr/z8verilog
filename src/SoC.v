`include "Memory.v"
`include "Processor.v"
`include "Ps2Decoder.v"

`default_nettype none

module SoC(
    input  wire        clk,
    input  wire        reset,
    input  wire        ps2Clk,
    input  wire        ps2Data,
    input  wire        serialIn,
    output wire        serialOut,
    output wire [15:0] addr,
    output wire  [7:0] port2,
    output wire  [3:0] port3,
    output wire        videoSync,
    output wire        videoPixel
);
    wire [15:0] memAddr;
    wire [7:0]  memDataRead, rom00Read, rom08Read, ramRead;
    wire [7:0]  memDataWrite;
    wire        memWrite;
    wire        memStrobe, rom00Strobe, rom08Strobe, ramStrobe;
    wire        rom00Enable, rom08Enable, ramEnable, keyboardEnable;
    wire        vramRead;
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

    RAM8k ram(
        .clk(clk),
        .addr(memAddr[12:0]),
        .dataOut(ramRead),
        .dataIn(memDataWrite),
        .write(memWrite),
        .strobe(ramStrobe)
    );

    wire       ps2Error;
    wire [7:0] keybits;
    assign port2[0] = ~ps2Error;
    assign port2[1] = ps2Clk;
    assign port2[2] = keyboardEnable;
    assign port2[7:3] = ~keybits[7:4];
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
        .debugSerialOut(serialOut)
    );

    // 15 14 13 12   11 10 9 8   7 6 5 4   3 2 1 0
    assign rom00Enable    = memAddr[15:11] == 5'b0000_0;  // 0000-07FF
    assign rom08Enable    = memAddr[15:11] == 5'b0000_1;  // 0800-0FFF
    assign keyboardEnable = memAddr[15:4]  == 12'h7F0;    // 6000-7FFF; only 7F0x are used
    assign ramEnable      = memAddr[15:13] == 5'b111;     // E000-FFFF;
    assign vramRead = (memAddr[15:9] == 7'b1111_111) & memStrobe & ~memWrite;
    assign videoSync = ~port3[3];
    assign videoPixel = videoSync & ~pixels[7];
    assign rom00Strobe = memStrobe & rom00Enable;
    assign rom08Strobe = memStrobe & rom08Enable;
    assign ramStrobe   = memStrobe & ramEnable;
    assign memDataRead = keyboardEnable ? keybits :
                         rom00Enable    ? rom00Read :
                         rom08Enable    ? rom08Read :
                         ramEnable      ? ramRead : 0;
    assign addr = memAddr;

    reg loadDelay = 0;

    always @(posedge clk) begin
        if (vramRead & ~loadDelay) begin
            loadDelay <= 1;
            clkDivider <= 1;
        end
        else begin
            loadDelay <= 0;
            clkDivider <= ~clkDivider;
        end


        if (loadDelay)
            pixels <= memDataRead;
        else if (clkDivider)
            pixels <= { pixels[6:0], 1'b1 };
    end

    Processor proc(
        .clk(clk),
        .reset(reset),
        .memAddr(memAddr),
        .memDataRead(memDataRead),
        .memDataWrite(memDataWrite),
        .memWrite(memWrite),
        .memStrobe(memStrobe),
//        .port2Out(port2),
        .port3Out(port3)
    );
endmodule
