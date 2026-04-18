module tt_um_project (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: input path
    output wire [7:0] uio_out,  // IOs: output path
    output wire [7:0] uio_oe,   // IOs: output enable (1=output, 0=input)
    input  wire       ena,      // Always enabled on TT board
    input  wire       clk,      // Clock
    input  wire       rst_n     // Active-low reset
);

    // Default: bidirectional pins unused
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // Example mapping for a simple design:
    // ui_in[0] -> x0
    // ui_in[1] -> x1
    // ui_in[2] -> w0
    // ui_in[3] -> w1
    // uo_out[0] -> y0
    // uo_out[1] -> y1
    //
    // Replace this block with the actual wrapped logic.

    wire [1:0] x;
    wire [1:0] w;
    wire [1:0] y;

    assign x = ui_in[1:0];
    assign w = ui_in[3:2];

    // Placeholder logic
    assign y = ena ? (x + w) : 2'b00;

    assign uo_out = {6'b0, y};

endmodule