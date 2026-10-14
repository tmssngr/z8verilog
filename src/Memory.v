`ifndef MEMORY
`define MEMORY

`default_nettype none

module RAM2k(
    input  wire        clk,
    input  wire        clkEnable,
    input  wire [10:0] addr,
    input  wire  [7:0] dataIn,
    output reg   [7:0] dataOut,
    input  wire        write,
    input  wire        strobe
);
    localparam size = 1 << 11;
    reg [7:0] memory[0 : size - 1];
`ifdef BENCH
    integer i, file;
    initial begin
        for (i = 0; i < size; i = i + 1) begin
            memory[i] = 8'h0;
        end
    end
`endif

    always @(posedge clk) begin
        if (clkEnable & strobe) begin
            if (write) begin
                memory[addr] <= dataIn;
                dataOut <= dataIn;
            end
            else begin
                dataOut <= memory[addr];
            end
        end
    end
endmodule


module RAM8k(
    input  wire        clk,
    input  wire        clkEnable,
    input  wire [12:0] addr,
    input  wire  [7:0] dataIn,
    output wire  [7:0] dataOut,
    input  wire        write,
    input  wire        strobe
);
    wire enable0 = addr[12:11] == 2'b00;
    wire enable1 = addr[12:11] == 2'b01;
    wire enable2 = addr[12:11] == 2'b10;
    wire enable3 = addr[12:11] == 2'b11;

    wire [7:0] dataOut0;
    wire [7:0] dataOut1;
    wire [7:0] dataOut2;
    wire [7:0] dataOut3;

    RAM2k ram0(
        .clk(clk),
        .clkEnable(clkEnable),
        .addr(addr[10:0]),
        .dataIn(dataIn),
        .dataOut(dataOut0),
        .write(enable0 & write),
        .strobe(enable0 & strobe)
    );
    RAM2k ram1(
        .clk(clk),
        .clkEnable(clkEnable),
        .addr(addr[10:0]),
        .dataIn(dataIn),
        .dataOut(dataOut1),
        .write(enable1 & write),
        .strobe(enable1 & strobe)
    );
    RAM2k ram2(
        .clk(clk),
        .clkEnable(clkEnable),
        .addr(addr[10:0]),
        .dataIn(dataIn),
        .dataOut(dataOut2),
        .write(enable2 & write),
        .strobe(enable2 & strobe)
    );
    RAM2k ram3(
        .clk(clk),
        .clkEnable(clkEnable),
        .addr(addr[10:0]),
        .dataIn(dataIn),
        .dataOut(dataOut3),
        .write(enable3 & write),
        .strobe(enable3 & strobe)
    );

    assign dataOut = enable0 ? dataOut0 :
                     enable1 ? dataOut1 :
                     enable2 ? dataOut2 : dataOut3;
endmodule

module SemiDualPortRAM2k(
    input  wire        w_clk,
    input  wire [10:0] w_addr,
    input  wire  [7:0] w_data,
    input  wire        w_enable,
    input  wire        r_clk,
    input  wire [10:0] r_addr,
    output reg   [7:0] r_data,
    input  wire        r_enable
);
    localparam size = 1 << 11;
    // A simultaneous read and write of one address has no defined result.
    reg [7:0] memory[0 : size - 1] /* synthesis syn_ramstyle = "no_rw_check" */;

    always @(posedge w_clk) begin
        if (w_enable) begin
            memory[w_addr] <= w_data;
        end
    end

    always @(posedge r_clk) begin
        if (r_enable) begin
            r_data <= memory[r_addr];
        end
    end
endmodule

module DualPortRAM2k(
    input  wire        r_clk,
    input  wire [10:0] r_addr,
    output wire  [7:0] r_data,
    input  wire        r_strobe,

    input  wire        clk,
    input  wire [10:0] addr,
    input  wire  [7:0] dataIn,
    output wire  [7:0] dataOut,
    input  wire        write,
    input  wire        strobe
);
    wire write_enable = strobe & write;

    // Mirror writes so the CPU and video each have one synchronous read port.
    // This avoids the unsupported dual-port read-before-write mode.
    RAM2k cpu_ram(
        .clk(clk), .clkEnable(1'b1), .addr(addr), .dataIn(dataIn),
        .dataOut(dataOut), .write(write), .strobe(strobe)
    );
    SemiDualPortRAM2k video_ram(
        .w_clk(clk), .w_addr(addr), .w_data(dataIn), .w_enable(write_enable),
        .r_clk(r_clk), .r_addr(r_addr), .r_data(r_data), .r_enable(r_strobe)
    );
endmodule

module DualPortRAM8k(
    input  wire        r_clk,
    input  wire [12:0] r_addr,
    output wire  [7:0] r_data,
    input  wire        r_strobe,

    input  wire        clk,
    input  wire [12:0] addr,
    input  wire  [7:0] dataIn,
    output wire  [7:0] dataOut,
    input  wire        write,
    input  wire        strobe
);
    wire r_enable0 = r_addr[12:11] == 2'b00;
    wire r_enable1 = r_addr[12:11] == 2'b01;
    wire r_enable2 = r_addr[12:11] == 2'b10;
    wire r_enable3 = r_addr[12:11] == 2'b11;

    wire [7:0] r_data0;
    wire [7:0] r_data1;
    wire [7:0] r_data2;
    wire [7:0] r_data3;

    wire enable0 = addr[12:11] == 2'b00;
    wire enable1 = addr[12:11] == 2'b01;
    wire enable2 = addr[12:11] == 2'b10;
    wire enable3 = addr[12:11] == 2'b11;

    wire [7:0] dataOut0;
    wire [7:0] dataOut1;
    wire [7:0] dataOut2;
    wire [7:0] dataOut3;

    DualPortRAM2k ram0(
        .r_clk(r_clk),
        .r_addr(r_addr[10:0]),
        .r_data(r_data0),
        .r_strobe(r_enable0 & r_strobe),

        .clk(clk),
        .addr(addr[10:0]),
        .dataIn(dataIn),
        .dataOut(dataOut0),
        .write(enable0 & write),
        .strobe(enable0 & strobe)
    );
    DualPortRAM2k ram1(
        .r_clk(r_clk),
        .r_addr(r_addr[10:0]),
        .r_data(r_data1),
        .r_strobe(r_enable1 & r_strobe),

        .clk(clk),
        .addr(addr[10:0]),
        .dataIn(dataIn),
        .dataOut(dataOut1),
        .write(enable1 & write),
        .strobe(enable1 & strobe)
    );
    DualPortRAM2k ram2(
        .r_clk(r_clk),
        .r_addr(r_addr[10:0]),
        .r_data(r_data2),
        .r_strobe(r_enable2 & r_strobe),

        .clk(clk),
        .addr(addr[10:0]),
        .dataIn(dataIn),
        .dataOut(dataOut2),
        .write(enable2 & write),
        .strobe(enable2 & strobe)
    );
    DualPortRAM2k ram3(
        .r_clk(r_clk),
        .r_addr(r_addr[10:0]),
        .r_data(r_data3),
        .r_strobe(r_enable3 & r_strobe),

        .clk(clk),
        .addr(addr[10:0]),
        .dataIn(dataIn),
        .dataOut(dataOut3),
        .write(enable3 & write),
        .strobe(enable3 & strobe)
    );

    reg [1:0] r_bank;
    reg [1:0] bank;
    always @(posedge r_clk) begin
        if (r_strobe) begin
            r_bank <= r_addr[12:11];
        end
    end
    always @(posedge clk) begin
        if (strobe) begin
            bank <= addr[12:11];
        end
    end

    assign r_data = r_bank == 2'b00 ? r_data0 :
                    r_bank == 2'b01 ? r_data1 :
                    r_bank == 2'b10 ? r_data2 : r_data3;
    assign dataOut = bank == 2'b00 ? dataOut0 :
                     bank == 2'b01 ? dataOut1 :
                     bank == 2'b10 ? dataOut2 : dataOut3;
endmodule

module ROM2k#(
    parameter initFile = ""
) (
    input  wire        clk,
    input  wire        clkEnable,
    input  wire [10:0] addr,
    output reg   [7:0] dataOut,
    input  wire        strobe
);
    localparam size = 1 << 11;
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
        if (clkEnable & strobe) begin
            dataOut <= memory[addr];
        end
    end
endmodule

`endif
