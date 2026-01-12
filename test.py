# test_my_design.py (simple)

import cocotb
from cocotb.triggers import Timer # Wait certain amount of sim time
from cocotb.clock import Clock  # Gen clk
from cocotb.triggers import RisingEdge  # Trigger on rising edge

# Test definition
@cocotb.test()
async def isa_test(dut): # DUT is top level RTL module
    """Try accessing the design."""
    clk = Clock(dut.clk, 1, "ns") # Generate 1 ns clk
    cocotb.start_soon(clk.start())  # Start clk in parallel

    cocotb.log.info("Reset done.")
    while(True):
        await Timer(1, "ns")

        if (dut.uut.wb_result.value == 0xDEAD0000):
            cocotb.log.info("SAW DEAD0000") 
        # Stops sim when we reach DEADCODE (comes from HALT in boot.s) or 1000ef (Not sure yet)
        if (dut.uut.wb_result.value == 0xDEADC0DE):
            break 

