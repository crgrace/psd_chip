///////////////////////////////////////////////////////////////////
// File Name: digital_core_tb.sv
// Engineer:  Carl Grace (crgrace@lbl.gov)
// Description: SystemVerilog testbench for digital_core.sv.
//              The purpose of the digital_core is to read 
//              and write the regfile and send the config bits
//              to the analog core. 
//
//          UART packet definition:
//  bit:      17       16:9         8:1       0 
//                  |          |          |
//          parity     addr        data      wrb  
// 
///////////////////////////////////////////////////////////////////


module digital_core_tb();
    timeunit 1ns/10ps;
    localparam NUMREGS = 32;

// config bits

logic [3:0] disable_channel; // high to power down channel
logic [3:0] enable_replica; // high to use replica circuits
logic [7:0] v_buff_ref_global; // global ref for both int stages
logic [7:0] v_buff_ref_fine0; // fine ref for both int stages
logic [7:0] v_buff_ref_fine1; // fine ref for both int stages
logic [7:0] v_buff_ref_fine2; // fine ref for both int stages
logic [7:0] v_buff_ref_fine3; // fine ref for both int stages
logic [7:0] v_ref_comp0; // opamp ref voltage
logic [7:0] v_ref_comp1; // opamp ref voltage
logic [7:0] v_ref_comp2; // opamp ref voltage
logic [7:0] v_ref_comp3; // opamp ref voltage
logic [7:0] v_comp_thresh_sout_global; // SOUT disc. thresh
logic [7:0] v_comp_thresh_sout_fine0; // SOUT disc. thresh
logic [7:0] v_comp_thresh_sout_fine1; // SOUT disc. thresh
logic [7:0] v_comp_thresh_sout_fine2; // SOUT disc. thresh
logic [7:0] v_comp_thresh_sout_fine3; // SOUT disc. thresh
logic [7:0] v_comp_thresh_fout_global; // FOUT disc. thresh
logic [7:0] v_comp_thresh_fout_fine0; // FOUT disc. thresh
logic [7:0] v_comp_thresh_fout_fine1; // FOUT disc. thresh
logic [7:0] v_comp_thresh_fout_fine2; // FOUT disc. thresh
logic [7:0] v_comp_thresh_fout_fine3; // FOUT disc. thresh
logic [3:0] i_bias_total_int; // delay bias for total int
logic [3:0] i_bias_partial_int; // delay bias for partial int
logic [3:0] i_bias_disc; // bias current for discriminator
logic [3:0] i_bias_disc_sout_delay; // delay for disc output
logic [3:0] i_bias_fout_width_trim; // std width trim
logic sel_std_sout_comp_width; // high for std width
logic [3:0] i_bias_lvds; // sets lvds loop current
logic [7:0] tunable_res_total_int; // adjust resistor value
logic [7:0] tunable_res_subtr_gain; // adjust resistor value
logic [2:0] digital_testbus0_sel; // select signal to testbus0
logic digital_testbus0_en; // enable testbus0
logic [2:0] digital_testbus1_sel; // select signal to testbus1
logic digital_testbus1_en; // enable testbus1
logic [3:0] external_trigger_enable; // high to en ext trig
logic [3:0] cross_trigger_enable; // high to en cross trig
logic [7:0] current_monitor; // measure internal currents
logic [7:0] voltage_monitor; // measure internal voltages
logic [3:0] spare0; // 4 spare config bits
logic [3:0] spare1; // 4 spare config bits


// local digital_signals

logic reset_n;          // active low reset
logic clk;           // system clock (sent to PSD_CHIP)
logic clk_free_running;       // clock ANDed with en to get system clk
logic clk_en;       // high to enable clk

// uart
logic piso;     // output from current chip (input to FPGA)
logic posi;     // input to current chip (output from FPGA)
logic posi_tx;     // (output from FPGA)
logic posi_tx_en; // high to enable posi
// regfile variables
logic [7:0] config_bits [0:NUMREGS-1]; // output bits

// external FPGA signals
logic txclk_fpga; // clock used to define data sent to PSD_CHIP
logic tx_busy_fpga;
logic ld_tx_data_fpga;
logic [17:0] tx_data_fpga;
logic rx_empty_fpga;
logic uld_rx_data_fpga;
logic [17:0] rx_data_fpga;

// parse rx data

logic [17:0] receivedData;
logic rcvd_wrb;
logic [7:0] rcvd_data_word;
logic [7:0] rcvd_data_address;
logic rcvd_parity_bit;
logic first; // suppress first readout
logic verbose;
`include "../tasks/uart_tasks.sv"
`include "../tasks/uart_tests.sv"

       
initial begin
    verbose = FALSE;
    reset_n = 1;
    clk_free_running = 0;
    txclk_fpga = 0;
    ld_tx_data_fpga = 0;
    receivedData = 0;
    uld_rx_data_fpga = 1'b0;
    first = 1;
    posi_tx_en = 1;
    clk_en = 0;
// reset DUT
    #10 reset_n = 0;
    #100 reset_n = 1;
    
//    regfileOpUART(WRITE,8'h01,8'hab);

//#2000 regfileOpUART(READ,8'h01,8'h00);
//    testExternalInterfaceUART(8'hab);
#1000      randomTestExternalInterface(100);

// test RX rejection of run start bit
    #1000 clk_en = 1;
    #1000 $display("Testing runt start bit rejection");
    posi_tx_en = 0;
    #15 posi_tx_en = 1;
    #1000 clk_en = 0;
    $display("all testing complete");
end  // initial

always_comb begin
    posi = posi_tx & posi_tx_en;
    clk = clk_free_running & clk_en;
end // always_comb

// system clock generator
initial begin
    forever begin
      #5 clk_free_running = ~clk_free_running;
    end
end  // initial

initial begin
    forever begin
        // this is the clock that controls the data being sent out   
        #80 txclk_fpga = ~txclk_fpga; // 1/16th speed of clk
    end
end // initial

// read out FPGA received UART
always @(negedge rx_empty_fpga) begin

    @(posedge txclk_fpga);
        uld_rx_data_fpga = 1'b1;
    @(posedge clk);
        uld_rx_data_fpga = 1'b0;
    @(posedge clk);
        receivedData = rx_data_fpga;
    
end // always
 
always_comb begin
    rcvd_wrb = receivedData[0];
    rcvd_data_word = receivedData[8:1];
    rcvd_data_address = receivedData[16:9];
    rcvd_parity_bit = receivedData[17];
end

always @(receivedData) begin
    if (first) begin
        first = 0;
    end
    else begin
        if (verbose) begin
            #10 $display("UART data received:");
            $display("rcvd_data_address = 0x%h", rcvd_data_address);
            $display("rcvd_data_word = 0x%h",rcvd_data_word);
            $display("wrb = 0x%h",rcvd_wrb);
            $display("parity bit = 0x%h",rcvd_parity_bit);
        end
    end
end
// DUT

digital_core
    digital_core_inst
    (.piso                      (piso),
    .disable_channel            (disable_channel),
    .enable_replica             (enable_replica),
    .v_buff_ref_global          (v_buff_ref_global),
    .v_buff_ref_fine0           (v_buff_ref_fine0),
    .v_buff_ref_fine1           (v_buff_ref_fine1),
    .v_buff_ref_fine2           (v_buff_ref_fine2),
    .v_buff_ref_fine3           (v_buff_ref_fine3),
    .v_ref_comp0                (v_ref_comp0),
    .v_ref_comp1                (v_ref_comp1),
    .v_ref_comp2                (v_ref_comp2),
    .v_ref_comp3                (v_ref_comp3),
    .v_comp_thresh_sout_global  (v_comp_thresh_sout_global),
    .v_comp_thresh_sout_fine0   (v_comp_thresh_sout_fine0),
    .v_comp_thresh_sout_fine1   (v_comp_thresh_sout_fine1),
    .v_comp_thresh_sout_fine2   (v_comp_thresh_sout_fine2),
    .v_comp_thresh_sout_fine3   (v_comp_thresh_sout_fine3),
    .v_comp_thresh_fout_global  (v_comp_thresh_fout_global),
    .v_comp_thresh_fout_fine0   (v_comp_thresh_fout_fine0),
    .v_comp_thresh_fout_fine1   (v_comp_thresh_fout_fine1),
    .v_comp_thresh_fout_fine2   (v_comp_thresh_fout_fine2),
    .v_comp_thresh_fout_fine3   (v_comp_thresh_fout_fine3),
    .i_bias_total_int           (i_bias_total_int),
    .i_bias_partial_int         (i_bias_partial_int),
    .i_bias_disc                (i_bias_disc),
    .i_bias_disc_sout_delay     (i_bias_disc_sout_delay),
    .i_bias_fout_width_trim     (i_bias_fout_width_trim),
    .sel_std_sout_comp_width    (sel_std_sout_comp_width),
    .i_bias_lvds                (i_bias_lvds),
    .tunable_res_total_int      (tunable_res_total_int),
    .tunable_res_subtr_gain     (tunable_res_subtr_gain),
    .digital_testbus0_sel       (digital_testbus0_sel),
    .digital_testbus0_en        (digital_testbus0_en),
    .digital_testbus1_sel       (digital_testbus1_sel),
    .digital_testbus1_en        (digital_testbus1_en),
    .external_trigger_enable    (external_trigger_enable),
    .cross_trigger_enable       (cross_trigger_enable),
    .current_monitor            (current_monitor),
    .voltage_monitor            (voltage_monitor),
    .spare0                     (spare0),
    .spare1                     (spare1),
    .posi                       (posi),
    .clk                        (clk),
    .reset_n                    (reset_n)
    );

// external UART RX & TX models FPGA interface
uart_tx
    uart_tx_FPGA_inst
    (.tx_out        (posi_tx),
    .tx_busy        (tx_busy_fpga),
    .tx_data        (tx_data_fpga),
    .ld_tx_data     (ld_tx_data_fpga),
    .txclk          (txclk_fpga),
    .reset_n        (reset_n)
    );

uart_rx
    uart_rx_FPGA_inst
    (.rx_data       (rx_data_fpga),
    .rx_empty       (rx_empty_fpga),
    .rx_in          (piso),
    .uld_rx_data    (uld_rx_data_fpga),
    .rxclk          (clk),
    .reset_n        (reset_n)
    );

endmodule
