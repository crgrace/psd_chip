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
#

vlog +incdir+../testbench/tasks/ -incr -sv "../src/regfile.sv"
vlog -incr -sv "../src/uart_rx.sv" 
vlog -incr -sv "../src/uart_tx.sv" 
vlog -incr -sv "../src/uart.sv" 
vlog -incr -sv "../src/external_interface.sv"
vlog +incdir+../testbench/tasks/ -incr -sv "../src/digital_core.sv"
#vlog -L rf2p_512x64_4_50 -L tsmc_cl018g_rvt_neg -L tsmc18_cg_neg "../par/digital_core.output.v"

#
# Standard Cells
#
vlog -incr -vopt "/eda/foundry/ARM/TSMC/cl018g/tsmc/cl018g/sc9tap_cg_rvt/r9p0-00rel0/verilog/tsmc18_cg_neg.v"
#vlog -incr -vopt  "/eda/foundry/ARM/TSMC/cl018g/tsmc/cl018g/sc9_base_rvt/2008q3v01/verilog/sage-x_tsmc_cl018g_rvt_neg.v"
#
# Testbenches
#
vlog +incdir+../testbench/tasks/ -incr -vopt -sv "../testbench/unit_tests/external_interface_tb.sv" 
vlog -incr -vopt -sv "../testbench/unit_tests/digital_core_tb.sv" 


