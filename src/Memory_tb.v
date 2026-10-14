module testMemory;
    reg clk = 0;
    reg r_clk = 0;
    always #5 clk = ~clk;
    always #7 r_clk = ~r_clk;

    reg [12:0] addr = 0;
    reg [7:0] dataIn = 0;
    reg write = 0;
    reg strobe = 0;
    wire [7:0] dataOut;

    reg [12:0] r_addr = 0;
    reg r_strobe = 0;
    wire [7:0] r_data;

    DualPortRAM8k uut(
        .r_clk(r_clk), .r_addr(r_addr), .r_data(r_data),
        .r_strobe(r_strobe),
        .clk(clk), .addr(addr), .dataIn(dataIn), .dataOut(dataOut),
        .write(write), .strobe(strobe)
    );

    task check_cpu;
        input [7:0] expected;
        begin
            if (dataOut !== expected) begin
                $fatal(1, "CPU read: expected %h, got %h", expected, dataOut);
            end
        end
    endtask

    task check_video;
        input [7:0] expected;
        begin
            if (r_data !== expected) begin
                $fatal(1, "Video read: expected %h, got %h", expected, r_data);
            end
        end
    endtask

    task cpu_write;
        input [12:0] address;
        input [7:0] value;
        begin
            @(negedge clk);
            addr = address;
            dataIn = value;
            write = 1;
            strobe = 1;
            @(posedge clk);
            #1 check_cpu(value); // Write-through output remains available to the CPU.
            @(negedge clk);
            strobe = 0;
            write = 0;
        end
    endtask

    task cpu_read;
        input [12:0] address;
        input [7:0] expected;
        begin
            @(negedge clk);
            addr = address;
            strobe = 1;
            @(posedge clk);
            #1 check_cpu(expected);
            @(negedge clk);
            strobe = 0;
        end
    endtask

    task video_read;
        input [12:0] address;
        input [7:0] expected;
        begin
            @(negedge r_clk);
            r_addr = address;
            r_strobe = 1;
            @(posedge r_clk);
            #1 check_video(expected);
            @(negedge r_clk);
            r_strobe = 0;
        end
    endtask

    initial begin
        cpu_write(13'h0000, 8'h11);
        cpu_write(13'h07ff, 8'h22);
        cpu_write(13'h0800, 8'h33);
        cpu_write(13'h1000, 8'h55);
        cpu_write(13'h1fff, 8'h44);

        cpu_read(13'h0000, 8'h11);
        cpu_read(13'h07ff, 8'h22);
        cpu_read(13'h0800, 8'h33);
        cpu_read(13'h1000, 8'h55);
        cpu_read(13'h1fff, 8'h44);
        addr = 13'h0000;
        #1 check_cpu(8'h44); // The last selected bank must hold without a strobe.

        video_read(13'h07ff, 8'h22);
        r_addr = 13'h0800;
        #1 check_video(8'h22); // Address changes alone must not change the output.
        video_read(13'h0800, 8'h33);
        video_read(13'h1000, 8'h55);
        video_read(13'h1fff, 8'h44);
        video_read(13'h0000, 8'h11);

        $display("Memory: PASS");
        $finish(0);
    end
endmodule
