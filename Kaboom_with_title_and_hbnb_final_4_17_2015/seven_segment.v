`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// EC 551 Spring 2015
// Team Kaboom
//
// Seven Segment Display Module
//
//////////////////////////////////////////////////////////////////////////////////

module seven_segment (
	input clk,
	input [15:0] data_in,
	output [6:0] seven_out,  // for seven segment display
	output reg [3:0] digit
    );
	reg [3:0] four_bits_in;

   binary_to_seven SEVEN( .data_in(four_bits_in), 
			.data_out(seven_out));
	
	initial begin
		digit = 4'b1110;
	end
	
	/////////////////////////////////////////////////////
	// Begin clock division
	parameter N = 10;	// parameter for clock division
	reg [N-1:0] count;
	reg slow_clk;
	always @ (posedge clk) begin
		count <= count + 1'b1;
		slow_clk <= count[N-1];
	end
	// End clock division
	/////////////////////////////////////////////////////
    

	always @(posedge slow_clk)
	case(digit)
		4'b1110: begin
			digit <= 4'b1101;
			four_bits_in <= data_in[7:4];
		end
		
		4'b1101: begin
			digit <= 4'b1011;
			four_bits_in <= data_in[11:8];
		end
		
		4'b1011: begin
			digit <= 4'b0111;
			four_bits_in <= data_in[15:12];
		end
		
		4'b0111: begin
			digit <= 4'b1110;
			four_bits_in <= data_in[3:0];
		end
		
		default: begin
			digit <= 4'b1110;
			four_bits_in <= data_in[3:0];
		end
	endcase

endmodule



module binary_to_seven (
	output reg [6:0] data_out, 
	input [3:0] data_in
	);
	
always @ (data_in)
	case (data_in)
		  4'b0000:	data_out <= 7'b0000001;  //abcdefg
        4'b0001:	data_out <= 7'b1001111;
        4'b0010:	data_out <= 7'b0010010;
        4'b0011:	data_out <= 7'b0000110;
        4'b0100:	data_out <= 7'b1001100;
        4'b0101:	data_out <= 7'b0100100;
        4'b0110:	data_out <= 7'b0100000;
        4'b0111:	data_out <= 7'b0001111;
        4'b1000:	data_out <= 7'b0000000;
        4'b1001:	data_out <= 7'b0000100;
        4'b1010:	data_out <= 7'b0001000;
        4'b1011:	data_out <= 7'b1100000;
        4'b1100:	data_out <= 7'b0110001;
        4'b1101:	data_out <= 7'b1000010;
        4'b1110:	data_out <= 7'b0110000;
        4'b1111:	data_out <= 7'b0111000;
	endcase

endmodule



