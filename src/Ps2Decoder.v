`include "Ps2Rx.v"
`include "SerialTxDbg.v"

`default_nettype none

// see https://wiki.osdev.org/PS/2_Keyboard
module Ps2Decoder #(
    parameter counterBits = 8,
    parameter minClk = 15,
    parameter maxClk = 25,
    parameter readAt = 5
)
(
    input wire       clk,
    input wire       ps2Clk,
    input wire       ps2Data,
    input wire       reset,
    input wire[3:0]  address,
    output wire[7:0] keybits,
    output wire      error,
    output reg       softReset,
    output wire      debugSerialOut
);
    wire [7:0] data;
    wire       dataReady;
    reg        prevDataReady = 0;
    reg        receivedE0 = 0;
    reg        receivedF0 = 0;
    reg [3:0]  column = 0;
    reg [3:0]  columnMask = 0;

    reg        shift = 0;
    reg        ctrl = 0;
    reg        alt = 0;

    Ps2Rx #(
        .counterBits(counterBits),
        .minClk(minClk),
        .maxClk(maxClk),
        .readAt(readAt)
    ) rx(
        .clk(clk),
        .ps2Clk(ps2Clk),
        .ps2Data(ps2Data),
        .reset(reset),
        .data(data),
        .dataReady(dataReady),
        .error(error)
    );

    reg [7:0] serialData = 0;
    reg       serialTxLoad = 0;
    wire      serialTxReady;
    SerialTxDbg #(
        .counterBits(10),
        .delay(35) // 115200
        //.delay(416) 9600
    ) serialTx(
        .clk(clk),
        .data(serialData),
        .dataLoad(serialTxLoad),
        .serialOut(debugSerialOut),
        .ready(serialTxReady)
    );

    task setColumn;
        input [3:0] col;
        input [1:0] row;
        begin
            column <= col;
            columnMask <= 1 << row;

            serialData <= {row, col};
            serialTxLoad <= 1;
        end
    endtask

    always @(posedge clk) begin
        if (reset) begin
            receivedE0 <= 0;
            receivedF0 <= 0;
            prevDataReady <= 0;
            column <= 0;
            columnMask <= 0;
            shift <= 0;
            ctrl <= 0;
            alt <= 0;
        end
        else begin
            if (dataReady != prevDataReady) begin
                prevDataReady <= dataReady;

                if (dataReady) begin
/*                     serialData <= data;
                    serialTxLoad <= 1;
 */
                    case (data)
                    8'hE0: begin
                        receivedE0 <= 1;
                    end
                    8'hF0: begin
                        receivedF0 <= 1;
                    end
                    8'h11: alt <= ~receivedF0;
                    8'h14: ctrl <= ~receivedF0;
                    8'h71: if (receivedE0 & ctrl & alt) begin// Del
                        softReset <= ~receivedF0;
                    end
                    default: begin
                        if (receivedF0) begin
                            column <= 0;
                            columnMask <= 0;
                        end
                        else if (receivedE0) begin
                            case (data)
                            8'h6B: setColumn(4'hD, 2'h2); // cursor left
                            //8'h71: del
                            8'h72: setColumn(4'hD, 2'h1); // cursor down
                            8'h74: setColumn(4'hD, 2'h0); // cursor right
                            8'h75: setColumn(4'hD, 2'h3); // cursor up
                            endcase
                        end
                        else begin
                            case (data)
                            8'h0D: setColumn(4'h1, 2'h2); // tab (left/right)
                            8'h0E: setColumn(4'h1, 2'h3); // ` (up/down)
                            //8'h11: alt <= ~receivedF0;    // left alt
                            8'h12: setColumn(4'h1, 2'h1); // left shift
                            //8'h14: ctrl <= ~receivedF0;   // left ctrl
                            8'h15: setColumn(4'h2, 2'h2); // Q
                            8'h16: setColumn(4'h2, 2'h3); // 1
                            8'h1A: setColumn(4'h2, 2'h0); // Y
                            8'h1B: setColumn(4'h3, 2'h1); // S
                            8'h1C: setColumn(4'h2, 2'h1); // A
                            8'h1D: setColumn(4'h3, 2'h2); // W
                            8'h1E: setColumn(4'h3, 2'h3); // 2
                            8'h21: setColumn(4'h4, 2'h0); // C
                            8'h22: setColumn(4'h3, 2'h0); // X
                            8'h23: setColumn(4'h4, 2'h1); // D
                            8'h24: setColumn(4'h4, 2'h2); // E
                            8'h25: setColumn(4'h5, 2'h3); // 4
                            8'h26: setColumn(4'h4, 2'h3); // 3
                            8'h29: setColumn(4'h1, 2'h0); // Space
                            8'h2A: setColumn(4'h5, 2'h0); // V
                            8'h2B: setColumn(4'h5, 2'h1); // F
                            8'h2C: setColumn(4'h6, 2'h2); // T
                            8'h2D: setColumn(4'h5, 2'h2); // R
                            8'h2E: setColumn(4'h6, 2'h3); // 5
                            8'h31: setColumn(4'h7, 2'h0); // N
                            8'h32: setColumn(4'h6, 2'h0); // B
                            8'h33: setColumn(4'h7, 2'h1); // H
                            8'h34: setColumn(4'h6, 2'h1); // G
                            8'h35: setColumn(4'h7, 2'h2); // Z
                            8'h36: setColumn(4'h7, 2'h3); // 6
                            8'h3A: setColumn(4'h8, 2'h0); // M
                            8'h3B: setColumn(4'h8, 2'h1); // J
                            8'h3C: setColumn(4'h8, 2'h2); // U
                            8'h3D: setColumn(4'h8, 2'h3); // 7
                            8'h3E: setColumn(4'h9, 2'h3); // 8
                            8'h41: setColumn(4'h9, 2'h0); // ,
                            8'h42: setColumn(4'h9, 2'h1); // K
                            8'h43: setColumn(4'h9, 2'h2); // I
                            8'h44: setColumn(4'hA, 2'h2); // O
                            8'h45: setColumn(4'hB, 2'h3); // 0
                            8'h46: setColumn(4'hA, 2'h3); // 9
                            8'h49: setColumn(4'hA, 2'h0); // .
                            8'h4A: setColumn(4'hB, 2'h0); // /
                            8'h4B: setColumn(4'hA, 2'h1); // L
                            8'h4C: setColumn(4'hB, 2'h1); // ; (ö*)
                            8'h4D: setColumn(4'hB, 2'h2); // P
                            8'h52: setColumn(4'hC, 2'h1); // ' (ä-)
                            8'h54: setColumn(4'hC, 2'h2); // [ (ü+)
                            8'h55: setColumn(4'hC, 2'h2); // =
                            8'h59: setColumn(4'h1, 2'h1); // right shift
                            8'h5A: setColumn(4'hC, 2'h0); // Enter
                            8'h5B: setColumn(4'hC, 2'h2); // ]
                            8'h5D: setColumn(4'hC, 2'h1); // \
                            8'h66: setColumn(4'hC, 2'h3); // backspace

                            8'h76: setColumn(4'h1, 2'h3); // ESC
                            endcase
                        end
                        receivedE0 <= 0;
                        receivedF0 <= 0;
                    end
                    endcase
                end
            end
            else begin
                if (serialTxLoad) begin
                    serialTxLoad <= 0;
                end
            end
        end
    end

    assign keybits = column == address ? {columnMask, 4'b0} : 0;
endmodule
