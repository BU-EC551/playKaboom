`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////////
// EC 551 FINAL PROJECT
// Team Kaboom
// Top Module			 								
////////////////////////////////////////////////////////////////////////////////////////

module vga_display_bomb(
	input rst,	// global reset
	input clk,  // 100 MHz clock
	
	//Player Controls
	input move_bomber,
	input back_bomber,	
	input pad_r,
	input pad_l,	
	input title_toggle,
	input single_player,
	input pause,
	input resume,
	//Bluetoooth signals
	input pad_left,
	input pad_right,
	
	//Sound_FX signals
	output reg catch_FX,
	output reg throw_FX,
	output reg explosion_FX,
	output reg getpad_FX,
	output reg gameover_FX,
	
	// VGA signals
	output reg [2:0] R, G,
	output reg [1:0] B,
	output HS,
	output VS,
	
	//Seven Segment Display
	output [6:0] seven,
	output [3:0] svn_digit,
	
	//Temporary Test I/O - REMOVE IN FINAL SUBMISSION
	output test_led0,
	output test_led1,
	output reg test_led2,
	output reg test_led3
	);
	
	////////////////////////////////////////////////////////////////////////////////////////
	//////////  	BEGIN  DECLARATIONS	 	//////////
	////////////////////////////////////////////////////////////////////////////////////////
	
	reg [2:0] game_state = 0;
	
	//VGA controls
	wire [10:0] hcount, vcount;	// coordinates for the current pixel
	wire blank;	// signal to indicate the current coordinate is blank
	
	
	//BOMBER MOVEMENT 
	reg move = 0;	 
	reg back = 1;
	reg [12:0] move_ctr;
	wire [1:0] random;
	reg rand_rst;
	
	
	assign test_led0 = move;	//FOR TESTING - DELETE LATER?
	assign test_led1 = back;
	
	
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
	
	wire [7:0] bomb_six_dout;
	reg [9:0] bomb_six_address = 0;
	
	wire [7:0] bomb_seven_dout;
	reg [9:0] bomb_seven_address = 0;
	
	wire [7:0] bomb_eight_dout;
	reg [9:0] bomb_eight_address = 0;
	
	wire [7:0] hbb_dout;
	reg [12:0] hbb_address = 0;
	
	wire [7:0] hbnb_dout;
	reg [12:0] hbnb_address = 0;

	wire [7:0] pad_dout;
	reg [9:0] pad_address = 0;
	
	wire [7:0] explosion_dout;
	reg [15:0] explosion_address = 0;
	
	reg [10:0] sb_hi, sb_lo, pad_lo, pad_hi,b2_lo,b2_hi,bomb_two_top, bomb_two_bot,bomb_two_lo, bomb_two_hi, bomb_three_lo, bomb_three_hi, bomb_four_lo, bomb_four_hi, bomb_five_lo, bomb_five_hi,bomb_six_lo, bomb_six_hi,bomb_seven_lo, bomb_seven_hi,bomb_eight_lo, bomb_eight_hi; //variable block positions
   reg  [10:0] bomb_top, bomb_bot, bomb_lo, bomb_hi, exp_lo, exp_hi, hbb_hi, hbb_lo, hbnb_hi, hbnb_lo,bomb_three_top, bomb_three_bot,bomb_four_top, bomb_four_bot,bomb_five_top, bomb_five_bot,bomb_six_top, bomb_six_bot,bomb_seven_top, bomb_seven_bot,bomb_eight_top, bomb_eight_bot;
	localparam START_BOMB_TOP = 200;
	localparam START_BOMB_BOT = 231;
	localparam START_BOMB_LO  = 310; 
	localparam START_BOMB_HI  = 331;


	wire start_bomb_block;
	wire bomb_block;
   wire bomb_two_block;
   wire bomb_three_block;
   wire bomb_four_block;
   wire bomb_five_block;
	wire bomb_six_block;
	wire bomb_seven_block;
	wire bomb_eight_block;	// Falling bomb
	wire hbb_block;	// Happy Bomber Bomb (hbb)
	wire hbnb_block;	// Happy Bomber No Bomb (hbnb)

	wire pad_block;	// Horizontally moving pads
	wire pad1_block;
	wire pad2_block;
	wire explosion_block; //Explosion
	wire background_top;	//Background Top
	wire background_bottom;	//Background Bottom
	wire scoreboard; //Score tab
	reg start_bmb;
	reg bmb;
	reg bmb_2;
	reg bmb_3;
	reg bmb_4;
	reg bmb_5;
	reg bmb_6;
	reg bmb_7;
	reg bmb_8;
	reg flag;
	reg flag_1;
	reg flag_2;
	reg x;
	reg rst_1;
	reg rst_2;
	reg rst_3;
	reg rst_4;
	reg rst_5;
	reg rst_6;
	reg rst_7;
	reg rst_8;
	reg exp1;
	reg exp2;
	reg exp3;
	reg exp4;
	reg exp5;
	reg exp6;
	reg exp7;
	reg exp8;
	reg rst_exp;
	reg yesbomb;
	reg nobomb;
	reg rst_hbb;
	reg rst_hbnb;
	reg hbnb_top;
	reg hbnb_bot;
	reg rst_score;
	
	
	reg rst_pad;
	
	//various things for the scoreboard
	reg [9:0] score;	  // actual score
	wire [3:0] dec_score [0:3];  // score as four BCD decimal digits
	wire [9:0] score_char;	  // the VGA position blocks
	

	///////////////TITLESCREEN DECLARATIONS//////
	reg load_titlescreen;
	reg [24:0] color_timer;
	reg [2:0] color_val;
	
	wire [127:0] tile;
	reg [6:0] tile_ctr = 127;
	
	reg [1:0] x_ctr;
	reg [4:0] col_ctr;
	reg [1:0] y_ctr;
	
	
	reg [3:0] char_ctr;
	reg [5:0] char_sel;
	
	wire [7:0] kaboom;
	reg won;
	
	reg [3:0] font_scale = 1;
	parameter tile_wd = 8;
	parameter tile_ht = 16; 
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
	6'h22, //Y
	6'h19 //P 
	};
	//END TITLE SCREEN VARIABLES
	
/*******************************************/
/*****	END DECLARATIONS	*****/
/*******************************************/	
	
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
	
////////////////////////////////////////////////////////////////////////////////////////
//////////  	BEGIN  SPRITE INSTANTIATIONS	//////////
////////////////////////////////////////////////////////////////////////////////////////

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

bomb6 bsix(
  .clka(clk),
  .wea(1'b0),
  .addra(bomb_six_address),
  .dina(8'h00),
  .douta(bomb_six_dout)
);

bseven bomb7(
  .clka(clk),
  .wea(1'b0),
  .addra(bomb_seven_address),
  .dina(8'h00),
  .douta(bomb_seven_dout)
);

beight bomb8(
  .clka(clk),
  .wea(1'b0),
  .addra(bomb_eight_address),
  .dina(8'h00),
  .douta(bomb_eight_dout)
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
	
	//Pads
	pad pad(
  .clka(clk),
  .wea(1'b0),
  .addra(pad_address),
  .dina(8'h00),
  .douta(pad_dout)
	);

	//Explosion Everything is merged together in 1 .coe file
	explosion1 explosion(
  .clka(clk),
  .wea(1'b0),
  .addra(explosion_address),
  .dina(8'h00),
  .douta(explosion_dout)
	);	
	
/*******************************************/
/*****	END SPRITE INSTANTIATONS	*****/
/*******************************************/	



////////////////////////////////////////////////////////////////////////////////////////
//////////	BEGIN INSTANTIATION OF NON-SPRITE MODULES	//////////
////////////////////////////////////////////////////////////////////////////////////////

	//convert binary score to decimal digits
	score_2_dec DEC_SCORE(
	.bin_in(score),
	.dec_1(dec_score[0]),
	.dec_10(dec_score[1]),
	.dec_100(dec_score[2]),
	.dec_1000(dec_score[3])
	);
	
	// Seven Segment Display
	seven_segment SVN_SCORE(
	.clk(clk),
	.data_in(score),	// currently using this with move_ctr for debugging - change back later
	.seven_out(seven),
	.digit(svn_digit)
	);
	
	// font ROM
	font_rom FONT(
	.clk(clk),
	.sel(char_sel),
	      .char_out(tile)
	);

	//Generate a random 2-bit number for bomber movement
	rand_gen RAND_NUM(
	.clk(clk),
	.rst(rand_rst),
	.random(random)
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
/*******************************************/
/*****	END NON-SPRITE INSTANTIATONS	*****/
/*******************************************/	
	
	
////////////////////////////////////////////////////////////////////////////////////////
//////////  	BEGIN  VGA BLOCK DEFINITIONS	//////////
////////////////////////////////////////////////////////////////////////////////////////
	
	///////////////////GAMEMPLAY BLOCKS/////////////////////////////
	assign bomb_block = ~blank & (hcount >= bomb_lo & hcount <= bomb_hi & vcount >= bomb_top & vcount <= bomb_bot); //22x32
	assign bomb_two_block = ~blank & (hcount >= bomb_two_lo & hcount <= bomb_two_hi & vcount >= bomb_two_top & vcount <= bomb_two_bot); //22x32
	assign bomb_three_block = ~blank & (hcount >= bomb_three_lo & hcount <= bomb_three_hi & vcount >= bomb_three_top & vcount <= bomb_three_bot); //22x32
	assign bomb_four_block = ~blank & (hcount >= bomb_four_lo & hcount <= bomb_four_hi & vcount >= bomb_four_top & vcount <= bomb_four_bot); //22x32
	assign bomb_five_lock = ~blank & (hcount >= bomb_five_lo & hcount <= bomb_five_hi & vcount >= bomb_five_top & vcount <= bomb_five_bot); //22x32
	assign bomb_six_block = ~blank & (hcount >= bomb_six_lo & hcount <= bomb_six_hi & vcount >= bomb_six_top & vcount <= bomb_six_bot); //22x32
	assign bomb_seven_block = ~blank & (hcount >= bomb_seven_lo & hcount <= bomb_seven_hi & vcount >= bomb_seven_top & vcount <= bomb_seven_bot); //22x32
	assign bomb_eight_lock = ~blank & (hcount >= bomb_eight_lo & hcount <= bomb_eight_hi & vcount >= bomb_eight_top & vcount <= bomb_eight_bot); //22x32

	assign hbb_block = ~blank & (hcount >= hbb_lo & hcount <= hbb_hi & vcount >= 20 & vcount <= 107); //64x88
	assign hbnb_block = ~blank & (hcount >= hbnb_lo & hcount <= hbnb_hi & vcount >= 20 & vcount <= 107); //64x88
	assign pad_block = ~blank & (hcount >= pad_lo & hcount <= pad_hi & vcount >= 410 & vcount <= 425); //84x16
	assign pad1_block = ~blank & (hcount >= pad_lo & hcount <= pad_hi & vcount >= 435 & vcount <= 450); //84x16
	assign pad2_block = ~blank & (hcount >= pad_lo & hcount <= pad_hi & vcount >= 460 & vcount <= 475); //64x16
	assign explosion_block = ~blank & (hcount >= exp_lo & hcount <= exp_hi & vcount >= 419 & vcount <= 482); //64x64
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
	
	//////////TITLE SCREEN BLOCKS////////////////
	assign kaboom[0] = ~blank & (hcount >= (TITLE_CTR_H - 4*font_scale*tile_wd)& hcount <= (TITLE_CTR_H - 3*font_scale*tile_wd - 1) 	& vcount >= (TILE_CTR_V - (tile_ht/2)*font_scale)	& vcount <= (TILE_CTR_V + (tile_ht/2)*font_scale - 1)); 
	assign kaboom[1] = ~blank & (hcount >= (TITLE_CTR_H - 3*font_scale*tile_wd)& hcount <= (TITLE_CTR_H - 2*font_scale*tile_wd - 1) 	& vcount >= (TILE_CTR_V - (tile_ht/2)*font_scale)	& vcount <= (TILE_CTR_V + (tile_ht/2)*font_scale - 1)); 
	assign kaboom[2] = ~blank & (hcount >= (TITLE_CTR_H - 2*font_scale*tile_wd)& hcount <= (TITLE_CTR_H - font_scale*tile_wd - 1) 	& vcount >= (TILE_CTR_V - (tile_ht/2)*font_scale)	& vcount <= (TILE_CTR_V + (tile_ht/2)*font_scale - 1)); 
	assign kaboom[3] = ~blank & (hcount >= (TITLE_CTR_H - font_scale*tile_wd) 	& hcount <= (TITLE_CTR_H - 1)	& vcount >= (TILE_CTR_V - (tile_ht/2)*font_scale)	& vcount <= (TILE_CTR_V + (tile_ht/2)*font_scale - 1)); 
	assign kaboom[4] = ~blank & (hcount >=  TITLE_CTR_H 	& hcount <= (TITLE_CTR_H + font_scale*tile_wd - 1) 	& vcount >= (TILE_CTR_V - (tile_ht/2)*font_scale)	& vcount <= (TILE_CTR_V + (tile_ht/2)*font_scale - 1)); 
   assign kaboom[5] = ~blank & (hcount >= (TITLE_CTR_H + font_scale*tile_wd) 	& hcount <= (TITLE_CTR_H + 2*font_scale*tile_wd - 1) 	& vcount >= (TILE_CTR_V - (tile_ht/2)*font_scale)	& vcount <= (TILE_CTR_V + (tile_ht/2)*font_scale - 1)); 
	assign kaboom[6] = ~blank & (hcount >= (TITLE_CTR_H + 2*font_scale*tile_wd)& hcount <= (TITLE_CTR_H + 3*font_scale*tile_wd - 1) 	& vcount >= (TILE_CTR_V - (tile_ht/2)*font_scale)	& vcount <= (TILE_CTR_V + (tile_ht/2)*font_scale - 1)); 
	assign kaboom[7] = ~blank & (hcount >= (TITLE_CTR_H + 3*font_scale*tile_wd)& hcount <= (TITLE_CTR_H + 4*font_scale*tile_wd - 1) 	& vcount >= (TILE_CTR_V - (tile_ht/2)*font_scale)	& vcount <= (TILE_CTR_V + (tile_ht/2)*font_scale - 1)); 
	
	assign start_bomb_block = ~blank & (hcount >= START_BOMB_LO & hcount <= START_BOMB_HI & vcount >= START_BOMB_TOP & vcount <= START_BOMB_BOT); //22x32


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
/*******************************************/
/*****	END VGA BLOCK DEFINITIONS	*****/
/*******************************************/	
	
////////////////////////////////////////////////////////////////////////////////////////
//////////  	BEGIN  REGISTER INITIALIZATION	//////////
////////////////////////////////////////////////////////////////////////////////////////
	initial begin
	gameover_FX <= 1'b1; catch_FX <= 1'b1; throw_FX <= 1'b1; explosion_FX <= 1'b1; getpad_FX <= 1'b1;
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
	bomb_six_top = 108;
	
	bomb_six_bot = 139;
	bomb_six_lo = 21;
	bomb_six_hi = 42;
	bomb_seven_top = 108;
	bomb_seven_bot = 139;
	bomb_seven_lo = 21;
	bomb_seven_hi = 42;
	bomb_eight_top = 108;
	bomb_eight_bot = 139;
	bomb_eight_lo = 21;
	bomb_eight_hi = 42;

	b2_lo = 21;
	b2_hi = 42;
       	
	hbb_lo = 1;
	hbb_hi = 64;	
	hbnb_lo = 1;
	hbnb_hi = 64;	
	pad_lo = 1;
	pad_hi = 64;
	exp_lo = 1;
	exp_hi = 64;
	bmb=1;
	flag=0;
	flag_1=0;
	flag_2=0;
	won=0;
	bmb_2=0;
	bmb_3=0;
	bmb_4=0;
	bmb_5=0;
	bmb_6=0;
	bmb_7=0;
	bmb_8=0;
	x=1;
	rst_1=0;
	rst_2=0;
	rst_3=0;
	rst_4=0;
	rst_5=0;
	rst_6=0;
	rst_7=0;
	rst_8=0;
	exp1=0;
	exp2=0;
	exp3=0;
	exp4=0;
	exp5=0;
	exp6=0;
	exp7=0;
	exp8=0;
	rst_exp=0;
	rst_hbb=1;
	rst_hbnb=0;
	rst_pad=0;
	yesbomb=0;
	nobomb=1;
	rst_score=1;
	
	

	/////////////////////////////////////////////
	///////  TITLE SCREEN INITIALIZATIONS	 /////
	/////////////////////////////////////////////

	//Rama
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
	
	//Sai
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
	
	//JC 
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
	
	//Laura
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
/*******************************************/
/*****	END REGISTER INITIALIZATIONS	*****/
/*******************************************/	
	
////////////////////////////////////////////////////////////////////////////////////////
//////////	BEGIN GAME STATE CONTROL ALWAYS BLOCK (@clk)	//////////
////////////////////////////////////////////////////////////////////////////////////////
	always @ (posedge clk) begin
	
	rand_rst <= 0;  // when this is set to 1 it should get turned off at the next rising clock
	
	/* GAME STATES
	 * 	0 - Title Screen
	 * 	1 - Two Player Mode
	 * 	2 - Game Over
	 * 	3 - You Won
	 * 	4 - Single Player Mode
	 *	5 - Reset State
	 *	6 - Pause for Two Player
	 *	7 - Pause for Single Player
	 */
	 
	case (game_state)
	0: begin
	if (title_toggle) begin
	game_state <= 1;
	end else if (single_player) begin
	rand_rst <= 1;
	game_state <= 4;
	end
	end
	
	1: begin
	if (flag_2) game_state<=2;//GAME OVER	flag
	if (won) game_state<=3; //YOU WON flag
	if (pause) game_state <= 6;
	end
	
	2,3: if (resume) game_state <= 5;	//go to reset state
	
	4: begin
	if (flag_2) game_state<=2;	
	if (won==1) game_state<=3;
	if (pause) game_state <= 7;
	end
	
	5: if (load_titlescreen) game_state <= 0;
	
	6: if (resume) game_state <= 1;
	
	7: if (resume) game_state <= 4;
	
	endcase

	end
	
/**********************************************************/
/*****	END GAME STATE CONTROL ALWAYS BLOCK (@clk)	*****/
/**********************************************************/	
	
////////////////////////////////////////////////////////////////////////////////////////
//////////	BEGIN MOVEMENT CONTROL ALWAYS BLOCK (@clk_slow)	//////////
////////////////////////////////////////////////////////////////////////////////////////

reg last_gameover;
reg last_catch;
reg last_throw;
reg last_explosion;
reg last_getpad;
reg catch_flag;


always @ (posedge clk_slow) begin
throw_FX <= 1'b1;

last_gameover <= flag_2;
gameover_FX <= ~(flag_2 & !last_gameover); //NEEDS THE PAUSE AFTER EXPLOSION TO WORK

last_explosion <= (exp1==1|exp2==1|exp3==1|exp4==1|exp5==1|exp6==1|exp7==1|exp8==1);
explosion_FX <= ~((exp1==1|exp2==1|exp3==1|exp4==1|exp5==1|exp6==1|exp7==1|exp8==1) & !last_explosion);

last_throw <= (bomb_top==109|bomb_two_top==109|bomb_three_top==109|bomb_four_top==109|bomb_five_top==109|bomb_six_top==109|bomb_seven_top==109|bomb_eight_top==109);
throw_FX <= ~((bomb_top==109|bomb_two_top==109|bomb_three_top==109|bomb_four_top==109|bomb_five_top==109|bomb_six_top==109|bomb_seven_top==109|bomb_eight_top==109) & !last_throw);

last_getpad <= won; //NEEDS THE PAUSE AFTER LAST CATCH TO WORK
getpad_FX <= ~(won & !last_getpad);

last_catch <= catch_flag;
catch_FX <= ~(catch_flag & !last_catch);
if(catch_flag==1) catch_flag<=0;



	case (game_state)

	///////////////////////////
	///	 TITLE SCREEN	///
	///////////////////////////
	0: begin
	load_titlescreen <= 0;
	end
	
	/////////////////////////////////////////////
	///	 GAME PLAY - 1 or 2 PLAYER MODE	///
	/////////////////////////////////////////////
	1,4: begin
	
	//bomber movement
	if (game_state == 1) begin	// 2 Player
	move <= move_bomber;
	back <= back_bomber;
	end else if (game_state == 4) begin
	test_led2 <= 1; 	// LED FOR DEUBGGING - DELETE LATER
	if (move_ctr < 8'hFF) begin
	test_led3 <= 1;	// LED FOR DEUBGGING - DELETE LATER
	move_ctr <= move_ctr + random;
	end else begin
	move_ctr <= 0;
	move <= ~move;
	back <= ~back;  // do it this way to make sure they are never the same
	end
	end
	
	
	if (pad_r & pad_hi < 640) begin
	rst_pad<=0;
	pad_lo <= pad_lo + 3'b010;
	pad_hi <= pad_hi + 3'b010;
	end 
	
	/*else if (pad_right & pad_hi < 635) begin
	rst_pad<=0;
	pad_lo <= pad_lo + 3'b101;
	pad_hi <= pad_hi + 3'b101;
	end 	*/	
	
	else if(pad_l & pad_lo>1) begin
	rst_pad<=0;
	pad_lo <= pad_lo - 3'b010;
	pad_hi <= pad_hi - 3'b010;
	end
	
	/*else if(pad_left & pad_lo>1) begin
	rst_pad<=0;
	pad_lo <= pad_lo - 3'b101;
	pad_hi <= pad_hi - 3'b101;
	end*/

	if((exp_lo<=(pad_hi+1))|(exp_hi>=(pad_lo-1)))
begin
rst_pad<=1;
end
	else begin
	rst_pad<=0;
	pad_lo <=pad_lo; //0;
	pad_hi <=pad_hi; //63;
	end
	
	

	if ((bomb_bot < 400) & (pad_hi>=bomb_lo&pad_hi<=bomb_lo+85)) begin //Bottom of the screen
	exp1<=0;
	rst_score<=0;
	//rst_hbnb<=1;
	//yesbomb<=1;
	//nobomb<=0;
	rst_exp<=1;
	rst_pad<=0;
	x<=1;
	bmb<=1;
	bomb_top <= bomb_top + 3'b001;
	bomb_bot <= bomb_bot + 3'b001;
	//bomb_lo<=b2_lo;
	//bomb_hi<=b2_hi;
	rst_1<=0;
	
	if(bomb_bot==141 | bomb_bot==174 |bomb_bot==207 | bomb_bot==240 | bomb_bot==273 |bomb_bot==307 |bomb_bot==341|bomb_bot==375)
	begin
	rst_1<=1;
	end
	
	 if ((bomb_bot >= 399 & bomb_bot <= 475) & ((pad_hi>=bomb_lo & pad_hi<=bomb_lo+85)|(pad_hi==bomb_lo)|(pad_lo==bomb_hi)))
	begin
	bmb<=0;
	
	
	score <= score + 1;
	catch_flag <= 1;
	end
	end
	//////////////////////////////////////////	
	/////////////////////////////////////////////////////////////////////
	else if (bomb_bot < 480 & (pad_hi<bomb_lo|pad_lo>bomb_hi)) begin //Bottom of the screen
	//yesbomb<=1;
	//nobomb<=0;
	//rst_hbnb<=1;
	rst_score<=0;	
	rst_pad<=0;
	exp1<=0;
	rst_exp<=1;
	bmb<=1;
	bomb_top <= bomb_top + 3'b001;
	bomb_bot <= bomb_bot + 3'b001;
	//bomb_lo<=b2_lo;
	//bomb_hi<=b2_hi;
	rst_1<=0;
	if(bomb_bot==141 | bomb_bot==174 |bomb_bot==207 | bomb_bot==240 | bomb_bot==273 |bomb_bot==307 |bomb_bot==341|bomb_bot==375|bomb_bot==409|bomb_bot==443|bomb_bot==477)
	begin
	rst_1<=1;
	end
	else if(bomb_bot>460)begin
	rst_pad<=1;
	bmb<=0;
	x<=1;	
	rst_exp<=0;
	
exp1<=1;	
exp_lo<=bomb_lo-20;
exp_hi<=bomb_hi+22;
if((exp_lo<=(pad_hi+1))|(exp_hi>=(pad_lo-1)))
begin
rst_pad<=1;

end
end
	
	
	end 
	//////////////////////////////////////////////////////////////////
	else if (bomb_bot > 400 & bomb_bot < 480 & (pad_hi==bomb_lo|pad_lo==bomb_hi)) begin //Bottom of the screen
	rst_score<=0;
	rst_pad<=0;
	rst_exp<=1;
	exp1<=0;
	bmb<=1;
	bomb_top <= 108;
	bomb_bot <= 139;
	//bomb_lo<=b2_lo;
	//bomb_hi<=b2_hi;
	rst_1<=0;
	score<=score+1;
	catch_flag <= 1;
	//yesbomb<=0;
	//nobomb<=1;
	//rst_hbb<=1;
	if(bomb_bot==141 | bomb_bot==174 |bomb_bot==207 | bomb_bot==240 | bomb_bot==273 |bomb_bot==307 |bomb_bot==341|bomb_bot==375|bomb_bot==409|bomb_bot==443|bomb_bot==477)
	begin
	rst_1<=1;
	//rst_hbb<=1;
	//rst_hbnb<=1;
	end
	else if(bomb_bot>460)begin
	rst_pad<=1;
	bmb<=0;
rst_exp<=0;
exp1<=1;
exp_lo<=bomb_lo-20;
exp_hi<=bomb_lo+22;
if((exp_lo<=(pad_hi+1))|(exp_hi>=(pad_lo-1)))
begin
rst_pad<=1;
end
	x<=1;
	end
	end 
	
	////////////////////////////////////////////////////////////////
	/*else if(bomb_bot>475)begin
	bmb<=0;
	flag<=1;
	end*/
	//////////////////////////////////////////////////////////////
	else 
	begin
	//bmb<=1;
	//if (bmb) score <= score + 1;
	//catch_flag <= 1;
	//flag<=1;
	//	rst_hbb<=1;
	//yesbomb<=0;
	//nobomb<=1;
	bomb_top <= 108;
	bomb_bot <= 139;
	//bomb_lo<=b2_lo;
	//bomb_hi<=b2_hi;
	rst_1<=1;
	end
	
	
	if ((bomb_two_bot < 400) & (pad_hi>=bomb_two_lo & pad_hi<=bomb_two_lo+85)) begin //Bottom of the screen
	rst_score<=0;
	rst_pad<=0;
	rst_exp<=1;
	exp2<=0;
	x<=1;
	bmb_2<=1;
	bomb_two_top <= bomb_two_top + 3'b001;
	bomb_two_bot <= bomb_two_bot + 3'b001;
	
	rst_2<=0;
	
	if(bomb_two_bot==141 | bomb_two_bot==174 |bomb_two_bot==207 | bomb_two_bot==240 | bomb_two_bot==273 |bomb_two_bot==307 |bomb_two_bot==341|bomb_two_bot==375)
	begin
	rst_2<=1;
	end

	 if ((bomb_two_bot >= 399 & bomb_two_bot <= 475) & ((pad_hi>=bomb_two_lo & pad_hi<=bomb_two_lo+85)|(pad_hi==bomb_two_lo)|(pad_lo==bomb_two_hi)))
	begin
	bmb_2<=0;
	
	score <= score + 1;
	catch_flag <= 1;
	end
	end 
	else if (bomb_two_bot < 480 & (pad_hi<bomb_two_lo|pad_lo>bomb_two_hi)) begin //Bottom of the screen
	rst_score<=0;
	rst_pad<=0;
	rst_exp<=1;
	exp2<=0;
	bmb_2<=1;
	bomb_two_top <= bomb_two_top + 3'b001;
	bomb_two_bot <= bomb_two_bot + 3'b001;
	//bomb_two_lo<=b2_lo;
	//bomb_two_hi<=b2_hi;
	rst_2<=0;
	x<=1;
	
	
	if(bomb_two_bot==141 | bomb_two_bot==174 |bomb_two_bot==207 | bomb_two_bot==240 | bomb_two_bot==273 |bomb_two_bot==307 |bomb_two_bot==341|bomb_two_bot==375|bomb_two_bot==409|bomb_two_bot==443|bomb_two_bot==477)
	begin
	rst_2<=1;
	end
	 if(bomb_two_bot>460)begin
	rst_pad<=1;
	bmb_2<=0;
	x<=1;	
	rst_exp<=0;
exp2<=1;	
exp_lo<=bomb_two_lo-20;
exp_hi<=bomb_two_hi+22;
if((exp_lo<=(pad_hi+1))|(exp_hi>=(pad_lo-1)))
begin
rst_pad<=1;
end
end
	end 
	
	else if (bomb_two_bot > 400 & bomb_two_bot < 480 & (pad_hi==bomb_two_lo|pad_lo==bomb_two_hi)) begin //Bottom of the screen
	rst_score<=0;
	rst_pad<=0;
	rst_exp<=1;
	exp2<=0;
	bmb_2<=1;
	bomb_two_top <= 108;
	bomb_two_bot <= 139;
	//bomb_two_lo<=b2_lo;
	//bomb_two_hi<=b2_hi;
	rst_2<=0;
	x<=1;
	score<=score+1;
	catch_flag <= 1;
	if(bomb_two_bot==141 | bomb_two_bot==174 |bomb_two_bot==207 | bomb_two_bot==240 | bomb_two_bot==273 |bomb_two_bot==307 |bomb_two_bot==341|bomb_two_bot==375|bomb_two_bot==409|bomb_two_bot==443|bomb_two_bot==477)
	begin
	rst_2<=1;
	end
	 if(bomb_two_bot>460)begin
	rst_pad<=1;
	bmb_2<=0;
	x<=1;	
	rst_exp<=0;
exp2<=1;	
exp_lo<=bomb_two_lo-20;
exp_hi<=bomb_two_hi+22;
if((exp_lo<=(pad_hi+1))|(exp_hi>=(pad_lo-1)))
begin
rst_pad<=1;
end
end
	end 
	
	
	
	
	
	else begin
	//bmb<=1;
	//if (bmb) score <= score + 1;
	if(bomb_top==150)
	begin
	bomb_two_top <= 108;
	bomb_two_bot <= 139;
	bomb_two_lo<=b2_lo;
	bomb_two_hi<=b2_hi;
	rst_2<=1;
	end
	end
	/////////////////////////////////////////////////////////////////////
	if(score>=11)
	begin
	
	if ((bomb_three_bot < 400) & (pad_hi>=bomb_three_lo & pad_hi<=bomb_three_lo+85)) begin //Bottom of the screen
	rst_score<=0;
	rst_pad<=0;
	rst_exp<=1;
	exp3<=0;
	x<=1;
	bmb_3<=1;
	bomb_three_top <= bomb_three_top + 3'b001;
	bomb_three_bot <= bomb_three_bot + 3'b001;
	
	rst_3<=0;
	
	if(bomb_three_bot==141 | bomb_three_bot==174 |bomb_three_bot==207 | bomb_three_bot==240 | bomb_three_bot==273 |bomb_three_bot==307 |bomb_three_bot==341|bomb_three_bot==375)
	begin
	rst_3<=1;
	end
	 if ((bomb_three_bot >= 399 & bomb_three_bot <= 475) & ((pad_hi>=bomb_three_lo & pad_hi<=bomb_three_lo+85)|(pad_hi==bomb_three_lo)|(pad_lo==bomb_three_hi)))
	begin
	bmb_3<=0;
	
	score <= score + 1;
	catch_flag <= 1;
	end
	end 
	else if (bomb_three_bot < 480 & (pad_hi<bomb_three_lo|pad_lo>bomb_three_hi)) begin //Bottom of the screen
	rst_score<=0;
	rst_pad<=0;
	rst_exp<=1;
	exp3<=0;
	bmb_3<=1;
	bomb_three_top <= bomb_three_top + 3'b001;
	bomb_three_bot <= bomb_three_bot + 3'b001;
	//bomb_three_lo<=b2_lo;
	//bomb_three_hi<=b2_hi;
	rst_3<=0;
	x<=1;
	if(bomb_three_bot==141 | bomb_three_bot==174 |bomb_three_bot==207 | bomb_three_bot==240 | bomb_three_bot==273 |bomb_three_bot==307 |bomb_three_bot==341|bomb_three_bot==375|bomb_three_bot==409|bomb_three_bot==443|bomb_three_bot==477)
	begin
	rst_3<=1;
	end
	else if(bomb_three_bot>460)begin
	rst_pad<=1;
	bmb_3<=0;
	x<=1;	
	rst_exp<=0;
exp3<=1;	
exp_lo<=bomb_three_lo-20;
exp_hi<=bomb_three_hi+22;
if((exp_lo<=(pad_hi+1))|(exp_hi>=(pad_lo-1)))
begin
rst_pad<=1;
end
end
	end 
	
	else if (bomb_three_bot > 400 & bomb_three_bot < 480 & (pad_hi==bomb_three_lo|pad_lo==bomb_three_hi)) begin //Bottom of the screen
	rst_score<=0;
	rst_pad<=0;
	rst_exp<=1;
	exp3<=0;
	bmb_3<=1;
	bomb_three_top <= 108;
	bomb_three_bot <= 139;
	//bomb_three_lo<=b2_lo;
	//bomb_three_hi<=b2_hi;
	rst_3<=0;
	x<=1;
	score<=score+1;
	catch_flag <= 1;
	if(bomb_three_bot==141 | bomb_three_bot==174 |bomb_three_bot==207 | bomb_three_bot==240 | bomb_three_bot==273 |bomb_three_bot==307 |bomb_three_bot==341|bomb_three_bot==375|bomb_three_bot==409|bomb_three_bot==443|bomb_three_bot==477)
	begin
	rst_3<=1;
	end
	else if(bomb_three_bot>460)begin
	rst_pad<=1;
	bmb_3<=0;
	x<=1;	
	rst_exp<=0;
exp3<=1;	
exp_lo<=bomb_three_lo-20;
exp_hi<=bomb_three_hi+22;
if((exp_lo<=(pad_hi+1))|(exp_hi>=(pad_lo-1)))
begin
rst_pad<=1;
end
end
	end
	
	else begin
	if(bomb_two_top==150)
	begin
	bomb_three_top <= 108;
	bomb_three_bot <= 139;
	bomb_three_lo<=b2_lo;
	bomb_three_hi<=b2_hi;
	rst_3<=1;
	end
	end

	if ((bomb_four_bot < 400) & (pad_hi>=bomb_four_lo & pad_hi<=bomb_four_lo+85)) begin //Bottom of the screen
	rst_score<=0;
	rst_pad<=0;
	rst_exp<=1;
	exp4<=0;
	x<=1;
	bmb_4<=1;
	bomb_four_top <= bomb_four_top + 3'b001;
	bomb_four_bot <= bomb_four_bot + 3'b001;
	
	rst_4<=0;
	if(bomb_four_bot==141 | bomb_four_bot==174 |bomb_four_bot==207 | bomb_four_bot==240 | bomb_four_bot==273 |bomb_four_bot==307 |bomb_four_bot==341|bomb_four_bot==375)
	begin
	rst_4<=1;
	end
	 if ((bomb_four_bot >= 399 & bomb_four_bot <= 475) & ((pad_hi>=bomb_four_lo & pad_hi<=bomb_four_lo+85)|(pad_hi==bomb_four_lo)|(pad_lo==bomb_four_hi)))
	begin
	bmb_4<=0;
	
	score <= score + 1;
	catch_flag <= 1;
	end
	end 
	else if (bomb_four_bot < 480 & (pad_hi<bomb_four_lo|pad_lo>bomb_four_hi)) begin //Bottom of the screen
	rst_score<=0;
	rst_pad<=0;
	rst_exp<=1;
	exp4<=0;
	bmb_4<=1;
	bomb_four_top <= bomb_four_top + 3'b001;
	bomb_four_bot <= bomb_four_bot + 3'b001;
	//bomb_four_lo<=b2_lo;
	//bomb_four_hi<=b2_hi;
	rst_4<=0;
	x<=1;
	if(bomb_four_bot==141 | bomb_four_bot==174 |bomb_four_bot==207 | bomb_four_bot==240 | bomb_four_bot==273 |bomb_four_bot==307 |bomb_four_bot==341|bomb_four_bot==375|bomb_four_bot==409|bomb_four_bot==443|bomb_four_bot==477)
	begin
	rst_4<=1;
	end
	else if(bomb_four_bot>460)begin
	rst_pad<=1;
	bmb_4<=0;
	x<=1;	
	rst_exp<=0;
exp4<=1;	
exp_lo<=bomb_four_lo-20;
exp_hi<=bomb_four_hi+22;
if((exp_lo<=(pad_hi+1))|(exp_hi>=(pad_lo-1)))
begin
rst_pad<=1;
end
end
	end 	
	
	else if (bomb_four_bot > 400 & bomb_four_bot < 480 & (pad_hi==bomb_four_lo|pad_lo==bomb_four_hi)) begin //Bottom of the screen
	rst_score<=0;
	rst_pad<=0;
	rst_exp<=1;
	exp4<=0;
	bmb_4<=1;
	bomb_four_top <= 108;
	bomb_four_bot <= 139;
	//bomb_four_lo<=b2_lo;
	//bomb_four_hi<=b2_hi;
	rst_4<=0;
	x<=1;
	score<=score+1;
	catch_flag <= 1;
	if(bomb_four_bot==141 | bomb_four_bot==174 |bomb_four_bot==207 | bomb_four_bot==240 | bomb_four_bot==273 |bomb_four_bot==307 |bomb_four_bot==341|bomb_four_bot==375|bomb_four_bot==409|bomb_four_bot==443|bomb_four_bot==477)
	begin
	rst_4<=1;
	end
	else if(bomb_four_bot>460)begin
	rst_pad<=1;
	bmb_4<=0;
	x<=1;	
	rst_exp<=0;
exp4<=1;	
exp_lo<=bomb_four_lo-20;
exp_hi<=bomb_four_hi+22;
if((exp_lo<=(pad_hi+1))|(exp_hi>=(pad_lo-1)))
begin
rst_pad<=1;
end
end
	end 

	else begin
	//bmb<=1;
	//if (bmb) score <= score + 1;
	if(bomb_three_top==150)
	begin
	bomb_four_top <= 108;
	bomb_four_bot <= 139;
	bomb_four_lo<=b2_lo;
	bomb_four_hi<=b2_hi;
	rst_4<=1;
	end
	end
	///////////////////////////////////////////////////////////////////////////////////////////
	if(score>=25)
	begin
	
	if ((bomb_five_bot < 400) & (pad_hi>=bomb_five_lo & pad_hi<=bomb_five_lo+85)) begin //Bottom of the screen
	rst_score<=0;
	rst_pad<=0;
	rst_exp<=1;
	exp5<=0;
	x<=1;
	bmb_5<=1;
	bomb_five_top <= bomb_five_top + 3'b001;
	bomb_five_bot <= bomb_five_bot + 3'b001;
	
	rst_5<=0;
	if(bomb_five_bot==141 | bomb_five_bot==174 |bomb_five_bot==207 | bomb_five_bot==240 | bomb_five_bot==273 |bomb_five_bot==307 |bomb_five_bot==341|bomb_five_bot==375)
	begin
	rst_5<=1;
	end
	 if ((bomb_five_bot >= 399 & bomb_five_bot <= 475) & ((pad_hi>=bomb_five_lo & pad_hi<=bomb_five_lo+85)|(pad_hi==bomb_five_lo)|(pad_lo==bomb_five_hi)))
	begin
	bmb_5<=0;
	
	score <= score + 1;
	catch_flag <= 1;
	end
	end 
	else if (bomb_five_bot < 480 & (pad_hi<bomb_five_lo|pad_lo>bomb_five_hi)) begin //Bottom of the screen
	rst_score<=0;
	rst_pad<=0;
	rst_exp<=1;
	exp5<=0;
	bmb_5<=1;
	bomb_five_top <= bomb_five_top + 3'b001;
	bomb_five_bot <= bomb_five_bot + 3'b001;
	//bomb_five_lo<=b2_lo;
	//bomb_five_hi<=b2_hi;
	rst_5<=0;
	x<=1;
	if(bomb_five_bot==141 | bomb_five_bot==174 |bomb_five_bot==207 | bomb_five_bot==240 | bomb_five_bot==273 |bomb_five_bot==307 |bomb_five_bot==341|bomb_five_bot==375|bomb_five_bot==409|bomb_five_bot==443|bomb_five_bot==477)
	begin
	rst_5<=1;
	end
	else if(bomb_five_bot>460)begin
	rst_pad<=1;
	bmb_5<=0;
	x<=1;	
	rst_exp<=0;
exp5<=1;	
exp_lo<=bomb_five_lo-20;
exp_hi<=bomb_five_hi+22;
if((exp_lo<=(pad_hi+1))|(exp_hi>=(pad_lo-1)))
begin
rst_pad<=1;
end
end
	end 
	
	
	
	else if (bomb_five_bot > 400 & bomb_five_bot < 480 & (pad_hi==bomb_five_lo|pad_lo==bomb_five_hi)) begin //Bottom of the screen
	rst_score<=0;
	rst_pad<=0;
	rst_exp<=1;
	exp5<=0;
	bmb_5<=1;
	bomb_five_top <= 108;
	bomb_five_bot <= 139;
	//bomb_five_lo<=b2_lo;
	//bomb_five_hi<=b2_hi;
	rst_5<=0;
	x<=1;
	score<=score+1;
	catch_flag <= 1;
	if(bomb_five_bot==141 | bomb_five_bot==174 |bomb_five_bot==207 | bomb_five_bot==240 | bomb_five_bot==273 |bomb_five_bot==307 |bomb_five_bot==341|bomb_five_bot==375|bomb_five_bot==409|bomb_five_bot==443|bomb_five_bot==477)
	begin
	rst_5<=1;
	end
	else if(bomb_five_bot>460)begin
	rst_pad<=1;
	bmb_5<=0;
	x<=1;	
	rst_exp<=0;
exp5<=1;	
exp_lo<=bomb_five_lo-20;
exp_hi<=bomb_five_hi+22;
if((exp_lo<=(pad_hi+1))|(exp_hi>=(pad_lo-1)))
begin
rst_pad<=1;
end
end
	end 
	
	else begin
	//bmb<=1;
	//if (bmb) score <= score + 1;
	if(bomb_four_top==150)
	begin
	bomb_five_top <= 108;
	bomb_five_bot <= 139;
	bomb_five_lo<=b2_lo;
	bomb_five_hi<=b2_hi;
	rst_5<=1;
	end
	end
	
	if ((bomb_six_bot < 400) & (pad_hi>=bomb_six_lo & pad_hi<=bomb_six_lo+85)) begin //Bottom of the screen
	rst_score<=0;
	rst_pad<=0;
	rst_exp<=1;
	exp6<=0;
	x<=1;
	bmb_6<=1;
	bomb_six_top <= bomb_six_top + 3'b001;
	bomb_six_bot <= bomb_six_bot + 3'b001;
	
	rst_6<=0;
	
	if(bomb_six_bot==141 | bomb_six_bot==174 |bomb_six_bot==207 | bomb_six_bot==240 | bomb_six_bot==273 |bomb_six_bot==307 |bomb_three_bot==341|bomb_six_bot==375)
	begin
	rst_6<=1;
	end
	 if ((bomb_six_bot >= 399 & bomb_six_bot <= 475) & ((pad_hi>=bomb_six_lo & pad_hi<=bomb_six_lo+85)|(pad_hi==bomb_six_lo)|(pad_lo==bomb_six_hi)))
	begin
	bmb_6<=0;
	
	score <= score + 1;
	catch_flag <= 1;
	end
	end 
	else if (bomb_six_bot < 480 & (pad_hi<bomb_six_lo|pad_lo>bomb_six_hi)) begin //Bottom of the screen
	rst_score<=0;
	rst_pad<=0;
	rst_exp<=1;
	exp6<=0;
	bmb_6<=1;
	bomb_six_top <= bomb_six_top + 3'b001;
	bomb_six_bot <= bomb_six_bot + 3'b001;
	//bomb_six_lo<=b2_lo;
	//bomb_six_hi<=b2_hi;
	rst_6<=0;
	x<=1;
	if(bomb_six_bot==141 | bomb_six_bot==174 |bomb_six_bot==207 | bomb_six_bot==240 | bomb_six_bot==273 |bomb_six_bot==307 |bomb_six_bot==341|bomb_six_bot==375|bomb_six_bot==409|bomb_six_bot==443|bomb_six_bot==477)
	begin
	rst_6<=1;
	end
	else if(bomb_six_bot>460)begin
	rst_pad<=1;
	bmb_6<=0;
	x<=1;	
	rst_exp<=0;
exp6<=1;	
exp_lo<=bomb_six_lo-20;
exp_hi<=bomb_six_hi+22;
if((exp_lo<=(pad_hi+1))|(exp_hi>=(pad_lo-1)))
begin
rst_pad<=1;
end
end
	end 
	
	else if (bomb_six_bot > 400 & bomb_six_bot < 480 & (pad_hi==bomb_six_lo|pad_lo==bomb_six_hi)) begin //Bottom of the screen
	rst_score<=0;
	rst_pad<=0;
	rst_exp<=1;
	exp6<=0;
	bmb_6<=1;
	bomb_six_top <= 108;
	bomb_six_bot <= 139;
	//bomb_six_lo<=b2_lo;
	//bomb_six_hi<=b2_hi;
	rst_6<=0;
	x<=1;
	score<=score+1;
	catch_flag <= 1;
	if(bomb_six_bot==141 | bomb_six_bot==174 |bomb_six_bot==207 | bomb_six_bot==240 | bomb_six_bot==273 |bomb_six_bot==307 |bomb_six_bot==341|bomb_six_bot==375|bomb_six_bot==409|bomb_six_bot==443|bomb_six_bot==477)
	begin
	rst_6<=1;
	end
	else if(bomb_six_bot>460)begin
	rst_pad<=1;
	bmb_6<=0;
	x<=1;	
	rst_exp<=0;
exp6<=1;	
exp_lo<=bomb_six_lo-20;
exp_hi<=bomb_six_hi+22;
if((exp_lo<=(pad_hi+1))|(exp_hi>=(pad_lo-1)))
begin
rst_pad<=1;
end
end
	end
	
	else begin
	if(bomb_five_top==150)
	begin
	bomb_six_top <= 108;
	bomb_six_bot <= 139;
	bomb_six_lo<=b2_lo;
	bomb_six_hi<=b2_hi;
	end
	end
	//////////////////////////////////////////////////////////////////////////////
	if(score>=41)
	begin
	
	if ((bomb_seven_bot < 400) & (pad_hi>=bomb_seven_lo & pad_hi<=bomb_seven_lo+85)) begin //Bottom of the screen
	rst_score<=0;
	rst_pad<=0;
	rst_exp<=1;
	exp7<=0;
	x<=1;
	bmb_7<=1;
	bomb_seven_top <= bomb_seven_top + 3'b001;
	bomb_seven_bot <= bomb_seven_bot + 3'b001;
	
	rst_7<=0;
	
	if(bomb_seven_bot==141 | bomb_seven_bot==174 |bomb_seven_bot==207 | bomb_seven_bot==240 | bomb_seven_bot==273 |bomb_seven_bot==307 |bomb_seven_bot==341|bomb_seven_bot==375)
	begin
	rst_7<=1;
	end
	 if ((bomb_seven_bot >= 399 & bomb_seven_bot <= 475) & ((pad_hi>=bomb_seven_lo & pad_hi<=bomb_seven_lo+85)|(pad_hi==bomb_seven_lo)|(pad_lo==bomb_seven_hi)))
	begin
	bmb_7<=0;
	
	
	score <= score + 1;
	catch_flag <= 1;
	end
	end 
	else if (bomb_seven_bot < 480 & (pad_hi<bomb_seven_lo|pad_lo>bomb_seven_hi)) begin //Bottom of the screen
	rst_score<=0;
	rst_pad<=0;
	rst_exp<=1;
	exp7<=0;
	bmb_7<=1;
	bomb_seven_top <= bomb_seven_top + 3'b001;
	bomb_seven_bot <= bomb_seven_bot + 3'b001;
	//bomb_seven_lo<=b2_lo;
	//bomb_seven_hi<=b2_hi;
	rst_7<=0;
	x<=1;
	if(bomb_seven_bot==141 | bomb_seven_bot==174 |bomb_seven_bot==207 | bomb_seven_bot==240 | bomb_seven_bot==273 |bomb_seven_bot==307 |bomb_seven_bot==341|bomb_seven_bot==375|bomb_seven_bot==409|bomb_seven_bot==443|bomb_seven_bot==477)
	begin
	rst_7<=1;
	end
	else if(bomb_seven_bot>460)begin
	rst_pad<=1;
	bmb_7<=0;
	x<=1;	
	rst_exp<=0;
exp7<=1;	
exp_lo<=bomb_seven_lo-20;
exp_hi<=bomb_seven_hi+22;
if((exp_lo<=(pad_hi+1))|(exp_hi>=(pad_lo-1)))
begin
rst_pad<=1;
end
end
	end 
	
	else if (bomb_seven_bot > 400 & bomb_seven_bot < 480 & (pad_hi==bomb_seven_lo|pad_lo==bomb_seven_hi)) begin //Bottom of the screen
	rst_score<=0;
	rst_pad<=0;
	rst_exp<=1;
	exp7<=0;
	bmb_7<=1;
	bomb_seven_top <= 108;
	bomb_seven_bot <= 139;
	//bomb_seven_lo<=b2_lo;
	//bomb_seven_hi<=b2_hi;
	rst_7<=0;
	x<=1;
	score<=score+1;
	catch_flag <= 1;
	if(bomb_seven_bot==141 | bomb_seven_bot==174 |bomb_seven_bot==207 | bomb_seven_bot==240 | bomb_seven_bot==273 |bomb_seven_bot==
	307 |bomb_seven_bot==341|bomb_seven_bot==375|bomb_seven_bot==409|bomb_seven_bot==443|bomb_seven_bot==477)
	begin
	rst_7<=1;
	end
	else if(bomb_seven_bot>460)begin
	rst_pad<=1;
	bmb_7<=0;
	x<=1;	
	rst_exp<=0;
exp7<=1;	
exp_lo<=bomb_seven_lo-20;
exp_hi<=bomb_seven_hi+22;
if((exp_lo<=(pad_hi+1))|(exp_hi>=(pad_lo-1)))
begin
rst_pad<=1;
end
end
	end
	
	else begin
	if(bomb_six_top==150)
	begin
	bomb_seven_top <= 108;
	bomb_seven_bot <= 139;
	bomb_seven_lo<=b2_lo;
	bomb_seven_hi<=b2_hi;
	end
	end
	
	if ((bomb_eight_bot < 400) & (pad_hi>=bomb_eight_lo & pad_hi<=bomb_eight_lo+85)) begin //Bottom of the screen
	rst_score<=0;
	rst_pad<=0;
	rst_exp<=1;
	exp8<=0;
	x<=1;
	bmb_8<=1;
	bomb_eight_top <= bomb_eight_top + 3'b001;
	bomb_eight_bot <= bomb_eight_bot + 3'b001;
	
	rst_8<=0;
	
	if(bomb_eight_bot==141 | bomb_eight_bot==174 |bomb_eight_bot==207 | bomb_eight_bot==240 | bomb_eight_bot==273 |bomb_eight_bot==307 |bomb_eight_bot==341|bomb_eight_bot==375)
	begin
	rst_8<=1;
	end
	 if ((bomb_eight_bot >= 399 & bomb_eight_bot <= 475) & ((pad_hi>=bomb_eight_lo & pad_hi<=bomb_eight_lo+85)|(pad_hi==bomb_eight_lo)|(pad_lo==bomb_eight_hi)))
	begin
	bmb_8<=0;
	
	
	score <= score + 1;
	catch_flag <= 1;
	end
	end 
	else if (bomb_eight_bot < 480 & (pad_hi<bomb_eight_lo|pad_lo>bomb_eight_hi)) begin //Bottom of the screen
	rst_score<=0;
	rst_pad<=0;
	rst_exp<=1;
	exp8<=0;
	bmb_8<=1;
	bomb_eight_top <= bomb_eight_top + 3'b001;
	bomb_eight_bot <= bomb_eight_bot + 3'b001;
	//bomb_eight_lo<=b2_lo;
	//bomb_eight_hi<=b2_hi;
	rst_8<=0;
	x<=1;
	if(bomb_eight_bot==141 | bomb_eight_bot==174 |bomb_eight_bot==207 | bomb_eight_bot==240 | bomb_eight_bot==273 |bomb_eight_bot==307 |bomb_eight_bot==341|bomb_eight_bot==375|bomb_eight_bot==409|bomb_eight_bot==443|bomb_eight_bot==477)
	begin
	rst_8<=1;
	end
	else if(bomb_eight_bot>460)begin
	rst_pad<=1;
	bmb_8<=0;
	x<=1;	
	rst_exp<=0;
exp8<=1;	
exp_lo<=bomb_eight_lo-20;
exp_hi<=bomb_eight_hi+22;
if((exp_lo<=(pad_hi+1))|(exp_hi>=(pad_lo-1)))
begin
rst_pad<=1;
end
end
	end 
	
	else if (bomb_eight_bot > 400 & bomb_eight_bot < 480 & (pad_hi==bomb_eight_lo|pad_lo==bomb_eight_hi)) begin //Bottom of the screen
	rst_score<=0;
	rst_pad<=0;
	rst_exp<=1;
	exp8<=0;
	bmb_8<=1;
	bomb_eight_top <= 108;
	bomb_eight_bot <= 139;
	//bomb_eight_lo<=b2_lo;
	//bomb_eight_hi<=b2_hi;
	rst_8<=0;
	x<=1;
	score<=score+1;
	catch_flag <= 1;
	if(bomb_eight_bot==141 | bomb_eight_bot==174 |bomb_eight_bot==207 | bomb_eight_bot==240 | bomb_eight_bot==273 |bomb_eight_bot==307 |bomb_eight_bot==341|bomb_eight_bot==375|bomb_eight_bot==409|bomb_eight_bot==443|bomb_eight_bot==477)
	begin
	rst_8<=1;
	end
	else if(bomb_eight_bot>460)begin
	rst_pad<=1;
	bmb_8<=0;
	x<=1;	
	rst_exp<=0;
exp8<=1;	
exp_lo<=bomb_eight_lo-20;
exp_hi<=bomb_eight_hi+22;
if((exp_lo<=(pad_hi+1))|(exp_hi>=(pad_lo-1)))
begin
rst_pad<=1;
end
end
	end
	
	else begin
	if(bomb_seven_top==150)
	begin
	bomb_eight_top <= 108;
	bomb_eight_bot <= 139;
	bomb_eight_lo<=b2_lo;
	bomb_eight_hi<=b2_hi;
	end
	end
	end
	end
	end
	//Happy Bomber with bomb
	if ((hbb_hi < 640) & (bomb_hi < 640) & move) 
	begin
	
	hbb_lo <= hbb_lo + 3'b001;
	hbb_hi <= hbb_hi + 3'b001;
	b2_lo<=b2_lo + 3'b001;
	b2_hi<=b2_hi + 3'b001;
	
end	
	else if(hbb_lo>1 & bomb_lo > 1 & back )
	begin
	hbb_lo <= hbb_lo - 3'b001;
	hbb_hi <= hbb_hi - 3'b001;
	b2_lo<=b2_lo - 3'b001;
	b2_hi<=b2_hi - 3'b001;
	end
	else begin
	hbb_lo <= hbb_lo; //0;
	hbb_hi <= hbb_hi; //63;
	end
	
	//Happy Bomber without bomb
	if ((hbnb_hi < 640) & (bomb_hi < 640) & (move)) begin
	
	hbnb_lo <= hbnb_lo + 3'b001;
	hbnb_hi <= hbnb_hi + 3'b001;
	b2_lo<=b2_lo + 3'b001;
	b2_hi<=b2_hi + 3'b001;
	
	
	end 
	else if(hbnb_lo>1 & bomb_lo > 1 & back )
	begin
	hbnb_lo <= hbnb_lo - 3'b001;
	hbnb_hi <= hbnb_hi - 3'b001;
	b2_lo<=b2_lo - 3'b001;
	b2_hi<=b2_hi - 3'b001;
	
	end
	else begin
	hbnb_lo <= hbnb_lo;//0;
	hbnb_hi <= hbnb_hi;//63;
	
	end
	
	if(bomb_top<=148)// | bomb_two_top<=120 | bomb_three_top<=120| bomb_four_top<=120| bomb_five_top<=120|bomb_six_top<=120|bomb_seven_top<=120|bomb_eight_top<=120)
	begin
	
	if(bomb_top==108| bomb_top==121| bomb_top==131| bomb_top==141)// | bomb_two_top==109 | bomb_three_top==109| bomb_four_top==109| bomb_five_top==109|bomb_six_top==109|bomb_seven_top==109|bomb_eight_top==109)
	begin
	rst_hbnb<=1;
	rst_hbb<=1;
	
	end
	
	nobomb<=0;
	yesbomb<=1;
	rst_hbnb<=1;
	rst_hbb<=0;

	end
	else 
	begin
	
	if(bomb_top==149 | bomb_top==200|bomb_top==250|bomb_top==300|bomb_top==350|bomb_top==401 |bomb_bot==460)// | bomb_two_top==122 | bomb_three_top==122| bomb_four_top==122| bomb_five_top==122|bomb_six_top==122|bomb_seven_top==122|bomb_eight_top==122)
	begin
	rst_hbb<=1;
	rst_hbnb<=1;
	
	end	

	yesbomb<=0;
	nobomb<=1;
	rst_hbnb<=0;
	rst_hbb<=1;

	end
	
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
	
	if(bomb_bot==478 | bomb_two_bot==478 | bomb_three_bot==478 | bomb_four_bot==478 | bomb_five_bot==478)
	begin
flag<=1;
end
if((bomb_bot==478 | bomb_two_bot==478 | bomb_three_bot==478 | bomb_four_bot==478 | bomb_five_bot==478) & flag==1)
	begin
flag_1<=1;
end	
if((bomb_bot==478 | bomb_two_bot==478 | bomb_three_bot==478 | bomb_four_bot==478 | bomb_five_bot==478) & flag_1==1)
	begin
flag_2<=1;
score<=score;
end

if(score==100 & flag==1 & flag_1==1)
begin
flag_1<=0;
end
else if(score==120 & flag==1)
begin
flag<=0;
end
if(score>=150)
begin
won<=1;
score<=score;
end	
	
	//pad block
	/*	if (pad_r & pad_hi < 640) begin
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
	
	end*/
	
	
	end // end game_state=1 (gameplay)/////////////////////////////////////////////////////////////////
	
	//////////////////////
	///	 GAME OVER	 ///
	//////////////////////
	2: begin
	hbb_lo <= 127;
	hbb_hi <= 190;
	hbnb_lo <= 452; 
	hbnb_hi <= 515;
	end


	//////////////////////
	///	 YOU WON	 ///
	//////////////////////
	3: begin
	////////////////////////////////
	//	//
	//  GAME STATE 3 PLACEHOLDER  //
	//	//
	////////////////////////////////
	end
	
	
	//////////////////////
	///	RESET STATE	 ///
	//////////////////////	
	/*5: begin
	load_titlescreen <= 1;
	score <= 0;
	
	bomb_top <= 108;
	bomb_bot <= 139;
	bomb_lo <= 21;
	bomb_hi <= 42;
	bomb_two_top <= 108;
	bomb_two_bot <= 139;
	bomb_two_lo <= 21;
	bomb_two_hi <= 42;
	bomb_three_top <= 108;
	bomb_three_bot <= 139;
	bomb_three_lo <= 21;
	bomb_three_hi <= 42;
	bomb_four_top <= 108;
	bomb_four_bot <= 139;
	bomb_four_lo <= 21;
	bomb_four_hi <= 42;
	bomb_five_top <= 108;
	bomb_five_bot <= 139;
	bomb_five_lo <= 21;
	bomb_five_hi <= 42;
	bomb_six_top <= 108;
	
	bomb_six_bot <= 139;
	bomb_six_lo <= 21;
	bomb_six_hi <= 42;
	bomb_seven_top <= 108;
	bomb_seven_bot <= 139;
	bomb_seven_lo <= 21;
	bomb_seven_hi <= 42;
	bomb_eight_top <= 108;
	bomb_eight_bot <= 139;
	bomb_eight_lo <= 21;
	bomb_eight_hi <= 42;

	b2_lo<=21;
	b2_hi<=42;
	
	hbb_lo <= 1;
	hbb_hi <= 64;	
	hbnb_lo <= 1;
	hbnb_hi <= 64;	
	pad_lo <= 1;
	pad_hi <= 64;
	exp_lo <= 1;
	exp_hi <= 64;
	bmb<=1;
	flag<=0;
	flag_1<=0;
	flag_2<=0;
	won<=0;
	bmb_2<=1;
	bmb_3<=1;
	bmb_4<=1;
	bmb_5<=1;
	bmb_6<=1;
	bmb_7<=1;
	bmb_8<=1;
	x<=1;
	rst_1<=0;
	rst_2<=0;
	rst_3<=0;
	rst_4<=0;
	rst_5<=0;
	rst_6<=0;
	rst_7<=0;
	rst_8<=0;
	exp1<=0;
	exp2<=0;
	exp3<=0;
	exp4<=0;
	exp5<=0;
	exp6<=0;
	exp7<=0;
	exp8<=0;
	rst_exp<=0;
	
	rst_pad<=0;
	end	
	*/
	
	endcase //end of the game_state case statement

end 
/*************************************************************/
/*****	END MOVEMENT CONTROL ALWAYS BLOCK (@clk_slow)	*****/
/*************************************************************/	

	
////////////////////////////////////////////////////////////////////////////////////////
////////// 	BEGIN VGA DRAWING ALWAYS BLOCK (@clk_25MHz)	//////////
////////////////////////////////////////////////////////////////////////////////////////
/*	This always block controls actually drawing the sprites, text, etc. 	
 */
	
	always @ (posedge clk_25MHz)
	begin	
	
   case (game_state)
	///////////////////////////
	///	 TITLE SCREEN	///
	///////////////////////////
	0: begin	
	
	if (color_val < 3'b111) begin
	if (color_timer < 25'b1_1111_1111_1111_1111_1111_1111) begin
	color_timer <= color_timer + 1;
	end else begin
	color_timer <= 0;
	color_val <= color_val + 1;
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
	
	if (start_bomb_block) begin //draw title screen bomb
	R <= bomb_dout[7:5];
	G <= bomb_dout[4:2];
	B <= bomb_dout[1:0];
	if (bomb_address == 703) 
	begin
	bomb_address <= 0;
	end
	else bomb_address <= bomb_address + 1;
	
	end
	
	if (kaboom) begin 
	R <= color_val & { 3{tile[tile_ctr]} };
	G <= 0; //toggle[5:3] & { 3{tile[tile_ctr]} };
	B <= 0; //{ toggle[6], 1'b0 } & { 2{tile[tile_ctr]} };
	
	
	col_ctr <= col_ctr + 1;
	if (x_ctr == (font_scale-1)) begin
	tile_ctr <= tile_ctr - 6'b1;
	x_ctr <= 0;
	if (col_ctr == (font_scale*8-1)) begin	  //at end of each row
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
	end else begin	// do this pixel over again
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
	if (start_col_ctr== 7) begin	  //at end of each row
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
	if (cred_col_ctr== 7) begin	  //at end of each row
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
	
	end //end case game_state = 0 
	/**************************
	***	END TITLE SCREEN	***
	**************************/
	 

	/////////////////////////////////////////////
	///	 GAME PLAY - 1 and 2 PLAYER MODE	///
	/////////////////////////////////////////////

	 1,4: begin

	if(rst==1)
	begin
	hbb_address <= 0; //Avoids shifting after a reset.     
	hbnb_address <= 0;	
	pad_address <= 0;
	end	
	if (rst_1==1)
	begin
	bomb_address<=0;
	end
	if (rst_2==1)
	begin
	bomb_two_address<=0;
	end
	if (rst_3==1)
	begin
	bomb_three_address<=0;
	end
	   if (rst_4==1)
	begin
	bomb_four_address<=0;
	end
	if (rst_5==1)
	begin
	bomb_five_address<=0;
	end
	if (rst_6==1)
	begin
	bomb_six_address<=0;
	end
	if (rst_7==1)
	begin
	bomb_seven_address<=0;
	end
	if (rst_8==1)
	begin
	bomb_eight_address<=0;
	end
	if (rst_exp==1)
	begin
	explosion_address<=0;
	end
	if (rst_hbb==1)
	begin
	hbb_address<=0;
	end
	if (rst_hbnb==1)
	begin
	hbnb_address<=0;
	end
	if(rst_pad==1)
	begin
	pad_address<=0;
	end
	 if (hbnb_block & nobomb) begin //hbnb block detection
	R <= hbnb_dout[7:5];
	G <= hbnb_dout[4:2];
	B <= hbnb_dout[1:0];
	if (hbnb_address == 5631) hbnb_address <= 0;
	else hbnb_address <= hbnb_address + 1;	
	end
	 else if (hbb_block & yesbomb) begin //hbb block detection
	R <= hbb_dout[7:5];
	G <= hbb_dout[4:2];
	B <= hbb_dout[1:0];
	if (hbb_address == 5631)  hbb_address <= 0;
	else hbb_address <= hbb_address + 1;
	end
	else if (pad_block & flag_2==0) begin  //Implement later  to eliminate pads
	R <= pad_dout[7:5];
	G <= pad_dout[4:2];
	B <= pad_dout[1:0];
	if (pad_address == 1023) pad_address <= 0;
	else pad_address <= pad_address + 1;
	end
	
	else if (pad1_block & flag_1==0) begin  //Implement later  to eliminate pads
	R <= pad_dout[7:5];
	G <= pad_dout[4:2];
	B <= pad_dout[1:0];
	if (pad_address == 1023) pad_address <= 0;
	else pad_address <= pad_address + 1;
	end
	
	else if (pad2_block & flag==0) begin  //Implement later  to eliminate pads
	R <= pad_dout[7:5];
	G <= pad_dout[4:2];
	B <= pad_dout[1:0];
	if (pad_address == 1023) pad_address <= 0;
	else pad_address <= pad_address + 1;
	end

	else if (bomb_block & bmb==1) begin //bomb block detection
	R <= bomb_dout[7:5];
	G <= bomb_dout[4:2];
	B <= bomb_dout[1:0];
	if (bomb_address == 703)  
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

	else if (bomb_six_block & bmb_6==1) begin //bomb block detection
	R <= bomb_six_dout[7:5];
	G <= bomb_six_dout[4:2];
	B <= bomb_six_dout[1:0];
	if (bomb_six_address == 703) 
	begin
	bomb_six_address <= 0;
	end
	else bomb_six_address <= bomb_six_address + 1;
	end	

	else if (bomb_seven_block & bmb_7==1) begin //bomb block detection
	R <= bomb_seven_dout[7:5];
	G <= bomb_seven_dout[4:2];
	B <= bomb_seven_dout[1:0];
	if (bomb_seven_address == 703) 
	begin
	bomb_seven_address <= 0;
	end
	else bomb_seven_address <= bomb_seven_address + 1;
	end	

	else if (bomb_eight_block & bmb_8==1) begin //bomb block detection
	R <= bomb_eight_dout[7:5];
	G <= bomb_eight_dout[4:2];
	B <= bomb_eight_dout[1:0];
	if (bomb_eight_address == 703) 
	begin
	bomb_eight_address <= 0;
	end
	else bomb_eight_address <= bomb_eight_address + 1;
	end
	
	
	else if (explosion_block & (exp1==1|exp2==1|exp3==1|exp4==1|exp5==1|exp6==1|exp7==1|exp8==1)) begin //explosion
	R <= explosion_dout[7:5];
	G <= explosion_dout[4:2];
	B <= explosion_dout[1:0];
	if (explosion_address == 32767) explosion_address <= 0;
	else explosion_address <= explosion_address + 1;
	end
	
	
	//Comment/Uncomment for enabling bombers
	
	
	
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
	if(rst_score==1)
	begin
	R <= 0;
	G <= 0;
	B <= 0;
	end
	else begin
	R <= 3'b111 & { 3{tile[tile_ctr]} };
	G <= 3'b111 & { 3{tile[tile_ctr]} };
	B <= 3'b111 & { 2{tile[tile_ctr]} };


	col_ctr <= col_ctr + 1;
	tile_ctr <= tile_ctr - 1;
	if (col_ctr == 7) begin	  //at end of each row
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

	end
	end
	end
	else begin	//the screen is black everywhere else
	R <= 0;
	G <= 0;
	B <= 0;
	end
	end
	
	////////////////////////////////////////////////////////////
	///	 GAME OVER / YOU WIN / PAUSE (2p) / PAUSE (1p)	///
	////////////////////////////////////////////////////////////
	2,3,6,7: begin
	if (color_val < 3'b111) begin
	if (color_timer < 25'b1_1111_1111_1111_1111_1111_1111) begin
	color_timer <= color_timer + 1;
	end else begin
	color_timer <= 0;
	color_val <= color_val + 1;
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
	
	//draw Happy Bomber for Game Over State
	if (game_state == 2) begin
	if (hbb_block) begin //hbb block detection
	R <= hbb_dout[7:5];
	G <= hbb_dout[4:2];
	B <= hbb_dout[1:0];
	if (hbb_address == 5631)  hbb_address <= 0;
	else hbb_address <= hbb_address + 1;
	end
	
	else if (hbnb_block) begin //hbnb block detection
	R <= hbnb_dout[7:5];
	G <= hbnb_dout[4:2];
	B <= hbnb_dout[1:0];
	if (hbnb_address == 5631) hbnb_address <= 0;
	else hbnb_address <= hbnb_address + 1;	
	end
	end
	
	if (kaboom) begin 
	if (game_state == 2) begin
	R <= color_val & { 3{tile[tile_ctr]} };
	G <= 0; 
	end else begin //game states 3, 6, 7
	R <= 0;
	G <= color_val & { 3{tile[tile_ctr]} };
	end
	
	B <= 0;
	
	col_ctr <= col_ctr + 1;
	if (x_ctr == (font_scale-1)) begin
	tile_ctr <= tile_ctr - 6'b1;
	x_ctr <= 0;
	if (col_ctr == (font_scale*8-1)) begin	  //at end of each row
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
	
	if (game_state <= 2) begin
	case (char_ctr)
	0: char_sel <= 10; //A
	1: char_sel <= 22; //M
	2: char_sel <= 14; //E
	3: char_sel <= 24; //O
	4: char_sel <= 31; //V
	5: char_sel <= 14; //E
	6: char_sel <= 27; //R
	7: char_sel	<= 16; //G
	endcase
	end else if ( game_state == 3) begin	
	case (char_ctr)
	0: char_sel <= 24; //O
	1: char_sel <= 30; //U
	2: char_sel <= 39; //space
	3: char_sel <= 32; //W
	4: char_sel <= 24; //O
	5: char_sel <= 23; //N
	6: char_sel <= 39; //space
	7: char_sel	<= 34; //Y
	endcase	
	end else if ((game_state == 6) | (game_state == 7)) begin
	case (char_ctr)
	0: char_sel <= 25; //P
	1: char_sel <= 10; //A
	2: char_sel <= 30; //U
	3: char_sel <= 28; //S
	4: char_sel <= 14; //E
	5: char_sel <= 13; //D
	6: char_sel <= 39; //space
	7: char_sel	<= 39; //space
	endcase
	end

	end
	end else begin	// do this pixel over again
	x_ctr <= x_ctr + 1;
	end
	end
	end	
	/********************************************
	 ***	END GAME OVER / YOU WON / PAUSE	***
	 ********************************************/
	endcase	// end game_state case statement
	end
/*************************************************************/
/*****	END VGA DRAWING ALWAYS BLOCK (@clk_25MHz)	*****/
/*************************************************************/
endmodule