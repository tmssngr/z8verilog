`ifndef VBS_GENERATOR
`define VBS_GENERATOR

`include "Memory.v"

module VbsGenerator(
    input wire       clk, // assuming 8MHz
    output reg       sync,
    output wire      pixel,

    output reg[8:0]  x,
    output reg[7:0]  y,
    output wire      visible,
    input wire       data,
    input wire       valid
);
    parameter LINE_COUNT = 313;
    parameter H_PIXEL_COUNT = 320;
    parameter V_PIXEL_COUNT = 192;
    parameter H_BYTE_COUNT = H_PIXEL_COUNT / 8;
    parameter H_FRONT_PORCH = 93;
    parameter V_FRONT_PORCH = 34;
    reg[8:0] hCounter = 0; // perfect fit 64us * 8
    reg[8:0] vCounter = 0;

    initial begin
        sync = 1;
    end

    reg xRange = 0;
    reg yRange = 0;

    always @(posedge clk) begin
        hCounter <= hCounter + 1'b1;

        if (hCounter == 1
           | (hCounter == 30 && vCounter != 0 && vCounter != 3)
        ) begin
            sync <= ~sync;
        end

        if (yRange) begin
            if (hCounter == H_FRONT_PORCH) begin
                xRange <= 1;
                x <= 0;
            end

            if (xRange) begin
                x <= x + 1'b1;

                if (x == H_PIXEL_COUNT - 1) begin
                    xRange <= 0;
                end
            end
        end

        if (hCounter == {9{1'b1}}) begin
            if (vCounter != LINE_COUNT - 1) begin
                vCounter <= vCounter + 1'b1;
                if (vCounter == V_FRONT_PORCH) begin
                    yRange <= 1;
                    y <= 0;
                end

                if (yRange) begin
                    if (y == V_PIXEL_COUNT - 1) begin
                        yRange <= 0;
                    end
                    else begin
                        y <= y + 1'b1;
                    end
                end
            end
            else begin
                vCounter <= 0;
            end
        end
    end

    assign visible = xRange & yRange;
    assign pixel = data & valid;
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