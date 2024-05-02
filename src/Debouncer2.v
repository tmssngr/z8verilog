`default_nettype none

module Debouncer2 #(
    parameter counterBits = 4
)
(
    input wire clk,
    input wire in1,
    input wire in2,
    output reg out1,
    output reg out2
);
    reg [counterBits - 1:0] counter = 0;
    reg prev1 = 0;
    reg prev2 = 0;

    initial begin
        out1 <= 0;
        out2 <= 0;
    end

    always @(posedge clk) begin
        if (in1 == prev1 & in2 == prev2) begin
            if (counter == {counterBits{1'b1}}) begin
                out1 <= prev1;
                out2 <= prev2;
            end
            else begin
                counter <= counter + 1'b1;
            end
        end
        else begin
            counter <= 0;
            prev1 <= in1;
            prev2 <= in2;
        end
    end
endmodule
