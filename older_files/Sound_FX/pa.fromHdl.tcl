
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name Sound_FX -dir "C:/Users/Juan Carlos/Documents/Boston University/Spring 2015/Advanced Digital Design with Verilog and FPGA EC551/Project/Sound_FX/planAhead_run_3" -part xc6slx16csg324-3
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "clk_div.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {clk_div.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set_property top clk_div $srcset
add_files [list {clk_div.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc6slx16csg324-3
