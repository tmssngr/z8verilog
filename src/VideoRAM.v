`default_nettype none

`include "Memory.v"

module VideoRAM(
    input wire       cClk,
    input wire[12:0] cAddr,
    input wire[7:0]  cDataIn,
    input wire       cStrobe,
    input wire       cWrite,
    output wire[7:0] cDataOut,

    input wire       vClk,
    input wire[8:0]  x,
    input wire[7:0]  y,
    input wire       visible,
    output wire      pixel,
    output wire      valid
);

    reg[12:0] vAddr = 0;
    wire[7:0] vData;
    wire      vStrobe;

    wire[12:0] rAddr;
    wire       rStrobe;
    DualPortRAM8k ram(
        .r_clk(vClk),
        .r_addr(vAddr),
        .r_data(vData),
        .r_strobe(vStrobe),

        .clk(cClk),
        .addr(cAddr),
        .dataIn(cDataIn),
        .dataOut(cDataOut),
        .write(cWrite),
        .strobe(cStrobe)
    );

    wire[5:0] xByteCounter = x[8:3];
    wire[2:0] xBitCounter = x[2:0];
    reg[1:0]  offsetCounter = 0;
    wire[3:0] vAddrOffset = xByteCounter == 39 && offsetCounter[1] ? 4'd9 : 4'd1;

    reg[7:0] dataSR = 0;
    reg[1:0] validSR = 0;


    assign vStrobe = visible & xBitCounter == 0;

    always @(posedge vClk) begin
        dataSR <= {dataSR[6:0], 1'b0};
        validSR = {validSR[0], visible};

        if (visible) begin
            if (x == 0) begin
                if (y == 0 || offsetCounter[1]) begin
                    offsetCounter <= 0;
                end
                else begin
                    offsetCounter <= offsetCounter + 1'b1;
                end
            end

            if (xBitCounter == 1) begin
                dataSR <= vData;
                vAddr <= vAddr + vAddrOffset;
            end
        end
    end

    assign pixel = ~dataSR[7];
    assign valid = validSR[1];
endmodule