    if (tmr[0]) begin
        loadT0();
        tmr[0] <= 0;
        if (sioTxCounter == 0 && sioTxState == SIO_START) begin
            // start bit
            serialOut <= 0;
        end
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
                if (p3m[6]) begin
                    if (sioRxState != SIO_IDLE) begin
                        sioRxCounter <= sioRxCounter + 1'b1;
                        if (sioRxCounter == 7) begin
                            sioRxState <= sioRxState + 1'b1;
                            if (sioRxState == SIO_START) begin
                                // no start bit any more -> restart
                                if (serialIn) begin
                                    sioRxState <= SIO_IDLE;
                                end
                            end
                            else if (sioRxState == SIO_STOP1) begin
                                sioRxState <= SIO_IDLE;
                                if (serialIn) begin
                                    sioRx <= sioRxShiftRegister;
                                    // IRQ3
                                    irq[3] <= 1;
                                end
                            end
                            else begin
                                sioRxShiftRegister <= {serialIn, sioRxShiftRegister[7:1]};
                            end
                        end
                    end
                    if (sioTxState != SIO_IDLE) begin
                        sioTxCounter <= sioTxCounter + 1'b1;
                        if (sioTxCounter == 15) begin
                            if (sioTxState == SIO_STOP2) begin
                                // IRQ4
                                irq[4] <= 1;
                                sioTxState <= SIO_IDLE;
                            end
                            else begin
                                serialOut <= sioTx[0];
                                sioTx <= {1'b1, sioTx[7:1]};
                                sioTxState <= sioTxState + 1'b1;
                            end
                        end
                    end
                end
                else begin
                    // IRQ4
                    irq[4] <= 1;
                end
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

// SIO RX =================================================
    sioRxPrevIn <= serialIn;
    if (sioRxState == SIO_IDLE) begin
        if (sioRxPrevIn & ~serialIn) begin
            sioRxState <= sioRxState + 1'b1;
            sioRxCounter <= 0;
            loadT0();
        end
    end
