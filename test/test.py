import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def test_adpll(dut):
    dut._log.info("Starting ADPLL structural simulation test...")
    
    # 1. Clear interface control pins and hold divider in reset state initially
    dut.rst_n.value = 0      # Active-low reset asserted
    dut.ena.value = 1        # Power/enable block active
    dut.ui_in.value = 0x00   # Clear inputs initially
    
    await Timer(10, unit="ns")
    
    # 2. Enable the high-speed DCO ring oscillator path 
    dut._log.info("DCO loop enabled. Simulating ring structure delays...")
    # 0x30 -> Binary 8'b0011_0000 
    # This keeps your DCO enabled loop active while feeding a clear,
    # non-zero division ratio step to your tracking configuration bits.
    dut.ui_in.value = 0x30   
    
    # 3. Wait a short period for the oscillator loop to start up and stabilize.
    # Since mock gates use deterministic #0.1 delays, a 20ns wait guarantees
    # multiple active clock edges are fed to the synchronous divider during reset.
    await Timer(20, unit="ns")
    
    # 4. Release Reset cleanly to start tracking steps
    dut._log.info("Releasing reset line to activate the clock divider...")
    dut.rst_n.value = 1
    
    # 5. Let the simulation step forward out to 1ms total
    # to guarantee clean viewing of multiple full cycles of the divided output
    await Timer(1, unit="ms")
    
    # Checkpoint values at simulation end using .value to safely fetch array states
    outputs = dut.uo_out.value
    raw_clk = outputs[0]
    div_clk = outputs[1]
    dut._log.info(f"Simulation Checkpoint Completed -> raw_dco_clk: {raw_clk}, clk_out (Divided): {div_clk}")