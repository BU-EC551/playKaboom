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
	output VS,
	
	output [6:0] seven,
	output [3:0] svn_digit
	);
	
	//VGA controls
	wire [10:0] hcount, vcount;	// coordinates for the current pixel
	wire blank;	// signal to indicate the current coordinate is blank
	//SPRITES VARIABLES
	wire [7:0] bomb_dout;
	reg [9:0] bomb_address = 0;
	
	wire [7:0] bomb_two_dout;
	reg [9:0] bomb_two_address = 0;
	
	wire [7:0] bomb_three_dout;
	reg [9:0] bomb_three_address = 0;
	
	wire [7:0] bomb_four_dout;
	reg [9:0] bomb_four_address = 0;
	
	wire [7:0] bomb_five_dout;
	reg [9:0] bomb_five_address = 0;
	
	wire [7:0] hbb_dout;
	reg [12:0] hbb_address = 0;
	
	wire [7:0] hbnb_dout;
	reg [12:0] hbnb_address = 0;
	
	wire [7:0] sb_dout;
	reg [12:0] sb_address = 0;
	
	wire [7:0] pad_dout;
	reg [9:0] pad_address = 0;
	
	//wire [7:0] explosion_dout;
	//reg [15:0] explosion_address = 0;
	
	reg [10:0] sb_hi, sb_lo, pad_lo, pad_hi,b2_lo,b2_hi,bomb_two_top, bomb_two_bot,bomb_two_lo, bomb_two_hi, bomb_three_lo, bomb_three_hi, bomb_four_lo, bomb_four_hi, bomb_five_lo, bomb_five_hi; //variable block positions
   reg  [10:0] bomb_top, bomb_bot, bomb_lo, bomb_hi, exp_lo, exp_hi, hbb_hi, hbb_lo, hbnb_hi, hbnb_lo,bomb_three_top, bomb_three_bot,bomb_four_top, bomb_four_bot,bomb_five_top, bomb_five_bot;
	
	wire bomb_block;
   wire bomb_two_block;
   wire bomb_three_block;
   wire bomb_four_block;
   wire bomb_five_block;	// Falling bomb
	wire hbb_block;		// Happy Bomber Bomb (hbb)
	wire hbnb_block;		// Happy Bomber No Bomb (hbnb)
	wire sb_block;			// Sad Bomber (sb)
	wire pad_block;		// Horizontally moving pads
	wire pad1_block;
	wire pad2_block;
	//wire explosion_block; //Explosion
	wire background_top;		//Background Top
	wire background_bottom;		//Background Bottom
	wire scoreboard; //Score tab
	reg bmb;
	reg bmb_2;
	reg bmb_3;
	reg bmb_4;
	reg bmb_5;
	reg flag;
	reg x;
	
	//various things for the scoreboard
	reg [9:0] score;				  // actual score
	wire [3:0] dec_score [0:3];  // score as four BCD decimal digits
	//reg [3:0] char_ctr;			  // indicates which digit VGA should draw
	//reg [4:0] char_sel;			  // character selector for font rom
	//wire [127:0] tile;           // character tile from font rom
	wire [9:0] score_char;		  // the VGA position blocks
	
	//reg [127:0] tile_ctr = 127;  // for moving through the tile
	//reg [1:0] x_ctr;
	//reg [4:0] row_ctr;
	//reg [1:0] y_ctr;
	
	///////////////////////////// TITLE ROM///////////////////////
	reg [24:0] color_timer;
	reg [2:0] R_val;
	
	wire test_box;
	
	wire test_char;
	
	wire [127:0] tile;
	
	reg [127:0] tile_ctr = 127;
	
	reg [1:0] x_ctr;
	reg [4:0] row_ctr;
	reg [1:0] y_ctr;
	
	reg [3:0] char_ctr;
	reg [5:0] char_sel;
	
	wire [7:0] str;
	
	reg [3:0] font_scale = 1;
	parameter tile_wd = 8;
	parameter tile_ht = 16; 
	parameter tile_top = 100;
	parameter text_H_ctr = 320;
	reg size_timer;
	
	wire [13:0] cred_blk;
	reg [127:0] cred_tile_ctr = 127;
	reg [4:0] cred_row_ctr;
	reg [3:0] cred_char_ctr;
	
	////////////////////////////////////////End Rom/////////////
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
	parameter M = 19;
	reg clk_slow;
	reg [M-1:0] count_tiny;
	always @ (posedge clk) begin
		count_tiny <= count_tiny + 1'b1;
		clk_slow <= count_tiny[M-1];
	end
	
	reg flag_in_sync = 0;
	reg flag_out_sync = 0;
	
	score_2_dec DEC_SCORE(
		.bin_in(score),
		.dec_1(dec_score[0]),
		.dec_10(dec_score[1]),
		.dec_100(dec_score[2]),
		.dec_1000(dec_score[3])
	);
	
	seven_segment SVN_SCORE(
		.clk(clk),
		.data_in(score),
		.seven_out(seven),
		.digit(svn_digit)
	);
	
	font_rom FONT(
			.clk(clk),
			.sel(char_sel),
	      .char_out(tile)
	);
	
	//Bomb BRAM instantiation
	bomb_sprite bomb(
  .clka(clk),
  .wea(1'b0),
  .addra(bomb_address),
  .dina(8'h00),
  .douta(bomb_dout)
	);
	
	btwo bomb2(
  .clka(clk),
  .wea(1'b0),
  .addra(bomb_two_address),
  .dina(8'h00),
  .douta(bomb_two_dout)
);

bthree bomb3(
  .clka(clk),
  .wea(1'b0),
  .addra(bomb_three_address),
  .dina(8'h00),
  .douta(bomb_three_dout)
);

bfour bomb4(
  .clka(clk),
  .wea(1'b0),
  .addra(bomb_four_address),
  .dina(8'h00),
  .douta(bomb_four_dout)
);
bfive bomb5(
  .clka(clk),
  .wea(1'b0),
  .addra(bomb_five_address),
  .dina(8'h00),
  .douta(bomb_five_dout)
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
	/*Explosion explosion(
  .clka(clk),
  .wea(1'b0),
  .addra(explosion_address),
  .dina(8'h00),
  .douta(explosion_dout)
	);*/		
		
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
	assign bomb_block = ~blank & (hcount >= bomb_lo & hcount <= bomb_hi & vcount >= bomb_top & vcount <= bomb_bot); //22x32
	assign bomb_two_block = ~blank & (hcount >= bomb_two_lo & hcount <= bomb_two_hi & vcount >= bomb_two_top & vcount <= bomb_two_bot); //22x32
	assign bomb_three_block = ~blank & (hcount >= bomb_three_lo & hcount <= bomb_three_hi & vcount >= bomb_three_top & vcount <= bomb_three_bot); //22x32
	assign bomb_four_block = ~blank & (hcount >= bomb_four_lo & hcount <= bomb_four_hi & vcount >= bomb_four_top & vcount <= bomb_four_bot); //22x32
	assign bomb_five_lock = ~blank & (hcount >= bomb_five_lo & hcount <= bomb_five_hi & vcount >= bomb_five_top & vcount <= bomb_five_bot); //22x32
	//assign bomb_block = ~blank & (hcount >= bomb_three_lo & hcount <= bomb_three_hi & vcount >= bomb_three_top & vcount <= bomb_three_bot); //22x32
	//assign bomb_block = ~blank & (hcount >= bomb_four_lo & hcount <= bomb_four_hi & vcount >= bomb_four_top & vcount <= bomb_four_bot); //22x32
	//assign bomb_block = ~blank & (hcount >= bomb_five_lo & hcount <= bomb_five_hi & vcount >= bomb_five_top & vcount <= bomb_five_bot); //22x32
	assign hbb_block = ~blank & (hcount >= hbb_lo & hcount <= hbb_hi & vcount >= 20 & vcount <= 107); //64x88
	assign hbnb_block = ~blank & (hcount >= hbnb_lo & hcount <= hbnb_hi & vcount >= 20 & vcount <= 107); //64x88
	assign sb_block = ~blank & (hcount >= sb_lo & hcount <= sb_hi & vcount >= 20 & vcount <= 107); //64x88
	assign pad_block = ~blank & (hcount >= pad_lo & hcount <= pad_hi & vcount >= 410 & vcount <= 425); //84x16
	assign pad1_block = ~blank & (hcount >= pad_lo & hcount <= pad_hi & vcount >= 435 & vcount <= 450); //84x16
	assign pad2_block = ~blank & (hcount >= pad_lo & hcount <= pad_hi & vcount >= 460 & vcount <= 475); //64x16
	//assign explosion_block = ~blank & (hcount >= exp_lo & hcount <= exp_hi & vcount >= 419 & vcount <= 482); //64x64
	assign background_top = ~blank & (hcount >= 0 & hcount <= 640 & vcount >= 20 & vcount <= 107); //640x88
	assign background_bottom = ~blank & (hcount >= 0 & hcount <= 640 & vcount >= 108 & vcount <= 480); //640x392
	assign scoreboard = ~blank & (hcount >= 0 & hcount <= 640 & vcount >= 0 & vcount <= 20); //score tab
	
	assign score_char[9] = ~blank & (hcount >= 490 & hcount <= 497 & vcount >= 2 & vcount <= 17); //S
	assign score_char[8] = ~blank & (hcount >= 500 & hcount <= 507 & vcount >= 2 & vcount <= 17); //C
	assign score_char[7] = ~blank & (hcount >= 510 & hcount <= 517 & vcount >= 2 & vcount <= 17); //O
	assign score_char[6] = ~blank & (hcount >= 520 & hcount <= 527 & vcount >= 2 & vcount <= 17); //R
	assign score_char[5] = ~blank & (hcount >= 530 & hcount <= 537 & vcount >= 2 & vcount <= 17); //E
	assign score_char[4] = ~blank & (hcount >= 540 & hcount <= 547 & vcount >= 2 & vcount <= 17); //:
	//leave a blank tile width
	assign score_char[3] = ~blank & (hcount >= 560 & hcount <= 567 & vcount >= 2 & vcount <= 17); //MSB
	assign score_char[2] = ~blank & (hcount >= 570 & hcount <= 577 & vcount >= 2 & vcount <= 17);  
	assign score_char[1] = ~blank & (hcount >= 580 & hcount <= 587 & vcount >= 2 & vcount <= 17); 
	assign score_char[0] = ~blank & (hcount >= 590 & hcount <= 597 & vcount >= 2 & vcount <= 17); //LSB
	
	
	// a totally separate set of screen regions for the title screen
	
	assign str[0] = ~blank & (hcount >= (320 - 4*font_scale*tile_wd)	& hcount <= (320 - 3*font_scale*tile_wd - 1) & vcount >= tile_top	& vcount <= (tile_top + tile_ht*font_scale - 1)); //32x64 tile
	assign str[1] = ~blank & (hcount >= (320 - 3*font_scale*tile_wd)	& hcount <= (320 - 2*font_scale*tile_wd - 1)	& vcount >= tile_top	& vcount <= (tile_top + tile_ht*font_scale - 1)); //32x64 tile
	assign str[2] = ~blank & (hcount >= (320 - 2*font_scale*tile_wd)	& hcount <= (320 - font_scale*tile_wd - 1) 	& vcount >= tile_top	& vcount <= (tile_top + tile_ht*font_scale - 1)); //32x64 tile
	assign str[3] = ~blank & (hcount >= (320 - font_scale*tile_wd) 	& hcount <= (320 - 1)								& vcount >= tile_top	& vcount <= (tile_top + tile_ht*font_scale - 1)); //32x64 tile
	assign str[4] = ~blank & (hcount >=  320 									& hcount <= (320 + font_scale*tile_wd - 1) 	& vcount >= tile_top	& vcount <= (tile_top + tile_ht*font_scale - 1)); //32x64 tile
   assign str[5] = ~blank & (hcount >= (320 + font_scale*tile_wd) 	& hcount <= (320 + 2*font_scale*tile_wd - 1) & vcount >= tile_top	& vcount <= (tile_top + tile_ht*font_scale - 1)); //32x64 tile
	assign str[6] = ~blank & (hcount >= (320 + 2*font_scale*tile_wd) 	& hcount <= (320 + 3*font_scale*tile_wd - 1) & vcount >= tile_top	& vcount <= (tile_top + tile_ht*font_scale - 1)); //32x64 tile
	assign str[7] = ~blank & (hcount >= (320 + 3*font_scale*tile_wd) 	& hcount <= (320 + 4*font_scale*tile_wd - 1) & vcount >= tile_top	& vcount <= (tile_top + tile_ht*font_scale - 1)); //32x64 tile
	
	genvar i;
	generate
	for (i=0; i<14; i=i+1) begin
		assign cred_blk[i +: 1] = ~blank & (  hcount >= (200 + i*tile_wd)
												 & hcount <= (200 + (i+1)*tile_wd - 1)   
												 & vcount >=  350
												 & vcount <=  365 );
	end
	endgenerate
	
	/*assign kaboom[0] = ~blank & (hcount >= 100 & hcount <= 131 & vcount >= 100	& vcount <= 163); //4 * 8x16 tile
	assign kaboom[1] = ~blank & (hcount >= 135 & hcount <= 166 & vcount >= 100	& vcount <= 163); //4 * 8x16 tile
	assign kaboom[2] = ~blank & (hcount >= 170 & hcount <= 201 & vcount >= 100	& vcount <= 163); //4 * 8x16 tile
	assign kaboom[3] = ~blank & (hcount >= 205 & hcount <= 236 & vcount >= 100	& vcount <= 163); //4 * 8x16 tile
	assign kaboom[4] = ~blank & (hcount >= 240 & hcount <= 271 & vcount >= 100	& vcount <= 163); //4 * 8x16 tile
   assign kaboom[5] = ~blank & (hcount >= 275 & hcount <= 306 & vcount >= 100	& vcount <= 163); //4 * 8x16 tile
	assign kaboom[6] = ~blank & (hcount >= 310 & hcount <= 341 & vcount >= 100	& vcount <= 163); //4 * 8x16 tile
	assign kaboom[7] = ~blank & (hcount >= 345 & hcount <= 376 & vcount >= 100	& vcount <= 163); //4 * 8x16 tile	
	assign title_bomb = ~blank & (hcount >= bomb_lo & hcount <= bomb_hi & vcount >= bomb_top & vcount <= bomb_bot); //22x32	
	*/
	
	// initialize registers
	initial begin
		bomb_top = 108;
		bomb_bot = 139;
		bomb_lo = 21;
		bomb_hi = 42;
		bomb_two_top = 108;
		bomb_two_bot = 139;
		bomb_two_lo = 21;
		bomb_two_hi = 42;
		bomb_three_top = 108;
		bomb_three_bot = 139;
		bomb_three_lo = 21;
		bomb_three_hi = 42;
		bomb_four_top = 108;
		bomb_four_bot = 139;
		bomb_four_lo = 21;
		bomb_four_hi = 42;
		bomb_five_top = 108;
		bomb_five_bot = 139;
		bomb_five_lo = 21;
		bomb_five_hi = 42;
		b2_lo = 21;
		b2_hi = 42;
       		
		hbb_lo = 1;
		hbb_hi = 64;		
		hbnb_lo = 1;
		hbnb_hi = 64;		
		sb_lo = 1;
		sb_hi = 64;		
		pad_lo = 1;
		pad_hi = 64;
		//exp_lo = 1;
		//exp_hi = 64;
		bmb=1;
		flag=0;
		bmb_2=1;
		bmb_3=1;
		bmb_4=1;
		bmb_5=1;
		x=1;
		
	end
	reg sync_flag = 0;
	//this always block controls the block movement by increasing/resetting position values //NEW MODULE
	always @ (posedge clk_slow) begin
	
		//bomb
		if ((bomb_bot < 400) & (pad_hi>=bomb_lo&pad_hi<=bomb_lo+85)) begin //Bottom of the screen			x<=1;
			bmb<=1;
			bomb_top <= bomb_top + 3'b001;
			bomb_bot <= bomb_bot + 3'b001;
			flag <= 0;
			sync_flag <= 0; //start address
			
		if ((bomb_bot == 399) & (pad_hi>=bomb_lo & pad_hi<=bomb_lo+85))
			begin
			score <= score + 1;
			end
		end 
		
		else if (bomb_bot < 480 & (pad_hi<bomb_lo|pad_lo>bomb_hi)) begin //Bottom of the screen
			
			bmb<=1;
			bomb_top <= bomb_top + 3'b001;
			bomb_bot <= bomb_bot + 3'b001;
			flag_in_sync <= 1; //Sync Flag
			flag<=0;
			x<=1;
			if(bomb_bot>475)begin
			bmb<=0;
			flag<=1;
			x<=1;
		
			end
		end 
		//////////////////////////////////////////////////////////////////
		/*else if (bomb_bot>475 & bomb_bot<500)begin
		bomb_top <= bomb_top + 3'b001;
			bomb_bot <= bomb_bot + 3'b001;
			bmb<=0;
			end*/
		
		////////////////////////////////////////////////////////////////
		/*else if(bomb_bot>475)begin
		bmb<=0;
		flag<=1;
		end*/
		//////////////////////////////////////////////////////////////
		else begin
		//bmb<=1;
			//if (bmb) score <= score + 1;
			bomb_top <= 108;
			bomb_bot <= 139;
			bomb_lo<=b2_lo;
			bomb_hi<=b2_hi;
			
			//flag<=0;
		end
		/*if(bomb_bot>475)begin
		flag<=1;
		end*/
		
		if ((bomb_two_bot < 400) & (pad_hi>=bomb_two_lo & pad_hi<=bomb_two_lo+85)) begin //Bottom of the screen
			x<=1;
			bmb_2<=1;
			bomb_two_top <= bomb_two_top + 3'b001;
			bomb_two_bot <= bomb_two_bot + 3'b001;
			flag<=0;
			if ((bomb_two_bot == 399) & (pad_hi>=bomb_two_lo & pad_hi<=bomb_two_lo+85))
			begin
			score <= score + 1;
			end
		end 
		else if (bomb_two_bot < 480 & (pad_hi<bomb_two_lo|pad_lo>bomb_two_hi)) begin //Bottom of the screen
			
			bmb_2<=1;
			bomb_two_top <= bomb_two_top + 3'b001;
			bomb_two_bot <= bomb_two_bot + 3'b001;
			flag<=0; //For Explosion
			x<=1; //For Explosion
			if(bomb_two_bot>475)begin
			bmb_2<=0;
			flag<=1;
			x<=1;
		
			end
		end
		
		else begin
		//bmb<=1;
			//if (bmb) score <= score + 1;
			if(bomb_top==200)
			begin
			bomb_two_top <= 108;
			bomb_two_bot <= 139;
			bomb_two_lo<=b2_lo;
			bomb_two_hi<=b2_hi;
		end
		end
		
		
		if ((bomb_three_bot < 400) & (pad_hi>=bomb_three_lo & pad_hi<=bomb_three_lo+85)) begin //Bottom of the screen
			x<=1;
			bmb_3<=1;
			bomb_three_top <= bomb_three_top + 3'b001;
			bomb_three_bot <= bomb_three_bot + 3'b001;
			flag<=0;
			if ((bomb_three_bot == 399) & (pad_hi>=bomb_three_lo & pad_hi<=bomb_three_lo+85))
			begin
			score <= score + 1;
			end
		end 
		else if (bomb_three_bot < 480 & (pad_hi<bomb_three_lo|pad_lo>bomb_three_hi)) begin //Bottom of the screen
			
			bmb_3<=1;
			bomb_three_top <= bomb_three_top + 3'b001;
			bomb_three_bot <= bomb_three_bot + 3'b001;
			flag<=0;
			x<=1;
			if(bomb_three_bot>475)begin
			bmb_3<=0;
			flag<=1;
			x<=1;
		
			end
		end 
		
		else begin
		//bmb<=1;
			//if (bmb) score <= score + 1;
			if(bomb_top==250)
			begin
			bomb_three_top <= 108;
			bomb_three_bot <= 139;
			bomb_three_lo<=b2_lo;
			bomb_three_hi<=b2_hi;
		end
		end
		
		
		
		if ((bomb_four_bot < 400) & (pad_hi>=bomb_four_lo & pad_hi<=bomb_four_lo+85)) begin //Bottom of the screen
			x<=1;
			bmb_4<=1;
			bomb_four_top <= bomb_four_top + 3'b001;
			bomb_four_bot <= bomb_four_bot + 3'b001;
			flag<=0;
		if ((bomb_four_bot == 399) & (pad_hi>=bomb_four_lo & pad_hi<=bomb_four_lo+85))
			begin
			score <= score + 1;
			end
		end 
		else if (bomb_four_bot < 480 & (pad_hi<bomb_four_lo|pad_lo>bomb_four_hi)) begin //Bottom of the screen
			
			bmb_4<=1;
			bomb_four_top <= bomb_four_top + 3'b001;
			bomb_four_bot <= bomb_four_bot + 3'b001;
			flag<=0;
			x<=1;
			if(bomb_four_bot>475)begin
			bmb_4<=0;
			flag<=1;
			x<=1;
		
			end
		end 
		
		else begin
		//bmb<=1;
			//if (bmb) score <= score + 1;
			if(bomb_top==320)
			begin
			bomb_four_top <= 108;
			bomb_four_bot <= 139;
			bomb_four_lo<=b2_lo;
			bomb_four_hi<=b2_hi;
		end
		end		
		
		if ((bomb_five_bot < 400) & (pad_hi>=bomb_five_lo & pad_hi<=bomb_five_lo+85)) begin //Bottom of the screen
			x<=1;
			bmb_5<=1;
			bomb_five_top <= bomb_five_top + 3'b001;
			bomb_five_bot <= bomb_five_bot + 3'b001;
			flag<=0;
			if ((bomb_five_bot == 399) & (pad_hi>=bomb_five_lo & pad_hi<=bomb_five_lo+85))
			begin
			score <= score + 1;
			end
		end
		
		else if (bomb_five_bot < 480 & (pad_hi<bomb_five_lo|pad_lo>bomb_five_hi)) begin //Bottom of the screen
			
			bmb_5<=1;
			bomb_five_top <= bomb_five_top + 3'b001;
			bomb_five_bot <= bomb_five_bot + 3'b001;
			flag<=0;
			x<=1;
			if(bomb_five_bot>475)begin
			bmb_5<=0;
			flag<=1;
			x<=1;
		
			end
		end 
		
		else begin
		//bmb<=1;
			//if (bmb) score <= score + 1;
			if(bomb_top==370)
			begin
			bomb_five_top <= 108;
			bomb_five_bot <= 139;
			bomb_five_lo<=b2_lo;
			bomb_five_hi<=b2_hi;
		end
		end
		//Happy Bomber with bomb
		if (hbb_hi < 640 & bomb_hi < 640 & move) 
		begin
		
			hbb_lo <= hbb_lo + 3'b001;
			hbb_hi <= hbb_hi + 3'b001;
			b2_lo<=b2_lo+3'b001;
			b2_hi<=b2_hi+3'b001;
			end
			//exp_lo <= exp_lo + 3'b001;
			//exp_hi <= exp_hi + 3'b001;
	
		else if(hbb_lo>1 & bomb_lo > 1 & back)
		begin
		hbb_lo <= hbb_lo - 3'b001;
			hbb_hi <= hbb_hi - 3'b001;
			b2_lo<=b2_lo-3'b001;
			b2_hi<=b2_hi-3'b001;
			//exp_lo <= exp_lo - 3'b001;
			//exp_hi <= exp_hi - 3'b001;
			
		end
		else begin
			hbb_lo <= hbb_lo; //0;
			hbb_hi <= hbb_hi; //63;
		end
		
		/*
		//Happy Bomber without bomb
		if (hbnb_hi < 640 & bomb_hi < 640 & move) begin
		
			hbnb_lo <= hbnb_lo + 3'b001;
			hbnb_hi <= hbnb_hi + 3'b001;
			bomb_lo<=bomb_lo+3'b001;
			bomb_hi<=bomb_hi+3'b001;
			//exp_lo <= exp_lo + 3'b001;
			//exp_hi <= exp_hi + 3'b001;
			
		end 
		else if(hbnb_lo>1 & bomb_lo > 1 & back)
		begin
		hbnb_lo <= hbnb_lo - 3'b001;
			hbnb_hi <= hbnb_hi - 3'b001;
			bomb_lo<=bomb_lo-3'b001;
			bomb_hi<=bomb_hi-3'b001;
			//exp_lo <= exp_lo - 3'b001;
			//exp_hi <= exp_hi - 3'b001;
		end
		else begin
			hbnb_lo <= hbnb_lo;//0;
			hbnb_hi <= hbnb_hi;//63;
			
		end
		
		//Sad Bomber with bomb
		if (sb_hi < 640 & bomb_hi < 640 &  move) 
		begin
			sb_lo <= sb_lo + 3'b001;
			sb_hi <= sb_hi + 3'b001;
			bomb_lo<=bomb_lo+3'b001;
			bomb_hi<=bomb_hi+3'b001;
			//exp_lo <= exp_lo + 3'b001;
			//exp_hi <= exp_hi + 3'b001;
			
		end 
		else if(sb_lo>1 & bomb_lo > 1 & back)
		begin
		sb_lo <= sb_lo - 3'b001;
			sb_hi <= sb_hi - 3'b001;
			bomb_lo<=bomb_lo-3'b001;
			bomb_hi<=bomb_hi-3'b001;
			//exp_lo <= exp_lo - 3'b001;
			//exp_hi <= exp_hi - 3'b001;
		end
		else begin
			sb_lo <= sb_lo;//0;
			sb_hi <= sb_hi;//63;
		//end*/
		
		//pad block
		if (pad_r & pad_hi < 640) begin
			pad_lo <= pad_lo + 3'b001;
			pad_hi <= pad_hi + 3'b001;
		end 
		else if(pad_l & pad_lo>1)
		begin
		pad_lo <= pad_lo - 3'b001;
			pad_hi <= pad_hi - 3'b001;
		end
		else begin
			pad_lo <=pad_lo; //0;
			pad_hi <=pad_hi; //63;
		end
		
	end  //end of the clk_slow always block
	
	//This always block controls actually drawing the blocks on the screen
	
	always @ (posedge clk_25MHz)
	begin	
	if(rst==1)
		begin
			hbb_address <= 0; //Avoids shifting after a reset.     
			hbnb_address <= 0;
			sb_address <= 0;
			//explosion_address <= 0;
			pad_address <= 0;
		end
		
		/////////////////////////title rom/////////////////////
		
		if (R_val < 3'b111) begin
			if (color_timer < 25'b1_1111_1111_1111_1111_1111_1111) begin
				color_timer <= color_timer + 1;
			end else begin
				color_timer <= 0;
				R_val <= R_val + 1;
				if (size_timer) begin
					size_timer <= 0;
					font_scale <= font_scale + 1;
				end else begin
					size_timer <= 1;
				end
			end
		end
		else begin
			font_scale <= 4;
		end
		
		if (str) begin 
				R <= R_val & { 3{tile[tile_ctr]} };
				G <= 0; //toggle[5:3] & { 3{tile[tile_ctr]} };
				B <= 0; //{ toggle[6], 1'b0 } & { 2{tile[tile_ctr]} };
				
				
				row_ctr <= row_ctr + 1;
				if (x_ctr == (font_scale-1)) begin
					tile_ctr <= tile_ctr - 1;
					x_ctr <= 0;
					if (row_ctr == (font_scale*8-1)) begin		  //at end of each row
						row_ctr <= 0;
						
						if (char_ctr == 7) begin
							char_ctr <= 0;
							if (y_ctr == (font_scale-1)) begin		
								y_ctr <= 0;
							end else begin
								y_ctr <= y_ctr + 1;
								tile_ctr <= tile_ctr + 7;	// do this row over again
							end
						end else begin
							char_ctr <= char_ctr + 1;
							tile_ctr <= tile_ctr + 7;  // same row, different char
						end
						
						case (char_ctr)
							0: char_sel <= 10; //A
							1: char_sel <= 11; //B
							2: char_sel <= 24; //O
							3: char_sel <= 24; //O
							4: char_sel <= 22; //M
							5: char_sel <= 30; //!
							6: char_sel <= 32; //blank
							7: char_sel	<= 20; //K
						endcase
						

					end
				end else begin		// do this pixel over again
					x_ctr <= x_ctr + 1;
				end
		end


		//Draw the credits
		/*else if (cred_blk) begin
			R <= 3'b111 & { 3{tile[cred_tile_ctr]} };
			G <= 3'b111 & { 3{tile[cred_tile_ctr]} };
			B <= 3'b111 & { 2{tile[cred_tile_ctr]} };


			cred_row_ctr<= cred_row_ctr+ 1;
			cred_tile_ctr <= cred_tile_ctr - 1;
			if (cred_row_ctr== 7) begin		  //at end of each row
				cred_row_ctr<= 0;
				if (cred_char_ctr == 13) begin
					cred_char_ctr <= 0;	
				end else begin
					cred_char_ctr <= cred_char_ctr + 1;
					cred_tile_ctr <= cred_tile_ctr + 7;  // same row, different char
				end
					
				char_sel <= credit_text[cred_char_ctr];
					
				//notice that this should be offset so it draws the right character next time	
				
			end
		end*/
		
		////////////////////title rom////////////////////////////
		
		if (bomb_block & bmb==1)
			begin //bomb block detection
					R <= bomb_dout[7:5];
					G <= bomb_dout[4:2];
					B <= bomb_dout[1:0];
					if (bomb_address < 703) bomb_address <= bomb_address + 1;
					else if (sync_flag==0) bomb_address <= 0;
			end
		
		/*else if (bomb_two_block & bmb_2==1) begin //bomb block detection
				R <= bomb_two_dout[7:5];
				G <= bomb_two_dout[4:2];
				B <= bomb_two_dout[1:0];
				if (bomb_two_address == 703) 
					begin
					bomb_two_address <= 0;
					end
				else bomb_two_address <= bomb_two_address + 1;
		end		


else if (bomb_three_block & bmb_3==1) begin //bomb block detection
				R <= bomb_three_dout[7:5];
				G <= bomb_three_dout[4:2];
				B <= bomb_three_dout[1:0];
				if (bomb_three_address == 703) 
					begin
					bomb_three_address <= 0;
					end
				else bomb_three_address <= bomb_three_address + 1;
		end		
		
		
		else if (bomb_four_block & bmb_4==1) begin //bomb block detection
				R <= bomb_four_dout[7:5];
				G <= bomb_four_dout[4:2];
				B <= bomb_four_dout[1:0];
				if (bomb_four_address == 703) 
					begin
					bomb_four_address <= 0;
					end
				else bomb_four_address <= bomb_four_address + 1;
		end		
		
		
		else if (bomb_five_block & bmb_5==1) begin //bomb block detection
				R <= bomb_five_dout[7:5];
				G <= bomb_five_dout[4:2];
				B <= bomb_five_dout[1:0];
				if (bomb_five_address == 703)
					begin
					bomb_five_address <= 0;
					end
				else bomb_five_address <= bomb_five_address + 1;
		end	*/	

		/*else if (explosion_block & flag==1) begin //explosion
				R <= explosion_dout[7:5];
				G <= explosion_dout[4:2];
				B <= explosion_dout[1:0];
				if (explosion_address == 57343) explosion_address <= 0;
				else explosion_address <= explosion_address + 1;
		end*/			
		
		//Comment/Uncomment for enabling bombers
		
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
			else if (scoreboard) begin  //black background for score
				R <= 0;
				G <= 0;
				B <= 0;
				if (score_char) begin
					R <= 3'b111 & { 3{tile[tile_ctr]} };
					G <= 3'b111 & { 3{tile[tile_ctr]} };
					B <= 3'b111 & { 2{tile[tile_ctr]} };


					row_ctr <= row_ctr + 1;
					tile_ctr <= tile_ctr - 1;
					if (row_ctr == 7) begin		  //at end of each row
						row_ctr <= 0;
						if (char_ctr == 9) begin
							char_ctr <= 0;	
						end else begin
							char_ctr <= char_ctr + 1;
							tile_ctr <= tile_ctr + 7;  // same row, different char
						end
							
						//notice that this should be offset so it draws the right character next time	
						case (char_ctr)
							0: char_sel <= 12; //load C
							1: char_sel <= 22; //load O
							2: char_sel <= 23; //load R
							3: char_sel <= 14; //load E
							4: char_sel <= 26; //load :
							5: char_sel <= dec_score[3]; //load MSB
							6: char_sel <= dec_score[2]; 
							7: char_sel <= dec_score[1]; 
							8: char_sel <= dec_score[0]; 
							9: char_sel <= 24; //load S
						endcase		
					end


					// this is the same code as above, but scalable - leave for now
					// in case we want to make the score bigger at some point
					/*row_ctr <= row_ctr + 1;
					if (x_ctr == 1) begin
						tile_ctr <= tile_ctr - 1;
						x_ctr <= 0;
						if (row_ctr == 15) begin		  //at end of each row
							row_ctr <= 0;
							
							if (char_ctr == 3) begin
								char_ctr <= 0;
								if (y_ctr == 1) begin		
									y_ctr <= 0;
								end else begin
									y_ctr <= y_ctr + 1;
									tile_ctr <= tile_ctr + 7;	// do this row over again
								end
							end else begin
								char_ctr <= char_ctr + 1;
								tile_ctr <= tile_ctr + 7;  // same row, different char
							end
							
							case (char_ctr)
								0: char_sel <= dec_score[3]; //MSB
								1: char_sel <= dec_score[2]; 
								2: char_sel <= dec_score[1]; 
								3: char_sel <= dec_score[0]; //LSB
							endcase
							

						end
					end else begin		// do this pixel over again
						x_ctr <= x_ctr + 1;
					end*/
				end
		end
		
		else begin	//the screen is black everywhere else
			R <= 0;
			G <= 0;
			B <= 0;
		end
		
	end
endmodule
