`include "ddTest.sv"

module top #(parameter N = 32);
    
    // Input
    logic Clock;
    logic Reset;
    logic Start;
    logic[N-1:0] V;
    // Output
    logic[(4*(N+2))/(3-1):0][3:0] BCD;
    logic Ready;
    int fd;

    parameter clockCycle = 10;
    int cycleCount = 0;
    ref int totalFailures = 0;
    ref int cycle_count = 0;
    
    DoubleDabble #(.N(N))DUT
    (
        .Clock(Clock),
        .Reset(Reset),
        .Start(Start),
        .V(V),
        .BCD(BCD),
        .Ready(Ready)
    );
    
    // Create free running clock
    initial
    begin
        Clock = 1'b0;
        forever #(clockCycle/2) Clock <= ~Clock;
    end

    `ifdef DEBUG
    // create cycle counter for debugging
    initial
    begin
        forever @(posedge Clock) cycle_count++;
    end
    `endif

    `ifdef DEBUG
    initial
    begin
        forever @(posedge Clock)
        begin
            $display("Cycle #: %0d, Reset: %b, Start: %b, V: %b, BCD: %b, Ready: %b", cycle_count, Reset, Start, V, BCD, Ready);
        end
    end
    `endif
    
    initial begin
        fd = $fopen("DoubleDabbleTestSuite.txt", "w");
        if (fd == 0) 
        begin
            $error("Failed to open file for logging");
        end
    end

    initial
    begin
        //fd = $fopen("DoubleDabbleTestSuite.txt", "w");
        DoubleDabbleTest #(.m_N(N)) myTest = new(fd, clockCycle);
        $fdisplay(fd, "Begin DoubleDabble Test Suite");
        //`ifdef DEBUG
        //    $display("Cycle #: %0d, Reset: %b, Start: %b, V: %b, BCD: %b, Ready: %b", cycle_count, Reset, Start, V, BCD, Ready);
        //`endif
        myTest.test_all_bits_high(Reset, Start, V, BCD, Ready, cycle_count, totalFailures); 
        //$display("V: %0d, BCD: %b", V, ddAlgorithm::DoubleDabble_A (V));
        $fdisplay(fd, "End DoubleDabble Test Suite");
        $fclose(fd);
        $finish;
    end

endmodule