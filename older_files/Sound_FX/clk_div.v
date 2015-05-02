module clk_div(
	input play,
	input Clk_in,
	output reg Clk_out,
	output reg gain,
	output reg shutdown
	);

parameter sys_clk = 100000000;	// 100 MHz system clock
parameter clk_out = 440; //440hz Central A
reg [20:0] duration = 400; //Counter between frequency changes
reg [20:0] max = sys_clk / (2*clk_out); // Max-counter size
reg [20:0] counter = 0; // Counter size
reg [30:0] i = 1000;

always@(posedge Clk_in)
begin
	if(play)
	begin
	max <= sys_clk / (2*clk_out);

		gain <= 0; //0 6dB - 1 12dB	
		shutdown <= 1; //1 Device Enable - 0 Device Disabled
				if(counter == max-1)
					begin
					counter <= 0;
					Clk_out <= ~Clk_out;
					end
				else
					begin
					counter <= counter + 1'd1;
					end
			
			if(duration==0)
				begin
				max <= max-1; //Increasing effect
				duration <= 500;
				end
			else
				begin
				duration <= duration-1;
				end

	end //play
end //always

always@(posedge Clk_in) //Make it one hz and put flag enable/disable with play up there
begin
				if(counter == max-1)
					begin
					counter <= 0;
					Clk_out <= ~Clk_out;
					end
				else
					begin
					counter <= counter + 1'd1;
					end
end //always
endmodule