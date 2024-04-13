`default_nettype none

module Memory #(
    parameter addrBusWidth = 8,
    parameter isRom = 1,
    parameter initFile = ""
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


module RAM2k(
    input  wire        clk,
    input  wire [10:0] addr,
    input  wire  [7:0] dataIn,
    output wire  [7:0] dataOut,
    input  wire        write,
    input  wire        strobe
);
    Memory #(
        .addrBusWidth(11),
        .isRom(0)
    ) ram(
        .clk(clk),
        .addr(addr),
        .dataOut(dataOut),
        .dataIn(dataIn),
        .write(write),
        .strobe(strobe)
    );
endmodule


module RAM8k(
    input  wire        clk,
    input  wire [12:0] addr,
    input  wire  [7:0] dataIn,
    output wire  [7:0] dataOut,
    input  wire        write,
    input  wire        strobe
);
    RAM2k ram0(
        .clk(clk),
        .addr(addr[10:0]),
        .dataIn(dataIn),
        .dataOut(dataOut0),
        .write(enable0 & write),
        .strobe(enable0 & strobe)
    );
    RAM2k ram1(
        .clk(clk),
        .addr(addr[10:0]),
        .dataIn(dataIn),
        .dataOut(dataOut1),
        .write(enable1 & write),
        .strobe(enable1 & strobe)
    );
    RAM2k ram2(
        .clk(clk),
        .addr(addr[10:0]),
        .dataIn(dataIn),
        .dataOut(dataOut2),
        .write(enable2 & write),
        .strobe(enable2 & strobe)
    );
    RAM2k ram3(
        .clk(clk),
        .addr(addr[10:0]),
        .dataIn(dataIn),
        .dataOut(dataOut3),
        .write(enable3 & write),
        .strobe(enable3 & strobe)
    );

    wire enable0 = addr[12:11] == 2'b00;
    wire enable1 = addr[12:11] == 2'b01;
    wire enable2 = addr[12:11] == 2'b10;
    wire enable3 = addr[12:11] == 2'b11;

    wire [7:0] dataOut0;
    wire [7:0] dataOut1;
    wire [7:0] dataOut2;
    wire [7:0] dataOut3;

    assign dataOut = enable0 ? dataOut0 :
                     enable1 ? dataOut1 :
                     enable2 ? dataOut2 : dataOut3;
endmodule

module ROM2k#(
    parameter initFile = ""
) (
    input  wire        clk,
    input  wire [10:0] addr,
    output wire  [7:0] dataOut,
    input  wire        strobe
);
    Memory #(
        .addrBusWidth(11),
        .isRom(1),
        .initFile(initFile)
    ) rom(
        .clk(clk),
        .addr(addr),
        .dataOut(dataOut),
        .dataIn(8'b0),
        .write(1'b0),
        .strobe(strobe)
    );
endmodule
