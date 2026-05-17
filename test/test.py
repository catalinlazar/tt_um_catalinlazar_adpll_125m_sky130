import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def test_adpll(dut):
    dut._log.info("Starting ADPLL structural simulation test...")
    dut.uio_in.value = 0
    dut.ena.value = 1
    
    # Dot-navigating into your instantiated block
    dut.user_project.clk.value = 0
    dut.user_project.rst_n.value = 0
    dut.user_project.ui_in.value = 0

    await Timer(100, unit="ns")
    dut.ui_in.value = 0x24
    dut._log.info("DCO enabled. Simulating structural feedback inverter chain delays...")

    for i in range(200):
        await Timer(5, unit="ns")

    # --- Approach A: Safe Bitwise Extractor ---
    # 1. Read the entire 8-bit output vector as a standard Python integer
    uo_out_val = int(dut.uo_out.value)
    
    # 2. Extract the safe bit states mathematically via bit-masking
    clk_div = uo_out_val & 1         # Bit 0 (clk_divided_clean)
    dco_raw = (uo_out_val >> 1) & 1  # Bit 1 (raw_dco_clk)
    adpll_active = (uo_out_val >> 2) & 1 # Bit 2 (adpll_rst_n status)

    dut._log.info(f"Simulation Checkpoint -> raw_dco_clk: {dco_raw}, clk_out (Divided): {clk_div}")
    
    # Verify using our safe mask value
    assert adpll_active == 1, "ADPLL core active status tracking indicator failed!"