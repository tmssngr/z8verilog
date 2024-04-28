`ifndef VBS_GENERATOR
`define VBS_GENERATOR

module VbsGenerator(
    input wire  clk, // assuming 8MHz
    output reg  sync,
    output wire pixel
);
    parameter LINE_COUNT = 313;
    reg[8:0] hCounter = 0; // perfect fit 64us * 8
    reg[8:0] vCounter = 0;

    initial begin
        sync = 1;
    end

    reg [7:0] memory[0:2047];
    integer i;
    initial begin
        for (i = 0; i < 2048; i = i + 1) begin
            memory[i] = 0;
        end
        memory[11'h000] = 8'b00010000;
        memory[11'h010] = 8'b00111000;
        memory[11'h020] = 8'b01101100;
        memory[11'h030] = 8'b11000110;
        memory[11'h040] = 8'b11111110;
        memory[11'h050] = 8'b11000110;
        memory[11'h060] = 8'b11000110;
        memory[11'h070] = 8'h0;

        memory[11'h00F] = 8'b00000000;
        memory[11'h01F] = 8'b01111000;
        memory[11'h02F] = 8'b00001100;
        memory[11'h03F] = 8'b01111100;
        memory[11'h04F] = 8'b11001100;
        memory[11'h05F] = 8'b11001100;
        memory[11'h06F] = 8'b01110110;
        memory[11'h07F] = 8'b0;

        memory[11'h780] = 8'b11111110;
        memory[11'h790] = 8'b01100010;
        memory[11'h7a0] = 8'b01100000;
        memory[11'h7b0] = 8'b01111100;
        memory[11'h7c0] = 8'b01100000;
        memory[11'h7d0] = 8'b01100010;
        memory[11'h7e0] = 8'b11111110;
        memory[11'h7f0] = 8'b0;

        memory[11'h78F] = 8'h0;
        memory[11'h79F] = 8'b01111100;
        memory[11'h7aF] = 8'b11000110;
        memory[11'h7bF] = 8'b11111110;
        memory[11'h7cF] = 8'b11000000;
        memory[11'h7dF] = 8'b11000110;
        memory[11'h7eF] = 8'b01111100;
        memory[11'h7fF] = 8'h0;
    end

    reg xRange = 0;
    reg yRange = 0;
    reg[7:0] xCounter = 0;
    reg[7:0] yCounter = 0;

    reg[7:0] shiftReg = 0;

    reg[10:0] addr = 0;
    wire loadShiftReg = xRange & yRange & xCounter[2:0] == 0;

    always @(posedge clk) begin
        hCounter <= hCounter + 1'b1;

        if (hCounter == 1
           | (hCounter == 30 && vCounter != 0 && vCounter != 3)
        ) begin
            sync <= ~sync;
        end

        shiftReg <= {shiftReg[6:0], 1'b0};

        if (yRange) begin
            if (hCounter == 95) begin
                xRange <= 1;
                xCounter <= 0;
            end

            if (xRange) begin
                if (loadShiftReg) begin
                    shiftReg <= memory[addr];
                    addr <= addr + 1;
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

        if (hCounter == {9{1'b1}}) begin
            if (vCounter != LINE_COUNT - 1) begin
                vCounter <= vCounter + 1'b1;
                if (vCounter == 34) begin
                    yRange <= 1;
                    yCounter <= 0;
                    addr <= 0;
                end
            end
            else begin
                vCounter <= 0;
            end
        end
    end

    assign pixel = shiftReg[7];
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