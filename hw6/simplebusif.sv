`include "../svTest/testFramework.sv"

int cycle_count = 0;

interface memBus
(
    input logic clock,
    input logic resetN
);
    logic start, read;
    logic dataValid;
    logic[7:0] address;
    logic[7:0] data;

    modport procThread 
    (
        input resetN, clock,
        output start, read,
        inout dataValid,
        output address,
        inout data
    );

    modport memThread 
    (
        input resetN, clock,
        input start, read,
        inout dataValid,
        input address,
        inout data
    );

endinterface //interfacename

module top #(parameter NUMMEM = 4);

logic clock = 1;
logic resetN = 0;

always #5 clock = ~clock;

initial #2 resetN = 1;

memBus bus
(
    .clock(clock),
    .resetN(resetN)
);

ProcessorIntThread #(.NUMMEM(NUMMEM)) P(.bus(bus));

genvar iIter;
generate
    for(iIter = 0; iIter < NUMMEM; iIter++)
    begin
        MemoryIntThread #(.devAddr(iIter)) M(.bus(bus));
    end
endgenerate

endmodule

module ProcessorIntThread #(parameter NUMMEM = 4)
(
    memBus.procThread bus
);
    import testFramework::*;
    
    logic en_devAddr, en_AddrUp, en_AddrLo, ld_Data, en_Data, access = 0;
    logic doRead, wDataRdy, dv;
    logic [7:0] DataReg;
    logic [23:0] AddrReg;

    enum {DEV_ADDR, MA,MB,MC,MD} State, NextState;

    assign bus.data = (en_Data) ? DataReg : 'bz;
    assign bus.dataValid = (State == MD) ? dv : 1'bz;

    always_comb
        if (en_AddrLo) bus.address[7:0] = AddrReg[7:0];
        else if (en_AddrUp) bus.address[7:0] = AddrReg[15:8];
        else if (en_devAddr) bus.address[7:0] = AddrReg[23:16];
        else bus.address = 'bz;
        
    always_ff @(posedge bus.clock)
        if (ld_Data) DataReg <= bus.data;
        
    always_ff @(posedge bus.clock, negedge bus.resetN)
        if (!bus.resetN) State <= DEV_ADDR;
        else State <= NextState;
        
        
    always_comb
    begin
        bus.start = 0;
        en_devAddr = 0;
        en_AddrUp = 0;
        en_AddrLo = 0;
        bus.read = 0;
        ld_Data = 0;
        en_Data = 0;
        dv = 0;
        
        case(State)
        // new reset state
        DEV_ADDR:
        begin
            NextState = (access) ? MA : DEV_ADDR;
            bus.start = (access) ? 1 : 0;
            en_devAddr = (access) ? 1 : 0;
        end
        // -reset state-, if access, send high addr bits
        MA:	
        begin
            NextState = MB;
            en_AddrUp =  1;
        end
        // access state, send low addr bits
        MB:	
        begin
            NextState = (doRead) ? MC : MD;
            en_AddrLo = 1;
            bus.read = (doRead) ? 1 : 0;
        end
        // read state, wait for read reply, then slup it into DataReg
        MC:	
        begin
            NextState = (bus.dataValid) ? DEV_ADDR : MC;
            ld_Data = (bus.dataValid) ? 1 : 0;
        end
        // write state, wait for then send valid data
        MD:	
        begin
            NextState = (wDataRdy) ? DEV_ADDR : MD;
            en_Data = (wDataRdy) ? 1 : 0;
            dv = (wDataRdy) ? 1 : 0;
        end
        endcase
    end
        
    task WriteMem(input [23:0] Avalue, input [7:0] Dvalue);   
    begin
        assert(Avalue[23:16] < NUMMEM)
            else $fatal("Avalue %h is larger than NUMMEM %d", Avalue[23:16], NUMMEM);

        access <= 1;
        doRead <= 0;
        wDataRdy <= 1;
        AddrReg <= Avalue;
        DataReg <= Dvalue;
        @(posedge bus.clock) access <= 0; // send dev addr
        @(posedge bus.clock); // send high addr
        @(posedge bus.clock); // send low
        wait (State == DEV_ADDR); 
        repeat (2) @(posedge bus.clock);
    end
    endtask

    task ReadMem(input [23:0] Avalue);   
    begin
        assert(Avalue[23:16] < NUMMEM)
            else $fatal("Avalue %h is larger than NUMMEM %d", Avalue[23:16], NUMMEM);

        access <= 1;
        doRead <= 1;
        wDataRdy <= 0;
        AddrReg <= Avalue;
        @(posedge bus.clock) access <= 0;
        @(posedge bus.clock);
        @(posedge bus.clock);
        wait (State == DEV_ADDR); 
        repeat (2) @(posedge bus.clock);
    end
    endtask

    `TEST_TASK(simpleBusTest, test_write_then_read)
        repeat (2) @(posedge bus.clock);
        WriteMem(24'h00_0406, 8'hDC);
        ReadMem(24'h00_0406);
        EXPECT_EQ_LOGIC(DataReg, 8'hDC, "", "hex");
    `END_TEST_TASK(simpleBusTest, test_write_then_read)

    `TEST_TASK(simpleBusTest, test_write_then_read_dev1)
        repeat (2) @(posedge bus.clock);
        WriteMem(24'h01_0406, 8'hDC);
        ReadMem(24'h01_0406);
        EXPECT_EQ_LOGIC(DataReg, 8'hDC, "", "hex");
    `END_TEST_TASK(simpleBusTest, test_write_then_read_dev1)

    `TEST_TASK(simpleBusTest, test_write_dev1_read_dev2)
        repeat (2) @(posedge bus.clock);
        WriteMem(24'h01_0406, 8'hAC);
        ReadMem(24'h02_0406);
        EXPECT_EQ_LOGIC(DataReg, 8'h0, "", "hex");
        ReadMem(24'h01_0406);
        EXPECT_EQ_LOGIC(DataReg, 8'hAC, "", "hex");
    `END_TEST_TASK(simpleBusTest, test_write_dev1_read_dev2)

    `TEST_TASK(simpleBusTest, test_overwrite_same_spot)
        repeat (2) @(posedge bus.clock);
        WriteMem(24'h00_0406, 8'hDC);
        ReadMem(24'h00_0406);
        EXPECT_EQ_LOGIC(DataReg, 8'hDC, "", "hex");
        WriteMem(24'h00_0406, 8'hAC);
        ReadMem(24'h00_0406);
        EXPECT_EQ_LOGIC(DataReg, 8'hAC, "", "hex");
    `END_TEST_TASK(simpleBusTest, test_overwrite_same_spot)

    `TEST_TASK(simpleBusTest, test_write_dev3_write_dev2_then_read)
        repeat (2) @(posedge bus.clock);
        WriteMem(24'h03_0406, 8'hAC);
        WriteMem(24'h02_AF90, 8'hFF);
        ReadMem(24'h03_0406);
        EXPECT_EQ_LOGIC(DataReg, 8'hAC, "", "hex");
        ReadMem(24'h02_AF90);
        EXPECT_EQ_LOGIC(DataReg, 8'hFF, "", "hex");
    `END_TEST_TASK(simpleBusTest, test_write_dev3_write_dev2_then_read)

    `TEST_TASK(simpleBusTest, test_this_is_not_a_good_test)
        repeat (2) @(posedge bus.clock);
        // Note this is from the textbook but is *not* a good test!!
        WriteMem(24'h03_0406, 8'hDC);
        ReadMem(24'h03_0406);
        EXPECT_EQ_LOGIC(DataReg, 8'hDC, "", "hex");
        WriteMem(24'h03_0407, 8'hAB);
        ReadMem(24'h03_0406);
        EXPECT_EQ_LOGIC(DataReg, 8'hDC, "", "hex");
        ReadMem(24'h03_0407);
        EXPECT_EQ_LOGIC(DataReg, 8'hAB, "", "hex");
    `END_TEST_TASK(simpleBusTest, test_this_is_not_a_good_test)

    `TEST_TASK(simpleBusTest, test_write_high)
        repeat (2) @(posedge bus.clock);
        WriteMem(24'h00_FFFF, 8'h1A);
        ReadMem(24'h00_FFFF);
        EXPECT_EQ_LOGIC(DataReg, 8'h1A, "", "hex");
    `END_TEST_TASK(simpleBusTest, test_write_high)

    `TEST_TASK(simpleBusTest, test_write_low)
        repeat (2) @(posedge bus.clock);
        WriteMem(24'h02_0001, 8'hBE);
        ReadMem(24'h02_0001);
        EXPECT_EQ_LOGIC(DataReg, 8'hBE, "", "hex");
    `END_TEST_TASK(simpleBusTest, test_write_low)
    
    `TEST_TASK(simpleBusTest, test_overflow_addr)
        repeat (2) @(posedge bus.clock);
        WriteMem(16'h100_0001, 8'hBE);
        ReadMem(16'h100_0001);
        EXPECT_EQ_LOGIC(DataReg, 8'hBE, "", "hex");
        ReadMem(16'h00_0001);
        EXPECT_EQ_LOGIC(DataReg, 8'hBE, "", "hex");
    `END_TEST_TASK(simpleBusTest, test_overflow_addr)

    `TEST_TASK(simpleBusTest, test_overflow_data)
        repeat (2) @(posedge bus.clock);
        WriteMem(24'h03_0001, 8'hBE);
        ReadMem(24'h03_0001);
        EXPECT_EQ_LOGIC(DataReg, 8'hEBE, "", "hex");
        ReadMem(24'h03_0001);
        EXPECT_EQ_LOGIC(DataReg, 8'hBE, "", "hex");
    `END_TEST_TASK(simpleBusTest, test_overflow_data)

    `TEST_TASK(simpleBusTest, test_trigger_too_large_addr_assert)
        repeat (2) @(posedge bus.clock);
        WriteMem(24'h04_0001, 8'hBE);
        ReadMem(24'h04_0001);
        EXPECT_EQ_LOGIC(DataReg, 8'hEBE, "", "hex");
    `END_TEST_TASK(simpleBusTest, test_trigger_too_large_addr_assert)

    //int cycle_count = 0;
    // create cycle counter for debugging
    initial
    begin
        forever @(posedge bus.clock) cycle_count++;
    end

    initial
    begin
        forever @(posedge bus.clock)
        begin
            //$display("Cycle #: %0d, ld_Data: %0d, DataReg: %h, State: %s, bus.dataValid: %b, bus.data: %h", cycle_count, ld_Data, DataReg, State.name(), bus.dataValid, bus.data);
        end
    end

    initial
    begin
        testFramework::TestManager::runAllTasks();
        $finish;
    end

endmodule

module MemoryIntThread #(parameter devAddr = 0)
(
    memBus.memThread bus
);
    
    logic [7:0] Mem[16'hFFFF:0], MemData;
    logic ld_AddrUp, ld_AddrLo, memDataAvail = 0;
    logic en_Data, ld_Data, dv;
    logic [7:0] DataReg;
    logic [15:0] AddrReg;

    int cycle_count = 0;

    enum {DEV_ADDR, SA, SB, SC, SD} State, NextState;

    initial
    begin
        for (int i = 0; i < 16'hFFFF; i++)
            Mem[i] <= 0;
    end
    // maybe tristate dataValid?
    assign bus.data = (en_Data) ? MemData : 'bz;
    assign bus.dataValid = (State == SC) ? dv : 1'bz;

    always @(AddrReg, ld_Data)
        MemData = Mem[AddrReg];

    always_ff @(posedge bus.clock)
        if (ld_AddrUp) AddrReg[15:8] <= bus.address;
    
    always_ff @(posedge bus.clock)
        if (ld_AddrLo) AddrReg[7:0] <= bus.address;

    always @(posedge bus.clock)
    begin
        if (ld_Data)
        begin
            DataReg <= bus.data;
            Mem[AddrReg] <= bus.data;
        end
    end
    
    always_ff @(posedge bus.clock, negedge bus.resetN)
        if (!bus.resetN) State <= DEV_ADDR;
        else State <= NextState;
  
    always_comb
    begin
        ld_AddrUp = 0;
        ld_AddrLo = 0;
        dv = 0;
        en_Data = 0;
        ld_Data = 0;
        
        case (State)
            DEV_ADDR:
            begin
                if((bus.start == 1'b1) && (bus.address == devAddr))
                begin
                    NextState = SA;
                    //$display("bus.start is %0d, bus.address is %0d, devAddr is %0d", bus.start, bus.address, devAddr);
                end
                else
                    NextState = DEV_ADDR;
            end

            // reset state, wait for start signal, capture upper addr bits
            SA: 
            begin
                //$display("SA bus.address %h", bus.address);
                NextState = SB;
                ld_AddrUp = 1;
            end
            // access state, capture lower addr bits, decide if read or write
            SB: 
            begin
                //$display("SB bus.address %h", bus.address);
                NextState = (bus.read) ? SC : SD;
                ld_AddrLo = 1;
            end
            SC: 
            // read state, wait for data from memory, put it on the bus, set data valid high
            begin
                NextState = (memDataAvail) ? DEV_ADDR : SC;
                dv = (memDataAvail) ? 1 : 0;
                en_Data = (memDataAvail) ? 1 : 0;
            end
            SD: 
            // write state, wait for valid data on the bus, then slurp it into mem
            begin
                NextState = (bus.dataValid) ? DEV_ADDR: SD;
                ld_Data = (bus.dataValid) ? 1 : 0;
            end
        endcase
    end

    initial
    begin
        forever @(posedge bus.clock) cycle_count++;
    end
    
    initial
    begin
        forever @(posedge bus.clock)
        begin
            //$display("MemoryIntThread: Cycle #: %0d, ld_Data: %0d, DataReg: %h, State: %s, bus.dataValid: %b, bus.data: %h", cycle_count, ld_Data, DataReg, State.name(), bus.dataValid, bus.data);
            //$display("MemoryIntThread: Cycle #: %0d, devAddr %0d, State: %s, bus.address: %h, bus.data %h, bus.dataValid %h, AddrReg %h", cycle_count, devAddr, State.name(), bus.address, bus.data, bus.dataValid, AddrReg);
        end
    end

    // *** testbench code
    always @(State)
    begin
        bit [2:0] delay;
        memDataAvail <= 0;
        if (State == SC)
        begin
            delay = $random;
            repeat (2 + delay)
                @(posedge bus.clock);
            memDataAvail <= 1;
        end
    end
    
endmodule
