`ifndef VBS_GENERATOR
`define VBS_GENERATOR

`include "Memory.v"

module VbsGenerator_es40(
    input wire       clk, // assuming 8MHz
    input wire[12:0] cAddr,
    input wire[7:0]  cDataIn,
    input wire       cStrobe,
    input wire       cWrite,
    output wire[7:0] cDataOut,
    output wire      o_syncH,
    output wire      o_syncV,
    output wire      o_pixel
);
    parameter H_PIXEL_COUNT = 320;
    parameter V_PIXEL_COUNT = 192;
    parameter H_BYTE_COUNT = H_PIXEL_COUNT / 8;
    parameter LAST_H_BYTE = H_BYTE_COUNT - 1;
    parameter H_LENGTH = 512;
    parameter H_FRONT_PORCH = 27;
    parameter H_SYNC = 38;
    parameter H_BACK_PORCH = 56;
    localparam H_VISIBLE = H_LENGTH - H_FRONT_PORCH - H_SYNC - H_BACK_PORCH;
    localparam signed H_START = -(H_FRONT_PORCH + H_SYNC + H_BACK_PORCH);
    localparam signed H_SYNC_START = H_START + H_FRONT_PORCH;
    localparam signed H_SYNC_END = H_SYNC_START + H_SYNC;
    localparam signed H_PIXEL_START_AT = (H_VISIBLE - H_PIXEL_COUNT) / 2;
    localparam signed H_END = H_VISIBLE - 1;

    parameter V_LENGTH = 313;
    parameter V_FRONT_PORCH = 5;
    parameter V_SYNC = 4;
    parameter V_BACK_PORCH = 29;
    localparam V_VISIBLE = V_LENGTH - V_FRONT_PORCH - V_SYNC - V_BACK_PORCH;
    localparam signed V_START = V_VISIBLE - V_LENGTH;
    localparam signed V_SYNC_START = V_START + V_FRONT_PORCH;
    localparam signed V_SYNC_END = V_SYNC_START + V_SYNC;
    localparam signed V_PIXEL_START = (V_VISIBLE - V_PIXEL_COUNT) / 2;
    localparam signed V_END = V_VISIBLE - 1;

    reg signed[9:0] hCounter = H_START; // perfect fit 64us * 8 + sign
    reg signed[9:0] vCounter = V_START;

    reg[12:0] vAddr = 0;
    wire[7:0] vData;
    wire      vStrobe;

    wire[12:0] rAddr;
    wire       rStrobe;
    RAM8k ram(
        .clk(clk),
        .clkEnable(1'b1),
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
    wire[3:0] offset = xByteCounter == LAST_H_BYTE && offsetCounter[1] ? 4'd9 : 4'd1;

    reg[7:0] shiftReg = 0;

    assign vStrobe = xRange & yRange & xBitCounter == 0;
    wire loadShiftReg = xRange & yRange & xBitCounter == 1;

    assign o_syncH = hCounter >= H_SYNC_START & hCounter < H_SYNC_END;
    assign o_syncV = vCounter >= V_SYNC_START & vCounter < V_SYNC_END;

    always @(posedge clk) begin
        if (hCounter < H_END) begin
            hCounter <= hCounter + 1'b1;
        end
        else begin
            hCounter <= H_START;
            if (vCounter < V_END) begin
                vCounter <= vCounter + 1'b1;
                if (vCounter == V_PIXEL_START) begin
                    yRange <= 1;
                    yCounter <= 0;
                    vAddr <= 0;
                    offsetCounter <= 0;
                end

                if (yRange) begin
                    if (yCounter == V_PIXEL_COUNT - 1) begin
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
                vCounter <= V_START;
            end
        end


        shiftReg <= {shiftReg[6:0], 1'b1};

        if (yRange) begin
            if (hCounter == H_PIXEL_START_AT) begin
                xRange <= 1;
            end

            if (xRange) begin
                xBitCounter <= xBitCounter + 1'b1;

                if (loadShiftReg) begin
                    shiftReg <= vData;
                    vAddr <= vAddr + offset;
                    xByteCounter <= xByteCounter + 1'b1;
                    if (xByteCounter == LAST_H_BYTE) begin
                        xRange <= 0;
                        xByteCounter <= 0;
                        xBitCounter <= 0;
                    end
                end
            end
        end
    end

    assign o_pixel = ~shiftReg[7];
/*rect
    assign o_pixel = (vCounter == 0 & hCounter >= 0 & hCounter <= H_END)
                 | (vCounter > 0 & vCounter < V_END & (hCounter == 0 | hCounter == H_END))
                 | (vCounter == V_END & hCounter >= 0 & hCounter <= H_END);
*/
endmodule

`endif
