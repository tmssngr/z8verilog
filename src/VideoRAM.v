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
    input wire[12:0] x,
    input wire[12:0] y,
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

    wire[8:0] xByteCounter = x[12:4];
    wire[2:0] xBitCounter = x[3:1];
    reg[1:0]  addrOffsetCounter = 0;

    reg[7:0] dataSR = 0;
    reg[1:0] validSR = 0;

    assign vStrobe = visible & xBitCounter == 0 & x[0] == 0;

    always @(posedge vClk) begin
        if (y == 0 & x == -1) begin
            addrOffsetCounter <= 0;
            vAddr <= 0;
        end

        if (x[0] == 0) begin
            dataSR <= {dataSR[6:0], 1'b0};
            validSR <= {validSR[0], y >= 0 & y < 192 * 2 & x >= 0 & x < 640};

            if (y >= 0 & y < 192 * 2 && xBitCounter == 1 & xByteCounter < 40) begin
                dataSR <= vData;
                vAddr <= vAddr + 4'd1;
                if (xByteCounter == 39) begin
                    if (y[0]) begin
                        vAddr <= vAddr - 11'd39;
                    end
                    else begin
                        if (addrOffsetCounter[1]) begin
                            vAddr <= vAddr + 4'd9;
                            addrOffsetCounter <= 0;
                        end
                        else begin
                            addrOffsetCounter <= addrOffsetCounter + 1'b1;
                        end
                    end
                end
            end
        end
    end

    assign pixel = ~dataSR[7];
    assign valid = validSR[1];
endmodule