`default_nettype none

/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off PINMISSING */

module tt_um_catalinlazar_adpll_125m_sky130 (
    input  wire [7:0] ui_in,    // Dedicated inputs - [5]: loop enable, [4:0]: div ratio config
    output wire [7:0] uo_out,   // Dedicated outputs - [0]: raw clock, [1]: divided clock
    input  wire [7:0] uio_in,   // IOs: Input path (Unused)
    output wire [7:0] uio_out,  // IOs: Output path (Unused)
    output wire [7:0] uio_oe,   // IOs: Enable path (Unused)
    input  wire       ena,      // always 1 when the design is powered
    input  wire       clk,      // System clock (Physically anchored to uo_out[7])
    input  wire       rst_n     // reset_n - low to reset divider
);

    // Internal structural routing connections
    wire loop_enabled;
    wire raw_dco_clk;
    wire clk_out;
    wire [4:0] div_ratio;

    // Interface extraction
    assign loop_enabled = ui_in[5];
    assign div_ratio    = ui_in[4:0];

    // Safe, non-floating tie offs for the bidirectional port controls
    assign uio_out = 8'b0000_0000;
    assign uio_oe  = 8'b0000_0000;

    // =========================================================================
    // DEDICATED OUTPUT BUS MAPPING
    // Driving uo_out[7] directly with clk acts as an un-optimizable physical 
    // anchor. It forces OpenROAD to preserve the pin and route it safely inside 
    // the layout core canvas.
    // =========================================================================
    assign uo_out[0]     = raw_dco_clk;
    assign uo_out[1]     = clk_out;
    assign uo_out[6:2]   = 5'b00000;
    assign uo_out[7]     = clk; 

    // =========================================================================
    // STRUCTURAL HARDWARE: Self-Oscillating Digitally Controlled Ring Loop
    // =========================================================================
    wire ring_p0, ring_p1, ring_p2, ring_p3;

    // Start loop control element using sky130 cell primitives
    sky130_fd_sc_hd__nand2_1 U_gate_nand (
        .Y(ring_p0),
        .A(loop_enabled),
        .B(ring_p3)
    );

    sky130_fd_sc_hd__inv_1 U_delay_inv1 (
        .Y(ring_p1),
        .A(ring_p0)
    );

    sky130_fd_sc_hd__inv_1 U_delay_inv2 (
        .Y(ring_p2),
        .A(ring_p1)
    );

    // Dynamic selection MUX providing frequency tuning choices
    sky130_fd_sc_hd__mux2_1 U_tap_mux (
        .X(ring_p3),
        .A0(ring_p2),
        .A1(ring_p1),
        .S(div_ratio[0])
    );

    // Capture the oscillating node safely to feed our logic blocks
    assign raw_dco_clk = ring_p0;

    // =========================================================================
    // SYNCHRONOUS CLOCK DIVIDER BLOCK
    // =========================================================================
    sync_divider U_sync_divider (
        .clk_in(raw_dco_clk),
        .rst_n(rst_n),
        .div_ratio(div_ratio),
        .clk_out(clk_out)
    );

endmodule

/* verilator lint_on PINMISSING */
/* verilator lint_on UNUSEDSIGNAL */