`default_nettype none

module tt_um_catalinlazar_adpll_125m_sky130 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (0=input, 1=output)
    input  wire       ena,      // Core power/selection status
    input  wire       clk,      // TinyTapeout System Clock (50MHz)
    input  wire       rst_n     // Global active-low reset
);

    // --- Input Mapping ---
    wire ref_clk_ext = ui_in[0];
    wire clk_sel     = ui_in[1];
    wire adpll_rst_n = ui_in[2];
    wire tap_sel     = ui_in[3]; // 0 = 127 stages (~125MHz), 1 = 63 stages (~250MHz)
    wire [3:0] div_sel = ui_in[7:4]; // Dynamic division ratio control

    // Reference clock selection
    wire primary_ref_clk = clk_sel ? ref_clk_ext : clk;

    // --- Structural 127-Stage Ring Oscillator (DCO) ---
    wire [126:0] loop;
    wire dco_enabled = adpll_rst_n;

    // Stage 0: NAND gate acts as the oscillation toggle/start mechanism
    sky130_fd_sc_hd__nand2_1 U_nand_0 (
        .A(dco_enabled),
        .B(loop[126]),
        .Y(loop[0])
    );

    // Stages 1 to 126: Structural Inverter Chain
    genvar i;
    generate
        for (i = 1; i <= 126; i = i + 1) begin : ring_buffer
            sky130_fd_sc_hd__inv_1 U_inv (
                .A(loop[i-1]),
                .Y(loop[i])
            );
        end
    </generate>

    // Coarse Frequency Tapping Multiplexer
    wire raw_dco_clk;
    sky130_fd_sc_hd__mux2_1 U_tap_mux (
        .A0(loop[126]), // Full 127-stage path (~125 MHz baseline)
        .A1(loop[62]),  // Shortened 63-stage path (~250 MHz baseline)
        .S(tap_sel),
        .X(raw_dco_clk)
    );

    // --- Feedback Divider & Peripheral Blocks ---
    wire clk_divided_clean;
    
    // Map our user inputs directly to division control (minimum divide by 2)
    wire [4:0] current_div = {1'b0, div_sel} + 5'd2;

    sync_divider feedback_div (
        .clk_in(raw_dco_clk),
        .rst_n(adpll_rst_n),
        .div_ratio(current_div),
        .clk_out(clk_divided_clean)
    );

    // --- Output Map ---
    assign uo_out[0] = clk_divided_clean; // Main divided output clock
    assign uo_out[1] = raw_dco_clk;       // Raw oscillator monitor out
    assign uo_out[2] = adpll_rst_n;       // Status flag placeholder
    assign uo_out[7:3] = 5'b00000;        // Ground unused pins

    // Disable bidirectional lines
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

endmodule