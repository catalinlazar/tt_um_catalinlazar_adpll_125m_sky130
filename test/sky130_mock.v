`timescale 1ns/1ps
`default_nettype none

// 1. Gated Control Primitive Inverter Cell
module sky130_fd_sc_hd__inv_1 (
    output wire Y,
    input  wire A,
    input  wire VPWR,
    input  wire VGND,
    input  wire VPB,
    input  wire VNB
);
    // 100ps propagation delay to allow time progression in ring structures
    assign #0.1 Y = ~A;
endmodule

// 2. Gated Control Primitive NAND Gate
module sky130_fd_sc_hd__nand2_1 (
    output wire Y,
    input  wire A,
    input  wire B,
    input  wire VPWR,
    input  wire VGND,
    input  wire VPB,
    input  wire VNB
);
    // 100ps propagation delay to prevent simulator lock-up on feedback loop enable
    assign #0.1 Y = ~(A & B);
endmodule

// 3. Dynamic Structural Tap Selector MUX Cell (U_tap_mux)
module sky130_fd_sc_hd__mux2_1 (
    output wire X,
    input  wire A0,
    input  wire A1,
    input  wire S,
    input  wire VPWR,
    input  wire VGND,
    input  wire VPB,
    input  wire VNB
);
    // 100ps propagation delay ensures switching between taps advances time cleanly
    assign #0.1 X = S ? A1 : A0;
endmodule