`ifndef VBS_GENERATOR
`define VBS_GENERATOR

module VRAM (
    input  wire        clk,
    input  wire [10:0] addr,
    output reg   [7:0] dataOut,
    input  wire        strobe
);
    reg [7:0] memory[0 : 2047];

    integer i;
    initial begin
        for (i = 0; i < 2048; i = i + 1) begin
            memory[i] = 0;
        end
        memory[11'h000] = 8'b00010000;
        memory[11'h028] = 8'b00111000;
        memory[11'h050] = 8'b01101100;
        memory[11'h080] = 8'b11000110;
        memory[11'h0A8] = 8'b11111110;
        memory[11'h0D0] = 8'b11000110;
        memory[11'h100] = 8'b11000110;
        memory[11'h128] = 8'h0;

        memory[11'h027] = 8'b00000000;
        memory[11'h04F] = 8'b01111000;
        memory[11'h077] = 8'b00001100;
        memory[11'h0A7] = 8'b01111100;
        memory[11'h0CF] = 8'b11001100;
        memory[11'h0F7] = 8'b11001100;
        memory[11'h127] = 8'b01110110;
        memory[11'h14F] = 8'b0;
    end

    always @(posedge clk) begin
        if (strobe) begin
            dataOut <= memory[addr];
        end
    end
endmodule

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

    reg[10:0] addr = 0;
    wire[7:0] data;
    wire strobe;
    VRAM ram(
        .clk(clk),
        .addr(addr),
        .dataOut(data),
        .strobe(strobe)
    );

    reg xRange = 0;
    reg yRange = 0;
    reg[5:0] xByteCounter = 0;
    reg[2:0] xBitCounter = 0;
    reg[7:0] yCounter = 0;
    reg[1:0] offsetCounter = 0;
    wire[3:0] offset = xByteCounter == 39 && offsetCounter[1] ? 4'd9 : 4'd1;

    reg[7:0] shiftReg = 0;

    assign strobe = xRange & yRange & xBitCounter == 0;
    wire loadShiftReg = xRange & yRange & xBitCounter == 1;

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
                // xByteCounter <= 0;
                // xBitCounter <= 0;
            end

            if (xRange) begin
                xBitCounter <= xBitCounter + 1'b1;

                if (loadShiftReg) begin
                    shiftReg <= data;
                    addr <= addr + offset;
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
                    addr <= 0;
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