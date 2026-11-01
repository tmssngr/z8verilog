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
    reg [8:0] timerBeforeEdge;
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

        // A serial edge must not reload a running timer when UART mode is off.
        memory[12] = 8'hE6; // ld T0, #3
        memory[13] = T0;
        memory[14] = 3;
        memory[15] = 8'hE6; // ld PRE0, #09h (divide by two, continuous)
        memory[16] = PRE0;
        memory[17] = 8'h09;
        memory[18] = 8'hE6; // load and enable T0
        memory[19] = TMR;
        memory[20] = 8'h03;
        memory[21] = 8'h8B; // jr always, -2
        memory[22] = 8'hFE;
        reset = 0;
        repeat (50) cpuStep();
        while (uut.pre0counter !== 9'd8) cpuStep();
        timerBeforeEdge = uut.t0counter;
        serialIn = 0;
        cpuStep();
        if (uut.sioRxState !== SIO_IDLE)
            $fatal(1, "UART must ignore start edges while disabled");
        if (uut.pre0counter !== 9'd7 || uut.t0counter !== timerBeforeEdge)
            $fatal(1, "Disabled UART input must not disturb Timer 0");

        // Toggle UART mode through real P3M writes, including mid-frame disable.
        reset = 1;
        serialIn = 1;
        for (i = 12; i < 44; i = i + 1) memory[i] = 8'hFF;
        memory[12] = 8'hE6; // enable UART
        memory[13] = P3M;
        memory[14] = 8'h40;
        memory[25] = 8'hE6; // disable UART after ten NOPs
        memory[26] = P3M;
        memory[27] = 8'h00;
        memory[38] = 8'hE6; // enable UART again after ten NOPs
        memory[39] = P3M;
        memory[40] = 8'h40;
        memory[41] = 8'h8B; // jr always, -2
        memory[42] = 8'hFE;
        cpuStep();
        reset = 0;
        while (uut.p3m !== 8'h40) cpuStep();
        serialIn = 0;
        cpuStep();
        if (uut.sioRxState !== SIO_START || uut.t0counter !== 9'd3)
            $fatal(1, "Enabled UART must start reception and reload Timer 0");
        while (uut.p3m !== 0) cpuStep();
        if (uut.sioRxState !== SIO_IDLE || uut.sioTxState !== SIO_IDLE)
            $fatal(1, "Disabling UART mode must abandon the active frame");
        serialIn = 1;
        cpuStep();
        serialIn = 0;
        cpuStep();
        if (uut.sioRxState !== SIO_IDLE)
            $fatal(1, "Disabled UART must ignore subsequent serial edges");
        while (uut.p3m !== 8'h40) cpuStep();
        if (uut.sioRxState !== SIO_IDLE)
            $fatal(1, "Enabling UART on a static low input must wait for a new edge");
        serialIn = 1;
        cpuStep();
        serialIn = 0;
        cpuStep();
        if (uut.sioRxState !== SIO_START)
            $fatal(1, "Re-enabled UART must accept a new start edge");

        $display("%m: SUCCESS");
        $finish(0);
    end

    initial begin
        #10000;
        $fatal(1, "Processor test timed out");
    end
endmodule
