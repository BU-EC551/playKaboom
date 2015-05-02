`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// EC 551 Final Project
// Team Kaboom
// 
// This code is based on an example at:
// http://stackoverflow.com/questions/14497877/how-to-implement-a-pseudo-hardware-random-number-generator
// and the taps table / diagram at
// http://www.eej.ulst.ac.uk/~ian/modules/EEE515/files/old_files/lfsr/lfsr_table.pdf
//////////////////////////////////////////////////////////////////////////////////
module rand_gen (
	input clk,
	input rst,
	output [1:0] random
);
	
	LFSR_5 RAND0(
		.clk(clk),
		.rst(rst),
		.rand_bit(random[0])
		);
		
	LFSR_8 RAND1(
		.clk(clk),
		.rst(rst),
		.rand_bit(random[1])
	);

endmodule

//5 Bit
module LFSR_5 (
  input  clk,
  input  rst,
  output rand_bit
);

reg [4:0] data;

assign rand_bit = data[4];

wire feedback = data[4] ^ data[2];

always @(posedge clk)
  if (rst)
    data <= 5'b01111;
  else
    data <= {data[3:0], feedback} ;
endmodule

//8 Bit
module LFSR_8 (
  input  clk,
  input  rst,
  output rand_bit
);

reg [7:0] data;

assign rand_bit = data[7];


wire feedback = data[7] ^ data[5] ^ data[4] ^ data[3] ;

always @(posedge clk)
  if (rst) 
    data <= 8'b0111_1111;
  else
    data <= {data[6:0], feedback} ;
endmodule

