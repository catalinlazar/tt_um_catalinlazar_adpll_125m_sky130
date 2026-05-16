`default_nettype none

module sync_divider (
    input  wire       clk_in,    // High-speed raw clock input from the DCO (~250-500 MHz)
    input  wire       rst_n,     // Active-low synchronous reset
    input  wire [4:0] div_ratio, // Configurable division ratio (e.g., divide by 16, 20, etc.)
    output reg        clk_out    // Clean, divided, symmetrical clock output
);

    // Internal tracking registers
    reg [4:0] count;
    reg       clk_track;

    // Determine the toggle point to maintain a ~50% duty cycle
    // For an even division N, we want to toggle at (N/2) - 1
    wire [4:0] toggle_limit = (div_ratio >> 1) - 1'b1;
    wire [4:0] max_count    = div_ratio - 1'b1;

    always @(posedge clk_in) begin
        if (!rst_n) begin
            count     <= 5'b00000;
            clk_track <= 1'b0;
        end else begin
            if (count >= max_count) begin
                count     <= 5'b00000;
                clk_track <= 1'b1; // Reset phase start
            end else begin
                count <= count + 1'b1;
                
                // Symmetrical toggle logic for even division ratios
                if (count == toggle_limit) begin
                    clk_track <= ~clk_track;
                end
            end
        end
    end

    // Buffer the tracking register to the output pin
    always @(*) begin
        clk_out = clk_track;
    end

endmodule