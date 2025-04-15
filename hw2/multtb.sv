// use generates

// % vsim –c –gNumBits=8 Top
module top #(parameter WIDTH = 8);

    // Inputs to DUT
	reg [WIDTH-1:0] multiplicand, multiplier;
    // Outputs from DUT
    wire[(WIDTH*2)-1:0] product;
    wire[(WIDTH)-1:0] rcaInputB;
    wire carryOut;
    wire[(WIDTH)-1:0] rcaInputA;
    wire[WIDTH-1:0] partialProducts_D;

    localparam NUM_ITERS = 2**((WIDTH*2));
    reg[NUM_ITERS -1:0] iter;
    reg[(WIDTH*2)-1:0] expectedResult;
    integer fails = 0;

    multiply #(.WIDTH(WIDTH)) dut
    (
        .multiplicand(multiplicand), .multiplier(multiplier), .product(product), .rcaInputB_D(rcaInputB), .carryOut(carryOut), .rcaInputA_D(rcaInputA), .partialProducts_D(partialProducts_D)
    );

    initial
    begin
        for(iter = 0; iter <= NUM_ITERS; iter++)
        begin
            {multiplicand, multiplier} = iter;
            #(WIDTH+WIDTH) // let inputs percolate
            expectedResult = multiplier*multiplicand;
            if(expectedResult === product)
            begin
                `ifdef DEBUG
                    $display("Iteration %0b, PASS. expected product: %0b,  multiplicand, M = %0b, multiplier, Q = %0b, product, P %0b, rcaInputB = %b, carryOut = %0b, rcaInputA = %b, partialProducts_D = %b\n", iter, expectedResult, multiplicand, multiplier, product, rcaInputB, carryOut, rcaInputA, partialProducts_D);
                `endif
            end
            else
            begin
                $display("Iteration %0b, FAIL. expected product: %0b,  multiplicand, M = %0b, multiplier, Q = %0b, product, P %0b, rcaInputB = %b, carryOut = %0b, rcaInputA = %b, partialProducts_D = %b\n", iter, expectedResult, multiplicand, multiplier, product, rcaInputB, carryOut, rcaInputA, partialProducts_D);
                fails++;
            end
        end
        $display("Testbench completed, %0d failures.\n", fails);
        $finish;
    end
endmodule