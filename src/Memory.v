`default_nettype none

module Memory #(
    parameter addrBusWidth = 8,
    parameter isRom = 1
) (
    input  wire                      clk,
    input  wire [addrBusWidth - 1:0] addr,
    input  wire                [7:0] dataIn,
    output reg                 [7:0] dataOut,
    input  wire                      write,
    input  wire                      strobe
);
    localparam size = 1 << addrBusWidth;
    reg [7:0] memory[0 : size - 1];
`ifdef BENCH
    integer i, file;
    initial begin
        for (i = 0; i < size; i = i + 1) begin
            memory[i] = 8'h0;
        end

        file = $fopen("memory.txt", "w");
    end
`endif

    `include "alu.vh"
    `include "assembly.vh"
    `include "sfr.vh"
    `include "program.vh"

`ifdef BENCH
    initial begin
        $fclose(file);
    end
`endif

    always @(posedge clk) begin
        if (strobe) begin
            if (write & ~isRom) begin
                memory[addr] <= dataIn;
                dataOut <= dataIn;
            end
            else begin
                dataOut <= memory[addr];
            end
        end
    end
endmodule
