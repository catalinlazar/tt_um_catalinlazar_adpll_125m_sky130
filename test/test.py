import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def test_adpll(dut):
    dut._log.info("Starting ADPLL structural simulation test...")
    
    # Initialize high-level top ports
    dut.uio_in.value = 0
    dut.ena.value = 1
    
    # Change direct 'dut.clk' to dot-navigate into the instantiated block:
    dut.user_project.clk.value = 0
    dut.user_project.rst_n.value = 0
    dut.user_project.ui_in.value = 0

    await Timer(100, unit="ns")
    
    # Active Gated Ring Control line loop configuration
    dut.ui_in.value = 0x24
    dut._log.info("DCO loop enabled. Simulating ring structure delays...")

    # Cycle delay resolution loops
    for i in range(200):
        await Timer(5, unit="ns")

    # Read cleanDriven outputs without floating bit exceptions
    uo_out_val = int(dut.uo_out.value)
    dco_raw = (uo_out_val >> 1) & 1
    clk_div = uo_out_val & 1
    
    dut._log.info(f"Simulation Checkpoint -> raw_dco_clk: {dco_raw}, clk_out (Divided): {clk_div}")
    
    assert ((uo_out_val >> 2) & 1) == 1, "ADPLL core active status tracking indicator failed!"