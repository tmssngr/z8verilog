`ifndef VBS_GENERATOR
`define VBS_GENERATOR

module VbsGenerator(
    input wire  clk, // assuming 4MHz
    output reg  sync,
    output wire pixel
);
    parameter LINE_COUNT = 313;
    reg[7:0] hCounter = 0; // perfect fit 64us * 4
    reg[8:0] vCounter = 0;

    initial begin
        sync = 1;
    end

    always @(posedge clk) begin
        hCounter <= hCounter + 1'b1;

        if (hCounter == 1
           | (hCounter == 15 && vCounter != 0 && vCounter != 3)
        ) begin
            sync <= ~sync;
        end

        if (hCounter == {8{1'b1}}) begin
            if (vCounter != LINE_COUNT - 1) begin
                vCounter <= vCounter + 1'b1;
            end
            else begin
                vCounter <= 0;
            end
        end
    end

    parameter xStart = 49;
    parameter xEnd = 243;
    parameter yStart = 35;
    parameter yEnd = 307;
    assign pixel = (vCounter == yStart & hCounter >= xStart & hCounter <= xEnd)
                 | (vCounter > yStart & vCounter < yEnd & (hCounter == xStart | hCounter == xEnd))
                 | (vCounter == yEnd & hCounter >= xStart & hCounter <= xEnd);
endmodule

`endif