module top(
    input wire clk,
    output wire[5:0] leds
);

    reg[20:0] counter = 0;

    always @(posedge clk) begin
        counter <= counter + 20'b1;
    end

    SoC soC(
        .clk(counter[20]),
        .port2(leds)
    );

endmodule