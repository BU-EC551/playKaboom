`timescale 1ns / 1ps
module sprites_sync(
    input clk,
    input flag_in,
	 input flag_in2,
    output reg flag_out
    );

always @(posedge clk)
begin
	
	if(flag_in) flag_out <= 1;
end
endmodule
