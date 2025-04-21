module top;

    logic Clock;
    logic[31:0] S;
    logic CO;
    logic[31:0] A, B;
    logic CI;

    `ifdef DEBUG
    logic[31:0] A_debug0;
    logic[31:0] A_debug1;
    logic[31:0] A_debug2;
    logic[31:0] A_debug3;

    logic[31:0] B_debug0;
    logic[31:0] B_debug1;
    logic[31:0] B_debug2;
    logic[31:0] B_debug3;

    logic[31:0] S_debug0;
    logic[31:0] S_debug1;
    logic[31:0] S_debug2;
    logic[31:0] S_debug3;

    logic[3:0] C_debug;
    `endif
    
    // A, B, CI
    logic[64:0] iter = 0;
    logic[31:0] aIter = 0;
    logic[31:0] bIter = 0;
    logic cInIter = 0;
    // S, CO
    logic[32:0] expectedResult;
    integer fails = 0;
    integer maxInt = 2147483647;

    // 4‑deep array of 32‑bit regs
    logic [3:0][64:0] pipeline;

    PAdder dut
    (
        .Clock(Clock),
        .S(S),
        .CO(CO),
        .A(A),
        .B(B),
        .CI(CI)
        `ifdef DEBUG
        ,
        .A_debug0(A_debug0),
        .A_debug1(A_debug1),
        .A_debug2(A_debug2),
        .A_debug3(A_debug3),

        .B_debug0(B_debug0),
        .B_debug1(B_debug1),
        .B_debug2(B_debug2),
        .B_debug3(B_debug3),

        .S_debug0(S_debug0),
        .S_debug1(S_debug1),
        .S_debug2(S_debug2),
        .S_debug3(S_debug3),

        .C_debug(C_debug)
        `endif
    );

    initial
    begin
        Clock = 1'b0;
        forever #20 Clock <= ~Clock;
    end

    initial
    begin
        $display("Begin Testbench");
        repeat (maxInt)
        begin
            @(posedge Clock)
            begin
                $display("Iteration %0d", iter);

                // check the output 4 cycles later
                pipeline[3] <= pipeline[2];
                pipeline[2] <= pipeline[1];
                pipeline[1] <= pipeline[0];

                aIter <= $urandom_range(0, maxInt);
                bIter <= $urandom_range(0, maxInt);
                cInIter <= $urandom_range(0, 1);
                
                pipeline[0] <= {aIter, bIter, cInIter};
                A <= aIter;
                B <= bIter;
                CI <= cInIter;                
                expectedResult <= pipeline[3][64:33] + pipeline[3][32:1] + pipeline[3][0];
                `ifdef DEBUG
                    $display("aIter = %0d, bIter = %0d, cInIter = %0d", aIter, bIter, cInIter); 
                    $display("pipeline[3]: %b, pipeline[2]: %b, pipeline[1]: %b, pipeline[0]: %b", pipeline[3], pipeline[2], pipeline[1], pipeline[0]);
                    $display("pipeline[3][64:32] = %0d, pipeline[3][33:1] = %0d, pipeline[3][0] = %0d", pipeline[3][64:33], pipeline[3][32:1], pipeline[3][0]);
                    $display("expectedResult %0d, %b", expectedResult[31:0], expectedResult[31:0]);
                    $display("output Sum %0d, %b", S, S);
                    $display("expected carry %0d", expectedResult[32]);
                    $display("output carry %0d", CO);
                    $display("A_debug0: %b, A_debug1: %b, A_debug2: %b", A_debug0, A_debug1, A_debug2);
                    $display("B_debug0: %b, B_debug1: %b, B_debug2: %b", B_debug0, B_debug1, B_debug2);
                    $display("S_debug0: %b, S_debug1: %b, S_debug2: %b, S_debug3: %b", S_debug0, S_debug1, S_debug2, S_debug3);
                    $display("C_debug[3]: %b, C_debug[2]: %b, C_debug[1]: %b, C_debug[0]: %b", C_debug[3], C_debug[2], C_debug[1], C_debug[0]);
                `endif
                if((expectedResult[31:0] === S)&&(expectedResult[32] === CO))
                begin
                    `ifdef DEBUG
                        $display("Iteration %0d, PASS. expected sum: %b, expected carry: %b, S = %b, CO = %b, A = %b, B = %b, CO = %b \n", iter, expectedResult[31:0], expectedResult[32], S, CO, A, B, CO);
                    `endif
                end
                else
                begin
                    $display("Iteration %0d, FAIL. expected sum: %b, expected carry: %b, S = %b, CO = %b, A = %b, B = %b, CO = %b \n", iter, expectedResult[31:0], expectedResult[32], S, CO, A, B, CO);
                    fails++;
                end
            end
            iter++;
        end
        $display("Testbench completed, %0d failures.\n", fails);
        $finish;
    end

    
endmodule