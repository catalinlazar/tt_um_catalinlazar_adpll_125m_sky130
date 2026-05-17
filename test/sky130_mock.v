// Example for the inverter cell
module sky130_fd_sc_hd__inv_1 (
    output Y,
    input A,
    input VPWR,
    input VGND,
    input VPB,
    input VNB
);
    assign Y = ~A;
endmodule

// Example for the NAND cell (adjust if your module name differs)
module sky130_fd_sc_hd__nand2_1 (
    output Y,
    input A,
    input B,
    input VPWR,
    input VGND,
    input VPB,
    input VNB
);
    assign Y = ~(A & B);
endmodule

// Example for the MUX cell used by U_tap_mux
module sky130_fd_sc_hd__mux2_1 (
    output X,
    input A0,
    input A1,
    input S,
    input VPWR,
    input VGND,
    input VPB,
    input VNB
);
    assign X = S ? A1 : A0;
endmodule