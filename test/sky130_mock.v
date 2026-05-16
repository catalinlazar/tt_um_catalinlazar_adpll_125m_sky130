`timescale 1ns/1ps
`default_nettype none

// Simulation mock models for structural primitives used in the ADPLL
module sky130_fd_sc_hd__inv_1 (
    input  wire A,
    output wire Y
);
    // 50 ps delay ensures clean oscillation in Icarus Verilog
    assign #0.05 Y = ~A;
endmodule

module sky130_fd_sc_hd__nand2_1 (
    input  wire A,
    input  wire B,
    output wire Y
);
    assign #0.06 Y = ~(A & B);
endmodule

module sky130_fd_sc_hd__mux2_1 (
    input  wire A0,
    input  wire A1,
    input  wire S,
    output wire X
);
    assign #0.08 X = S ? A1 : A0;
endmodule