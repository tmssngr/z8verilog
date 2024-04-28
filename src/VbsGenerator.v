`ifndef VBS_GENERATOR
`define VBS_GENERATOR

module VideoRam(
    input wire       clk,
    input wire[12:0] addr,
    output reg[7:0]  data
);
    reg [7:0] mem0[0:2047];
    reg [7:0] mem1[0:2047];
    reg [7:0] mem2[0:2047];
    reg [7:0] mem3[0:2047];
    integer i;
    initial begin
        for (i = 0; i < 2048; i = i + 1) begin
            mem0[i] = i;
            mem1[i] = i;
            mem2[i] = i;
        end
        for (i = 0; i < 2048; i = i + 1) begin
            mem3[i] = i;
        end
        mem0[11'h000] = 8'b00010000;
        mem0[11'h028] = 8'b00111000;
        mem0[11'h050] = 8'b01101100;
        mem0[11'h080] = 8'b11000110;
        mem0[11'h0A8] = 8'b11111110;
        mem0[11'h0D0] = 8'b11000110;
        mem0[11'h100] = 8'b11000110;
        mem0[11'h128] = 8'h0;

        mem0[11'h027] = 8'b00000000;
        mem0[11'h04F] = 8'b01111000;
        mem0[11'h077] = 8'b00001100;
        mem0[11'h0A7] = 8'b01111100;
        mem0[11'h0CF] = 8'b11001100;
        mem0[11'h0F7] = 8'b11001100;
        mem0[11'h127] = 8'b01110110;
        mem0[11'h14F] = 8'b0;

        mem3[11'h780] = 8'b11111110;
        mem3[11'h790] = 8'b01100010;
        mem3[11'h7a0] = 8'b01100000;
        mem3[11'h7b0] = 8'b01111100;
        mem3[11'h7c0] = 8'b01100000;
        mem3[11'h7d0] = 8'b01100010;
        mem3[11'h7e0] = 8'b11111110;
        mem3[11'h7f0] = 8'b0;

        mem3[11'h78F] = 8'h0;
        mem3[11'h79F] = 8'b01111100;
        mem3[11'h7aF] = 8'b11000110;
        mem3[11'h7bF] = 8'b11111110;
        mem3[11'h7cF] = 8'b11000000;
        mem3[11'h7dF] = 8'b11000110;
        mem3[11'h7eF] = 8'b01111100;
        mem3[11'h7fF] = 8'h0;
    end

    always @(posedge clk) begin
        case (addr[12:11])
            0 : data <= mem0[addr[10:0]];
            1 : data <= mem1[addr[10:0]];
            2 : data <= mem2[addr[10:0]];
            default : data <= mem3[addr[10:0]];
        endcase
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

    VideoRam ram(
        .clk(clk),
        .addr(addr),
        .data(data)
    );

    reg xRange = 0;
    reg yRange = 0;
    reg[8:0] xCounter = 0;
    reg[7:0] yCounter = 0;
    reg[1:0] offsetCounter = 0;
    wire[3:0] offset = xCounter[8:3] == 6'b10_0111 && offsetCounter[1] ? 4'd9 : 4'd1;

    reg[7:0] shiftReg = 0;

    reg[12:0] addr = 0;
    wire[7:0] data;
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
                    shiftReg <= data;
                    addr <= addr + offset;
                end

                if (xCounter[8:3] == 6'b10_0111 && xCounter[2:0] == 3'b111) begin // 27 << 3 + 7 = 319
                    xRange <= 0;
                    if (yCounter == 8'hBF) begin
                        yRange <= 0;
                    end
                    else begin
                        yCounter <= yCounter + 1'b1;
                    end

                    offsetCounter <= offsetCounter[1] ? 0 : offsetCounter + 1;
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
                    offsetCounter <= 0;
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