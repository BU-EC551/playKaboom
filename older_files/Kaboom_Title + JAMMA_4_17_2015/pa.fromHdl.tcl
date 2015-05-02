
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name VGA_Test -dir "C:/Users/Juan Carlos/Documents/Boston University/Spring 2015/Advanced Digital Design with Verilog and FPGA EC551/Project/Kaboom_with_title_4_17_2015/planAhead_run_2" -part xc6slx16csg324-3
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "vga_display.ucf" [current_fileset -constrset]
add_files [list {ipcore_dir/bomb_sprite.ngc}]
add_files [list {ipcore_dir/HappyBomber_bomb.ngc}]
add_files [list {ipcore_dir/HappyBomber_NoBomb.ngc}]
add_files [list {ipcore_dir/Sad_Bomber.ngc}]
add_files [list {ipcore_dir/pad.ngc}]
add_files [list {ipcore_dir/btwo.ngc}]
add_files [list {ipcore_dir/bthree.ngc}]
add_files [list {ipcore_dir/bfour.ngc}]
add_files [list {ipcore_dir/bfive.ngc}]
set hdlfile [add_files [list {VGA_control.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {seven_segment.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {score_2_dec.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {ipcore_dir/Sad_Bomber.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {ipcore_dir/pad.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {ipcore_dir/HappyBomber_NoBomb.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {ipcore_dir/HappyBomber_bomb.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {ipcore_dir/btwo.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {ipcore_dir/bthree.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {ipcore_dir/bomb_sprite.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {ipcore_dir/bfour.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {ipcore_dir/bfive.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {font_rom.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {VGA_display.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {ipcore_dir/btwo_synth.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {ipcore_dir/bthree_synth.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {ipcore_dir/bfour_synth.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {ipcore_dir/bfive_synth.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set_property top vga_display_bomb $srcset
add_files [list {vga_display.ucf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/bfive.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/bfour.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/bomb_sprite.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/bthree.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/btwo.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/Explosion.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/HappyBomber_bomb.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/HappyBomber_NoBomb.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/pad.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/Sad_Bomber.ncf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc6slx16csg324-3
