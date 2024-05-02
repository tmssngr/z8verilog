`ifndef VBS_GENERATOR
`define VBS_GENERATOR

`include "Memory.v"

module VbsGenerator(
    input wire       clk, // assuming 8MHz
    output reg       sync,
    output wire      pixel,
    input wire[12:0] cAddr,
    input wire[7:0]  cDataIn,
    input wire       cStrobe,
    input wire       cWrite,
    output wire[7:0] cDataOut
);
    parameter LINE_COUNT = 313;
    reg[8:0] hCounter = 0; // perfect fit 64us * 8
    reg[8:0] vCounter = 0;

    initial begin
        sync = 1;
    end

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

    reg xRange = 0;
    reg yRange = 0;
    reg[5:0] xByteCounter = 0;
    reg[2:0] xBitCounter = 0;
    reg[7:0] yCounter = 0;
    reg[1:0] offsetCounter = 0;
    wire[3:0] offset = xByteCounter == 39 && offsetCounter[1] ? 4'd9 : 4'd1;

    reg needsLoadingFromRAM = 0;
    reg[7:0] ramData = 0;
    reg[7:0] shiftReg = 0;

    assign vStrobe = xRange & yRange & xBitCounter == 0;
    wire loadFromRAM = xRange & yRange & needsLoadingFromRAM & (~cStrobe | xBitCounter == 6);
    wire loadShiftReg = xRange & yRange & xBitCounter == 7;

    always @(posedge clk) begin
        hCounter <= hCounter + 1'b1;

        if (hCounter == 1
           | (hCounter == 30 && vCounter != 0 && vCounter != 3)
        ) begin
            sync <= ~sync;
        end

        shiftReg <= {shiftReg[6:0], 1'b1};

        if (yRange) begin
            if (hCounter == 87) begin
                xRange <= 1;
            end

            if (xRange) begin
                xBitCounter <= xBitCounter + 1'b1;

                if (xBitCounter == 0) begin
                    needsLoadingFromRAM <= 1;
                end
                else if (loadFromRAM) begin
                    ramData <= vData;
                    vAddr <= vAddr + offset;
                    needsLoadingFromRAM <= 0;
                end
                else if (loadShiftReg) begin
                    shiftReg <= ramData;
                    xByteCounter <= xByteCounter + 1'b1;
                    if (xByteCounter == 39) begin
                        xRange <= 0;
                        xByteCounter <= 0;
                        xBitCounter <= 0;
                    end
                end
            end
        end

        if (hCounter == {9{1'b1}}) begin
            if (vCounter != LINE_COUNT - 1) begin
                vCounter <= vCounter + 1'b1;
                if (vCounter == 34) begin
                    yRange <= 1;
                    yCounter <= 0;
                    vAddr <= 0;
                    offsetCounter <= 0;
                end

                if (yRange) begin
                    if (yCounter == 191) begin
                        yRange <= 0;
                    end
                    else begin
                        yCounter <= yCounter + 1'b1;
                    end

                    if (offsetCounter[1]) begin
                        offsetCounter <= 0;
                    end
                    else begin
                        offsetCounter <= offsetCounter + 1'b1;
                    end
                end
            end
            else begin
                vCounter <= 0;
            end
        end
    end

    assign pixel = ~shiftReg[7];
/* rect
    parameter xStart = 96;
    parameter xEnd = 486;
    parameter yStart = 35;
    parameter yEnd = 307;
    assign pixel = (vCounter == yStart & hCounter >= xStart & hCounter <= xEnd)
                 | (vCounter > yStart & vCounter < yEnd & (hCounter == xStart | hCounter == xEnd))
                 | (vCounter == yEnd & hCounter >= xStart & hCounter <= xEnd);
*/
endmodule

`endif