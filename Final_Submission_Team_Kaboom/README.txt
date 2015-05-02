This project is in fulfilment of our course “EC 551 Advanced Digital Design with Verilog and FPGA” at Boston University. The folder, “Verilog Code” contains a set of verilog modules, which emulate the popular Atari arcade game, “Kaboom”. This folder contains all the modules required for you to sytnhesize this code in Xilinx ISE, to be implemented on a Xilinx Spartan 6 FPGA, on a Digilent Nexys-3 board.  

For this project, we have developed our own sprites from scratch.  The sprites are stored in the form of .coe files, which are stored in the FPGA’s BRAM. All the graphics of this project are drawn on a 640X480 monitor by the VGA signals. The characters can be moved as per the user’s choice, by pressing buttons on the FPGA. The top module is “vga_display.v”. All other modules are instantiated within this module. 

There are also lines of code that allow the user to use this code to play the game from an Android smartphone app for kaboom, via bluetooth. The .apk file is a code for the Android app for Kaboom. This app creates the pads on a smartphone screen, and allows the user to move the pads on the phone, while at the same time, the pads move in the same manner on the screen. This pairing is achieved via Bluetooth. 

The other modules are for a score counter, a VGA controller, to control the drawing of the sprites, and also codes for displaying the score in hex, on the on-board 7-segment display. To run the code on your computer, download the folder “Verilog Code” onto your computer, and open the “VGA_Test.xise” file in Xilinx ISE. Run the code as you would run any other verilog code, program the FPGA with the “vga_display_bomb.bit” file, and you will be good to go!

Enjoy the game, happy “Kaboom”ing!!!!


BUTTON LAYOUT GUIDE
Please refer to the .ucf file for specific button port names.


					(pad right)
				
(bomber left)		(pad left)			(bomber right)
				
					(display reset)
					


TOGGLE SWITCH GUIDE
toggle switches from left to right (X means it does nothing):

(X)	(X)	(X) (X) (start 1-player) (resume) (pause) (start 2-player)