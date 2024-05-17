`default_nettype none

`include "Memory.v"

module VideoRAM(
    input wire      clk, // assuming 8MHz
    input wire[8:0] x,
    input wire[7:0] y,
    input wire      visible,
    output wire     pixel,
    output wire     valid
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

    wire[5:0] xByteCounter = x[8:3];
    wire[2:0] xBitCounter = x[2:0];
    reg[1:0]  offsetCounter = 0;
    wire[3:0] addrOffset = xByteCounter == 39 && offsetCounter[1] ? 4'd9 : 4'd1;

    reg[7:0] dataSR = 0;
    reg[1:0] validSR = 0;

    assign strobe = visible & xBitCounter == 0;

    always @(posedge clk) begin
        dataSR <= {dataSR[6:0], 1'b0};
        validSR = {validSR[0], visible};

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
                dataSR <= dataOut;
                addr <= addr + addrOffset;
            end
        end
    end

    assign pixel = dataSR[7];
    assign valid = validSR[1];
endmodule