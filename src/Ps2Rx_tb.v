`include "assert.vh"

module testPs2Rx();
    reg clk = 0;
    reg reset = 0;
    reg ps2Clk = 1;
    reg ps2Data = 1;

    localparam BIT_DELAY = 3;

    wire [7:0] data;
    wire       dataReady;
    wire       error;
    Ps2Rx #(
        .counterBits(2),
        .minClk(2),
        .maxClk(4),
        .readAt(1)
    ) uut(
        .clk(clk),
        .ps2Clk(ps2Clk),
        .ps2Data(ps2Data),
        .reset(reset),
        .data(data),
        .dataReady(dataReady),
        .error(error)
    );

    always
        #1  clk = ~clk;

    task clkPulse;
        begin
            @(negedge clk);
            ps2Clk = 0; 
            repeat (BIT_DELAY) @(negedge clk);
            ps2Clk = 1; 
            repeat (BIT_DELAY - 1) @(negedge clk);
        end
    endtask

    initial begin
        @(negedge clk);
        `assert(dataReady, 0);
        @(negedge clk);
        
        ps2Data = 0; // start bit
        clkPulse();

        ps2Data = 1; // 0
        clkPulse();
        ps2Data = 0; // 1
        clkPulse();
        ps2Data = 1; // 2
        clkPulse();
        ps2Data = 0; // 3
        clkPulse();
        ps2Data = 0; // 4
        clkPulse();
        ps2Data = 1; // 5
        clkPulse();
        ps2Data = 1; // 6
        clkPulse();
        ps2Data = 0; // 7
        clkPulse();
        ps2Data = 1; // parity
        clkPulse();
        ps2Data = 1; // stop bit
        clkPulse();
        repeat (BIT_DELAY) @(negedge clk);
        `assert(data, 8'b0110_0101);
        `assert(dataReady, 1);

        ps2Clk = 0; // start bit
        @(negedge clk);
        `assert(dataReady, 0); // the next start bit unsets the dataReady

        $display("%m: SUCCESS");
        $finish(0);
    end

    initial begin
        $dumpfile("Ps2Rx.vcd");
        $dumpvars(0, testPs2Rx);
    end
endmodule
