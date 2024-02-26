`default_nettype none

module SerialTx
#(
    parameter counterBits = 8,
    parameter delay = 234 // 27,000,000 (27Mhz) / 115200 Baud rate
                          // 9600 baud -> one bit has 1s / 9600 = 104.16 us length
)
(
    input wire       clk,
    input wire [7:0] data,
    input wire       dataLoad,
    output reg       serialOut,
    output wire      ready
);

    localparam STATE_IDLE      = 0;
    localparam STATE_START_BIT = 1;
    localparam STATE_DATA_BITS = 2;
    localparam STATE_STOP_BIT  = 3;

    reg [counterBits - 1:0] counter = 0;
    reg [1:0] state = 0;
    reg [2:0] bitCount = 0;
    reg [7:0] bits = 0;
    reg prevDataLoad = 0;

    initial begin
        serialOut <= 1;
    end

    always @(posedge clk) begin
        prevDataLoad <= dataLoad;
        case (state)
        STATE_IDLE: begin
            if (dataLoad & !prevDataLoad) begin
                bits <= data;
                state <= STATE_START_BIT;
                counter <= 1;
                serialOut <= 0;
            end
        end
        STATE_START_BIT: begin
            if (counter == delay) begin
                state <= STATE_DATA_BITS;
                counter <= 1;
                bitCount <= 0;
                serialOut <= bits[0];
                bits <= { 1'b1, bits[7:1]};
            end
            else begin
                counter <= counter + 1'b1;
            end
        end
        STATE_DATA_BITS: begin
            if (counter == delay) begin
                counter <= 1;
                bitCount <= bitCount + 1'b1;
                serialOut <= bits[0];
                if (bitCount == 3'b111) begin
                    state <= STATE_STOP_BIT;
                end
                else begin
                    bits <= { 1'b0, bits[7:1]};
                end
            end
            else begin
                counter <= counter + 1'b1;
            end
        end
        STATE_STOP_BIT: begin
            if (counter == delay) begin
                state <= STATE_IDLE;
            end
            else begin
                counter <= counter + 1'b1;
            end
        end
        endcase
    end

    assign ready = state == STATE_IDLE;
endmodule