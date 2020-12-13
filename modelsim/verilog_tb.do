
set SIM_LEVEL rtl ;# rtl|post_syn|post_par|libprep
#set SIM_LEVEL post_par ;# rtl|post_syn|post_par|libprep
#set SIM_LEVEL rtl ;# rtl|post_syn|post_par|libprep
#set SIM_LEVEL libprep
variable SIM_CORNER min ;# min|max

switch $SIM_LEVEL {

  rtl      {
# compile source
    do {compile_src.do}
# run vsim
    ### for code coverage ###
    vsim -coverage -voptargs="+cover=bcfst" -L tsmc_cl018g_rvt_neg -L tsmc18_cg_neg -suppress 12027 digital_core_tb  -vopt -voptargs="+acc" -sv_seed random
    ### for simulation ###
 #   vsim -L tsmc_cl018g_rvt_neg -L tsmc18_cg_neg -suppress 12027 external_interface_tb  -vopt -voptargs="+acc -xprop,mode=resolve" -sv_seed random
  }

  post_par {
    do {compile_postpar.do}

   vsim -coverage -L rf2p_512x64_4_50 -L tsmc_cl018g_rvt_neg -L tsmc18_cg_neg -suppress 12027 digital_core_tb -sv_seed random\
        -sdfnoerror -vopt -voptargs="+acc -xprop,mode=resolve" -sdftyp :larpix_single_tb:larpix_v2b_inst:digital_core_inst=[pwd]/../par/digital_core.signoff.sdf \
            -sdftyp :larpix_single_tb:larpix_v2b_inst:digital_core_inst=[pwd]/../par/digital_core.signoff.sdf 


    #add wave -group fpga_rx sim/:larpix_tb:mcp_inst:rx:*
    #force -deposit sim/:larpix_tb:larpix_inst:digital_core_inst:regmap_bits_376 St0 0
    #noforce sim/:larpix_tb:larpix_inst:digital_core_inst:regmap_bits_376
#    run 750us
  }



  libprep {
    do {compile_reflibs.do}
    exit 
  }
} ;#-sdfreport=digital_core.sdf.report

#
#
#do {wave.gate.do}
#
# Set the window types
#
#view wave
#view structure
#view signals

#
# Source user do file (UDO)
#
#run 3us
#do {verilog_tb.udo}

#
# End
#
