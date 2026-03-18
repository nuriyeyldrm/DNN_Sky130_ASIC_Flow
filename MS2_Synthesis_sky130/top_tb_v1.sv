`timescale 1ns/1ps
`define UNIT_DELAY 1

module top_tb_v1();

function automatic bit has_x(input logic [16:0] v);
    has_x = (^v === 1'bx);
endfunction

reg signed [4:0] x0, x1, x2, x3;
reg signed [4:0] w04, w14, w24, w34;
reg signed [4:0] w05, w15, w25, w35;
reg signed [4:0] w06, w16, w26, w36;
reg signed [4:0] w07, w17, w27, w37;
reg signed [4:0] w48, w58, w68, w78;
reg signed [4:0] w49, w59, w69, w79;

reg clk;

wire signed [16:0] out0, out1;
wire out10_ready, out11_ready;

reg in_ready;
// Top module
// Instantiation of top module
// Please replace the instantiation with the top module of your gate level model
// Look for 'test failed' in the message. If there is no such message then your output matches the golden outputs. 


top top(.x0(x0), .x1(x1), .x2(x2), .x3(x3), 
        .w04(w04), .w14(w14), .w24(w24), .w34(w34), 
        .w05(w05), .w15(w15), .w25(w25), .w35(w35),
        .w06(w06), .w16(w16), .w26(w26), .w36(w36),
        .w07(w07), .w17(w17), .w27(w27), .w37(w37),
        .w48(w48), .w58(w58), .w68(w68), .w78(w78),
        .w49(w49), .w59(w59), .w69(w69), .w79(w79),
        .out0(out0), .out1(out1),
        .in_ready(in_ready), .out0_ready(out10_ready), .out1_ready(out11_ready),
        .clk(clk));

initial begin

    $dumpfile("wave.vcd");
    $dumpvars(0, top_tb_v1);

    clk = 0;
    in_ready = 0;

    repeat (2) @(posedge clk);
    in_ready = 1;
    
    x0 = 5'b00100;
    x1 = 5'b00010;
    x2 = 5'b00100;
    x3 = 5'b00001;
    
    w04 = 5'b00011;
    w14 = 5'b00010;
    w24 = 5'b01101;
    w34 = 5'b11010;
    w05 = 5'b10111;
    w15 = 5'b00001;
    w25 = 5'b11100;
    w35 = 5'b01110;
    w06 = 5'b00011;
    w16 = 5'b00110;
    w26 = 5'b10001;
    w36 = 5'b01111;
    w07 = 5'b01001;
    w17 = 5'b10110;
    w27 = 5'b01111;
    w37 = 5'b10110;
    w48 = 5'b00000;
    w58 = 5'b11111;
    w68 = 5'b00011;
    w78 = 5'b10101;
    w49 = 5'b10100;
    w59 = 5'b10001;
    w69 = 5'b10001;
    w79 = 5'b00110;

    $display("t=%0t clk=%b out0=%b out1=%b out0_dec=%0d out1_dec=%0d ready0=%b ready1=%b",
         $time, clk, out0, out1, $signed(out0), $signed(out1), out10_ready, out11_ready);
    
    // Wait until ready becomes known 0/1 (not X), then wait until it becomes 1
    wait (out10_ready !== 1'bx);
    wait (out11_ready !== 1'bx);

    wait (out10_ready === 1'b1);
    wait (out11_ready === 1'b1);

    wait (!has_x(out0));
    wait (!has_x(out1));

    @(posedge clk); #0;

    if ($signed(out0) == -17'sd726)
        $display("-----------out0 is correct-----------------");
    else
        $display("-----------out0 is incorrect-----------");

    if ($signed(out1) == -17'sd348)
        $display("-----------out1 is correct-----------");
    else
        $display("-----------out1 is incorrect-----------");

    if ($signed(out0) == -17'sd726 && $signed(out1) == -17'sd348)
        $display("*********** ALL TESTS PASSED *********");
    else
        $display("*********** SOME TEST(S) FAILED *********");


end


always
    #1 clk = !clk;


initial
  #100000 $finish;


endmodule
