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
    wire [7:0]  memDataRead, romRead, ramRead;
    wire [7:0]  memDataWrite;
    wire        memWrite;
    wire        memStrobe, romStrobe, ramStrobe;
    wire        romEnable, ramEnable, keyboardEnable;
    wire        vramRead;
    reg         clkDivider = 0;
    reg [7:0]   pixels;

    // 8k
    Memory #(
        .addrBusWidth(13),
        .isRom(1)
    ) rom(
        .clk(clk),
        .addr(memAddr[12:0]),
        .dataOut(romRead),
        .dataIn(memDataWrite),
        .write(1'b0),
        .strobe(romStrobe)
    );

    // 2k
    Memory #(
        .addrBusWidth(11),
        .isRom(0)
    ) ram(
        .clk(clk),
        .addr(memAddr[10:0]),
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

    assign romEnable      = memAddr[15:14] == 2'b00;  // 0000-3FFF
    assign keyboardEnable = memAddr[15:4] == 12'h7F0; // 6000-7FFF; only 7F0x are used
    assign ramEnable      = memAddr[15:13] == 3'b111; // E000-FFFF
    assign vramRead = (memAddr[15:9] == 7'b1111_111) & memStrobe & ~memWrite;
    assign videoSync = ~port3[3];
    assign videoPixel = videoSync & ~pixels[7];
    assign romStrobe = memStrobe  & romEnable;
    assign ramStrobe = memStrobe  & ramEnable;
    assign memDataRead = keyboardEnable ? keybits :
                         romEnable      ? romRead :
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
