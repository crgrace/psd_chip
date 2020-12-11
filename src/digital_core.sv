///////////////////////////////////////////////////////////////////
// File Name: digital_core.sv
// Engineer:  Carl Grace (crgrace@lbl.gov)
// Description: PSD_CHIP synthesized digital core.  
//              Includes:
//              UARTs for inter-chip communcation
//              32-byte Register Map for configuration bits.
//
//              Note that the "primary" is the chip writing to and reading
//              from the current chip. It could also be the FPGA.
//              The "secondary" is always the current chip.
//
///////////////////////////////////////////////////////////////////

module digital_core
    (parameter NUMREGS = 256)   // number of configuration registers
    
    (output logic piso,// PRIMARY-IN-SECONDARY-OUT TX UART output bit
    
// ANALOG CORE CONFIGURATION SIGNALS
// these are in the same order as the PSD_CHIP config bits google sheet

    output logic [PIXEL_TRIM_DAC_BITS*NUMCHANNELS-1:0] pixel_trim_dac,
    output logic [GLOBAL_DAC_BITS-1:0] threshold_global,
    output logic [NUMCHANNELS-1:0] csa_gain, // active high
    output logic csa_reset [NUMCHANNELS-1:0], // active high
    output logic [NUMCHANNELS-1:0] bypass_caps_enable, // active high
    output logic [15:0] ibias_tdac, // threshold dac ibias 
    output logic [15:0] ibias_comp, // discriminator ibias 
    output logic [15:0] ibias_buffer, // ab buffer ibias 
    output logic [15:0] ibias_csa, // csa ibias 
    output logic [3:0] ibias_vref_buffer, // vref buffer ibias
    output logic [3:0] ibias_vcm_buffer,  // vcm buffer ibias
    output logic [3:0] ibias_tpulse,  // tpulse ibias
    output logic [4:0] ref_current_trim, // trims ref voltage
    output logic override_ref, // high to enable external bandgap
    output logic ref_kickstart, // active high kickstart bit
    output logic [7:0] vref_dac, // sets vref for adc
    output logic [7:0] vcm_dac, // sets vcm for adc
    output logic [NUMCHANNELS-1:0] csa_bypass_enable, // inject into adc
    output logic [NUMCHANNELS-1:0] csa_bypass_select, // adc channels(s)
    output logic [NUMCHANNELS-1:0] csa_monitor_select, // monitor channels 
    output logic [NUMCHANNELS-1:0] csa_testpulse_enable,
    output logic [TESTPULSE_DAC_BITS-1:0] csa_testpulse_dac,
    output logic [3:0] current_monitor_bank0, // one hot monitor (see docs)
    output logic [3:0] current_monitor_bank1, // one hot monitor (see docs)
    output logic [3:0] current_monitor_bank2, // one hot monitor (see docs)
    output logic [3:0] current_monitor_bank3, // one hot monitor (see docs)
    output logic [2:0] voltage_monitor_bank0, // one hot monitor (see docs)
    output logic [2:0] voltage_monitor_bank1, // one hot monitor (see docs)
    output logic [2:0] voltage_monitor_bank2, // one hot monitor (see docs)
    output logic [2:0] voltage_monitor_bank3, // one hot monitor (see docs)
    output logic [7:0] voltage_monitor_refgen, // one hot monitor 
    output logic [3:0] tx_slices0, // number of LVDS slices for POSI0 link
    output logic [3:0] tx_slices1, // number of LVDS slices for POSI1 link
    output logic [3:0] tx_slices2, // number of LVDS slices for POSI2 link
    output logic [3:0] tx_slices3, // number of LVDS slices for POSI3 link
    output logic [3:0] i_tx_diff0, // TX0 bias current (diff)
    output logic [3:0] i_tx_diff1, // TX1 bias current (diff)
    output logic [3:0] i_tx_diff2, // TX2 bias current (diff)
    output logic [3:0] i_tx_diff3, // TX3 bias current (diff)
    output logic [3:0] i_rx0, // RX0 bias current 
    output logic [3:0] i_rx1, // RX1 bias current 
    output logic [3:0] i_rx2, // RX2 bias current 
    output logic [3:0] i_rx3, // RX3 bias current 
    output logic [3:0] i_rx_clk, // RX_CLK bias current 
    output logic [3:0] i_rx_rst, // RX_RST bias current 
    output logic [3:0] i_rx_ext_trig, // RX_EXT_TRIG bias current 
    output logic [3:0] r_term0, // RX0 termination resistor
    output logic [3:0] r_term1, // RX1 termination resistor
    output logic [3:0] r_term2, // RX2 termination resistor
    output logic [3:0] r_term3, // RX3 termination resistor
    output logic [3:0] r_term_clk, // RX_CLK termination resistor
    output logic [3:0] r_term_rst, // RX_RST termination resistor
    output logic [3:0] r_term_ext_trig, // RX_EXT_TRIG termination resistor
    output logic [3:0] v_cm_lvds_tx0,   // TX0 CM output voltage (lvds mode)
    output logic [3:0] v_cm_lvds_tx1,   // TX1 CM output voltage (lvds mode)
    output logic [3:0] v_cm_lvds_tx2,   // TX2 CM output voltage (lvds mode)
    output logic [3:0] v_cm_lvds_tx3,   // TX3 CM output voltage (lvds mode)
// INPUTS
    input logic [NUMCHANNELS-1:0] comp,   // decision bit from comparator 
    input logic [NUMCHANNELS-1:0] hit,    // high when discriminator fires
    input logic external_trigger,     // high to trigger channel
    input logic posi [3:0],// PRIMARY-OUT-SECONDARY-IN: RX UART input bit  
    input clk,    // master clk
    input reset_n);        // asynchronous digital reset (active low)

// calculate register widths
localparam REGMAP_ADDR_WIDTH = $clog2(REGNUM); // bits in regmap addr range
localparam FIFO_BITS = $clog2(FIFO_DEPTH);//bits in fifo addr range


// constants (e.g. register definitions)
// located at ../testbench/larpix_tasks/
// example compilation: 
//vlog +incdir+../testbench/larpix_tasks/ -incr -sv "../src/digital_core.sv"
`include "larpix_constants.sv"
    
// internal nets
logic [7:0] adc_word [NUMCHANNELS-1:0]; // useful for simulation debugging, not brought to pins

// digital config 
logic [7:0] chip_id; // unique id for each chip
logic load_config_defaults; // high to soft reset LArPix (set to low after)
logic [3:0] enable_piso_upstream; // enable different upstream PISOs
logic [3:0] enable_piso_downstream; // enable different downstream PISOs
logic [3:0] enable_posi;              // high for different POSIs
logic [1:0] test_mode_uart0;          // put uart0 into test mode
logic [1:0] test_mode_uart1;          // put uart1 into test mode
logic [1:0] test_mode_uart2;          // put uart2 into test mode
logic [1:0] test_mode_uart3;          // put uart3 into test mode
logic [7:0] test_mode;            // concat uart test modes
logic enable_cross_trigger;      // high for cross trigger mode
logic enable_periodic_trigger;      // high for periodic trigger mode
logic enable_rolling_periodic_trigger; // make the trigger rolling
logic enable_periodic_reset;      // high for periodic reset mode
logic enable_rolling_periodic_reset; // make the reset rolling
logic enable_periodic_trigger_veto; // does hit veto periodic trigger?
logic enable_hit_veto;   // is hit required to go into hold mode?
logic enable_fifo_diagnostics;   // high for diagnostics
logic [15:0] adc_hold_delay;     // how many clock cycles for sampling?
logic [7:0] adc_burst_length;  // how long is max adc burst?
logic [2:0] reset_length;       // how many cycles to reset CSA?
logic digital_monitor_enable;
logic [3:0] digital_monitor_select;
logic [5:0] digital_monitor_chan;
logic mark_first_packet;    // sets MSB of timestamp to 1 on first hit
logic [NUMCHANNELS-1:0] channel_mask; // high to disable channel
logic [NUMCHANNELS-1:0] external_trigger_mask; // high to disable channel
logic [NUMCHANNELS-1:0] cross_trigger_mask; // high to disable channel
logic [NUMCHANNELS-1:0] periodic_trigger_mask; // high to disable channel
logic [23:0] periodic_reset_cycles; // time between periodic reset
logic [31:0] periodic_trigger_cycles; // time between periodic triggers
logic [1:0] clk_ctrl;   // divide ratio
logic enable_tx_dynamic_powerdown; // high to power down of TX when idle
logic [2:0] tx_dynamic_powerdown_cycles; // how long to wait after powerup
logic enable_dynamic_reset; // high to enable dynamic reset mode
logic enable_min_delta_adc; // high to enable min delta ADC mode
logic threshold_polarity; // high to trigger when ABOVE threshold
logic [7:0] dynamic_reset_threshold; // ADC threshold that triggers 
logic [7:0] min_delta_adc; // difference in ADC values that triggers
logic [WIDTH-2:0] input_events [NUMCHANNELS-1:0]; // pre-parity routed 
logic [63:0] csa_enable; // enable from config bits
logic [63:0] csa_reset_channel; // reset from channel_ctrl
logic [7:0] dac_word_channel [NUMCHANNELS-1:0]; // SAR control from channel
logic [63:0] local_fifo_empty; // when low, event is ready
logic [63:0] triggered_natural; // low for external or cross trigger
logic [31:0] timestamp_32b;  //32bit timestamp
logic [NUMCHANNELS-1:0] read_local_fifo_n; // low to read local fifo
logic cross_trigger; // high when any channels naturally hit
logic [NUMCHANNELS-1:0] periodic_trigger;
logic fifo_full;    // high when shared fifo full
logic fifo_half;    // high when shared fifo more than half full
logic fifo_empty;    // high when shared fifo empty 
logic [FIFO_BITS:0] fifo_counter; // how full is shared fifo?
logic reset_n_sync;  // synced version of reset_n
logic reset_n_config_sync;  // synced version of reset_n_config
logic clk_core; // LArPix core clock
logic clk_rx;    // 2x oversampling rx clock
logic clk_tx;  // slow tx clock
logic read_fifo_n;  // read data from shared fifo (active low)
logic write_fifo_n;  // write data from shared fifo (active low)
logic [WIDTH-2:0] output_event; // event to put into the fifo
logic [7:0] config_bits [0:REGNUM-1];// regmap config bit outputs
logic [WIDTH-2:0] tx_data; // fifo data to be transmitted off-chip
logic [WIDTH-2:0] pre_event; // event (pre-parity) to put into fifo
logic load_event;     // high to load event from event builder
logic sync_timestamp; // timestamp set to 0 when high   
logic [NUMCHANNELS*8-1:0] digital_threshold; // adc > this?
logic [NUMCHANNELS-1:0] periodic_reset; // from reset pulser
logic lightpix_mode; // high to integrate hits for timeout
logic [6:0] hit_threshold; // how many hits to declare event?
logic [7:0] timeout; // number of clk cycles to wait for hits
logic [7:0] shadow_reset_length; // just in case...
logic [7:0] reset_length_channel; // just in case...
logic external_trigger_sync;
// need to use generates for large config words
// Cadence can't handle two dimensional ports
genvar g_i;
generate 
    for (g_i = 0; g_i < 64; g_i++) begin
        assign pixel_trim_dac[g_i*PIXEL_TRIM_DAC_BITS+(PIXEL_TRIM_DAC_BITS-1):g_i*PIXEL_TRIM_DAC_BITS] 
            = config_bits[PIXEL_TRIM+g_i][PIXEL_TRIM_DAC_BITS-1:0];
        assign digital_threshold[g_i*8+7:g_i*8] 
            = config_bits[DIGITAL_THRESHOLD+g_i][7:0];
        // distribute internal SAR DAC controls
        assign dac_word[g_i*8+7:g_i*8] = dac_word_channel[g_i];
        
    end
endgenerate

generate
    for (g_i = 0; g_i < 8; g_i++) begin
        assign csa_enable[g_i*8+7:g_i*8] 
            = config_bits[CSA_ENABLE+g_i][7:0]; //DG: mod
        assign csa_bypass_select[g_i*8+7:g_i*8] 
            = config_bits[BYPASS_SELECT+g_i][7:0]; //DG: mod
        assign csa_monitor_select[g_i*8+7:g_i*8] 
            = config_bits[CSA_MONITOR_SEL+g_i][7:0]; //DG: mod
        assign csa_testpulse_enable[g_i*8+7:g_i*8] 
            = config_bits[CSA_TEST_ENABLE+g_i][7:0]; //DG: mod
        assign channel_mask[g_i*8+7:g_i*8] 
            = config_bits[CHANNEL_MASK+g_i][7:0]; //DG: mod
        assign external_trigger_mask[g_i*8+7:g_i*8] 
            = config_bits[EXTERN_TRIG_MASK+g_i][7:0]; //DG: mod
        assign cross_trigger_mask[g_i*8+7:g_i*8] 
            = config_bits[CROSS_TRIG_MASK+g_i][7:0]; //DG: mod
        assign periodic_trigger_mask[g_i*8+7:g_i*8] 
            = config_bits[PER_TRIG_MASK+g_i][7:0]; //DG: mod
    end // for
endgenerate

generate
    for (g_i = 0; g_i < 4; g_i++) begin
        assign periodic_trigger_cycles[g_i*8+7:g_i*8] 
            = config_bits[PER_TRIG_CYC+g_i][7:0]; //DG: mod
    end // for
endgenerate

generate
    for (g_i = 0; g_i < 3; g_i++) begin
        assign periodic_reset_cycles[g_i*8+7:g_i*8] 
            = config_bits[RESET_CYCLES+g_i][7:0]; //DG: mod
    end // for
endgenerate


// ------- Config registers to LArPix
always_comb begin
    threshold_global = config_bits[GLOBAL_THRESH][7:0];
    csa_gain = {64{config_bits[CSA_CTRL][0]}};
    csa_bypass_enable = {64{config_bits[CSA_CTRL][1]}};
    bypass_caps_enable = {64{config_bits[CSA_CTRL][2]}};
    ibias_tdac[15:12] = config_bits[IBIAS_TDAC][3:0];
    ibias_tdac[11:8] = config_bits[IBIAS_TDAC][3:0];
    ibias_tdac[7:4] = config_bits[IBIAS_TDAC][3:0];
    ibias_tdac[3:0] = config_bits[IBIAS_TDAC][3:0];
    ibias_comp[15:12] = config_bits[IBIAS_COMP][3:0];
    ibias_comp[11:8] = config_bits[IBIAS_COMP][3:0];
    ibias_comp[7:4] = config_bits[IBIAS_COMP][3:0];
    ibias_comp[3:0] = config_bits[IBIAS_COMP][3:0];
    ibias_buffer[15:12] = config_bits[IBIAS_BUFFER][3:0];
    ibias_buffer[11:8] = config_bits[IBIAS_BUFFER][3:0];
    ibias_buffer[7:4] = config_bits[IBIAS_BUFFER][3:0];
    ibias_buffer[3:0] = config_bits[IBIAS_BUFFER][3:0];
    ibias_csa[15:12] = config_bits[IBIAS_CSA][3:0];
    ibias_csa[11:8] = config_bits[IBIAS_CSA][3:0];
    ibias_csa[7:4] = config_bits[IBIAS_CSA][3:0];
    ibias_csa[3:0] = config_bits[IBIAS_CSA][3:0];
    ibias_vref_buffer = config_bits[IBIAS_VREF][3:0];
    ibias_vcm_buffer = config_bits[IBIAS_VCM][3:0];
    ibias_tpulse[3:0] = config_bits[IBIAS_TPULSE][3:0];
    ref_current_trim = config_bits[REFGEN][4:0];
    override_ref = config_bits[REFGEN][5];
    ref_kickstart = config_bits[REFGEN][6];
    vref_dac = config_bits[DAC_VREF][7:0];
    vcm_dac = config_bits[DAC_VCM][7:0];
    csa_testpulse_dac = config_bits[CSA_TEST_DAC][7:0]; //DG: mod
    current_monitor_bank0 = config_bits[IMONITOR0][3:0];
    current_monitor_bank1 = config_bits[IMONITOR1][3:0];
    current_monitor_bank2 = config_bits[IMONITOR2][3:0];
    current_monitor_bank3 = config_bits[IMONITOR3][3:0];
    voltage_monitor_bank0 = config_bits[VMONITOR0][2:0];
    voltage_monitor_bank1 = config_bits[VMONITOR1][2:0];
    voltage_monitor_bank2 = config_bits[VMONITOR2][2:0];
    voltage_monitor_bank3 = config_bits[VMONITOR3][2:0];
    voltage_monitor_refgen = config_bits[VMONITOR4][7:0];
    digital_monitor_enable = config_bits[DMONITOR0][0];
    digital_monitor_select = config_bits[DMONITOR0][4:1];
    digital_monitor_chan = config_bits[DMONITOR1][5:0];
    chip_id = config_bits[CHIP_ID][7:0];
    enable_tx_dynamic_powerdown  = config_bits[DIGITAL][0];
    load_config_defaults = config_bits[DIGITAL][1];
    enable_fifo_diagnostics = config_bits[DIGITAL][2];
    clk_ctrl = config_bits[DIGITAL][4:3];
    tx_dynamic_powerdown_cycles = config_bits[DIGITAL][7:5];
    enable_piso_upstream = config_bits[ENABLE_PISO_UP][3:0];
    enable_piso_downstream = config_bits[ENABLE_PISO_DOWN][3:0];
    enable_posi = config_bits[ENABLE_POSI][3:0];
    test_mode_uart0 = config_bits[UART_TEST_MODE][1:0];
    test_mode_uart1 = config_bits[UART_TEST_MODE][3:2];
    test_mode_uart2 = config_bits[UART_TEST_MODE][5:4];
    test_mode_uart3 = config_bits[UART_TEST_MODE][7:6]; 
    enable_cross_trigger = config_bits[ENABLE_TRIG_MODES][0];
    enable_periodic_reset = config_bits[ENABLE_TRIG_MODES][1];
    enable_rolling_periodic_reset = config_bits[ENABLE_TRIG_MODES][2];
    enable_periodic_trigger = config_bits[ENABLE_TRIG_MODES][3];
    enable_rolling_periodic_trigger = config_bits[ENABLE_TRIG_MODES][4];
    enable_periodic_trigger_veto = config_bits[ENABLE_TRIG_MODES][5];
    enable_hit_veto = config_bits[ENABLE_TRIG_MODES][6];
    adc_hold_delay[7:0] = config_bits[ADC_HOLD_DELAY][7:0];
    shadow_reset_length = config_bits[SHADOW_RESET_LENGTH][7:0];
    adc_hold_delay[15:8] = config_bits[ADC_HOLD_DELAY+1][7:0];
    adc_burst_length = config_bits[ADC_BURST][7:0];
    enable_dynamic_reset = config_bits[ENABLE_ADC_MODES][0];
    enable_min_delta_adc = config_bits[ENABLE_ADC_MODES][1];
    threshold_polarity = config_bits[ENABLE_ADC_MODES][2];
    reset_length = config_bits[ENABLE_ADC_MODES][5:3];
    mark_first_packet = config_bits[ENABLE_ADC_MODES][6];
    dynamic_reset_threshold = config_bits[RESET_THRESHOLD][7:0];
    min_delta_adc = config_bits[MIN_DELTA_ADC][7:0];
    lightpix_mode = config_bits[LIGHTPIX0][0];
    hit_threshold = config_bits[LIGHTPIX0][7:1];
    timeout = config_bits[LIGHTPIX1][7:0];
    tx_slices0 = config_bits[TRX0][3:0];
    tx_slices1 = config_bits[TRX0][7:4];
    tx_slices2 = config_bits[TRX1][3:0];
    tx_slices3 = config_bits[TRX1][7:4];
    i_tx_diff0 = config_bits[TRX2][3:0];
    i_tx_diff1 = config_bits[TRX2][7:4];
    i_tx_diff2 = config_bits[TRX3][3:0];
    i_tx_diff3 = config_bits[TRX3][7:4];
    i_rx0 = config_bits[TRX4][3:0];
    i_rx1 = config_bits[TRX4][7:4];
    i_rx2 = config_bits[TRX5][3:0];
    i_rx3 = config_bits[TRX5][7:4];
    i_rx_clk = config_bits[TRX6][3:0];
    i_rx_rst = config_bits[TRX6][7:4];
    i_rx_ext_trig = config_bits[TRX7][7:4];
    r_term0 = config_bits[TRX8][4:0];
    r_term1 = config_bits[TRX9][4:0];
    r_term2 = config_bits[TRX10][4:0];
    r_term3 = config_bits[TRX11][4:0];
    r_term_clk = config_bits[TRX12][4:0];
    r_term_rst = config_bits[TRX13][4:0];
    r_term_ext_trig = config_bits[TRX14][4:0];
    v_cm_lvds_tx0 = config_bits[TRX15][3:0];
    v_cm_lvds_tx1 = config_bits[TRX15][7:4];
    v_cm_lvds_tx2 = config_bits[TRX16][3:0];
    v_cm_lvds_tx3 = config_bits[TRX16][7:4]; 

end // always_comb
// combine reset length

always_comb begin
    reset_length_channel = {5'b0,reset_length} | shadow_reset_length;
end
 // always_comb

// combine UART test modes
always_comb begin
    test_mode =
        {test_mode_uart3,test_mode_uart2,test_mode_uart1,test_mode_uart0};
end // always_comb

// cross trigger
always_comb begin
    cross_trigger = |triggered_natural;
end // always_comb

// reset logic
always_comb begin
    for (int i=0; i<NUMCHANNELS; i=i+1) begin 
        csa_reset[i] = csa_reset_channel[i] | !csa_enable[i];
    end
end // always_comb

// TX PHY enable
//always_comb begin
//    tx_enable = enable_piso_upstream | enable_piso_downstream;
//end

// tx PHY power down 


external_interface
    #(.NUMREGS(NUMREGS),
    ) external_interface_inst (
    .config_bits            (config_bits),
    .piso                   (piso),
    .posi                   (posi),
    .clk                    (clk),
    .reset_n                (reset_n),
    );

endmodule
