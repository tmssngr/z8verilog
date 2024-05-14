`include "Memory.v"
`include "Processor.v"
`include "Ps2Decoder.v"

`default_nettype none

module SoC(
    input  wire        clk,
    input  wire        reset,
    output wire [15:0] addr,
    output wire  [7:0] port2,
    output wire  [3:0] port3,
    input  wire        serialIn,
    output wire        serialOut
);
    wire [15:0] memAddr;
    wire [7:0]  memDataRead, rom00Read, rom08Read, ramRead;
    wire [7:0]  memDataWrite;
    wire        memWrite;
    wire        memStrobe, rom00Strobe, rom08Strobe, ramStrobe;
    wire        rom00Enable, rom08Enable, ramEnable, keyboardEnable;
    wire        vramRead;
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

    RAM8k ram(
        .clk(clk),
        .addr(memAddr[12:0]),
        .dataOut(ramRead),
        .dataIn(memDataWrite),
        .write(memWrite),
        .strobe(ramStrobe)
    );

    // 15 14 13 12   11 10 9 8   7 6 5 4   3 2 1 0
    assign rom00Enable    = memAddr[15:11] == 5'b0000_0;  // 0000-07FF
    assign rom08Enable    = memAddr[15:11] == 5'b0000_1;  // 0800-0FFF
    assign ramEnable      = memAddr[15:13] == 5'b111;     // E000-FFFF;
    assign rom00Strobe = memStrobe & rom00Enable;
    assign rom08Strobe = memStrobe & rom08Enable;
    assign ramStrobe   = memStrobe & ramEnable;
    assign memDataRead = rom00Enable    ? rom00Read :
                         rom08Enable    ? rom08Read :
                         ramEnable      ? ramRead : 0;
    assign addr = memAddr;

    Processor proc(
        .clk(clk),
        .reset(reset),
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
