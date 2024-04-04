`include "SerialTx.v"

`default_nettype none

module SerialTxDbg
#(
    parameter counterBits = 8,
    parameter delay = 234 // 27,000,000 (27Mhz) / 115200 Baud rate
                          // 9600 baud -> one bit has 1s / 9600 = 104.16 us length
)
(
    input wire       clk,
    input wire [7:0] data,
    input wire       dataLoad,
    output wire      serialOut,
    output wire      ready
);
    reg txLoad = 0;
    reg [7:0] txOut = 0;
    reg [7:0] buffer = 0;
    wire txReady;

    SerialTx #(
        .counterBits(counterBits),
        .delay(delay)
    ) tx(
        .clk(clk),
        .data(txOut),
        .dataLoad(txLoad),
        .serialOut(serialOut),
        .ready(txReady)
    );

    reg [2:0] state = 0;

    function [7:0] hexDigit(
        input [3:0] digit
    );
        hexDigit = digit < 4'hA 
                 ? { 4'h3, digit }
                 : digit + 8'h37;
    endfunction

    always @(posedge clk) begin
        if (state == 0 & dataLoad & txReady) begin
            buffer <= hexDigit(data[3:0]);
            txOut <= hexDigit(data[7:4]);
            txLoad <= 1;
            state <= state + 3'b1;
        end
        // wait for txReady to go low (accepted byte)
        else if (state == 1 & ~txReady) begin
            txLoad <= 0;
            state <= state + 3'b1;
        end
        // wait for txReady to go high (sent byte)
        else if (state == 2 & txReady) begin
            txOut <= buffer;
            txLoad <= 1;
            state <= state + 3'b1;
        end
        // wait for txReady to go low (accepted 2nd byte)
        else if (state == 3 & ~txReady) begin
            txLoad <= 0;
            state <= state + 3'b1;
        end
        // wait for txReady to go high (sent 2nd byte)
        else if (state == 4 & txReady) begin
            txOut <= 8'h0a;
            txLoad <= 1;
            state <= state + 3'b1;
        end
        // wait for txReady to go low (accepted 3rd byte)
        else if (state == 5 & ~txReady) begin
            txLoad <= 0;
            state <= 0;
        end
    end

    assign ready = state == 0 & txReady;
endmodule