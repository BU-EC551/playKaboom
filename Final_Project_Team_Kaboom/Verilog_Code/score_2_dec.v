`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Convert 10-bit score to a four-digit decimal number
// Based on code found at
// 
//////////////////////////////////////////////////////////////////////////////////
module score_2_dec(
	input [9:0] bin_in,
	output reg [3:0] dec_1,
	output reg [3:0] dec_10,
	output reg [3:0] dec_100,
	output reg [3:0] dec_1000
    );
	 
	 reg [25:0] shift;
	 integer i;
	 
	 always @ (bin_in) begin
		shift = 0;
		shift [9:0] = bin_in;
		
		for (i=0; i<10; i=i+1) begin
			if (shift [13:10] >= 5) 
				shift[13:10] = shift[13:10] + 3;
		
			if (shift [17:14] >= 5) 
				shift[17:14] = shift[17:14] + 3;
				
			if (shift [21:18] >= 5) 
				shift[21:18] = shift[21:18] + 3;
			
			if (shift [25:22] >= 5) 
				shift[21:18] = shift[21:18] + 3;
			
			shift = shift << 1;
		end
	
	dec_1 = shift[13:10]; 
	dec_10 = shift[17:14]; 
	dec_100 = shift[21:18]; 
	dec_1000 = shift[25:22]; 
	end

endmodule
