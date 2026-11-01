module testProcessor();
    `include "sfr.vh"
    `include "states.vh"

    reg clk = 0;
    reg clkEnable = 1;
    reg reset = 0;
    reg serialIn = 1;
    wire [15:0] memAddr;
    wire memStrobe;
    reg [7:0] memDataRead;
    reg [7:0] memory[0:255];
    integer i;

    Processor uut(
        .clk(clk), .clkEnable(clkEnable), .reset(reset),
        .memAddr(memAddr), .memDataRead(memDataRead),
        .memDataWrite(), .memWrite(), .memStrobe(memStrobe),
        .serialIn(serialIn), .serialOut(), .isIsr(),
        .port2Out(), .port3Out()
    );

    always #1 clk = ~clk;

    always @(posedge clk) begin
        if (clkEnable && memStrobe)
            memDataRead <= memAddr < 256 ? memory[memAddr[7:0]] : 8'hFF;
    end

    task cpuStep;
        begin
            @(negedge clk);
        end
    endtask

    initial begin
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 8'hFF;
        memory[12] = 8'hE6; // ld IMR, #95h
        memory[13] = IMR;
        memory[14] = 8'h95;
        memory[15] = 8'h8B; // jr always, -2
        memory[16] = 8'hFE;

        cpuStep();
        if (uut.imr[7] !== 0 || uut.pc !== 16'h000C)
            $fatal(1, "Power-on reset must disable interrupts and restart the CPU");
        repeat (30) cpuStep();
        if (uut.imr !== 8'h95)
            $fatal(1, "IMR setup instruction did not execute");

        // Reset is sampled only on an enabled CPU clock.
        clkEnable = 0;
        reset = 1;
        repeat (3) cpuStep();
        if (uut.imr !== 8'h95)
            $fatal(1, "Disabled CPU clocks must preserve IMR");
        clkEnable = 1;
        cpuStep();
        if (uut.imr !== 8'h15 || uut.pc !== 16'h000C)
            $fatal(1, "Warm reset must clear IMR[7] and preserve individual masks");
        repeat (2) cpuStep();
        if (uut.imr !== 8'h15)
            $fatal(1, "Interrupts must stay disabled while reset is asserted");

        $display("%m: SUCCESS");
        $finish(0);
    end
endmodule
