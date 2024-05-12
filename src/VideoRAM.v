`include "Memory.v"

module VideoRAM(
    input wire       clk, // assuming 8MHz
    input wire[12:0] cAddr,
    input wire[7:0]  cDataIn,
    input wire       cStrobe,
    input wire       cWrite,
    output wire[7:0] cDataOut,

    input wire[8:0] x,
    input wire[7:0] y,
    input wire      visible,
    output wire     pixel
);

    reg[12:0] vAddr = 0;
    wire[7:0] vData;
    wire      vStrobe;

    wire[12:0] rAddr;
    wire       rStrobe;
    RAM8k ram(
        .clk(clk),
        .addr(rAddr),
        .dataIn(cDataIn),
        .dataOut(vData),
        .write(cWrite),
        .strobe(rStrobe)
    );

    assign rAddr = cStrobe ? cAddr : vAddr;
    assign rStrobe = cStrobe | vStrobe;
    assign cDataOut = vData;

    wire[5:0] xByteCounter = x[8:3];
    wire[2:0] xBitCounter = x[2:0];
    reg[1:0] offsetCounter = 0;
    wire[3:0] vAddrOffset = xByteCounter == 39 && offsetCounter[1] ? 4'd9 : 4'd1;

    reg[7:0] shiftReg = 0;

    assign vStrobe = visible & xBitCounter == 0;

    always @(posedge clk) begin
        shiftReg <= {shiftReg[6:0], 1'b1};

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
                shiftReg <= vData;
                vAddr <= vAddr + vAddrOffset;
            end
        end
    end

    assign pixel = ~shiftReg[7];
endmodule