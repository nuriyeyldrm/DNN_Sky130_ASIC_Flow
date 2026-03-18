`timescale 1ns/1ps

module top_tb_scoreboard;

reg signed [4:0] x0, x1, x2, x3;
reg signed [4:0] w04, w14, w24, w34;
reg signed [4:0] w05, w15, w25, w35;
reg signed [4:0] w06, w16, w26, w36;
reg signed [4:0] w07, w17, w27, w37;
reg signed [4:0] w48, w58, w68, w78;
reg signed [4:0] w49, w59, w69, w79;

reg clk;
reg in_ready;

wire signed [16:0] out0, out1;
wire out0_ready, out1_ready;

integer vec_fd, out_fd, rc;
integer idx;

integer tx0, tx1, tx2, tx3;
integer tw04, tw05, tw06, tw07;
integer tw14, tw15, tw16, tw17;
integer tw24, tw25, tw26, tw27;
integer tw34, tw35, tw36, tw37;
integer tw48, tw58, tw68, tw78;
integer tw49, tw59, tw69, tw79;

reg [1023:0] vec_path;
reg [1023:0] out_path;

top dut (
    .x0(x0), .x1(x1), .x2(x2), .x3(x3),
    .w04(w04), .w05(w05), .w06(w06), .w07(w07),
    .w14(w14), .w15(w15), .w16(w16), .w17(w17),
    .w24(w24), .w25(w25), .w26(w26), .w27(w27),
    .w34(w34), .w35(w35), .w36(w36), .w37(w37),
    .w48(w48), .w58(w58), .w49(w49), .w59(w59),
    .w68(w68), .w69(w69), .w78(w78), .w79(w79),
    .out0(out0), .out1(out1),
    .in_ready(in_ready),
    .out0_ready(out0_ready), .out1_ready(out1_ready),
    .clk(clk)
);

initial clk = 1'b0;
always #1 clk = ~clk;

initial begin
    if (!$value$plusargs("VEC_FILE=%s", vec_path))
        vec_path = "build/scoreboard_vectors.txt";

    if (!$value$plusargs("OUT_FILE=%s", out_path))
        out_path = "build/scoreboard_observed.txt";

    vec_fd = $fopen(vec_path, "r");
    if (vec_fd == 0) begin
        $display("[TB] ERROR: could not open vector file: %s", vec_path);
        $finish;
    end

    out_fd = $fopen(out_path, "w");
    if (out_fd == 0) begin
        $display("[TB] ERROR: could not open output file: %s", out_path);
        $finish;
    end

    in_ready = 1'b0;
    x0 = '0; x1 = '0; x2 = '0; x3 = '0;
    w04 = '0; w05 = '0; w06 = '0; w07 = '0;
    w14 = '0; w15 = '0; w16 = '0; w17 = '0;
    w24 = '0; w25 = '0; w26 = '0; w27 = '0;
    w34 = '0; w35 = '0; w36 = '0; w37 = '0;
    w48 = '0; w58 = '0; w68 = '0; w78 = '0;
    w49 = '0; w59 = '0; w69 = '0; w79 = '0;

    repeat (2) @(posedge clk);

    while (!$feof(vec_fd)) begin
        rc = $fscanf(
            vec_fd,
            "%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\n",
            idx,
            tx0, tx1, tx2, tx3,
            tw04, tw05, tw06, tw07,
            tw14, tw15, tw16, tw17,
            tw24, tw25, tw26, tw27,
            tw34, tw35, tw36, tw37,
            tw48, tw58, tw68, tw78,
            tw49, tw59, tw69, tw79
        );

        if (rc != 29) begin
            if (!$feof(vec_fd)) begin
                $display("[TB] ERROR: malformed vector line, rc=%0d", rc);
                $finish;
            end
        end else begin
            // Apply one transaction before the active edge
            @(negedge clk);
            x0 = tx0; x1 = tx1; x2 = tx2; x3 = tx3;
            w04 = tw04; w05 = tw05; w06 = tw06; w07 = tw07;
            w14 = tw14; w15 = tw15; w16 = tw16; w17 = tw17;
            w24 = tw24; w25 = tw25; w26 = tw26; w27 = tw27;
            w34 = tw34; w35 = tw35; w36 = tw36; w37 = tw37;
            w48 = tw48; w58 = tw58; w68 = tw68; w78 = tw78;
            w49 = tw49; w59 = tw59; w69 = tw69; w79 = tw79;
            in_ready = 1'b1;

            // DUT registers outputs on this edge
            @(posedge clk);
            #1;

            $fwrite(out_fd, "%0d %0d %0d %0d %0d\n",
                idx, $signed(out0), $signed(out1), out0_ready, out1_ready);

            // Clear handshake so next vector does not see stale ready
            @(negedge clk);
            in_ready = 1'b0;

            // Give DUT one cycle to drop ready/outputs back if needed
            @(posedge clk);
            #1;
        end
    end

    $fclose(vec_fd);
    $fclose(out_fd);

    $display("*********** SCOREBOARD TB DONE ***********");
    $finish;
end

endmodule