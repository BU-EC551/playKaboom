`timescale 1ns / 1ps

module vga_display_bomb(
	input rst,	// global reset
	input clk,
	input move,
	input back,
	input pad_r,
	input pad_l,	// 100MHz clk
	// color outputs to show on display (current pixel)
	output reg rst_bmb,
	output reg [2:0] R, G,
	output reg [1:0] B,
	// VGA Synchronization signals
	output HS,
	output VS
	);
	
	//VGA controls
	wire [10:0] hcount, vcount;	// coordinates for the current pixel
	wire blank;	// signal to indicate the current coordinate is blank
	//SPRITES VARIABLES
	wire [7:0] bomb_dout;
	reg [9:0] bomb_address = 0;
	
	wire [7:0] hbb_dout;
	reg [12:0] hbb_address = 0;
	
	wire [7:0] hbnb_dout;
	reg [12:0] hbnb_address = 0;
	
	wire [7:0] sb_dout;
	reg [12:0] sb_address = 0;
	
	wire [7:0] pad_dout;
	reg [9:0] pad_address = 0;
	
	wire [7:0] explosion_dout;
	reg [15:0] explosion_address = 0;
	
	reg [10:0] bomb_top, bomb_bot, hbb_hi, hbb_lo, hbnb_hi, hbnb_lo, sb_hi, sb_lo, pad_lo, pad_hi; //variable block positions

	wire bomb_block;		// Falling bomb
	wire hbb_block;		// Happy Bomber Bomb (hbb)
	wire hbnb_block;		// Happy Bomber No Bomb (hbnb)
	wire sb_block;			// Sad Bomber (sb)
	wire pad_block;		// Horizontally moving pads
	wire pad1_block;
	wire pad2_block;
	wire explosion_block; //Explosion
	wire background_top;		//Background Top
	wire background_bottom;		//Background Bottom
	wire score; //Score tab
	
	//CLOCK DIVIDER #1
	//This is for the VGA Controller
	//Don't touch unless you understand what you are doing
	parameter N = 2;	
	reg clk_25MHz;
	reg [N-1:0] count;
	always @ (posedge clk) begin
		count <= count + 1'b1;
		clk_25MHz <= count[N-1];
	end	
	
	//CLOCK DIVIDER #2
	// clk_slow controls how fast the blocks move
	// increase M to slow them down, decrease M to speed them up
	// (but only change M by <10, it doesn't take much)
	parameter M = 20;
	reg clk_slow;
	reg [M-1:0] count_tiny;
	always @ (posedge clk) begin
		count_tiny <= count_tiny + 1'b1;
		clk_slow <= count_tiny[M-1];
	end
	
	//Bomb BRAM instantiation
	bomb_sprite bomb(
  .clka(clk),
  .wea(1'b0),
  .addra(bomb_address),
  .dina(8'h00),
  .douta(bomb_dout)
	);
	
	//Happy Bomber with bomb instantiation
	HappyBomber_bomb hbb (
  .clka(clk),
  .wea(1'b0),
  .addra(hbb_address),
  .dina(8'h00),
  .douta(hbb_dout)
	);
	
	//Happy Bomber without bomb instantiation
	HappyBomber_NoBomb hbnb (
  .clka(clk),
  .wea(1'b0),
  .addra(hbnb_address),
  .dina(8'h00),
  .douta(hbnb_dout)
	);
	
	//Sad Bomber with bomb instantiation
	Sad_Bomber sb (
  .clka(clk),
  .wea(1'b0),
  .addra(sb_address),
  .dina(8'h00),
  .douta(sb_dout)
	);
	
	//Pads
	pad pad(
  .clka(clk),
  .wea(1'b0),
  .addra(pad_address),
  .dina(8'h00),
  .douta(pad_dout)
	);

	//Explosion Everything is merged together in 1 .coe file
	Explosion explosion(
  .clka(clk),
  .wea(1'b0),
  .addra(explosion_address),
  .dina(8'h00),
  .douta(explosion_dout)
	);		
		
	// This is the VGA controller
	// You probably don't need to touch this
	vga_controller_640_60 vc(
		.rst(rst),
		.pixel_clk(clk_25MHz),
		.HS(HS),
		.VS(VS),
		.hcounter(hcount),
		.vcounter(vcount),
		.blank(blank));
	
	
	// create the moving blocks:
	assign bomb_block = ~blank & (hcount >= 200 & hcount <= 221 & vcount >= bomb_top & vcount <= bomb_bot); //22x32
	assign hbb_block = ~blank & (hcount >= hbb_lo & hcount <= hbb_hi & vcount >= 20 & vcount <= 107); //64x88
	assign hbnb_block = ~blank & (hcount >= hbnb_lo & hcount <= hbnb_hi & vcount >= 20 & vcount <= 107); //64x88
	assign sb_block = ~blank & (hcount >= sb_lo & hcount <= sb_hi & vcount >= 20 & vcount <= 107); //64x88
	assign pad_block = ~blank & (hcount >= pad_lo & hcount <= pad_hi & vcount >= 410 & vcount <= 425); //84x16
	assign pad1_block = ~blank & (hcount >= pad_lo & hcount <= pad_hi & vcount >= 435 & vcount <= 450); //84x16
	assign pad2_block = ~blank & (hcount >= pad_lo & hcount <= pad_hi & vcount >= 460 & vcount <= 475); //64x16
	assign explosion_block = ~blank & (hcount >= 400 & hcount <= 463 & vcount >= 200 & vcount <= 263); //64x64
	assign background_top = ~blank & (hcount >= 0 & hcount <= 640 & vcount >= 20 & vcount <= 107); //640x88
	assign background_bottom = ~blank & (hcount >= 0 & hcount <= 640 & vcount >= 108 & vcount <= 480); //640x392
	assign score = ~blank & (hcount >= 0 & hcount <= 640 & vcount >= 0 & vcount <= 17); //score tab
	
	// initialize registers
	initial begin
		bomb_top = 108;
		bomb_bot = 139;		
		hbb_lo = 288;
		hbb_hi = 351;		
		hbnb_lo = 288;
		hbnb_hi = 351;		
		sb_lo = 288;
		sb_hi = 351;		
		pad_lo = 288;
		pad_hi = 351;		
	end
	
	//this always block controls the block movement by increasing/resetting position values
	always @ (posedge clk_slow) begin	
	//If we find a way to reset the address of each sprite every time we increment the position we would have everything synchronized. I tried doing that but the same variable cannot be accessed from different "always"
	
		//bomb
		/*if (bomb_bot < 480) begin //Bottom of the screen
			bomb_address <=0;
			bomb_top <= bomb_top + 3'b001;
			bomb_bot <= bomb_bot + 3'b001;
		end 
		else begin
			bomb_address <=0;
			bomb_top <= 98;
			bomb_bot <= 129;
		end*/
		
		//Happy Bomber with bomb
		if (hbb_hi < 640 & move) begin
		
			hbb_lo <= hbb_lo + 3'b001;
			hbb_hi <= hbb_hi + 3'b001;
		end 
		else if(hbb_lo>1 & back)
		begin
		hbb_lo <= hbb_lo - 3'b001;
			hbb_hi <= hbb_hi - 3'b001;
		end
		else begin
			hbb_lo <= hbb_lo; //0;
			hbb_hi <= hbb_hi; //63;
		end
		
		
		//Happy Bomber without bomb
		if (hbnb_hi < 640 & move) begin
		
			hbnb_lo <= hbnb_lo + 3'b001;
			hbnb_hi <= hbnb_hi + 3'b001;
			
		end 
		else if(hbnb_lo>1 & back)
		begin
		hbnb_lo <= hbnb_lo - 3'b001;
			hbnb_hi <= hbnb_hi - 3'b001;
		end
		else begin
			hbnb_lo <= hbnb_lo;//0;
			hbnb_hi <= hbnb_hi;//63;
		end
		
		//Sad Bomber with bomb
		if (sb_hi < 640 & move) begin
			sb_lo <= sb_lo + 3'b001;
			sb_hi <= sb_hi + 3'b001;
		end 
		else if(sb_lo>1 & back)
		begin
		sb_lo <= sb_lo - 3'b001;
			sb_hi <= sb_hi - 3'b001;
		end
		
		//pad block
		if (pad_r & pad_hi < 632) begin
			pad_lo <= pad_lo + 3'b001;
			pad_hi <= pad_hi + 3'b001;
		end 
		else if(pad_l & pad_lo>1)
		begin
		pad_lo <= pad_lo - 3'b001;
			pad_hi <= pad_hi - 3'b001;
		end
		else begin
			pad_lo <=pad_lo;
			pad_hi <=pad_hi;
		end
		
	end  //end of the clk_slow always block
	
	//This always block controls actually drawing the blocks on the screen
	
	always @ (posedge clk_25MHz)
	begin	//Maybe better a Multiplexer for this, maybe not...
	//I think the blocks are experiencing a shift because of how it is getting the data. It shifts over time I guess. But not sure either.
	if(rst==1)
		begin
			hbb_address <= 0; //Avoids shifting after a reset.     
			hbnb_address <= 0;
			sb_address <= 0;
			explosion_address <= 0;
			pad_address <= 0;
		end
				
		if (bomb_block) begin //bomb block detection
				R <= bomb_dout[7:5];
				G <= bomb_dout[4:2];
				B <= bomb_dout[1:0];
				if (bomb_address == 703) 
					begin
					bomb_address <= 0;
					end
				else bomb_address <= bomb_address + 1;
		end		

		else if (explosion_block) begin //explosion
				R <= explosion_dout[7:5];
				G <= explosion_dout[4:2];
				B <= explosion_dout[1:0];
				if (explosion_address == 57343) explosion_address <= 0;
				else explosion_address <= explosion_address + 1;
		end			
		
		 else if (hbb_block) begin //hbb block detection
			R <= hbb_dout[7:5];
			G <= hbb_dout[4:2];
			B <= hbb_dout[1:0];
			if (hbb_address == 5631)  hbb_address <= 0;
			else hbb_address <= hbb_address + 1;
		end
		
			/*else if (hbnb_block) begin //hbnb block detection
			R <= hbnb_dout[7:5];
			G <= hbnb_dout[4:2];
			B <= hbnb_dout[1:0];
			if (hbnb_address == 5631) hbnb_address <= 0;
			else hbnb_address <= hbnb_address + 1;			
		end*/
		
		 /*else if (sb_block) begin  //sb block detection
			R <= sb_dout[7:5];
			G <= sb_dout[4:2];
			B <= sb_dout[1:0];
			if (sb_address == 5631) sb_address <= 0;
			else sb_address <= sb_address + 1;
		end*/
		
			else if (pad_block || pad1_block || pad2_block) begin  //Implement later  to eliminate pads
			R <= pad_dout[7:5];
			G <= pad_dout[4:2];
			B <= pad_dout[1:0];
			if (pad_address == 1023) pad_address <= 0;
			else pad_address <= pad_address + 1;
		end
		
			else if (background_top) begin  //Implement later  to eliminate pads
			R <= 3'b010;
			G <= 3'b011;
			B <= 2'b00;
		end
		
			else if (background_bottom) begin  //Implement later  to eliminate pads
			R <= 3'b000;
			G <= 3'b101;
			B <= 2'b11;
		end
			else if (score) begin  //Implement later  to eliminate pads
			R <= 3'b110;
			G <= 3'b110;
			B <= 2'b11;
		end
		
		else begin	//the screen is black everywhere else
			R <= 0;
			G <= 0;
			B <= 0;
		end
		
	end
endmodule
