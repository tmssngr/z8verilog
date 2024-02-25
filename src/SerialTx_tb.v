`include "assert.vh"

module testSerialTx();
    reg       clk = 0;
    reg [7:0] data = 0;
    reg       dataLoad = 0;
    wire      serialOut;
    wire      ready;

    localparam BIT_DELAY = 3;

    SerialTx #(
        .counterBits(2),
        .delay(BIT_DELAY)
    ) uut(
        .clk(clk),
        .data(data),
        .dataLoad(dataLoad),
        .serialOut(serialOut),
        .ready(ready)
    );

    integer i = 0;

    task testSerialOut;
        input expected;
        begin
            for (i = 0; i < BIT_DELAY; i = i + 1) begin
                `assert(ready, 0);
                `assert(serialOut, expected);
                @(negedge clk);
            end
        end
    endtask

    always
        #1  clk = ~clk;

    initial begin
        @(negedge clk);
        `assert(ready, 1);
        `assert(serialOut, 1);
        data = 8'h65;
        dataLoad = 1;
        @(negedge clk);
        `assert(ready, 0);
        testSerialOut(0); // start bit
        testSerialOut(1); // bit 0
        testSerialOut(0); // bit 1
        testSerialOut(1); // bit 2
        testSerialOut(0); // bit 3
        testSerialOut(0); // bit 4
        testSerialOut(1); // bit 5
        testSerialOut(1); // bit 6
        testSerialOut(0); // bit 7
        testSerialOut(1); // stop bit
        `assert(ready, 1);

        data = 8'hA0;
        @(negedge clk);
        `assert(ready, 1);
        dataLoad = 0;
        @(negedge clk);
        `assert(ready, 1);
        dataLoad = 1;
        @(negedge clk);
        `assert(ready, 0);
        testSerialOut(0); // start bit
        testSerialOut(0); // bit 0
        testSerialOut(0); // bit 1
        testSerialOut(0); // bit 2
        testSerialOut(0); // bit 3
        testSerialOut(0); // bit 4
        testSerialOut(1); // bit 5
        testSerialOut(0); // bit 6
        testSerialOut(1); // bit 7
        testSerialOut(1); // stop bit
        `assert(ready, 1);

        $display("%m: SUCCESS");
        $finish(0);
    end

    initial begin
        $dumpfile("SerialTx.vcd");
        $dumpvars(0, testSerialTx);
    end
endmodule
