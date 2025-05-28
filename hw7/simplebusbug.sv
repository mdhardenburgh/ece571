/*
 *
 *	Simple Bus code from Thomas modified to use interface with modports and clock, resetN signals
 *
 *
 *  This code includes my "improvements" to the original code.   No renaming of signals.   These
 *  were not intended to be part of student solutions; shown here just for illustration.
 *
 *	Specifically:
 *
 *	Separate clock generator module and use of "let" for clock period.   Could also use
 *  parameters.
 *
 *	Add $monitor in top to show key values.
 *
 *	Moved memory initialization out of memory interface thread into top testbench
 *
 *
 *
 */
`include "../svTest/testFramework.sv"


//let PERIOD = 100ns;
//let RESETDURATION = PERIOD/2;

localparam time PERIOD        = 100ns;
localparam time RESETDURATION = PERIOD/2;

module top;
    logic resetN;
    logic clock;

    //`ifdef DEBUG
    initial
    begin
        #RESETDURATION resetN = 1;

        $display("		  time access start read dValid addr data\n");
        $monitor($time, "   %b     %b     %b    %b   %h    %h", Processor.access, SB.start, SB.read, SB.dataValid, SB.address, SB.data);
    end
    //`endif

    SimpleBus SB(.*);
    ClockGenerator ClockGen(.*);
    ProcessorIntThread Processor(SB.ProcessorPort);
    MemoryIntThread Memory(SB.MemoryPort);

    initial
    begin
        for (int i = 0; i < 16'hFFFF; i++)
            Memory.Mem[i] <= 0;
    end
endmodule

module ClockGenerator(output logic clock);
    // clock is initialized to X!
    initial 
    begin
        clock <= 0; 
        forever #(PERIOD/2) clock = ~clock;
    end
endmodule


interface SimpleBus(input logic clock, resetN);
    wire [7:0] data;
    logic [7:0] address;
    logic start;
    logic read;
    wire dataValid;

    import testFramework::*;

    modport ProcessorPort
    (
        input clock, 
        input resetN, 
        inout data, 
        output address, 
        output start, 
        output read, 
        inout dataValid
    );
                        
    modport MemoryPort
    (
        input clock, 
        input resetN, 
        inout data, 
        input address, 
        input start, 
        input read, 
        inout dataValid
    );

    /**
    Note to grader: PLEASE check testFramework.sv at the root level for 
    CONCURENT_PROPERTY_ERROR and END_CONCURENT_PROPERTY_ERROR definitions

    Copied here for simplicity

        `define CONCURENT_PROPERTY_ERROR(SUITE, NAME) \
        property SUITE``_``NAME``_CONCURENT_PROPERTY_ERROR_P``;

        `define END_CONCURENT_PROPERTY_ERROR(SUITE, NAME) \
        endproperty \
        SUITE``_``NAME``_CONCURENT_PROPERTY_ERROR_A``: assert property(SUITE``_``NAME``_CONCURENT_PROPERTY_ERROR_P``) \
            else \
            begin \
                $error("%s.%s_CONCURENT_ASSERTION FAILED in test: %s", `"SUITE`", `"NAME`", TestManager::getConcurrentTask()); \
                TestManager::setConcurentFailure(); \
            end

    */
    sequence startPulse;
        @(posedge clock)
        $rose(start) ##1 $fell(start);
    endsequence

    sequence transaction;
        @(posedge clock)
        !$rose(start) ##1 !$fell(start) ##[1:$] !$rose(dataValid) ##1 !$fell(dataValid);
    endsequence

    
    `CONCURENT_PROPERTY_ERROR(simpleBus, addres_valid_for_cycles_in_which_start_is_asserted_and_next)
        @(posedge clock)
        disable iff (!resetN)
        (start===1'b1) |-> !$isunknown(address) ##1 !$isunknown(address);
    `END_CONCURENT_PROPERTY_ERROR(simpleBus, addres_valid_for_cycles_in_which_start_is_asserted_and_next)

    `CONCURENT_PROPERTY_ERROR(simpleBus, data_valid_asserted_data_lines_hold_valid_data)
        @(posedge clock)
        disable iff (!resetN)
        (dataValid===1'b1) |-> !$isunknown(data);
    `END_CONCURENT_PROPERTY_ERROR(simpleBus, data_valid_asserted_data_lines_hold_valid_data)

    `CONCURENT_PROPERTY_ERROR(simpleBus, start_asserted_for_only_one_cycle)
        @(posedge clock)
        disable iff (!resetN)
        (start === 1'b1) |-> ##1 (start === 1'b0);
    `END_CONCURENT_PROPERTY_ERROR(simpleBus, start_asserted_for_only_one_cycle)

    `CONCURENT_PROPERTY_ERROR(simpleBus, read_asserted_for_only_one_cycle)
        @(posedge clock)
        disable iff (!resetN)
        (read === 1'b1) |-> ##1 (read === 1'b0);
    `END_CONCURENT_PROPERTY_ERROR(simpleBus, read_asserted_for_only_one_cycle)

    `CONCURENT_PROPERTY_ERROR(simpleBus, dataValid_asserted_for_only_one_cycle)
        @(posedge clock)
        disable iff (!resetN)
        (dataValid === 1'b1) |-> ##1 (dataValid === 1'bz);
    `END_CONCURENT_PROPERTY_ERROR(simpleBus, dataValid_asserted_for_only_one_cycle)

    `CONCURENT_PROPERTY_ERROR(simpleBus, read_completes_in_2_to_10_cycles)
        @(posedge clock)
        disable iff (!resetN)
        $rose(start) ##1 $rose(read) |=> ##[2:10] !$isunknown(data) && (dataValid === 1'b1);
    `END_CONCURENT_PROPERTY_ERROR(simpleBus, read_completes_in_2_to_10_cycles)

    `CONCURENT_PROPERTY_ERROR(simpleBus, write_completes_in_2_to_7_cycles)
        @(posedge clock)
        disable iff (!resetN)
        //$rose(start) ##1 $fell(start) ##[2:7] !$isunknown(data) && (dataValid === 1'b1) |=> $rose(start) ##1 (read === 1'b0);
        //$rose(start) ##1 (read === 1'b0) |> $rose(start) ##1 $fell(start) ##[2:7] !$isunknown(data) && (dataValid === 1'b1);
        $rose(start) ##1 (read === 1'b0) |=> ##[2:7] !$isunknown(data) && (dataValid === 1'b1);
    `END_CONCURENT_PROPERTY_ERROR(simpleBus, write_completes_in_2_to_7_cycles)

    `CONCURENT_PROPERTY_ERROR(simpleBus, start_only_asserted_once_per_transaction)
        @(posedge clock)
        disable iff (!resetN)
        startPulse |-> !$rose(start) throughout transaction;
    `END_CONCURENT_PROPERTY_ERROR(simpleBus, start_only_asserted_once_per_transaction)

    `CONCURENT_PROPERTY_ERROR(simpleBus, read_only_asserted_after_start)
        @(posedge clock)
        disable iff (!resetN)
        $rose(read) |-> ($past(start) == 1'b1);
    `END_CONCURENT_PROPERTY_ERROR(simpleBus, read_only_asserted_after_start)
endinterface

module ProcessorIntThread(SimpleBus.ProcessorPort bus);

    import testFramework::*;

    logic en_AddrUp, en_AddrLo, ld_Data, en_Data, access = 0;
    logic doRead, wDataRdy, dv;
    logic [7:0] DataReg;
    logic [15:0] AddrReg;

    enum {MA,MB,MC,MD} State, NextState;

    assign bus.data = (en_Data) ? DataReg : 'bz;
    assign bus.dataValid = (State == MD) ? dv : 1'bz;

    always_comb
    begin
        if (en_AddrLo) bus.address = AddrReg[7:0];
        //if (en_AddrLo) bus.address = 'bz;
        else if (en_AddrUp) bus.address = AddrReg[15:8];
        //else if (en_AddrUp) bus.address = 'bz;
        else bus.address = 'bz;
    end
        
    always_ff @(posedge bus.clock)
        if (ld_Data) DataReg <= bus.data;
        
    always_ff @(posedge bus.clock, negedge bus.resetN)
        if (!bus.resetN) State <= MA;
        else State <= NextState;
        
        
    always_comb
    begin
        bus.start = 0;
        en_AddrUp = 0;
        en_AddrLo = 0;
        bus.read = 0;
        ld_Data = 0;
        en_Data = 0;
        dv = 0;

        unique case(State)
            MA:	begin
                NextState = (access) ? MB : MA;
                bus.start = (access) ? 1 : 0;
                en_AddrUp = (access) ? 1 : 0;
                end
            MB:	begin
                NextState = (doRead) ? MC : MD;
                en_AddrLo = 1;
                bus.read = (doRead) ? 1 : 0;
                end
            MC:	begin
                NextState = (bus.dataValid) ? MA : MC;
                ld_Data = (bus.dataValid) ? 1 : 0;
                end
            MD:	begin
                NextState = (wDataRdy) ? MA : MD;
                en_Data = (wDataRdy) ? 1 : 0;
                dv = (wDataRdy) ? 1 : 0;
                end
        endcase
    end
        
    task WriteMem(input [15:0] Avalue, input [7:0] Dvalue);   
    begin
        access <= 1;
        doRead <= 0;
        wDataRdy <= 0;
        AddrReg <= Avalue;
        DataReg <= Dvalue;
        @(posedge bus.clock) 
        access <= 0;
        repeat (4) @(posedge bus.clock);
        wDataRdy <= 1;
        @(posedge bus.clock);
        wait (State == MA); // *** shouldn't do this
        repeat (2) @(posedge bus.clock);
    end
    endtask

    task ReadMem(input [15:0] Avalue);   
    begin
        access <= 1;
        doRead <= 1;
        wDataRdy <= 0;
        AddrReg <= Avalue;
        @(posedge bus.clock) access <= 0;
        @(posedge bus.clock);
        wait (State == MA); // *** shouldn't do this
        repeat (2) @(posedge bus.clock);
    end
    endtask

    `TEST_TASK(simpleBusTest, test_write_then_read)
        repeat (2) @(posedge bus.clock);
        WriteMem(16'h0406, 8'hDC);
        ReadMem(16'h0406);
        //EXPECT_EQ_LOGIC(DataReg, 8'hDC, "", "hex");
    `END_TEST_TASK(simpleBusTest, test_write_then_read)
/*
    `TEST_TASK(simpleBusTest, test_overwrite_same_spot)
        repeat (2) @(posedge bus.clock);
        WriteMem(16'h0406, 8'hDC);
        ReadMem(16'h0406);
        //EXPECT_EQ_LOGIC(DataReg, 8'hDC, "", "hex");
        WriteMem(16'h0406, 8'hAC);
        ReadMem(16'h0406);
        //EXPECT_EQ_LOGIC(DataReg, 8'hAC, "", "hex");
    `END_TEST_TASK(simpleBusTest, test_overwrite_same_spot)
*/
    initial
    begin
        testFramework::TestManager::runAllTasks();
        $finish;
    end
endmodule

module MemoryIntThread(SimpleBus.MemoryPort bus);
    
    logic [7:0] Mem[16'hFFFF:0], MemData;
    logic ld_AddrUp, ld_AddrLo, memDataAvail = 0;
    logic en_Data, ld_Data, dv;
    logic [7:0] DataReg;
    logic [15:0] AddrReg;

    enum {SA, SB, SC, SD} State, NextState;

    assign bus.data = (en_Data) ? MemData : 'bz;
    assign bus.dataValid = (State == SC) ? dv : 1'bz;

    assign MemData = Mem[AddrReg];
        
    always_ff @(posedge bus.clock)
        if (ld_AddrUp) AddrReg[15:8] <= bus.address;
        
    always_ff @(posedge bus.clock)
        if (ld_AddrLo) AddrReg[7:0] <= bus.address;

    always @(posedge bus.clock)
    begin
        if (ld_Data)
        begin
            Mem[AddrReg] <= bus.data;
        end
    end
        
    always_ff @(posedge bus.clock, negedge bus.resetN)
    if (!bus.resetN) State <= SA;
    else State <= NextState;
    
    always_comb
    begin
        ld_AddrUp = 0;
        ld_AddrLo = 0;
        dv = 0;
        en_Data = 0;
        ld_Data = 0;
        
        unique case (State)
            SA: begin
                NextState = (bus.start) ? SB : SA;
                ld_AddrUp = (bus.start) ? 1 : 0;
                end
            SB: begin
                NextState = (bus.read) ? SC : SD;
                ld_AddrLo = 1;
                end
            SC: begin
                NextState = (memDataAvail) ? SA : SC;
                dv = (memDataAvail) ? 1 : 0;
                en_Data = (memDataAvail) ? 1 : 0;
                end
            SD: begin
                NextState = (bus.dataValid) ? SA: SD;
                ld_Data = (bus.dataValid) ? 1 : 0;
                end
        endcase
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
