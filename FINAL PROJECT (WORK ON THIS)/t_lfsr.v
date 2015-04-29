`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   08:28:05 04/25/2015
// Design Name:   LFSR
// Module Name:   X:/551_Project/Kaboom_with_title_and_hbnb_4_24_2015/t_lfsr.v
// Project Name:  VGA_Test
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: LFSR
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module t_lfsr;

	// Inputs
	reg clk;
	reg rst;

	// Outputs
	wire rand_bit;
	wire [4:0] data;

	// Instantiate the Unit Under Test (UUT)
	LFSR uut (
		.clk(clk), 
		.rst(rst), 
		.rand_bit(rand_bit),
		.data(data)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
   always #5 clk = !clk;
	
endmodule

