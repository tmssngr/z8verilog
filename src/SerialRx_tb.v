`include "assert.vh"

module testSerialRx();
  reg clk = 0;
  reg serialIn = 1;

  localparam BIT_DELAY = 3;

  wire [7:0] data;
  wire       dataReady;
  SerialRx #(
    .counterBits(2),
    .delay(BIT_DELAY)
  ) uut(
    .clk(clk),
    .serialIn(serialIn),
    .data(data),
    .dataReady(dataReady)
  );

  always
    #1  clk = ~clk;

  initial begin
    @(negedge clk);
    `assert(dataReady, 0);
    @(negedge clk);
    serialIn = 0; // start bit
    repeat (BIT_DELAY) @(negedge clk);
    serialIn = 1; // 0
    repeat (BIT_DELAY) @(negedge clk);
    serialIn = 0; // 1
    repeat (BIT_DELAY) @(negedge clk);
    serialIn = 1; // 2
    repeat (BIT_DELAY) @(negedge clk);
    serialIn = 0; // 3
    repeat (BIT_DELAY) @(negedge clk);
    serialIn = 0; // 4
    repeat (BIT_DELAY) @(negedge clk);
    serialIn = 1; // 5
    repeat (BIT_DELAY) @(negedge clk);
    serialIn = 1; // 6
    repeat (BIT_DELAY) @(negedge clk);
    serialIn = 0; // 7
    repeat (BIT_DELAY) @(negedge clk);
    serialIn = 1; // stop bit
    repeat (BIT_DELAY) @(negedge clk);
    `assert(data, 8'b0110_0101);
    `assert(dataReady, 1);

    serialIn = 0; // start bit
    @(negedge clk);
    `assert(dataReady, 0); // the next start bit unsets the dataReady

    $display("%m: SUCCESS");
    $finish(0);
  end

  initial begin
    $dumpfile("SerialRx.vcd");
    $dumpvars(0, testSerialRx);
  end
endmodule
