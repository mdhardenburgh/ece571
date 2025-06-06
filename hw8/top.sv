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

    `ifdef cause_request_vector_has_invalid_bits
    `TEST_TASK(arbiterAsserts, request_vector_has_invalid_bits)
        reset = 1'b1;
        r = 'bx;
        repeat (2) @(posedge clock);
        reset = 1'b0;
        r = 'bx;
        repeat (2) @(posedge clock);
        reset = 1'b0;
    `END_TEST_TASK(arbiterAsserts, request_vector_has_invalid_bits)
    `endif

    //remember force
    `TEST_TASK(arbiterAsserts, request_vector_has_valid_bits)
        reset = 1'b1;
        r = 'b10010111;
        repeat (2) @(posedge clock);
        reset = 1'b0;
        r = 'b10110111;
        repeat (2) @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0000_0001);
    `END_TEST_TASK(arbiterAsserts, request_vector_has_valid_bits)

    `TEST_TASK(arbiterAsserts, grant_before_reset)
        reset = 1'b1;
        r = 'b10010111;
        repeat (2) @(posedge clock);
        reset = 1'b1;
        EXPECT_EQ_LOGIC(g, 'b0);
    `END_TEST_TASK(arbiterAsserts, grant_before_reset)

    `TEST_TASK(arbiterAsserts, grant_after_reset)
        reset = 1'b1;
        r = 'b10010111;
        repeat (2) @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0);
        reset = 1'b0;
        r = 'b10010111;
        repeat (2) @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0000_0001);
    `END_TEST_TASK(arbiterAsserts, grant_after_reset)

    `TEST_TASK(arbiterAsserts, check_if_grant_is_produced_in_one_cycle)
        reset = 1'b1;
        r = 'b1001_1010;
        repeat (2) @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0);
        reset = 1'b0;
        r = 'b1001_1010;
        repeat (2) @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0000_0010);
        r = 'b1001_1001;
        repeat (2) @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0000_0001);
    `END_TEST_TASK(arbiterAsserts, check_if_grant_is_produced_in_one_cycle)

    `TEST_TASK(arbiterAsserts, verify_never_more_than_one_grant)
        reset = 1'b1;
        r = 'b1001_1010;
        repeat (2) @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0);
        reset = 1'b0;
        r = 'b1001_1010;
        repeat (2) @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0000_0010);
        r = 'b1111_1111;
        repeat (2) @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0000_0010);
        r = 'b0111_1110;
        repeat (2) @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0000_0010);
        r = 'b1000_0000;
        repeat (2) @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b1000_0000);
        r = 'b0100_1000;
        repeat (2) @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0000_1000);
    `END_TEST_TASK(arbiterAsserts, verify_never_more_than_one_grant)

    `TEST_TASK(arbiterAsserts, single_requestor_always_recieves_grant)
        reset = 1'b1;
        r = 'b0000_0010;
        repeat (2) @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0);
        reset = 1'b0;
        r = 'b0000_0010;
        repeat (2) @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0000_0010);
    `END_TEST_TASK(arbiterAsserts, single_requestor_always_recieves_grant)

    `TEST_TASK(arbiterAsserts, did_not_request_grant_grant_not_given)
        reset = 1'b1;
        r = 'b1101_0010;
        repeat (2) @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0);
        reset = 1'b0;
        repeat (2) @(posedge clock);
        EXPECT_NOT_EQ_LOGIC(g, 'b0000_0001);
        EXPECT_EQ_LOGIC(g, 'b0000_0010);
        r = 'b1001_1101;
        repeat (2) @(posedge clock);
        EXPECT_NOT_EQ_LOGIC(g, 'b0110_0010);
        EXPECT_EQ_LOGIC(g, 'b0000_0001);
        r = 'b1111_0111;
        repeat (2) @(posedge clock);
        EXPECT_NOT_EQ_LOGIC(g, 'b0000_1000);
        EXPECT_EQ_LOGIC(g, 'b0000_0001);
        r = 'b0000_0000;
        repeat (2) @(posedge clock);
        EXPECT_NOT_EQ_LOGIC(g, 'b0000_0001);
        EXPECT_EQ_LOGIC(g, 'b0000_0000);
    `END_TEST_TASK(arbiterAsserts, did_not_request_grant_grant_not_given)

    `TEST_TASK(arbiterAsserts, agent_contine_to_request_grant_agent_continue_to_get_grant)
        reset = 1'b1;
        r = 'b1001_0010;
        repeat (2) @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0);
        reset = 1'b0;
        repeat (2) @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0000_0010);
        r = 'b1001_1110;
        repeat (2) @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0000_0010);
        r = 'b1001_1111;
        repeat (2) @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0000_0010);
    `END_TEST_TASK(arbiterAsserts, agent_contine_to_request_grant_agent_continue_to_get_grant)

    `ifdef cause_after_grant_agent_does_not_contine_to_request_after_256_cycles

    `TEST_TASK(arbiterAsserts, after_256_cycles_higher_agent_reqs_grant)
        reset = 1'b1;
        r = 'b1001_0010;
        repeat (2) @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0);
        reset = 1'b0;
        repeat (2) @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0000_0010);
        r = 'b0000_0010;
        repeat (2 * 256) @(posedge clock);
        repeat (2) @(posedge clock);
        r = 'b0000_1001;
        repeat (4) @(posedge clock);
    `END_TEST_TASK(arbiterAsserts, after_256_cycles_higher_agent_reqs_grant)

    `TEST_TASK(arbiterAsserts, higher_req_after_high_req_then_wait_256_cycles)
        reset = 1'b1;
        r = 'b1001_0010;
        repeat (2) @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0);
        reset = 1'b0;
        repeat (2) @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0000_0010);
        r = 'b1000_0000;
        repeat (2) @(posedge clock);
        r = 'b1100_0000;
        repeat (2) @(posedge clock);
        r = 'b1101_0000;
        repeat (2) @(posedge clock);
        r = 'b1101_0001;
        repeat (2 * 256) @(posedge clock);
        repeat (2) @(posedge clock);
    `END_TEST_TASK(arbiterAsserts, higher_req_after_high_req_then_wait_256_cycles)

    `endif

    `TEST_TASK(arbiterAsserts, should_ignore_lower_request)
        reset = 1'b1;
        r = 'b1001_0010;
        repeat (2) @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0);
        reset = 1'b0;
        repeat (2) @(posedge clock);
        EXPECT_EQ_LOGIC(g, 'b0000_0010);
        r = 'b1001_0100;
        repeat (2 * 256) @(posedge clock);
        repeat (2) @(posedge clock);
    `END_TEST_TASK(arbiterAsserts, should_ignore_lower_request)

    initial
    begin
        testFramework::TestManager::runAllTasks();
        $finish;
    end    
endmodule