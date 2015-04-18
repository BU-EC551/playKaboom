`timescale 1ns / 1ps

module vga_display_bomb(
	input rst,	// global reset
	input clk,
	input move,
	input back,
	input pad_r,
	input pad_l,	// 100MHz clk
	input title_toggle,
	input pause,
	input resume,
	
	// color outputs to show on display (current pixel)
	output reg rst_bmb,
	output reg [2:0] R, G,
	output reg [1:0] B,
	// VGA Synchronization signals
	output HS,
	output VS,
	
	output [6:0] seven,
	output [3:0] svn_digit,
	
	output test_led0,
	output test_led1
	);
	
	reg [1:0] game_state = 0;
	
	assign test_led1 = game_state;
	assign test_led0 = title_toggle;
	
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
	reg rst_1;
	reg rst_2;
	reg rst_3;
	reg rst_4;
	reg rst_5;
	reg rst_hbb;
	reg rst_hbnb;
	reg yesbomb;
	reg nobomb;
	reg rst_pad;
	
	//various things for the scoreboard
	reg [9:0] score;				  // actual score
	wire [3:0] dec_score [0:3];  // score as four BCD decimal digits
	//reg [3:0] char_ctr;			  // indicates which digit VGA should draw
	//reg [4:0] char_sel;			  // character selector for font rom
	//wire [127:0] tile;           // character tile from font rom
	wire [9:0] score_char;		  // the VGA position blocks
	

	///////////////TITLESCREEN DECLARATIONS//////
	wire title_bomb;
	reg [24:0] color_timer;
	reg [2:0] R_val;
	
	wire [127:0] tile;
	reg [6:0] tile_ctr = 127;
	
	reg [1:0] x_ctr;
	reg [4:0] col_ctr;
	reg [1:0] y_ctr;
	
	
	reg [3:0] char_ctr;
	reg [5:0] char_sel;
	
	wire [7:0] str;
	
	
	reg [3:0] font_scale = 1;
	parameter tile_wd = 8;
	parameter tile_ht = 16; 
	//parameter tile_top = 100;
	parameter TILE_CTR_V = 108;  //top pixel of the bottom half of the title tiles
	parameter TITLE_CTR_H = 320; //first pixel in the right half of the title tiles
	
	parameter NAME_LEFT = 50;
	parameter NAME_WIDTH = 16;
	reg size_timer;
	
	wire [63:0] name_blk;
	reg [5:0] names [0:63];
	reg [6:0] cred_tile_ctr = 127;
	reg [3:0] cred_col_ctr;
	reg [4:0] cred_row_ctr;
	reg [3:0] cred_char_ctr;
	reg [1:0] line_ctr;
	
	wire [18:0] start_blk;
	//reg [5:0] start_msg [0:18];
	reg [6:0] start_tile_ctr = 127;
	reg [3:0] start_col_ctr;
	reg [4:0] start_char_ctr;
	
	reg [5:0] start_msg[0:18] = 
	{ 							 
								6'h1B, //R 
								6'h0E, //E
								6'h1C, //S
								6'h1C, //S
								6'h27, //
								6'h1C, //S
								6'h1D, //T
								6'h0A, //A
								6'h1B, //R
								6'h1D, //T
								6'h27, //
								6'h1D, //T
								6'h18, //O 
								6'h27, //
								6'h19, //P
								6'h15, //L
								6'h0A, //A
								6'h22,  //Y
								6'h19 //P 
							};
	
	////////////////END TITLE SCREEN VARIABLES///////////////
	
	
	
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
	
	
	
	
	
	
	
	//convert score to decimal digits
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
	

////////BEGIN SPRITE INSTANTIATIONS///////////////	
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
	
/////////////////////END SPRITE INSTANTIATIONS/////////////////////////////




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
	
	///////////////////GAMEMPLAY BLOCKS/////////////////////////////
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
	
	/////////////SCOREBOARD BLOCKS////////////////////
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
	
	/*BACKUP COPY OF WORKING VERSION
	//////////TITLE SCREEN BLOCKS////////////////
	assign str[0] = ~blank & (hcount >= (320 - 4*font_scale*tile_wd)	& hcount <= (320 - 3*font_scale*tile_wd - 1) & vcount >= tile_top	& vcount <= (tile_top + tile_ht*font_scale - 1)); //32x64 tile
	assign str[1] = ~blank & (hcount >= (320 - 3*font_scale*tile_wd)	& hcount <= (320 - 2*font_scale*tile_wd - 1)	& vcount >= tile_top	& vcount <= (tile_top + tile_ht*font_scale - 1)); //32x64 tile
	assign str[2] = ~blank & (hcount >= (320 - 2*font_scale*tile_wd)	& hcount <= (320 - font_scale*tile_wd - 1) 	& vcount >= tile_top	& vcount <= (tile_top + tile_ht*font_scale - 1)); //32x64 tile
	assign str[3] = ~blank & (hcount >= (320 - font_scale*tile_wd) 	& hcount <= (320 - 1)								& vcount >= tile_top	& vcount <= (tile_top + tile_ht*font_scale - 1)); //32x64 tile
	assign str[4] = ~blank & (hcount >=  320 									& hcount <= (320 + font_scale*tile_wd - 1) 	& vcount >= tile_top	& vcount <= (tile_top + tile_ht*font_scale - 1)); //32x64 tile
   assign str[5] = ~blank & (hcount >= (320 + font_scale*tile_wd) 	& hcount <= (320 + 2*font_scale*tile_wd - 1) & vcount >= tile_top	& vcount <= (tile_top + tile_ht*font_scale - 1)); //32x64 tile
	assign str[6] = ~blank & (hcount >= (320 + 2*font_scale*tile_wd) 	& hcount <= (320 + 3*font_scale*tile_wd - 1) & vcount >= tile_top	& vcount <= (tile_top + tile_ht*font_scale - 1)); //32x64 tile
	assign str[7] = ~blank & (hcount >= (320 + 3*font_scale*tile_wd) 	& hcount <= (320 + 4*font_scale*tile_wd - 1) & vcount >= tile_top	& vcount <= (tile_top + tile_ht*font_scale - 1)); //32x64 tile
	*/
	
	//////////TITLE SCREEN BLOCKS////////////////
	assign str[0] = ~blank & (hcount >= (TITLE_CTR_H - 4*font_scale*tile_wd)& hcount <= (TITLE_CTR_H - 3*font_scale*tile_wd - 1) 	& vcount >= (TILE_CTR_V - (tile_ht/2)*font_scale)	& vcount <= (TILE_CTR_V + (tile_ht/2)*font_scale - 1)); 
	assign str[1] = ~blank & (hcount >= (TITLE_CTR_H - 3*font_scale*tile_wd)& hcount <= (TITLE_CTR_H - 2*font_scale*tile_wd - 1) 	& vcount >= (TILE_CTR_V - (tile_ht/2)*font_scale)	& vcount <= (TILE_CTR_V + (tile_ht/2)*font_scale - 1)); 
	assign str[2] = ~blank & (hcount >= (TITLE_CTR_H - 2*font_scale*tile_wd)& hcount <= (TITLE_CTR_H - font_scale*tile_wd - 1) 	& vcount >= (TILE_CTR_V - (tile_ht/2)*font_scale)	& vcount <= (TILE_CTR_V + (tile_ht/2)*font_scale - 1)); 
	assign str[3] = ~blank & (hcount >= (TITLE_CTR_H - font_scale*tile_wd) 	& hcount <= (TITLE_CTR_H - 1)									& vcount >= (TILE_CTR_V - (tile_ht/2)*font_scale)	& vcount <= (TILE_CTR_V + (tile_ht/2)*font_scale - 1)); 
	assign str[4] = ~blank & (hcount >=  TITLE_CTR_H 								& hcount <= (TITLE_CTR_H + font_scale*tile_wd - 1) 	& vcount >= (TILE_CTR_V - (tile_ht/2)*font_scale)	& vcount <= (TILE_CTR_V + (tile_ht/2)*font_scale - 1)); 
   assign str[5] = ~blank & (hcount >= (TITLE_CTR_H + font_scale*tile_wd) 	& hcount <= (TITLE_CTR_H + 2*font_scale*tile_wd - 1) 	& vcount >= (TILE_CTR_V - (tile_ht/2)*font_scale)	& vcount <= (TILE_CTR_V + (tile_ht/2)*font_scale - 1)); 
	assign str[6] = ~blank & (hcount >= (TITLE_CTR_H + 2*font_scale*tile_wd)& hcount <= (TITLE_CTR_H + 3*font_scale*tile_wd - 1) 	& vcount >= (TILE_CTR_V - (tile_ht/2)*font_scale)	& vcount <= (TILE_CTR_V + (tile_ht/2)*font_scale - 1)); 
	assign str[7] = ~blank & (hcount >= (TITLE_CTR_H + 3*font_scale*tile_wd)& hcount <= (TITLE_CTR_H + 4*font_scale*tile_wd - 1) 	& vcount >= (TILE_CTR_V - (tile_ht/2)*font_scale)	& vcount <= (TILE_CTR_V + (tile_ht/2)*font_scale - 1)); 
	
	assign title_bomb = ~blank & (hcount >= 310 & hcount <= 331 & vcount >= 200 & vcount <= 231);
	
	
	
	genvar i;
	generate
		//START MESSAGE
		for (i=0; i<19; i=i+1) begin: start_loop
			assign start_blk[i] = ~blank & (  hcount >= (240 + i*tile_wd)
															& hcount <= (240 + (i+1)*tile_wd - 1)   
															& vcount >=  270
															& vcount <=  285 );
		end
	
		//NAME CREDITS
		for (i=0; i<16; i=i+1) begin: name_1
			assign name_blk[i +: 1] = ~blank & (  hcount >= (NAME_LEFT + i*tile_wd)
															& hcount <= (NAME_LEFT + (i+1)*tile_wd - 1)   
															& vcount >=  350
															& vcount <=  365 );
		end
	
		for (i=16; i<32; i=i+1) begin: name_2
			assign name_blk[i +: 1] = ~blank & (  hcount >= (NAME_LEFT + i*tile_wd)
																& hcount <= (NAME_LEFT +  (i+1)*tile_wd - 1)   
																& vcount >=  370
																& vcount <=  385 );
		end
		
		for (i=32; i<48; i=i+1) begin: name_3
			assign name_blk[i +: 1] = ~blank & (  hcount >= (NAME_LEFT + i*tile_wd)
																& hcount <= (NAME_LEFT +  (i+1)*tile_wd - 1)   
																& vcount >=  390
																& vcount <=  405 );
		end
		
		for (i=48; i<64; i=i+1) begin: name_4
			assign name_blk[i +: 1] = ~blank & (  hcount >= (NAME_LEFT + i*tile_wd)
																& hcount <= (NAME_LEFT +  (i+1)*tile_wd - 1)   
																& vcount >=  410
																& vcount <=  425 );
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
		rst_1=0;
		rst_2=0;
		rst_3=0;
		rst_4=0;
		rst_5=0;
		//rst_hbb=0;
		//rst_hbnb=0;
		//yesbomb=1;
		//nobomb=0;
		//TITLE SCREEN INITIALIZATIONS 
		

		
		//Rama L
		names[0] = 10;
		names[1] = 22;
		names[2] = 10;
		names[3] = 39;
		names[4] = 21;
		names[5] = 10;
		names[6] = 20;
		names[7] = 28;
		names[8] = 17;
		names[9] = 22;
		names[10] = 10;
		names[11] = 23;
		names[12] = 10;
		names[13] = 23;
		names[14] = 39;
		names[15] = 27;
		
		//Sai K Sankar
		names[16] = 10;
		names[17] = 18;
		names[18] = 39;
		names[19] = 20;
		names[20] = 39;
		names[21] = 28;
		names[22] = 10;
		names[23] = 23;
		names[24] = 20;
		names[25] = 10;
		names[26] = 27;
		names[27] = 39;
		names[28] = 39;
		names[29] = 39;
		names[30] = 39;
		names[31] = 28;
		
		//JC Morales
		names[32] = 12;
		names[33] = 39;
		names[34] = 22;
		names[35] = 24;
		names[36] = 27;
		names[37] = 10;
		names[38] = 21;
		names[39] = 14;
		names[40] = 28;
		names[41] = 39;
		names[42] = 39;
		names[43] = 39;
		names[44] = 39;
		names[45] = 39;
		names[46] = 39;
		names[47] = 19;
		
		//Laura Kamfonik
		names[48] = 10;
		names[49] = 30;
		names[50] = 27;
		names[51] = 10;
		names[52] = 39;
		names[53] = 20;
		names[54] = 10;
		names[55] = 22;
		names[56] = 15;
		names[57] = 24;
		names[58] = 23;
		names[59] = 18;
		names[60] = 20;
		names[61] = 39;
		names[62] = 39;
		names[63] = 21;
	end
	
	// controls game state
	always @ (posedge clk) begin
		case (game_state)
			0: if (title_toggle) game_state <= 1;
			1: if (pause) game_state <= 2;
			2: if (resume) game_state <= 1;
			3: game_state <= 1;
		endcase

	end
	
	//this always block controls the block movement by increasing/resetting position values
	always @ (posedge clk_slow) begin	
	
	case (game_state)
		0: begin
			//nothing moves
		end
		
	1: begin // game state 1, gameplay
	//hbwb<=1;
		//hbwob<=0;
		//bomb
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
		
		 if ((bomb_bot < 400) & (pad_hi>=bomb_lo&pad_hi<=bomb_lo+85)) begin //Bottom of the screen
			//rst_hbb<=0;
			
			//yesbomb<=1;
			//nobomb<=0;
			//rst_hbnb<=1;
			x<=1;
			bmb<=1;
			bomb_top <= bomb_top + 3'b001;
			bomb_bot <= bomb_bot + 3'b001;
			rst_1<=0;
			/*if(bomb_top<=150)
			begin
			rst_hbnb<=0;
		
			yesbomb<=0;
			nobomb<=1;
			rst_hbb<=1;
			end*/
			if(bomb_bot==140 | bomb_bot==172 |bomb_bot==205 | bomb_bot==237 | bomb_bot==270 |bomb_bot==302 |bomb_bot==334|bomb_bot==366)
			begin
			rst_1<=1;
			end
	
		else if ((bomb_bot == 399) & (pad_hi>=bomb_lo & pad_hi<=bomb_lo+85))
			begin
			score <= score + 1;
			end
		end 
		///////////////////////////////////////////
		/*else if(bomb_bot<476)begin
		bmb<=1;
		bomb_top <= bomb_top + 3'b001;
			bomb_bot <= bomb_bot + 3'b001;
			flag<=0;
		end */
		

		
		/////////////////////////////////////////////////////////////////////
		else if (bomb_bot < 480 & (pad_hi<bomb_lo|pad_lo>bomb_hi)) begin //Bottom of the screen
			
			bmb<=1;
			//rst_hbb<=0;
			
			//yesbomb<=1;
			//nobomb<=0;
			//rst_hbnb<=1;
			bomb_top <= bomb_top + 3'b001;
			bomb_bot <= bomb_bot + 3'b001;
			rst_1<=0;
			/*	if(bomb_bot>300)
			begin
			rst_hbnb<=1;
			
			yesbomb<=1;
			nobomb<=0;
			rst_hbb<=0;
			end
				if(bomb_top<=150)
			begin
			rst_hbnb<=0;
		
			yesbomb<=0;
			nobomb<=1;
			rst_hbb<=1;
			end*/		
			

				if(bomb_bot==140 | bomb_bot==172 |bomb_bot==205 | bomb_bot==237 | bomb_bot==270 |bomb_bot==302 |bomb_bot==334|bomb_bot==366|bomb_bot==400|bomb_bot==432|bomb_bot==464)
			begin
			rst_1<=1;
			
			end
			else if(bomb_bot>475)begin
			bmb<=0;

			x<=1;
		
			end
		end 
		//////////////////////////////////////////////////////////////////
		else if (bomb_bot > 400 & bomb_bot < 480 & (pad_hi==bomb_lo|pad_lo==bomb_hi)) begin //Bottom of the screen
			
			bmb<=1;
			//rst_hbb<=0;
			
			//yesbomb<=1;
			//nobomb<=0;
			//rst_hbnb<=1;
			bomb_top <= 108;
			bomb_bot <= 139;
			rst_1<=0;
				score<=score+1;
				rst_pad<=1;
				if(bomb_bot==141 | bomb_bot==174 |bomb_bot==207 | bomb_bot==240 | bomb_bot==273 |bomb_bot==307 |bomb_bot==341|bomb_bot==375|bomb_bot==409|bomb_bot==443|bomb_bot==477)
			begin
			rst_1<=1;
			
			end
			else if(bomb_bot>475)begin
			bmb<=0;

			x<=1;
		
			end
		end 
		
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
		/*rst_1<=1;
		rst_hbb<=0;
		rst_hbnb<=1;
	yesbomb<=1;
	nobomb<=0;*/
		end
		/*if(bomb_bot>475)begin
		flag<=1;
		end*/
		
		
		if ((bomb_two_bot < 400) & (pad_hi>=bomb_two_lo & pad_hi<=bomb_two_lo+85)) begin //Bottom of the screen
			
			//rst_hbb<=0;
			
			//yesbomb<=1;
			//nobomb<=0;
			//rst_hbnb<=1;
			x<=1;
			bmb_2<=1;
			bomb_two_top <= bomb_two_top + 3'b001;
			bomb_two_bot <= bomb_two_bot + 3'b001;
			rst_2<=0;
			/*if(bomb_two_top<=150)
			begin
			rst_hbnb<=0;
		
			yesbomb<=0;
			nobomb<=1;
			rst_hbb<=1;
			end*/	
			if(bomb_bot==140 | bomb_bot==172 |bomb_bot==205 | bomb_bot==237 | bomb_bot==270 |bomb_bot==302 |bomb_bot==334|bomb_bot==366)
			begin
			rst_2<=1;
			
			end

			else if ((bomb_two_bot == 399) & (pad_hi>=bomb_two_lo & pad_hi<=bomb_two_lo+85))
			begin
			bmb_2<=0;
			score <= score + 1;
			end
		end 
		else if (bomb_two_bot < 480 & (pad_hi<bomb_two_lo|pad_lo>bomb_two_hi)) begin //Bottom of the screen
			
			bmb_2<=1;
			//rst_hbb<=0;
			
			//yesbomb<=1;
			//nobomb<=0;
			//rst_hbnb<=1;
			bomb_two_top <= bomb_two_top + 3'b001;
			bomb_two_bot <= bomb_two_bot + 3'b001;
			rst_2<=0;
			x<=1;
			/*if(bomb_two_top<=150)
			begin
			rst_hbnb<=0;
		
			yesbomb<=0;
			nobomb<=1;
			rst_hbb<=1;
			end*/	
			
			if(bomb_bot==140 | bomb_bot==172 |bomb_bot==205 | bomb_bot==237 | bomb_bot==270 |bomb_bot==302 |bomb_bot==334|bomb_bot==366|bomb_bot==400|bomb_bot==432|bomb_bot==464)
			begin
			rst_2<=1;
			
			end
			else if(bomb_two_bot>475)begin
			bmb_2<=0;
		
			x<=1;
		
			end
		end 
		
		
		
		
		
		else if (bomb_two_bot > 400 & bomb_two_bot < 480 & (pad_hi==bomb_two_lo|pad_lo==bomb_two_hi)) begin //Bottom of the screen
			
			bmb_2<=1;
			//rst_hbb<=0;
			
			//yesbomb<=1;
			//nobomb<=0;
			//rst_hbnb<=1;
			bomb_two_top <= 108;
			bomb_two_bot <= 139;
			rst_2<=0;
			x<=1;
			score<=score+1;
			rst_pad<=1;
			/*if(bomb_two_bot>275)
			begin
			rst_hbnb<=1;
		
			yesbomb<=1;
			nobomb<=0;
			rst_hbb<=0;
			end*/
			if(bomb_two_bot==141 | bomb_two_bot==174 |bomb_two_bot==207 | bomb_two_bot==240 | bomb_two_bot==273 |bomb_two_bot==307 |bomb_two_bot==341|bomb_two_bot==375|bomb_two_bot==409|bomb_two_bot==443|bomb_two_bot==477)
			begin
			rst_2<=1;
			
			end
			else if(bomb_two_bot>475)begin
			bmb_2<=0;
		
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
			rst_2<=1;
			
		end
		end
		
		
		if ((bomb_three_bot < 400) & (pad_hi>=bomb_three_lo & pad_hi<=bomb_three_lo+85)) begin //Bottom of the screen
			//rst_hbb<=0;
			
			//yesbomb<=1;
			//nobomb<=0;
			//rst_hbnb<=1;
			x<=1;
			bmb_3<=1;
			bomb_three_top <= bomb_three_top + 3'b001;
			bomb_three_bot <= bomb_three_bot + 3'b001;
			rst_3<=0;
	/*if(bomb_three_top<=150)
			begin
			rst_hbnb<=0;
		
			yesbomb<=0;
			nobomb<=1;
			rst_hbb<=1;
			end	*/
	if(bomb_bot==140 | bomb_bot==172 |bomb_bot==205 | bomb_bot==237 | bomb_bot==270 |bomb_bot==302 |bomb_bot==334|bomb_bot==366)
			begin
			rst_3<=1;
			
			end
			else if ((bomb_three_bot == 399) & (pad_hi>=bomb_three_lo & pad_hi<=bomb_three_lo+85))
			begin
			bmb_3<=0;
			score <= score + 1;
			end
		end 
		else if (bomb_three_bot < 480 & (pad_hi<bomb_three_lo|pad_lo>bomb_three_hi)) begin //Bottom of the screen
			
			bmb_3<=1;
			//rst_hbb<=0;
			//
			//yesbomb<=1;
			//nobomb<=0;
			//rst_hbnb<=1;
			bomb_three_top <= bomb_three_top + 3'b001;
			bomb_three_bot <= bomb_three_bot + 3'b001;
			rst_3<=0;
			x<=1;

			if(bomb_bot==140 | bomb_bot==172 |bomb_bot==205 | bomb_bot==237 | bomb_bot==270 |bomb_bot==302 |bomb_bot==334|bomb_bot==366|bomb_bot==400|bomb_bot==432|bomb_bot==464)
			begin
			rst_3<=1;
			
			end
			else if(bomb_three_bot>475)begin
			bmb_3<=0;

			x<=1;
		
			end
		end 
		
		
		
		else if (bomb_three_bot > 400 & bomb_three_bot < 480 & (pad_hi==bomb_three_lo|pad_lo==bomb_three_hi)) begin //Bottom of the screen
			
			bmb_3<=1;
			//rst_hbb<=0;
			
			//yesbomb<=1;
			//nobomb<=0;
			//rst_hbnb<=1;
			bomb_three_top <= 108;
			bomb_three_bot <= 139;
			rst_3<=0;
			x<=1;
			score<=score+1;
			rst_pad<=1;
			/*if(bomb_three_bot>250)
			begin
			rst_hbnb<=1;
			
			yesbomb<=1;
			nobomb<=0;
			rst_hbb<=0;
			end*/
			if(bomb_three_bot==141 | bomb_three_bot==174 |bomb_three_bot==207 | bomb_three_bot==240 | bomb_three_bot==273 |bomb_three_bot==307 |bomb_three_bot==341|bomb_three_bot==375|bomb_three_bot==409|bomb_three_bot==443|bomb_three_bot==477)
			begin
			rst_3<=1;
			
			end
			else if(bomb_three_bot>475)begin
			bmb_3<=0;

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
			rst_3<=1;
			
		end
		end
		
		
		
		if ((bomb_four_bot < 400) & (pad_hi>=bomb_four_lo & pad_hi<=bomb_four_lo+85)) begin //Bottom of the screen
			
			//rst_hbb<=0;
			
			//yesbomb<=1;
			//nobomb<=0;
			//rst_hbnb<=1;
			x<=1;
			bmb_4<=1;
			bomb_four_top <= bomb_four_top + 3'b001;
			bomb_four_bot <= bomb_four_bot + 3'b001;
			rst_4<=0;
				
			if(bomb_bot==140 | bomb_bot==172 |bomb_bot==205 | bomb_bot==237 | bomb_bot==270 |bomb_bot==302 |bomb_bot==334|bomb_bot==366)
			begin
			rst_4<=1;
			
			end
		else if ((bomb_four_bot == 399) & (pad_hi>=bomb_four_lo & pad_hi<=bomb_four_lo+85))
			begin
			
			bmb_4<=0;
			score <= score + 1;
			end
		end 
		else if (bomb_four_bot < 480 & (pad_hi<bomb_four_lo|pad_lo>bomb_four_hi)) begin //Bottom of the screen
			//rst_hbb<=0;
			
			//yesbomb<=1;
			//nobomb<=0;
			//rst_hbnb<=1;
			x<=1;
			bmb_4<=1;
			bomb_four_top <= bomb_four_top + 3'b001;
			bomb_four_bot <= bomb_four_bot + 3'b001;
			rst_4<=0;
			x<=1;
			
			if(bomb_four_bot==141 | bomb_four_bot==174 |bomb_four_bot==207 | bomb_four_bot==240 | bomb_four_bot==273 |bomb_four_bot==307 |bomb_four_bot==341|bomb_four_bot==375|bomb_four_bot==409|bomb_four_bot==443|bomb_four_bot==477)
			begin
			rst_4<=1;
			
			end
			else if(bomb_four_bot>475)begin
			bmb_4<=0;

			x<=1;
		
			end
		end 
		
		
		
		
		else if (bomb_four_bot > 400 & bomb_four_bot < 480 & (pad_hi==bomb_four_lo|pad_lo==bomb_four_hi)) begin //Bottom of the screen
			//rst_hbb<=0;
			
			//yesbomb<=1;
			//nobomb<=0;
			//rst_hbnb<=1;
			x<=1;
			bmb_4<=1;
			bomb_four_top <= 108;
			bomb_four_bot <= 139;
			rst_4<=0;
			x<=1;
			score<=score+1;
			rst_pad<=1;
			/*if(bomb_four_bot>225)
			begin
			rst_hbnb<=1;
			
			yesbomb<=1;
			nobomb<=0;
			rst_hbb<=0;
			end*/
			if(bomb_bot==140 | bomb_bot==172 |bomb_bot==205 | bomb_bot==237 | bomb_bot==270 |bomb_bot==302 |bomb_bot==334|bomb_bot==366|bomb_bot==400|bomb_bot==432|bomb_bot==464)
			begin
			rst_4<=1;
			
			end
			else if(bomb_four_bot>475)begin
			bmb_4<=0;

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
			rst_4<=1;
			
		end
		end
		
		
		if ((bomb_five_bot < 400) & (pad_hi>=bomb_five_lo & pad_hi<=bomb_five_lo+85)) begin //Bottom of the screen
			//rst_hbb<=0;
			
			//yesbomb<=1;
			//nobomb<=0;
			//rst_hbnb<=1;
			x<=1;
			bmb_5<=1;
			bomb_five_top <= bomb_five_top + 3'b001;
			bomb_five_bot <= bomb_five_bot + 3'b001;
		rst_5<=0;
		
		
		if(bomb_bot==140 | bomb_bot==172 |bomb_bot==205 | bomb_bot==237 | bomb_bot==270 |bomb_bot==302 |bomb_bot==334|bomb_bot==366)
			begin
			rst_5<=1;
			//rst_hbb<=1;
			//rst_hbnb<=1;
			end
			else if ((bomb_five_bot == 399) & (pad_hi>=bomb_five_lo & pad_hi<=bomb_five_lo+85))
			begin
			bmb_5<=0;
			score <= score + 1;
			end
		end 
		if (bomb_five_bot < 480 & (pad_hi<bomb_five_lo|pad_lo>bomb_five_hi)) begin //Bottom of the screen
			//rst_hbb<=0;
			
			//yesbomb<=1;
			//nobomb<=0;
			//rst_hbnb<=1;
			bmb_5<=1;
			bomb_five_top <= bomb_five_top + 3'b001;
			bomb_five_bot <= bomb_five_bot + 3'b001;
			rst_5<=0;
			x<=1;
				
			if(bomb_five_bot==141 | bomb_five_bot==174 |bomb_five_bot==207 | bomb_five_bot==240 | bomb_five_bot==273 |bomb_five_bot==307 |bomb_five_bot==341|bomb_five_bot==375|bomb_five_bot==409|bomb_five_bot==443|bomb_five_bot==477)
			begin
			rst_5<=1;
			
			end
			else if(bomb_five_bot>475)begin
			bmb_5<=0;

			x<=1;
		
			end
		end 
		
		
		
		else if (bomb_five_bot > 400 & bomb_five_bot < 480 & (pad_hi==bomb_five_lo|pad_lo==bomb_five_hi)) begin //Bottom of the screen
			//rst_hbb<=0;
			
			//yesbomb<=1;
			//nobomb<=0;
			//rst_hbnb<=1;
			bmb_5<=1;
			bomb_five_top <= 108;
			bomb_five_bot <= 139;
		score<=score+1;
		rst_pad<=1;
			rst_5<=0;
			x<=1;
		/*	if(bomb_five_bot>200)
			begin
			rst_hbnb<=1;
			
			yesbomb<=1;
			nobomb<=0;
			rst_hbb<=0;
			end*/
			if(bomb_bot==140 | bomb_bot==172 |bomb_bot==205 | bomb_bot==237 | bomb_bot==270 |bomb_bot==302 |bomb_bot==334|bomb_bot==366|bomb_bot==400|bomb_bot==432|bomb_bot==464)
			begin
			rst_5<=1;
			
			end
			else if(bomb_five_bot>475)begin
			bmb_5<=0;

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
			rst_5<=1;
			
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
		
		
		//Happy Bomber without bomb
		if (hbnb_hi < 640 & bomb_hi < 640 & move) begin
		
			hbnb_lo <= hbnb_lo + 3'b001;
			hbnb_hi <= hbnb_hi + 3'b001;
			b2_lo<=b2_lo+3'b001;
			b2_hi<=b2_hi+3'b001;
			//exp_lo <= exp_lo + 3'b001;
			//exp_hi <= exp_hi + 3'b001;
			
		end 
		else if(hbnb_lo>1 & bomb_lo > 1 & back)
		begin
		hbnb_lo <= hbnb_lo - 3'b001;
			hbnb_hi <= hbnb_hi - 3'b001;
			b2_lo<=b2_lo-3'b001;
			b2_hi<=b2_hi-3'b001;
			//exp_lo <= exp_lo - 3'b001;
			//exp_hi <= exp_hi - 3'b001;
		end
		else begin
			hbnb_lo <= hbnb_lo;//0;
			hbnb_hi <= hbnb_hi;//63;
			
		end
		
		
		
		///////////////////////////////////////
		
		///////////////////////////////////////
		
		/*//Sad Bomber with bomb
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
		
		if(bomb_bot==139 | bomb_bot==171 | bomb_bot==203 | bomb_bot==235 | bomb_bot==267 | bomb_bot==299 | bomb_bot==331 | bomb_bot==363 | bomb_bot==394 | bomb_bot==426 | bomb_bot==458)
	begin
flag<=1;
end	
	end // end game_state if statement
	
	2,3: begin
	end
	endcase
			
	end  //end of the clk_slow always block
	
	//This always block controls actually drawing the blocks on the screen
	///////////////////////////
	/*always @(posedge clk_bomb)
		begin
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
		
		
		//Happy Bomber without bomb
		if (hbnb_hi < 640 & bomb_hi < 640 & move) begin
		
			hbnb_lo <= hbnb_lo + 3'b001;
			hbnb_hi <= hbnb_hi + 3'b001;
			b2_lo<=b2_lo+3'b001;
			b2_hi<=b2_hi+3'b001;
			//exp_lo <= exp_lo + 3'b001;
			//exp_hi <= exp_hi + 3'b001;
			
		end 
		else if(hbnb_lo>1 & bomb_lo > 1 & back)
		begin
		hbnb_lo <= hbnb_lo - 3'b001;
			hbnb_hi <= hbnb_hi - 3'b001;
			b2_lo<=b2_lo-3'b001;
			b2_hi<=b2_hi-3'b001;
			//exp_lo <= exp_lo - 3'b001;
			//exp_hi <= exp_hi - 3'b001;
		end
		else begin
			hbnb_lo <= hbnb_lo;//0;
			hbnb_hi <= hbnb_hi;//63;
			
		end
		end*/
	//////////////////////////
	always @ (posedge clk_25MHz)
	begin	//Maybe better a Multiplexer for this, maybe not...
	//I think the blocks are experiencing a shift because of how it is getting the data. It shifts over time I guess. But not sure either.
	
   case (game_state)
	0: begin		
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
		
		if (title_bomb) begin //draw title screen bomb
				R <= bomb_dout[7:5];
				G <= bomb_dout[4:2];
				B <= bomb_dout[1:0];
				if (bomb_address == 703) 
					begin
					bomb_address <= 0;
					end
				else bomb_address <= bomb_address + 1;
		
		end
		
		if (str) begin 
				R <= R_val & { 3{tile[tile_ctr]} };
				G <= 0; //toggle[5:3] & { 3{tile[tile_ctr]} };
				B <= 0; //{ toggle[6], 1'b0 } & { 2{tile[tile_ctr]} };
				
				
				col_ctr <= col_ctr + 1;
				if (x_ctr == (font_scale-1)) begin
					tile_ctr <= tile_ctr - 6'b1;
					x_ctr <= 0;
					if (col_ctr == (font_scale*8-1)) begin		  //at end of each row
						col_ctr <= 0;
						
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
							5: char_sel <= 36; //!
							6: char_sel <= 39; //blank
							7: char_sel	<= 20; //K
						endcase
						

					end
				end else begin		// do this pixel over again
					x_ctr <= x_ctr + 1;
				end
		end
		
		//start message
		else if (start_blk) begin
			R <= 3'b111 & { 3{tile[start_tile_ctr]} };
			G <= 3'b111 & { 3{tile[start_tile_ctr]} };
			B <= 3'b111 & { 2{tile[start_tile_ctr]} };
			
			start_col_ctr<= start_col_ctr+ 1;
			start_tile_ctr <= start_tile_ctr - 1;
			if (start_col_ctr== 7) begin		  //at end of each row
				start_col_ctr<= 0;
				if (start_char_ctr == 18) begin
					start_char_ctr <= 0;		
				end else begin
					start_char_ctr <= start_char_ctr + 1;
					start_tile_ctr <= start_tile_ctr + 7;  // same row, different char
				end
					
				char_sel <= start_msg[start_char_ctr];
				
			end
		end
		
		
		
		
		//name credits
		else if (name_blk) begin
			R <= 3'b111 & { 3{tile[cred_tile_ctr]} };
			G <= 3'b111 & { 3{tile[cred_tile_ctr]} };
			B <= 3'b111 & { 2{tile[cred_tile_ctr]} };


			cred_col_ctr<= cred_col_ctr+ 1;
			cred_tile_ctr <= cred_tile_ctr - 1;
			if (cred_col_ctr== 7) begin		  //at end of each row
				cred_col_ctr<= 0;
				if (cred_char_ctr == 15) begin
					cred_char_ctr <= 0;
					if (cred_row_ctr == 15) begin
						cred_row_ctr <= 0;
						line_ctr <= line_ctr + 1; //this overflows, on purpose	
					end else begin
						cred_row_ctr <= cred_row_ctr + 1;
					end			
				end else begin
					cred_char_ctr <= cred_char_ctr + 1;
					cred_tile_ctr <= cred_tile_ctr + 7;  // same row, different char
				end
					
				char_sel <= names[cred_char_ctr + line_ctr*NAME_WIDTH];
				
			end
		end
		
	end //end case 0 for game state

		
		
		////////////////////end title rom////////////////////////////
	
	 1,2: begin

		if(rst==1)
		begin
			hbb_address <= 0; //Avoids shifting after a reset.     
			hbnb_address <= 0;
			sb_address <= 0;
			//explosion_address <= 0;
			pad_address <= 0;
		end	
		else if (rst_1==1)
		begin
		bomb_address<=0;
		end
		else if (rst_2==1)
		begin
		bomb_two_address<=0;
		end
		else if (rst_3==1)
		begin
		bomb_three_address<=0;
		end
		else if (rst_4==1)
		begin
		bomb_four_address<=0;
		end
		else if (rst_5==1)
		begin
		bomb_five_address<=0;
		end
		else if(rst_hbb==1)
		begin
		hbb_address<=0;
		end
		else if(rst_hbnb==1)
		begin
		hbnb_address<=0;
		end
		//else if(rst_pad==1)
		//begin
	  // pad_address<=0;
		//end
		
		if (bomb_block & bmb==1) begin //bomb block detection
				R <= bomb_dout[7:5];
				G <= bomb_dout[4:2];
				B <= bomb_dout[1:0];
				if (bomb_address == 703 & flag==1) // (b1<=139 | b1<=171 | b1<=203 | b1<=235 | b1<=267 | b1<=299 | b1<=331 | b1<=363 | b1<=394 | b1<=426 | b1<=458) 
					begin
					bomb_address <= 0;
					end
				else bomb_address <= bomb_address + 1;
		end		
		else if (bomb_two_block & bmb_2==1) begin //bomb block detection
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
		end		

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
		
			/*else if (hbnb_block & nobomb) begin //hbnb block detection
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


					col_ctr <= col_ctr + 1;
					tile_ctr <= tile_ctr - 1;
					if (col_ctr == 7) begin		  //at end of each row
						col_ctr <= 0;
						if (char_ctr == 9) begin
							char_ctr <= 0;	
						end else begin
							char_ctr <= char_ctr + 1;
							tile_ctr <= tile_ctr + 7;  // same row, different char
						end
							
						//notice that this should be offset so it draws the right character next time	
						case (char_ctr)
							0: char_sel <= 12; //load C
							1: char_sel <= 24; //load O
							2: char_sel <= 27; //load R
							3: char_sel <= 14; //load E
							4: char_sel <= 38; //load :
							5: char_sel <= dec_score[3]; //load MSB
							6: char_sel <= dec_score[2]; 
							7: char_sel <= dec_score[1]; 
							8: char_sel <= dec_score[0]; 
							9: char_sel <= 28; //load S 
						endcase		
					end


					// this is the same code as above, but scalable - leave for now
					// in case we want to make the score bigger at some point
					/*col_ctr <= col_ctr + 1;
					if (x_ctr == 1) begin
						tile_ctr <= tile_ctr - 1;
						x_ctr <= 0;
						if (col_ctr == 15) begin		  //at end of each row
							col_ctr <= 0;
							
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
	end // end case 1 for game state
	3: begin
	end
	endcase // end game_state case statement
	end
endmodule
