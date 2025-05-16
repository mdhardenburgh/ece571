`include "doubleDabblePkg.sv"
`include "systemVerilogTestFramework/testFramework.sv"

module top #(parameter N = 32);
import testFramework::*;
    
    // Input
    logic Clock;
    logic Reset;
    logic Start;
    logic[N-1:0] V;
    // Output
    logic[(4*(N+2))/(3-1):0][3:0] BCD;
    logic Ready;

    parameter clockCycle = 10;
    int cycleCount = 0;
    int cycle_count = 0;
    
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

    `TEST_TASK(DoubleDabbleTest, test_all_bits_high)
            // replicate 1 for m_N number of times
            V = { N{ 1'b1 } };
            //V = $urandom_range(0, (2**m_N)-1);
            cycle_count = 0;

            Start = 0;
            Reset = 1;
            EXPECT_EQ_LOGIC(Ready, 1);

            #clockCycle; 

            // should be ready after a reset
            Reset = 0;
            EXPECT_EQ_LOGIC(Ready, 1);

            Start = 1;

            #(N * clockCycle);
            EXPECT_EQ_LOGIC(Reset, 0);
            EXPECT_EQ_LOGIC(Ready, 1);
            //wait (Ready == 1);
            EXPECT_EQ_LOGIC(doubleDabblePkg::doubleDabble(V), BCD);

    `END_TEST_TASK(DoubleDabbleTest, test_all_bits_high)

    initial
    begin
        testFramework::TestManager::runAllTasks();
        $finish;
    end

endmodule

/*
task automatic test_all_bits_high
(
    ref logic Reset,
    ref logic Start,
    ref logic[m_N-1:0] V,
    input logic[m_ddVectorWidth-1:0] BCD,
    input logic Ready,
    ref int cycle_count
);
    string testName = "test_all_bits_high";
    // replicate 1 for m_N number of times
    V = { m_N{ 1'b1 } };
    //V = $urandom_range(0, (2**m_N)-1);
    $display("V is %b", V);

    $fdisplay(m_fd, "Begin %s.%s", m_className, testName);
    cycle_count = 0;

    Start = 1;
    Reset = 1;

    #m_clockCycle; 

    // should be ready after a reset
    Reset = 0;

    #(m_N * m_clockCycle);

    if((Ready === 1) && (doubleDabble(V) === BCD))
    begin
        $fdisplay(m_fd, "PASS");
    end
    else
    begin
        $fdisplay(m_fd, "FAIL, expected Ready === 1, Ready === %b. Expected BCD %b, Result BCD %b", Ready, doubleDabble(V), BCD);
    end

    $fdisplay(m_fd, "End %s.%s", m_className, testName);

    m_totalFailures++;
endtask
*/
