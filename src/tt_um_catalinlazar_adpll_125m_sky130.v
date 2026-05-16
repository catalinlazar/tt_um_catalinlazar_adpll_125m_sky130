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

    wire ref_clk_ext   = ui_in[0];
    wire clk_sel       = ui_in[1];
    wire adpll_rst_n   = ui_in[2];
    wire tap_sel       = ui_in[3]; 
    wire [3:0] div_sel = ui_in[7:4]; 

    wire primary_ref_clk = clk_sel ? ref_clk_ext : clk;

    wire [126:0] loop;
    wire dco_enabled = adpll_rst_n;

    sky130_fd_sc_hd__nand2_1 U_nand_0 (
        .A(dco_enabled),
        .B(loop[126]),
        .Y(loop[0])
    );

    genvar i;
    generate
        for (i = 1; i <= 126; i = i + 1) begin : ring_buffer
            sky130_fd_sc_hd__inv_1 U_inv (
                .A(loop[i-1]),
                .Y(loop[i])
            );
        end
    </generate>

    wire raw_dco_clk;
    sky130_fd_sc_hd__mux2_1 U_tap_mux (
        .A0(loop[126]), 
        .A1(loop[62]),  
        .S(tap_sel),
        .X(raw_dco_clk)
    );

    wire clk_divided_clean;
    wire [4:0] current_div = {1'b0, div_sel} + 5'd2;

    sync_divider feedback_div (
        .clk_in(raw_dco_clk),
        .rst_n(adpll_rst_n),
        .div_ratio(current_div),
        .clk_out(clk_divided_clean)
    );

    assign uo_out[0] = clk_divided_clean;
    assign uo_out[1] = raw_dco_clk;
    assign uo_out[2] = adpll_rst_n;
    
    assign uo_out[7:3] = 5'b00000;
    assign uio_out     = 8'b00000000;
    assign uio_oe      = 8'b00000000;

    wire _unused_pins = &{ena, rst_n, primary_ref_clk, uio_in, 1'b0};

endmodule
