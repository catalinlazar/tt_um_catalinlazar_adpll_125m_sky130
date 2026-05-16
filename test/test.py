import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def test_adpll(dut):
    dut._log.info("Starting ADPLL structural simulation test...")
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.ena.value = 1
    dut.clk.value = 0
    dut.rst_n.value = 0

    await Timer(100, units="ns")
    dut.ui_in.value = 0x24

    dut._log.info("DCO enabled. Simulating structural feedback inverter chain delays...")

    for i in range(200):
        await Timer(5, units="ns")

    dco_raw = dut.uo_out[1].value
    clk_div = dut.uo_out[0].value
    dut._log.info(f"Simulation Checkpoint -> raw_dco_clk: {dco_raw}, clk_out (Divided): {clk_div}")
    
    assert dut.uo_out[2].value == 1, "ADPLL core active status tracking indicator failed!"
