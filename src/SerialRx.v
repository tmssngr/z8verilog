`default_nettype none

module SerialRx
#(
    parameter counterBits = 8,
    parameter delay = 234 // 27,000,000 (27Mhz) / 115200 Baud rate
                          // 9600 baud -> one bit has 1s / 9600 = 104.16 us length
)
(
    input wire      clk,
    input wire      serialIn,
    output reg[7:0] data,
    output reg      dataReady
);

    localparam delayHalf = delay / 2;

    reg [counterBits - 1:0] counter = 0;
    reg  [1:0] state = 0;
    reg  [2:0] bitNumber = 0;

    initial begin
        dataReady <= 0;
    end

    localparam STATE_IDLE      = 0;
    localparam STATE_START_BIT = 1;
    localparam STATE_DATA_BITS = 2;
    localparam STATE_STOP_BIT  = 3;

    always @(posedge clk) begin
        case (state)
        STATE_IDLE: begin
            if (serialIn == 0) begin
                state <= STATE_START_BIT;
                counter <= 1;
                bitNumber <= 0;
                dataReady <= 0;
            end
        end 
        STATE_START_BIT: begin
            if (counter == delayHalf) begin
                state <= STATE_DATA_BITS;
                counter <= 0;
            end 
            else begin
                counter <= counter + 1'b1;
            end
        end
        STATE_DATA_BITS: begin
            if (counter == delay - 1) begin
                counter <= 0;
                data <= {serialIn, data[7:1]};
                bitNumber <= bitNumber + 1'b1;
                if (bitNumber == 3'b111) begin
                    state <= STATE_STOP_BIT;
                end
            end
            else begin
                counter <= counter + 1'b1;
            end
        end
        STATE_STOP_BIT: begin
            if (counter == delay - 1) begin
                if (serialIn == 1) begin
                    dataReady <= 1;
                end
                state <= STATE_IDLE;
                counter <= 0;
            end
            else begin
                counter <= counter + 1'b1;
            end
        end
        endcase
    end
endmodule
