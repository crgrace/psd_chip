///////////////////////////////////////////////////////////////////
// File Name: psd_chip_constants.sv
// Engineer:  Carl Grace (crgrace@lbl.gov)
// Description:  Constants for PSD_CHIP operation and simulation
//          
///////////////////////////////////////////////////////////////////

`ifndef _psd_chip_constants_
`ifndef SYNTHESIS 
`define _psd_chip_constants_
`endif

// declare needed variables
localparam TRUE = 1;
localparam FALSE = 0;
localparam SILENT = 0;
localparam VERBOSE = 1;          // high to print out verification results

// localparams to define config registers
// configuration word definitions
localparam CHANNEL_DISABLE = 0;
localparam BUFF_REF0 = 1;
localparam BUFF_REF1 = 2;
localparam BUFF_REF2 = 3;
localparam BUFF_REF3 = 4;
localparam BUFF_REF4 = 5;
localparam FINE_REFP = 6;
localparam FINE_REFN = 7;
localparam D2S_REF0 = 8;
localparam D2S_REF1 = 9;
localparam D2S_REF2 = 10;
localparam D2S_REF3 = 11;
localparam THRESH_SOUT_GLOBAL = 12;
localparam THRESH_SOUT_FINE0 = 13;
localparam THRESH_SOUT_FINE1 = 14;
localparam THRESH_SOUT_FINE2 = 15;
localparam THRESH_SOUT_FINE3 = 16;
localparam THRESH_FOUT_GLOBAL = 17;
localparam THRESH_FOUT_FINE0 = 18;
localparam THRESH_FOUT_FINE1 = 19;
localparam THRESH_FOUT_FINE2 = 20;
localparam THRESH_FOUT_FINE3 = 21;
localparam IBIAS_TOTAL_INT = 22;
localparam IBIAS_PARTIAL_INT = 23;
localparam IBIAS_HOLD = 24;
localparam IBIAS_HOLD_DELAY = 25;
localparam IBIAS_SOUT_DELAY = 26;
localparam IBIAS_FOUT_WIDTH = 27;
localparam IBIAS_SOUT_COMP_WIDTH = 28;
localparam TUNABLE_RES_TOTAL_INT = 29;
localparam TUNABLE_RES_SUBTR_GAIN = 31;
localparam DIGITAL_TESTBUS0 = 32;
localparam DIGITAL_TESTBUS1 = 33;
localparam DIGITAL_TESTBUS2 = 34;
localparam DIGITAL_TESTBUS3 = 35;
localparam LVDS = 36;
localparam TRIGGER = 37;
localparam IMONITOR = 38;
localparam VMONITOR = 39;
localparam SPARE0 = 40;
localparam SPARE1 = 41;

// UART ops
localparam WRITE = 1;
localparam READ = 0;


`endif // _psd_chip_constants_
