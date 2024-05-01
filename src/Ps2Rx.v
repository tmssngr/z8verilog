`default_nettype none

module Ps2Rx #(
    parameter counterBits = 8,
    parameter minClk = 15,
    parameter maxClk = 25,
    parameter readAt = 5
)
(
    input wire      clk,
    input wire      ps2Clk,
    input wire      ps2Data,
    input wire      reset,
    output reg[7:0] data,
    output reg      dataReady,
    output reg      error
);
    initial begin
        dataReady <= 0;
    end

    localparam STATE_IDLE       = 0;
    localparam STATE_START_BIT  = 1;
    localparam STATE_DATA_BIT0  = 2;
    localparam STATE_DATA_BIT1  = 3;
    localparam STATE_DATA_BIT2  = 4;
    localparam STATE_DATA_BIT3  = 5;
    localparam STATE_DATA_BIT4  = 6;
    localparam STATE_DATA_BIT5  = 7;
    localparam STATE_DATA_BIT6  = 8;
    localparam STATE_DATA_BIT7  = 9;
    localparam STATE_PARITY_BIT = 10;
    localparam STATE_STOP_BIT   = 11;

    reg [3:0] state = STATE_IDLE;

    reg                     prevClk = 1;
    reg                     parity = 0;
    reg [counterBits - 1:0] counter = 0;

    always @(posedge clk) begin
        if (reset) begin
            dataReady <= 0;
            error <= 0;
            state <= STATE_IDLE;
        end
        else begin
            if (state == STATE_IDLE) begin
                if (~ps2Clk) begin
                    state <= state + 1;
                    dataReady <= 0;
                    error <= 0;
                    parity <= 0;
                    prevClk <= 0;
                    counter <= 0;
                    data <= 0;
                end
            end
            else begin
                if (prevClk != ps2Clk) begin
                    prevClk <= ps2Clk;
                    counter <= 0;
                    if (counter < minClk) begin
                        data <= {4'h1, state};
                        error <= 1;
                        state <= STATE_IDLE;
                    end
                    else if (ps2Clk) begin
                        if (state == STATE_STOP_BIT) begin
                            state <= STATE_IDLE;
                            dataReady <= ~error;
                        end
                        else begin
                            state <= state + 1'b1;
                        end
                    end
                end
                else begin
                    counter <= counter + 1'b1;

                    if (~prevClk && counter == readAt) begin
                        case (state)
                        STATE_START_BIT: begin
                            if (ps2Data) begin
                                state <= STATE_IDLE;
                            end
                        end
                        STATE_DATA_BIT0,
                        STATE_DATA_BIT1,
                        STATE_DATA_BIT2,
                        STATE_DATA_BIT3,
                        STATE_DATA_BIT4,
                        STATE_DATA_BIT5,
                        STATE_DATA_BIT6,
                        STATE_DATA_BIT7: begin
                            if (~error) begin
                                data <= {ps2Data, data[7:1]};
                            end
                            parity <= parity ^ ps2Data;
                        end
                        STATE_PARITY_BIT: begin
                            parity <= parity ^ ps2Data;
                        end
                        STATE_STOP_BIT: begin
                            if (~parity | ~ps2Data) begin
                                data <= {4'h2, state};
                                error <= 1;
                            end
                        end
                        endcase
                    end
                    else if (counter > maxClk) begin
                        data <= {4'h4, state};
                        error <= 1;
                        state <= STATE_IDLE;
                    end
                end
            end
        end
    end
endmodule
