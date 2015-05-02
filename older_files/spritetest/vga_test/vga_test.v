`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:27:39 03/28/2015 
// Design Name: 
// Module Name:    vga_test 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module vga_test(
    );
	 
bomb ram(
	.addra(bomb_addr),
	.clka(bomb_clk),
	.dina(bomb_din),
	.douta(bomb_dout),
	.wea(bomb_we)
);

endmodule
