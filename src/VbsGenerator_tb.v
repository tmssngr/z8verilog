`include "assert.vh"

module testVbsGenerator();
    reg  clk = 0;
    wire sync;
    wire pixel;

    parameter SYNC_LENGTH = 14;
    parameter AFTER_SYNC_LENGTH = 241;

    VbsGenerator uut(
        .clk(clk),
        .sync(sync),
        .pixel(pixel)
    );

    integer i, j, k;

    always
        #1 clk = ~clk;

    initial begin
        for (k = 0; k < 3; k = k + 1) begin
            // 1st line ---------------------------------------
            // _
            //  \___________
            @(negedge clk);
            `assert(sync, 1);

            for (i = 0; i < SYNC_LENGTH; i = i + 1) begin
                @(negedge clk);
                `assert(sync, 0);
            end

            // no 2nd sync toggle

            for (i = 0; i < AFTER_SYNC_LENGTH; i = i + 1) begin
                @(negedge clk);
                `assert(sync, 0);
            end

            // 2nd, 3rd line ----------------------------------
            //   __
            // _/  \________
            for (j = 0; j < 2; j= j + 1) begin
                @(negedge clk);
                `assert(sync, 0);

                // hsync
                for (i = 0; i < SYNC_LENGTH; i = i + 1) begin
                    @(negedge clk);
                    `assert(sync, 1);
                end

                for (i = 0; i < AFTER_SYNC_LENGTH; i = i + 1) begin
                    @(negedge clk);
                    `assert(sync, 0);
                end
            end

            // 4th line ---------------------------------------
            //   ___________
            // _/
            @(negedge clk);
            `assert(sync, 0);

            for (i = 0; i < SYNC_LENGTH; i = i + 1) begin
                @(negedge clk);
                `assert(sync, 1);
            end

            // no 2nd sync toggle

            for (i = 0; i < AFTER_SYNC_LENGTH; i = i + 1) begin
                @(negedge clk);
                `assert(sync, 1);
            end

            // 5th line ---------------------------------------
            // _    ________
            //  \__/
            for (j = 0; j < 309; j = j + 1) begin
                @(negedge clk);
                `assert(sync, 1);

                for (i = 0; i < SYNC_LENGTH; i = i + 1) begin
                    @(negedge clk);
                    `assert(sync, 0);
                end

                // no 2nd sync toggle

                for (i = 0; i < AFTER_SYNC_LENGTH; i = i + 1) begin
                    @(negedge clk);
                    `assert(sync, 1);
                end
            end
        end

        $display("%m: SUCCESS");
        $finish(0);
    end

    initial begin
        $dumpfile("VbsGenerator.vcd");
        $dumpvars(0, uut);
    end
endmodule