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
    # Reset and wait for 1 ns
    for i in range(1):
        dut.rst.value = 0
        await Timer(1, "ns")
    dut.rst.value = 1
    for i in range(1):
        await Timer(2, "ns")
    dut.rst.value = 0

    cocotb.log.info("Reset done.")
    while(True):
        await Timer(1, "ns")
        #if (dut.uut.axi_read_start.value):
        #    cocotb.log.info(f"{hex(dut.uut.axi_read_addr.value)}") 
        

        if (dut.uut.wb_result.value == 0xEADD0000):
            cocotb.log.info("SAW DEAD0000") 
        # Stops sim when we reach DEADCODE (comes from HALT in boot.s) or 1000ef (Not sure yet)
        if (dut.uut.wb_result.value == 0xDEADC0DE):
            break 

