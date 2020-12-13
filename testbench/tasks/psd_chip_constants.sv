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
localparam D2S_REF0 = 6;
localparam D2S_REF1 = 7;
localparam D2S_REF2 = 8;
localparam D2S_REF3 = 9;
localparam THRESH_SOUT_GLOBAL = 10;
localparam THRESH_SOUT_FINE0 = 11;
localparam THRESH_SOUT_FINE1 = 12;
localparam THRESH_SOUT_FINE2 = 13;
localparam THRESH_SOUT_FINE3 = 14;
localparam THRESH_FOUT_GLOBAL = 15;
localparam THRESH_FOUT_FINE0 = 16;
localparam THRESH_FOUT_FINE1 = 17;
localparam THRESH_FOUT_FINE2 = 18;
localparam THRESH_FOUT_FINE3 = 19;
localparam IBIAS_TOTAL_INT = 20;
localparam IBIAS_PARTIAL_INT = 21;
localparam IBIAS_DISC = 22;
localparam IBIAS_DISC_OUT = 23;
localparam IBIAS_FOUT_WIDTH = 24;
localparam IBIAS_LVDS = 25;
localparam TUNABLE_RES_TOTAL_INT = 26;
localparam TUNABLE_RES_SUBTR_GAIN = 27;
localparam DIGITAL_TESTBUS = 28;
localparam TRIGGER = 29;
localparam IMONITOR = 30;
localparam VMONITOR = 31;

// UART ops
localparam WRITE = 1;
localparam READ = 0;


`endif // _psd_chip_constants_
