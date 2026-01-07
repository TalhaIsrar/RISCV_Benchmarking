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
    dut.usePredictor.value = 1 # Connected to TB.sv file
    cocotb.start_soon(clk.start())  # Start clk in parallel

    # Reset and wait for 1 ns
    for i in range(1):
        dut.rst.value = 1
        await Timer(1, "ns")
    dut.rst.value = 0

    writeData = []
    writeAddr = []
    writePc = []
    memWriteAddr = []

    cocotb.log.info("Reset done.")
    while(True):
        await Timer(1, "ns")
        if (dut.uut.decode.regF.writeEn.value == 1): # Check if register file write is enabled
            try:
                msg = f"{hex(dut.uut.decode.regF.writeData.value)},{hex(dut.uut.decode.regF.writeAddr.value)},{hex(dut.uut.decode.pcPlus4.value)}"
                # cocotb.log.info(msg)
            except:
                pass

        goodAddr = not((dut.dmemAddr.value == 0xFFFFFFFC) or (dut.dmemAddr.value == 0x0)) # Filter invalid addresses
        load = bool(dut.dmemWen.value) # Mem read
        store = dut.uut.M_regSrc.value == 1; # Mem write

        if ((int(dut.data.addr.value) > int(0x1000_FFFF))&(load or store)):
            if not((dut.dmemAddr.value == 0xFFFFFFFC) or (dut.dmemAddr.value == 0xFFFFFF00) or (dut.dmemAddr.value == 0x0)):
                cocotb.log.info(f"{hex(dut.data.addr.value)}")


        # Logging memory operations by writing to array memWriteAddr used later in logging
        if (goodAddr&(load or store)):
            pc_plus4 = int(dut.uut.M_pcPlus4.value)
            dmem_addr = int(dut.dmemAddr.value)
            wdata     = int(dut.dmemWdata.value)
            rdata     = int(dut.dmemRdata.value)

            memWriteAddr.append(
                (hex(dmem_addr),
                hex(pc_plus4 - 4),
                hex(wdata),
                hex(rdata),
                load)
            )

        if (dut.uut.decode.regF.writeData.value == 0xDEAD0000):
            cocotb.log.info("SAW DEAD0000") 

        # Stops sim when we reach DEADCODE (comes from HALT in boot.s) or 1000ef (Not sure yet)
        if (dut.uut.decode.regF.writeData.value == 0xDEADC0DE)|(dut.dmemWdata.value == 0x1000ef):
            break 

    # DEBUG PRINTING

    for pc,addr,data in zip(writePc,writeAddr,writeData):
            msg = f"{hex(pc)},{hex(addr)},{hex(data)}"
            cocotb.log.info(msg)
    # print("loadstore Addr,pc,dmemWdata,dmemRdata,store?:\n")
    # for i in memWriteAddr:
    #     print(i)