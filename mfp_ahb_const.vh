// 
// mfp_ahb_const.vh
// Jan 25th, 2018
// Project Name: SimpleBot
// Target Devices: Nexys4 DDR
// Verilog include file with AHB definitions
// Rahul Marathe, Kiyasul Arif 
//
//---------------------------------------------------
// Physical bit-width of memory-mapped I/O interfaces
//---------------------------------------------------
`define MFP_N_LED             16
`define MFP_N_SW              16
`define MFP_N_PB              6            /// PUSHBUTTON WIDTH
`define MFP_N_7SEGEN          8            ///ENABLE WIDTH
 

//---------------------------------------------------
// Memory-mapped I/O addresses
//---------------------------------------------------
`define H_LED_ADDR    			(32'h1f800000)
`define H_SW_ADDR   			(32'h1f800004)
`define H_PB_ADDR   			(32'h1f800008)

`define H_7SEGEN_N              (32'h1f700000)        //// Physical Address of Register which is mapped to Seven Segment Enable
`define H_7SEG_HIGH             (32'h1f700004)        //// Physical Address of Register which is mapped to the Upper 32 bits of the Seven Segment 
`define H_7SEG_LOW              (32'h1f700008)        //// Physical Address of Register which is mapped to the Lower 32 bits of the Seven Segment 
`define H_SEG_DP                (32'h1f70000C)        //// Physical Address of Register which is mapped to the Decimal Point Enable


//////////////////////////////////////////////////////

`define H_LED_IONUM   			(4'h0)   
`define H_SW_IONUM  			(4'h1)
`define H_PB_IONUM  			(4'h2)

`define H_7SEGEN_IONUM          (4'h0)               //// CONSIDERING BITS 5:2 OF HADDR 
`define H_7SEG_DP_IONUM         (4'h3)               //// CONSIDERING BITS 5:2 OF HADDR 
`define H_7SEGHIGH_IONUM        (4'h1)               //// CONSIDERING BITS 5:2 OF HADDR 
`define H_7SEGLOW_IONUM         (4'h2)               //// CONSIDERING BITS 5:2 OF HADDR 

//---------------------------------------------------
// RAM addresses
//---------------------------------------------------
`define H_RAM_RESET_ADDR 		(32'h1fc?????)
`define H_RAM_ADDR	 		    (32'h0???????)
`define H_RAM_RESET_ADDR_WIDTH  (8) 
`define H_RAM_ADDR_WIDTH		(16) 

`define H_RAM_RESET_ADDR_Match  (7'h7f)
`define H_RAM_ADDR_Match 		(1'b0)
`define H_LED_ADDR_Match		(7'h7e)
`define H_7SEG_ADDR_Match       (7'h7d) 

//---------------------------------------------------
// AHB-Lite values used by MIPSfpga core
//---------------------------------------------------

`define HTRANS_IDLE    2'b00
`define HTRANS_NONSEQ  2'b10
`define HTRANS_SEQ     2'b11

`define HBURST_SINGLE  3'b000
`define HBURST_WRAP4   3'b010

`define HSIZE_1        3'b000
`define HSIZE_2        3'b001
`define HSIZE_4        3'b010
