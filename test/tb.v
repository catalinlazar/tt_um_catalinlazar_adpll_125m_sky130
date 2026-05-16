`default_nettype none
`timescale 1ns / 1ps

module tb ();

  reg proto_clk = 0;
  always #10 proto_clk = ~proto_clk;

  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;
  reg ena;
  reg rst_n;

  tt_um_catalinlazar_adpll_125m_sky130 user_project (
      .ui_in  (ui_in),   
      .uo_out (uo_out),  
      .uio_in (uio_in),  
      .uio_out(uio_out), 
      .uio_oe (uio_oe),  
      .ena    (ena),     
      .clk    (proto_clk),
      .rst_n  (rst_n)    
  );

endmodule
