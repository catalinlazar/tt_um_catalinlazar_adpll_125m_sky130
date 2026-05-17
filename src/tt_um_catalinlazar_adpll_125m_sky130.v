`default_nettype none

/* verilator lint_off UNUSEDSIGNAL */
module tt_um_catalinlazar_adpll_125m_sky130 (
    input  wire [7:0] ui_in,    
    output wire [7:0] uo_out,   
    input  wire [7:0] uio_in,   
    output wire [7:0] uio_out,  
    output wire [7:0] uio_oe,   
    input  wire       ena,      
    input  wire       clk,      
    input  wire       rst_n     
);
/* verilator lint_on UNUSEDSIGNAL */

    wire loop_enabled = ui_in[5];
    wire [4:0] div_ratio = ui_in[4:0];

    assign uio_out = 8'b0000_0000;
    assign uio_oe  = 8'b0000_0000;
    assign uo_out[0] = raw_dco_clk;
    assign uo_out[1] = clk_out;
    assign uo_out[7:2] = 6'b000000;

    wire raw_dco_clk;
    wire clk_out;
    wire ring_p0, ring_p1, ring_p2, ring_p3;

    // NO POWER PINS HERE. Clean logical mapping.
    sky130_fd_sc_hd__nand2_1 U_gate_nand (
        .Y(ring_p0), .A(loop_enabled), .B(ring_p3)
    );

    sky130_fd_sc_hd__inv_1 U_delay_inv1 (
        .Y(ring_p1), .A(ring_p0)
    );

    sky130_fd_sc_hd__inv_1 U_delay_inv2 (
        .Y(ring_p2), .A(ring_p1)
    );

    sky130_fd_sc_hd__mux2_1 U_tap_mux (
        .X(ring_p3), .A0(ring_p2), .A1(ring_p1), .S(div_ratio[0])
    );

    assign raw_dco_clk = ring_p0;

    sync_divider U_sync_divider (
        .clk_in(raw_dco_clk),
        .rst_n(rst_n),
        .div_ratio(div_ratio),
        .clk_out(clk_out)
    );

endmodule