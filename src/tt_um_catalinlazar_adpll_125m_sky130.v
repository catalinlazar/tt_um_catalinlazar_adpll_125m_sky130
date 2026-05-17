`default_nettype none

module tt_um_catalinlazar_adpll_125m_sky130 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, for running a clock
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - active low
);

    // Power/Substrate wires for explicit structural cell hooks
    wire vccd1 = 1'b1; // Digital Power (VPWR/VPB)
    wire vssd1 = 1'b0; // Digital Ground (VGND/VNB)

    // Unused bidirectional paths tied safely to low
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

    // Tie off unused high outputs to prevent floating/un-driven netlist errors
    assign uo_out[7:3] = 5'b00000;

    // Status Tracking Signal
    assign uo_out[2] = ena;

    // Structural Ring-Oscillator Loop Node Definitions
    wire nand_out;
    wire [13:0] inv_chain;

    // 1. Gated Control Primitive NAND Gate
    sky130_fd_sc_hd__nand2_1 U_nand_0 (
        .Y(nand_out),
        .A(ui_in[5]),
        .B(inv_chain[13]),
        .VPWR(vccd1),
        .VGND(vssd1),
        .VPB(vccd1),
        .VNB(vssd1)
    );

    // 2. Feedback Inverter Delay Chain
    sky130_fd_sc_hd__inv_1 U_inv_0  (.Y(inv_chain[0]),  .A(nand_out),     .VPWR(vccd1), .VGND(vssd1), .VPB(vccd1), .VNB(vssd1));
    sky130_fd_sc_hd__inv_1 U_inv_1  (.Y(inv_chain[1]),  .A(inv_chain[0]),  .VPWR(vccd1), .VGND(vssd1), .VPB(vccd1), .VNB(vssd1));
    sky130_fd_sc_hd__inv_1 U_inv_2  (.Y(inv_chain[2]),  .A(inv_chain[1]),  .VPWR(vccd1), .VGND(vssd1), .VPB(vccd1), .VNB(vssd1));
    sky130_fd_sc_hd__inv_1 U_inv_3  (.Y(inv_chain[3]),  .A(inv_chain[2]),  .VPWR(vccd1), .VGND(vssd1), .VPB(vccd1), .VNB(vssd1));
    sky130_fd_sc_hd__inv_1 U_inv_4  (.Y(inv_chain[4]),  .A(inv_chain[3]),  .VPWR(vccd1), .VGND(vssd1), .VPB(vccd1), .VNB(vssd1));
    sky130_fd_sc_hd__inv_1 U_inv_5  (.Y(inv_chain[5]),  .A(inv_chain[4]),  .VPWR(vccd1), .VGND(vssd1), .VPB(vccd1), .VNB(vssd1));
    sky130_fd_sc_hd__inv_1 U_inv_6  (.Y(inv_chain[6]),  .A(inv_chain[5]),  .VPWR(vccd1), .VGND(vssd1), .VPB(vccd1), .VNB(vssd1));
    sky130_fd_sc_hd__inv_1 U_inv_7  (.Y(inv_chain[7]),  .A(inv_chain[6]),  .VPWR(vccd1), .VGND(vssd1), .VPB(vccd1), .VNB(vssd1));
    sky130_fd_sc_hd__inv_1 U_inv_8  (.Y(inv_chain[8]),  .A(inv_chain[7]),  .VPWR(vccd1), .VGND(vssd1), .VPB(vccd1), .VNB(vssd1));
    sky130_fd_sc_hd__inv_1 U_inv_9  (.Y(inv_chain[9]),  .A(inv_chain[8]),  .VPWR(vccd1), .VGND(vssd1), .VPB(vccd1), .VNB(vssd1));
    sky130_fd_sc_hd__inv_1 U_inv_10 (.Y(inv_chain[10]), .A(inv_chain[9]),  .VPWR(vccd1), .VGND(vssd1), .VPB(vccd1), .VNB(vssd1));
    sky130_fd_sc_hd__inv_1 U_inv_11 (.Y(inv_chain[11]), .A(inv_chain[10]), .VPWR(vccd1), .VGND(vssd1), .VPB(vccd1), .VNB(vssd1));
    sky130_fd_sc_hd__inv_1 U_inv_12 (.Y(inv_chain[12]), .A(inv_chain[11]), .VPWR(vccd1), .VGND(vssd1), .VPB(vccd1), .VNB(vssd1));
    sky130_fd_sc_hd__inv_1 U_inv_13 (.Y(inv_chain[13]), .A(inv_chain[12]), .VPWR(vccd1), .VGND(vssd1), .VPB(vccd1), .VNB(vssd1));

    // Raw Controlled Digitally Controlled Oscillator Clock output
    wire raw_dco_clk;
    assign uo_out[1] = raw_dco_clk;

    // 3. Tuning Tap Multiplier Select Block
    sky130_fd_sc_hd__mux2_1 U_tap_mux (
        .X(raw_dco_clk),
        .A0(inv_chain[6]),
        .A1(inv_chain[13]),
        .S(ui_in[2]),
        .VPWR(vccd1),
        .VGND(vssd1),
        .VPB(vccd1),
        .VNB(vssd1)
    );

    // 4. Synchronous Divide-by-N Clock Downstream Block
    sync_divider U_divider_0 (
        .clk_in(raw_dco_clk),
        .rst_n(rst_n),
        .div_ratio({3'b000, ui_in[1:0]}), // Corrected name and explicit 5-bit padding
        .clk_out(uo_out[0])
    );

endmodule