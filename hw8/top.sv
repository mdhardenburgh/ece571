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

    `ifdef request_vector_has_invalid_bits
    `TEST_TASK(arbiterAsserts, request_vector_has_invalid_bits)
        reset <= 1'b1;
        r <= 'bx;
        @(posedge clock);
        #1
        reset <= 1'b0;
        r <= 'bx;
        @(posedge clock);
        #1
        reset <= 1'b0;
    `END_TEST_TASK(arbiterAsserts, request_vector_has_invalid_bits)
    `endif

    //remember force
    `TEST_TASK(arbiterAsserts, request_vector_has_valid_bits)
        reset = 1'b1;
        r = 'b10010111;
        @(posedge clock);
        @(posedge clock);
        reset = 1'b0;
        r = 'b10110111;
        @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b00000001);
    `END_TEST_TASK(arbiterAsserts, request_vector_has_valid_bits)

    `TEST_TASK(arbiterAsserts, grant_before_reset)
        reset = 1'b1;
        r = 'b10010111;
        @(posedge clock);
        reset = 1'b1;
        EXPECT_EQ_LOGIC(g, 'b0);
    `END_TEST_TASK(arbiterAsserts, grant_before_reset)

    `TEST_TASK(arbiterAsserts, grant_after_reset)
        reset = 1'b1;
        r = 'b10010111;
        @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0);
        reset = 1'b0;
        r = 'b10010111;
        @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b00000001);
    `END_TEST_TASK(arbiterAsserts, grant_after_reset)

    `TEST_TASK(arbiterAsserts, check_if_grant_is_produced_in_one_cycle)
        reset = 1'b1;
        r = 'b1001_1010;
        @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0);
        reset = 1'b0;
        r = 'b1001_1010;
        @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0000_0010);
        r = 'b1001_1011;
        @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0000_0001);
    `END_TEST_TASK(arbiterAsserts, check_if_grant_is_produced_in_one_cycle)

    `TEST_TASK(arbiterAsserts, verify_never_more_than_one_grant)
        reset = 1'b1;
        r = 'b1001_1010;
        @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0);
        reset = 1'b0;
        r = 'b1001_1010;
        @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0000_0010);
        r = 'b1111_1111;
        @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0000_0001);
        r = 'b0111_1110;
        /*
        @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0000_0010);
        r = 'b1000_0000;
        @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b1000_0000);
        r = 'b1000_1000;
        @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0000_1000);
        */
    `END_TEST_TASK(arbiterAsserts, verify_never_more_than_one_grant)
/*
    `TEST_TASK(arbiterAsserts, single_requestor_always_recieves_grant)
        reset = 1'b1;
        r = 'b0000_0010;
        @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0);
        reset = 1'b0;
        r = 'b0000_0010;
        @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0000_0010);
    `END_TEST_TASK(arbiterAsserts, single_requestor_always_recieves_grant)
*/
    initial
    begin
        testFramework::TestManager::runAllTasks();
        $finish;
    end    
endmodule