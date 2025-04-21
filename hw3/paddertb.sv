module top;

    logic Clock;
    logic[31:0] S;
    logic CO;
    logic[31:0] A, B;
    logic CI;
    
    // A, B, CI
    logic[64:0] iter = 0;
    logic[31:0] aIter = 0;
    logic[31:0] bIter = 0;
    logic cInIter = 0;
    // S, CO
    logic[32:0] expectedResult;
    integer fails = 0;
    logic[64:0] NUM_RANGE = (64'h1<<((32*2) + 1)) + 4;
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
    );

    /*
    rca #(32) KGD
    (
        .y(expectedResult[31:0]), .cOut(expectedResult[32]), .a(iter[64:32]), .b(iter[32:1], iter[0]); 
    );
    */

    initial
    begin
        Clock = 1'b0;
        forever #20 Clock <= ~Clock;
    end

    initial
    begin
        $display("Begin Testbench");
        //repeat (2147483647)
        repeat (245)
        begin
            @(posedge Clock)
            begin
                $display("Iteration %0d", iter);
                /*
                aIter <= $urandom_range(0, maxInt);
                bIter <= $urandom_range(0, maxInt);
                cInIter <= $urandom_range(0, 1);
                */

                // check the output 4 cycles later
                pipeline[3] <= pipeline[2];
                pipeline[2] <= pipeline[1];
                pipeline[1] <= pipeline[0];

                //pipeline[0] <= {aIter, bIter, cInIter};
                pipeline[0] <= iter;
                //A <= aIter;
                //B <= bIter;
                //CI <= cInIter;
                A <= iter[64:32];
                B <= iter[32:1];
                CI <= iter[0];
                
                expectedResult <= pipeline[3][64:32] + pipeline[3][32:1] + pipeline[3][0];
                `ifdef DEBUG
                    $display("aIter = %0d, bIter = %0d, cInIter = %0d", aIter, bIter, cInIter); 
                    $display("pipeline[3]: %b, pipeline[2]: %b, pipeline[1]: %b, pipeline[0]: %b", pipeline[3], pipeline[2], pipeline[1], pipeline[0]);
                    $display("pipeline[3][64:32] = %0d, pipeline[3][32:1] = %0d, pipeline[3][0] = %0d", pipeline[3][64:32], pipeline[3][32:1], pipeline[3][0]);
                    $display("expectedResult %0d", expectedResult[31:0]);
                    $display("output Sum %0d", S);
                    $display("expected carry %0d", expectedResult[32]);
                    $display("output carry %0d", CO);
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
        $display("Testbench completed, %d failures.\n", fails);
        $finish;
    end

    
endmodule