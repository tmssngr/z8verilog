`ifndef VBS_GENERATOR
`define VBS_GENERATOR

module VbsGenerator(
    input wire  clk, // assuming 4MHz
    output reg  sync,
    output wire pixel,
    input wire[10:0] addr,
    input wire[7:0] dataIn,
    input wire      strobe,
    input wire      write,
    output reg[7:0] dataOut
);
    parameter LINE_COUNT = 313;
    reg[7:0] hCounter = 0; // perfect fit 64us * 4
    reg[8:0] vCounter = 0;

    initial begin
        sync = 1;
    end

    reg [7:0] memory[0:2047];

    reg xRange = 0;
    reg yRange = 0;
    reg[7:0] xCounter = 0;
    reg[7:0] yCounter = 0;

    reg[7:0] shiftReg = 0;

    wire[10:0] videoAddr = {yCounter[7:1], xCounter[6:3]};
    wire loadShiftReg = xRange & yRange & xCounter[2:0] == 0;

    always @(posedge clk) begin
        if (strobe) begin
            if (write) begin
                memory[addr] <= dataIn;
            end
            else begin
                dataOut <= memory[addr];
            end
        end
    end

    always @(posedge clk) begin
        hCounter <= hCounter + 1'b1;

        if (hCounter == 1
           | (hCounter == 15 && vCounter != 0 && vCounter != 3)
        ) begin
            sync <= ~sync;
        end

        shiftReg <= {shiftReg[6:0], 1'b0};

        if (yRange) begin
            if (hCounter == 48) begin
                xRange <= 1;
                xCounter <= 0;
            end

            if (xRange) begin
                if (loadShiftReg) begin
                    shiftReg <= ~memory[videoAddr];
                end

                if (xCounter == 7'b1111_111) begin
                    xRange <= 0;
                    if (yCounter == 8'b1111_1111) begin
                        yRange <= 0;
                    end
                    else begin
                        yCounter <= yCounter + 1'b1;
                    end
                end
                else begin
                    xCounter <= xCounter + 1'b1;
                end
            end
        end

        if (hCounter == {8{1'b1}}) begin
            if (vCounter != LINE_COUNT - 1) begin
                vCounter <= vCounter + 1'b1;
                if (vCounter == 34) begin
                    yRange <= 1;
                    yCounter <= 0;
                end
            end
            else begin
                vCounter <= 0;
            end
        end
    end

    assign pixel = shiftReg[7];
/* rect
    parameter xStart = 49;
    parameter xEnd = 243;
    parameter yStart = 35;
    parameter yEnd = 307;
    assign pixel = (vCounter == yStart & hCounter >= xStart & hCounter < xEnd)
                 | (vCounter > yStart & vCounter < yEnd & (hCounter == xStart | hCounter == xEnd))
                 | (vCounter == yEnd & hCounter >= xStart & hCounter < xEnd);
*/
endmodule

`endif