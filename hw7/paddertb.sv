`include "../svTest/testFramework.sv"

`CONCURENT_ASSERTIONS(padderTestbench) #(parameter WIDTH = 64)
(
    input logic Clock,
    input logic[WIDTH-1:0] S,
    input logic CO,
    input logic[WIDTH-1:0] A, 
    input logic[WIDTH-1:0] B,
    input logic CI
);
    logic[WIDTH-1:0] MAX = (2**WIDTH)-1;

    localparam ADDERN = 8;
    localparam STAGES = WIDTH/ADDERN;

    /**
    Note to grader: PLEASE check testFramework.sv at the root level for 
    CONCURENT_PROPERTY_ERROR and END_CONCURENT_PROPERTY_ERROR definitions

    Copied here for simplicity

        `define CONCURENT_PROPERTY_ERROR(SUITE, NAME) \
        property SUITE``_``NAME``_CONCURENT_PROPERTY_ERROR_P``;

        `define END_CONCURENT_PROPERTY_ERROR(SUITE, NAME) \
        endproperty \
        RIGHT here is where I label the assert as per Mark's instructions. SUITE``_``NAME``_CONCURENT_PROPERTY_ERROR_A``: assert property(SUITE``_``NAME``_CONCURENT_PROPERTY_ERROR_P``) \
            else \
            begin \
                $error("%s.%s_CONCURENT_ASSERTION FAILED in test: %s", `"SUITE`", `"NAME`", TestManager::getConcurrentTask()); \
                TestManager::setConcurentFailure(); \
            end
    */
    
    `CONCURENT_PROPERTY_ERROR(padderTestbench, add_completes_in_four_cycles)
        @(posedge Clock)
        !$isunknown(A) && !$isunknown(B) && !$isunknown(CI) |-> ##STAGES !$isunknown(S) && !$isunknown(CO);
    `END_CONCURENT_PROPERTY_ERROR(padderTestbench, add_completes_in_four_cycles)

    `CONCURENT_PROPERTY_ERROR(padderTestbench, max_int_plus_one_causes_carry)
        @(posedge Clock)
        (A === MAX) && (B === WIDTH'(1)) && (CI === 1'b0) |-> ##STAGES (CO === 1'b1);
    `END_CONCURENT_PROPERTY_ERROR(padderTestbench, max_int_plus_one_causes_carry)

    `CONCURENT_PROPERTY_ERROR(padderTestbench, max_int_plus_carry_causes_carry)
        @(posedge Clock)
        ((A === MAX) && (B === 'b0) && (CI === 1'b1)) |-> ##(STAGES) (CO === 1'b1);
    `END_CONCURENT_PROPERTY_ERROR_PRINT(padderTestbench, max_int_plus_carry_causes_carry)
        $display("A=%0d, B=%0d, CI=%0d, CO=%0d", A, B, CI, CO);
    `END_CONCURENT_PROPERTY_ERROR_PRINT_END_PRINT

    `CONCURENT_PROPERTY_ERROR(padderTestbench, max_int_plus_one_causes_sum_overflow)
        @(posedge Clock)
        (A === MAX) && (B === WIDTH'(1)) && (CI === 1'b0)|-> ##STAGES (S === WIDTH'(0));
    `END_CONCURENT_PROPERTY_ERROR(padderTestbench, max_int_plus_one_causes_sum_overflow)

    `CONCURENT_PROPERTY_ERROR(padderTestbench, max_int_plus_carry_causes_sum_overflow)
        @(posedge Clock)
        (A === MAX) && (B === WIDTH'(0)) && (CI === 1'b1)|-> ##STAGES (S === WIDTH'(0));
    `END_CONCURENT_PROPERTY_ERROR(padderTestbench, max_int_plus_carry_causes_sum_overflow)

    `CONCURENT_PROPERTY_ERROR(padderTestbench, max_int_plus_max_int_causes_max_int_minus_one)
        @(posedge Clock)
        (A === MAX) && (B === MAX) && (CI === 1'b0)|-> ##STAGES (S === MAX-1) && (CO === 1'b1);
    `END_CONCURENT_PROPERTY_ERROR(padderTestbench, max_int_plus_max_int_causes_max_int_minus_one)

    `CONCURENT_PROPERTY_ERROR(padderTestbench, max_int_plus_max_int_plus_carry_causes_max_int)
        @(posedge Clock)
         (A === MAX) && (B === MAX) && (CI === 1'b1)|-> ##STAGES (S === MAX) && (CO === 1'b1);
    `END_CONCURENT_PROPERTY_ERROR(padderTestbench, max_int_plus_max_int_plus_carry_causes_max_int)

    `CONCURENT_PROPERTY_ERROR(padderTestbench, zero_plus_zero_no_carry_in_results_in_zero)
        @(posedge Clock)
        (A === WIDTH'(0)) && (B === WIDTH'(0)) && (CI === 1'b0)|-> ##STAGES (S === WIDTH'(0)) && (CO === 1'b0);
    `END_CONCURENT_PROPERTY_ERROR(padderTestbench, zero_plus_zero_no_carry_in_results_in_zero)
`END_CONCURENT_ASSERTIONS


module top #(parameter WIDTH = 64);

    import testFramework::*;

    logic Clock;
    logic[WIDTH-1:0] S;
    logic CO;
    logic[WIDTH-1:0] A, B;
    logic CI;

    logic[WIDTH-1:0] MAX = (2**WIDTH)-1;
    localparam MAX_REPEATS = 100000;
    localparam ADDERN = 8;
    localparam STAGES = WIDTH/ADDERN;

    logic[WIDTH*2:0] iter = 0;
    logic[WIDTH-1:0] aIter = 0;
    logic[WIDTH-1:0] bIter = 0;
    logic cInIter = 0;
    logic [STAGES-1:0][WIDTH*2:0] pipeline;
    logic[WIDTH:0] expectedResult;

    PAdder #(.N(WIDTH)) dut
    (
        .Clock(Clock),
        .S(S),
        .CO(CO),
        .A(A),
        .B(B),
        .CI(CI)
    );

    bind dut padderTestbench_CONCURENT_ASSERTIONS asserts
    (
        .Clock(Clock),
        .S(S),
        .CO(CO),
        .A(A),
        .B(B),
        .CI(CI)
    );

    initial
    begin
        Clock = 1'b0;
        forever #20 Clock <= ~Clock;
    end

    `TEST_TASK_N(padderTestbench, simple_add, WIDTH)
        A <= WIDTH'(5);
        B <= WIDTH'(4);
        CI <= 1'b0;
        repeat (STAGES+1) @(posedge Clock);
        EXPECT_EQ_LOGIC_N(S, A+B);
        A <= WIDTH'(7);
        B <= WIDTH'(7);
        CI <= 1'b0;
        repeat (STAGES+1) @(posedge Clock);
        EXPECT_EQ_LOGIC_N(S, A+B);
    `END_TEST_TASK_N(padderTestbench, simple_add, WIDTH)

    `TEST_TASK_N(padderTestbench, add_max_int, WIDTH)
        A <= MAX;
        B <= MAX;
        CI <= 1'b0;
        repeat (STAGES+1) @(posedge Clock);
        EXPECT_EQ_LOGIC_N(CO, 1'b1);
        EXPECT_EQ_LOGIC_N(S, MAX-1);
        A <= MAX;
        B <= MAX-1;
        CI <= 1'b1;
        repeat (STAGES+1) @(posedge Clock);
        EXPECT_EQ_LOGIC_N(CO, 1'b1);
        EXPECT_EQ_LOGIC_N(S, MAX-1);
        A <= MAX;
        B <= MAX;
        CI <= 1'b1;
        repeat (STAGES+1) @(posedge Clock);
        EXPECT_EQ_LOGIC_N(CO, 1'b1);
        EXPECT_EQ_LOGIC_N(S, MAX);
    `END_TEST_TASK_N(padderTestbench, add_max_int, WIDTH)

    `TEST_TASK_N(padderTestbench, zero_plus_zero, WIDTH)
        A <= WIDTH'(0);
        B <= WIDTH'(0);
        CI <= 1'b0;
        repeat (STAGES+1) @(posedge Clock);
        EXPECT_EQ_LOGIC_N(S, WIDTH'(0));
        EXPECT_EQ_LOGIC_N(CO, 1'b0);
    `END_TEST_TASK_N(padderTestbench, zero_plus_zero, WIDTH)

    `TEST_TASK_N(padderTestbench, zero_plus_carry_in, WIDTH)
        A <= WIDTH'(0);
        B <= WIDTH'(0);
        CI <= 1'b1;
        repeat (STAGES+1) @(posedge Clock);
        EXPECT_EQ_LOGIC_N(S, WIDTH'(1));
        EXPECT_EQ_LOGIC_N(CO, 1'b0);
    `END_TEST_TASK_N(padderTestbench, zero_plus_carry_in, WIDTH)

    `TEST_TASK_N(padderTestbench, max_int_plus_carry, WIDTH)
        A <= MAX;
        B <= WIDTH'(0);
        CI <= 1'b1;
        repeat (STAGES+1) @(posedge Clock);
        EXPECT_EQ_LOGIC_N(S, WIDTH'(0));
        EXPECT_EQ_LOGIC_N(CO, 1'b1);
    `END_TEST_TASK_N(padderTestbench, max_int_plus_carry, WIDTH)

    // This test assumes a 32 bit input, 4 stages
    `TEST_TASK_N(padderTestbench, sucessive_adds, WIDTH)
        A <= WIDTH'(5);
        B <= WIDTH'(1036);
        CI <= 1'b0;
        repeat (1) @(posedge Clock);
        A <= WIDTH'(7);
        B <= WIDTH'(53);
        CI <= 1'b0;
        repeat (1) @(posedge Clock);
        A <= MAX;
        B <= MAX;
        CI <= 1'b0;
        repeat (1) @(posedge Clock);
        A <= MAX;
        B <= MAX;
        CI <= 1'b1;
        repeat (1) @(posedge Clock);
        A <= WIDTH'(6827);
        B <= WIDTH'(100555);
        CI <= 1'b1;
        repeat (STAGES-3) @(posedge Clock);
        EXPECT_EQ_LOGIC_N(S, 5+1036);
        EXPECT_EQ_LOGIC_N(CO, 1'b0);
        repeat (1) @(posedge Clock);
        EXPECT_EQ_LOGIC_N(S, 7+53);
        EXPECT_EQ_LOGIC_N(CO, 1'b0);
        repeat (1) @(posedge Clock);
        EXPECT_EQ_LOGIC_N(S, MAX-1);
        EXPECT_EQ_LOGIC_N(CO, 1'b1);
        repeat (1) @(posedge Clock);
        EXPECT_EQ_LOGIC_N(S, MAX);
        EXPECT_EQ_LOGIC_N(CO, 1'b1);
        repeat (1) @(posedge Clock);
        EXPECT_EQ_LOGIC_N(S, 6827+100555+1);
        EXPECT_EQ_LOGIC_N(CO, 1'b0);
    `END_TEST_TASK_N(padderTestbench, sucessive_adds, WIDTH)

    logic[WIDTH:0] clockTicks = 0;

    // This test assumes a 32 bit input, 4 stages
    `TEST_TASK_N(padderTestbench, random_testing, WIDTH)
        repeat (MAX_REPEATS)
        begin
            @(posedge Clock)
            begin
                for(int iIter = 0; iIter < STAGES-1; iIter++)
                begin
                    pipeline[iIter+1] <= pipeline[iIter];
                end

                aIter <= $urandom_range(0, MAX);
                bIter <= $urandom_range(0, MAX);
                cInIter <= $urandom_range(0, 1);
                
                pipeline[0] <= {aIter, bIter, cInIter};
                A <= aIter;
                B <= bIter;
                CI <= cInIter;                
                expectedResult <= pipeline[STAGES-1][WIDTH*2:WIDTH+1] + pipeline[STAGES-1][WIDTH:1] + pipeline[STAGES-1][0];
                if(clockTicks > STAGES)
                begin
                    EXPECT_EQ_LOGIC_N(S, expectedResult[WIDTH-1:0]);
                    EXPECT_EQ_LOGIC_N(CO, expectedResult[WIDTH]);
                end
                clockTicks <= clockTicks + 1;
            end
        end
    `END_TEST_TASK_N(padderTestbench, random_testing, WIDTH)

    /*
    // This test assumes a 32 bit input, 4 stages
    `TEST_TASK(padderTestbench, random_testing)
        repeat (MAX_REPEATS)
        begin
            @(posedge Clock)
            begin
                // check the output 4 cycles later
                pipeline[3] <= pipeline[2];
                pipeline[2] <= pipeline[1];
                pipeline[1] <= pipeline[0];

                aIter <= $urandom_range(0, MAX);
                bIter <= $urandom_range(0, MAX);
                cInIter <= $urandom_range(0, 1);
                
                pipeline[0] <= {aIter, bIter, cInIter};
                A <= aIter;
                B <= bIter;
                CI <= cInIter;                
                expectedResult <= pipeline[3][64:33] + pipeline[3][32:1] + pipeline[3][0];
                if(clockTicks > 4)
                begin
                    EXPECT_EQ_LOGIC(S, expectedResult[31:0]);
                    EXPECT_EQ_LOGIC(CO, expectedResult[32]);
                end
                clockTicks <= clockTicks + 1;
            end
        end
    `END_TEST_TASK(padderTestbench, random_testing)
    */

    initial
    begin
        testFramework::TestManager::runAllTasks();
        $finish;
    end    
endmodule