// % vsim –c –gNumBits=8 Top
module top #(parameter WIDTH = 8);

    // Inputs to DUT
	reg [WIDTH-1:0] a, b;
    reg c;
    // Outputs from DUT
    wire[WIDTH-1:0] y;
    wire cOut;

    localparam NUM_ITERS = 2**((WIDTH*2) + 1);
    reg[NUM_ITERS -1:0] iter;
    reg[WIDTH:0] expectedResult;
    integer fails = 0;

    rca #(.WIDTH(WIDTH)) dut
    (
        .y(y), .cOut(cOut), .a(a), .b(b), .c(c)
    );

    initial
    begin
        for(iter = 0; iter <= NUM_ITERS; iter++)
        begin
            {a, b, c} = iter;
            #(WIDTH+1) // let inputs percolate
            expectedResult = a + b + c;
            if((expectedResult[WIDTH - 1:0] === y) && (expectedResult[WIDTH] === cOut))
            begin
                `ifdef DEBUG
                    $display("Iteration %0b, PASS. expected sum: %0b, expected carry: %0b, y = %0b, cOut = %0b, a = %0b, b = %0b, c = %0b \n", iter, expectedResult[WIDTH-1:0], expectedResult[WIDTH], y, cOut, a, b, c);
                `endif
            end
            else
            begin
                $display("Iteration %0b, FAIL. expected sum: %0b, expected carry: %0b, y = %0b, cOut = %0b, a = %0b, b = %0b, c = %0b \n", iter, expectedResult[WIDTH-1:0], expectedResult[WIDTH], y, cOut, a, b, c);
                fails++;
            end
        end
        $display("Testbench completed, %0d failures.\n", fails);
        $finish;
    end
endmodule