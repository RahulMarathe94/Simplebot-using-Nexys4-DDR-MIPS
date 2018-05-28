// mfp_nexys4_ddr.v
// Project Name: SimpleBot
// Target Devices: Nexys4 DDR
// January 25th, 2018
// Rahul Marathe, Kiyasul Arif
// Instantiate the mipsfpga system and rename signals to
// match the GPIO, LEDs and switches on Digilent's (Xilinx)
// Nexys4 DDR board

// Outputs:
// 16 LEDs (IO_LED) 
// Seven Segement Display and Seven Segment Decimal Point
// Inputs:
// 5 Pushbuttons (IO_PB): {BTNU, BTND, BTNL, BTNC, BTNR}
//////////////////////////////////////////////////////////////////

`include "mfp_ahb_const.vh"

module mfp_nexys4_ddr( 
                        input                      CLK100MHZ,
                        input                      CPU_RESETN,
                        input                      BTNU, BTND, BTNL, BTNC, BTNR, 
                        input   [`MFP_N_SW-1 :0]   SW,
                        output  [`MFP_N_LED-1:0]   LED,
                        output  [7:           0]   AN,                     // Enables for the 7 Segment 
                        output                     DP,                     // Enables for the Decimal Points
                        output                     CA,CB,CC,CD,CE,CF,CG,   // Common Cathode Segments for the Seven Segments 
                        inout   [ 8          :1]   JB,
                        input                      UART_TXD_IN
                        );

  // Press btnCpuReset to reset the processor. 
        
  wire clk_out; 
  wire tck_in, tck;
  
  clk_wiz_0 clk_wiz_0(.clk_in1(CLK100MHZ), .clk_out1(clk_out)); 
  IBUF IBUF1(.O(tck_in),.I(JB[4]));
  BUFG BUFG1(.O(tck), .I(tck_in));

  mfp_sys mfp_sys(
			        .SI_Reset_N(CPU_RESETN),
                    .SI_ClkIn(clk_out),
                    .HADDR(),
                    .HRDATA(),
                    .HWDATA(),
                    .HWRITE(),
					.HSIZE(),
                    .EJ_TRST_N_probe(JB[7]),
                    .EJ_TDI(JB[2]),
                    .EJ_TDO(JB[3]),
                    .EJ_TMS(JB[1]),
                    .EJ_TCK(tck),
                    .SI_ColdReset_N(JB[8]),
                    .EJ_DINT(1'b0),
                    .IO_Switch(SW),
                    .IO_PB({BTNU, BTND, BTNL, BTNC, BTNR}),
                    .IO_LED(LED),
                    .IO_7SEGEN_N(AN),                          // The Enables
                    .IO_7SEG_N({CA,CB,CC,CD,CE,CF,CG}),        // The 7 Common Cathodes
                    .IO_7SEG_DP(DP),                           // The Enable for Decimal Points
                    .UART_RX(UART_TXD_IN));
          
endmodule
