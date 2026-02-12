module top (x0, x1, x2, x3, w04, w05, w06, w07, w14, w15, w16, w17, w24, w25, w26, w27, w34, w35, w36,
w37, w48, w58, w49, w59, w68, w69, w78, w79, out0, out1, in_ready, out0_ready, out1_ready, clk);
	input logic signed [4:0] x0, x1, x2, x3, w04, w05, w06, w07, w14, w15, w16, w17, w24, w25, w26, w27, w34, w35, w36, w37,
	w48, w58, w49, w59, w68, w69, w78, w79;
	input in_ready;
	input clk;
	output logic signed [16:0] out0, out1;
	output logic out0_ready, out1_ready; 
	
	//Implementation of the neural network
	logic signed [10:0] y4,y5,y6,y7;	//[16:0] 
	logic signed [16:0] y8,y9;
	logic out_start, out_ready;
	
											//STAGE 1//
						
	/*assign y14 = (x0*w04 + x1*w14 + x2*w24 + x3*w34) ? x0*w04 + x1*w14 + x2*w24 + x3*w34: 0;
	assign y15 = (x0*w05 + x1*w15 + x2*w25 + x3*w35) ? x0*w05 + x1*w15 + x2*w25 + x3*w35: 0;
	assign y16 = (x0*w06 + x1*w16 + x2*w26 + x3*w36) ? x0*w06 + x1*w16 + x2*w26 + x3*w36: 0;
	assign y17 = (x0*w07 + x1*w17 + x2*w27 + x3*w37) ? x0*w07 + x1*w17 + x2*w27 + x3*w37: 0;*/
	
	always_comb begin
		if(in_ready) begin
			y4 = ((x0*w04 + x1*w14 + x2*w24 + x3*w34)> 0) ? x0*w04 + x1*w14 + x2*w24 + x3*w34: 0;
			y5 = ((x0*w05 + x1*w15 + x2*w25 + x3*w35)> 0) ? x0*w05 + x1*w15 + x2*w25 + x3*w35: 0;
			y6 = ((x0*w06 + x1*w16 + x2*w26 + x3*w36)> 0) ? x0*w06 + x1*w16 + x2*w26 + x3*w36: 0;
			y7 = ((x0*w07 + x1*w17 + x2*w27 + x3*w37)> 0) ? x0*w07 + x1*w17 + x2*w27 + x3*w37: 0;
			out_start = 1'b1;
		end
		else begin
			y4 = '0;
			y5 = '0;
			y6 = '0;
			y7 = '0;
			out_start = 1'b0;
		end
	end
											//STAGE 2//
											
	/*assign y8 = y4*w48 + y5*w58 + y6*w68 + y7*w78;
	assign y9 = y4*w49 + y5*w59 + y6*w69 + y7*w79;*/
	
	always_comb begin
		if(out_start) begin
			y8 = y4*w48 + y5*w58 + y6*w68 + y7*w78;
			y9 = y4*w49 + y5*w59 + y6*w69 + y7*w79;
			out_ready = 1'b1;
		end
		else begin
			y8 = '0;
			y9 = '0;
			out_ready = 1'b0;
		end
	end
	
	always@(posedge clk) begin
		if(out_ready) begin
			out0_ready <= 1'b1;
			out1_ready <= 1'b1;
			out0 <= y8;
			out1 <= y9;	
		 end
		else begin
			out0_ready <= 1'b0;
			out1_ready <= 1'b0;
			out0 <= '0;
			out1 <= '0;
		 end
	end

endmodule