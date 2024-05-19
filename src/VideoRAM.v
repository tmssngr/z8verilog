`default_nettype none

`include "Memory.v"

module VideoRAM(
    input wire       clk,
    input wire[12:0] x,
    input wire[12:0] y,
    input wire       visible,
    output wire      pixel,
    output wire      valid
);
    reg [7:0] memory[0 : 2047];
    reg [7:0] dataOut;
    reg[10:0] addr;
    wire strobe;

    integer i;
    initial begin
        for (i = 0; i < 2048; i = i + 1) begin
            memory[i] = 8'h0;
        end
        memory[11'h000] = 8'b00010000;
        memory[11'h028] = 8'b00111000;
        memory[11'h050] = 8'b01101100;
        memory[11'h080] = 8'b11000110;
        memory[11'h0A8] = 8'b11111110;
        memory[11'h0D0] = 8'b11000110;
        memory[11'h100] = 8'b11000110;
        memory[11'h128] = 8'h0;

        memory[11'h001] = 8'b00000000;
        memory[11'h029] = 8'b01111000;
        memory[11'h051] = 8'b00001100;
        memory[11'h081] = 8'b01111100;
        memory[11'h0a9] = 8'b11001100;
        memory[11'h0d1] = 8'b11001100;
        memory[11'h101] = 8'b01110110;
        memory[11'h129] = 8'b0;

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

    wire[8:0] xByteCounter = x[12:4];
    wire[2:0] xBitCounter = x[3:1];
    reg[1:0]  addrOffsetCounter = 0;

    reg[7:0] dataSR = 0;
    reg[1:0] validSR = 0;

    assign strobe = visible & xBitCounter == 0 & x[0] == 0;

    always @(posedge clk) begin
        if (y == 0 & x == -1) begin
            addrOffsetCounter <= 0;
            addr <= 0;
        end

        if (x[0] == 0) begin
            dataSR <= {dataSR[6:0], 1'b0};
            validSR <= {validSR[0], visible};

            if (y >= 0 & y < 192 * 2 && xBitCounter == 1 & xByteCounter < 40) begin
                dataSR <= dataOut;
                addr <= addr + 4'd1;
                if (xByteCounter == 39) begin
                    if (y[0]) begin
                        addr <= addr - 11'd39;
                    end
                    else begin
                        if (addrOffsetCounter[1]) begin
                            addr <= addr + 4'd9;
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

    assign pixel = dataSR[7];
    assign valid = validSR[1];
endmodule