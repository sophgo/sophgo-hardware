#-- Lattice Semiconductor Corporation Ltd.
#-- Synplify OEM project file

#device options
set_option -technology MACHXO3LF
set_option -part LCMXO3LF_2100C
set_option -package BG256C
set_option -speed_grade -5

#compilation/mapping options
set_option -symbolic_fsm_compiler true
set_option -resource_sharing true

#use verilog 2001 standard option
set_option -vlog_std v2001

#map options
set_option -frequency 100
set_option -maxfan 1000
set_option -auto_constrain_io 0
set_option -disable_io_insertion false
set_option -retiming false; set_option -pipe true
set_option -force_gsr false
set_option -compiler_compatible 0
set_option -dup false

set_option -default_enum_encoding default

#simulation options


#timing analysis options



#automatic place and route (vendor) options
set_option -write_apr_constraint 1

#synplifyPro options
set_option -fix_gated_and_generated_clocks 0
set_option -update_models_cp 0
set_option -resolve_multiple_driver 0


set_option -seqshift_no_replicate 0

#-- add_file options
set_option -include_path {E:/01_Project/07_SG2042_Server/99_CPLD/Project/03_Server_CPLD_V11/Pre_Final/Server_CPLD_V11_PRJ}
add_file -verilog -vlog_std v2001 {E:/01_Project/07_SG2042_Server/99_CPLD/Project/03_Server_CPLD_V11/Pre_Final/Server_CPLD_V11_PRJ/impl1/source/bmc_reset_ctrl.v}
add_file -verilog -vlog_std v2001 {E:/01_Project/07_SG2042_Server/99_CPLD/Project/03_Server_CPLD_V11/Pre_Final/Server_CPLD_V11_PRJ/impl1/source/cpu_power_control.v}
add_file -verilog -vlog_std v2001 {E:/01_Project/07_SG2042_Server/99_CPLD/Project/03_Server_CPLD_V11/Pre_Final/Server_CPLD_V11_PRJ/impl1/source/debounce_button_FSM_run.v}
add_file -verilog -vlog_std v2001 {E:/01_Project/07_SG2042_Server/99_CPLD/Project/03_Server_CPLD_V11/Pre_Final/Server_CPLD_V11_PRJ/impl1/source/eeprom_i2c.v}
add_file -verilog -vlog_std v2001 {E:/01_Project/07_SG2042_Server/99_CPLD/Project/03_Server_CPLD_V11/Pre_Final/Server_CPLD_V11_PRJ/impl1/source/i2c_master.v}
add_file -verilog -vlog_std v2001 {E:/01_Project/07_SG2042_Server/99_CPLD/Project/03_Server_CPLD_V11/Pre_Final/Server_CPLD_V11_PRJ/impl1/source/i2c_slave_for_register.v}
add_file -verilog -vlog_std v2001 {E:/01_Project/07_SG2042_Server/99_CPLD/Project/03_Server_CPLD_V11/Pre_Final/Server_CPLD_V11_PRJ/impl1/source/power_on_reset.v}
add_file -verilog -vlog_std v2001 {E:/01_Project/07_SG2042_Server/99_CPLD/Project/03_Server_CPLD_V11/Pre_Final/Server_CPLD_V11_PRJ/impl1/source/power_signal_detect.v}
add_file -verilog -vlog_std v2001 {E:/01_Project/07_SG2042_Server/99_CPLD/Project/03_Server_CPLD_V11/Pre_Final/Server_CPLD_V11_PRJ/impl1/source/server_power_control.v}
add_file -verilog -vlog_std v2001 {E:/01_Project/07_SG2042_Server/99_CPLD/Project/03_Server_CPLD_V11/Pre_Final/Server_CPLD_V11_PRJ/impl1/source/switch_reset_control.v}
add_file -verilog -vlog_std v2001 {E:/01_Project/07_SG2042_Server/99_CPLD/Project/03_Server_CPLD_V11/Pre_Final/Server_CPLD_V11_PRJ/impl1/source/timer.v}
add_file -verilog -vlog_std v2001 {E:/01_Project/07_SG2042_Server/99_CPLD/Project/03_Server_CPLD_V11/Pre_Final/Server_CPLD_V11_PRJ/impl1/source/top.v}
add_file -verilog -vlog_std v2001 {E:/01_Project/07_SG2042_Server/99_CPLD/Project/03_Server_CPLD_V11/Pre_Final/Server_CPLD_V11_PRJ/impl1/source/uart_sol.v}
add_file -verilog -vlog_std v2001 {E:/01_Project/07_SG2042_Server/99_CPLD/Project/03_Server_CPLD_V11/Pre_Final/Server_CPLD_V11_PRJ/impl1/source/usb_reset_ctrl.v}

#-- top module name
set_option -top_module server_top

#-- set result format/file last
project -result_file {E:/01_Project/07_SG2042_Server/99_CPLD/Project/03_Server_CPLD_V11/Pre_Final/Server_CPLD_V11_PRJ/impl1/Server_CPLD_V11_PRJ_impl1.edi}

#-- error message log file
project -log_file {Server_CPLD_V11_PRJ_impl1.srf}

#-- set any command lines input by customer


#-- run Synplify with 'arrange HDL file'
project -run
