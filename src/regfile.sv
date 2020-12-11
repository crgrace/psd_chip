///////////////////////////////////////////////////////////////////
// File Name: regfile.sv
// Engineer:  Carl Grace (crgrace@lbl.gov)
// Description: Dual-port register file for configuration bits 
//              Regfile has address space for 
//              256 distinct 8-bit registers
//
///////////////////////////////////////////////////////////////////

module regfile
    #(parameter NUMREGS = 16)
    (output logic [7:0] config_bits [0:NUMREGS-1], // output bits
    output logic [7:0] read_data,           // RAM data out (for readback)
    input logic [7:0] write_addr,           // RAM write address 
    input logic [7:0] write_data,           // RAM data in
    input logic [7:0] read_addr,            // RAM read address 
    input logic write,                      // high for write op
    input logic read,                       // high for read op
    input logic reset_n                     // digital reset (active low)
);

// configuration word definitions
// located at ../testbench/psd_chip/
// example compilation: 
//vlog +incdir+../testbench/psd_chip/ -incr -sv "../src/digital_core.sv"
`include "psd_chip_constants.sv"

always_ff @(posedge read or negedge reset_n) begin
    if (!reset_n) begin
        read_data <= 8'b0;
    end 
    else begin
        read_data <= config_bits[read_addr];
    end    // else
end // always_ff

always_ff @(posedge write or negedge reset_n) begin
    if (!reset_n) begin
        // SET DEFAULTS
        for (int i = 0; i < NUMREGS; i++) begin
            config_bits[i] = 8'h0;
        end // for 
//`include "config_regfile_assign.sv" // in ../testbench/larpix_tasks
    end 
    else begin
        config_bits[write_addr] <= write_data;
    end    // else
end // always_ff

endmodule
                
        

