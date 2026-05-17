`timescale 1ns/1ps
`default_nettype none

// 1. Inverter for the 126 loop stages
module sky130_fd_sc_hd__inv_1 (
    input  wire A,
    output wire Y
);
    assign #0.05 Y = ~A;
endmodule

// 2. NAND gate for the DCO enable gate (Stage 0)
module sky130_fd_sc_hd__nand2_1 (
    input  wire A,
    input  wire B,
    output wire Y
);
    assign #0.06 Y = ~(A & B);
endmodule

// 3. Multiplexer for the coarse tap selection
module sky130_fd_sc_hd__mux2_1 (
    input  wire A0,
    input  wire A1,
    input  wire S,
    output wire X
);
    assign #0.08 X = S ? A1 : A0;
endmodule