reg [8:0] pre0counter = 0;
reg [7:0] pre0 = 0;
reg [8:0] t0counter = 0;
reg [7:0] t0load = 0;

reg [8:0] pre1counter = 0;
reg [7:0] pre1 = 0;
reg [8:0] t1counter = 0;
reg [7:0] t1load = 0;

reg [7:0] tmr = 0;

always @(posedge clk) begin
    if (tmr[0]) begin
`ifdef BENCH
        $display("loading timer t0 with %h (pre: %h)", t0load, pre0[7:2]);
`endif
        pre0counter <= { pre0[7:2] == 0, pre0 | 2'b11 };
        t0counter <= { t0load == 0, t0load };
        tmr[0] <= 0;
    end
    if (tmr[1] & ~tmr[0]) begin
        // When the Prescaler Counter reaches its end-of-count, the initial value is reloaded and
        // counting continues. The prescaler never actually reaches 0. For example, if the prescaler is
        // set to divide-by-three, the count sequence is:
        // 3–2–1–3–2–1–3–2–1–3...
        if (pre0counter == 9'b0_000_001_00) begin
            pre0counter <= { pre0[7:2] == 0, pre0 | 2'b11 };
            if (t0counter == 1) begin
`ifdef BENCH
                $display("timer t0 overflow");
`endif
                t0counter <= { t0load == 0, t0load };
                if (pre0[0] == 0) begin
                    tmr[1] <= 0;
                end
                // IRQ4
                irq[4] <= 1;
            end
            else begin
                t0counter <= t0counter - 9'b1;
            end
        end
        else begin
            pre0counter <= pre0counter - 9'b1;
        end
    end
    if (tmr[2]) begin
`ifdef BENCH
        $display("loading timer t1 with %h (pre: %h)", t1load, pre1[7:2]);
`endif
        pre1counter <= { pre1[7:2] == 0, pre1 | 2'b11 };
        t1counter <= { t1load == 0, t1load };
        tmr[2] <= 0;
    end
    if (tmr[3] & ~tmr[2]) begin
        if (pre1counter == 9'b0_000_001_00) begin
            pre1counter <= { pre1[7:2] == 0, pre1 | 2'b11 };
            if (t1counter == 1) begin
`ifdef BENCH
                $display("timer t1 overflow");
`endif
                t1counter <= { t1load == 0, t1load };
                if (pre1[0] == 0) begin
                    tmr[3] <= 0;
                end
                // IRQ5
                irq[5] <= 1;
            end
            else begin
                t1counter <= t1counter - 9'b1;
            end
        end
        else begin
            pre1counter <= pre1counter - 9'b1;
        end
    end
end