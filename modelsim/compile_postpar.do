#
# Create work library
#
vlib work

#
# Map libraries
#
vmap work  

#
# Design sources
#vlog -L rf2p_512x64_4_50 -L tsmc_cl018g_rvt_neg -L tsmc18_cg_neg "/home/lxusers/c/crgrace/verilog/lightpix/par/digital_core.output.v"
#vlog -L rf2p_512x64_4_50 -L tsmc_cl018g_rvt_neg -L tsmc18_cg_neg "/home/lxusers/c/crgrace/verilog/lightpix/par/postCTS.v"
#vlog -L rf2p_512x64_4_50 -L tsmc_cl018g_rvt_neg -L tsmc18_cg_neg "/home/lxusers/c/crgrace/verilog/lightpix/par/route.v"
vlog -L tsmc_cl018g_rvt_neg -L tsmc18_cg_neg "/home/lxusers/c/crgrace/verilog/psd_chip/par/digital_core.signoff.v"


#
# Testbenches
#
vlog -incr -sv "../src/uart_rx.sv" 
vlog -incr -sv "../src/uart_tx.sv" 
vlog +incdir+../testbench/tasks/ -incr -vopt -sv "../testbench/unit_tests/external_interface_tb.sv" 
vlog -incr -vopt -sv "../testbench/unit_tests/digital_core_tb.sv" 

