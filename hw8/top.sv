`include "../svTest/testFramework.sv"

module top #(parameter AGENTS = 8);
    import testFramework::*;

    logic clock;
    logic reset;
    logic[AGENTS-1:0] r;
    logic[AGENTS-1:0] g;

    Arbiter #(.AGENTS(AGENTS)) DUT
    (
        .clock(clock),
        .reset(reset),
        .r(r),
        .g(g)
    );

    bind DUT ArbiterAssertions_CONCURENT_ASSERTIONS asserts
    (
        .clock(clock),
        .reset(reset),
        .r(r),
        .g(g)
    );

    initial
    begin
        clock = 1'b0;
        forever #20 clock <= ~clock;
    end

    
    `TEST_TASK(arbiterAsserts, request_vector_has_invalid_bits)
        reset <= 1'b0;
        r <= 'bx;
        @(posedge clock);
        reset <= 1'b1;
        r <= 'bx;
        @(posedge clock);
    `END_TEST_TASK(arbiterAsserts, request_vector_has_invalid_bits)

    

    initial
    begin
        testFramework::TestManager::runAllTasks();
        $finish;
    end    
endmodule