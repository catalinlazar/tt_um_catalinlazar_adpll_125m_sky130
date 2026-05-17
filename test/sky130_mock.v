`timescale 1ns/1ps
`default_nettype none

module sky130_fd_sc_hd__inv_1 (
    output wire Y,
    input  wire A,
    // Default values allow these pins to be omitted in RTL instantiations
    input  wire VPWR = 1'b1,
    input  wire VGND = 1'b0,
    input  wire VPB  = 1'b1,
    input  wire VNB  = 1'b0
);
    assign #0.1 Y = ~A;
endmodule

module sky130_fd_sc_hd__nand2_1 (
    output wire Y,
    input  wire A,
    input  wire B,
    input  wire VPWR = 1'b1,
    input  wire VGND = 1'b0,
    input  wire VPB  = 1'b1,
    input  wire VNB  = 1'b0
);
    assign #0.1 Y = ~(A & B);
endmodule

module sky130_fd_sc_hd__mux2_1 (
    output wire X,
    input  wire A0,
    input  wire A1,
    input  wire S,
    input  wire VPWR = 1'b1,
    input  wire VGND = 1'b0,
    input  wire VPB  = 1'b1,
    input  wire VNB  = 1'b0
);
    assign #0.1 X = S ? A1 : A0;
endmodule