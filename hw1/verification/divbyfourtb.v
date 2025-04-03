`timescale 1ns / 1ps //`timescale <unit_time> / <resolution>

module divbyfourtb;
    // Inputs to DUT
	reg [3:0] YT, YO;
    // Outputs from DUT
    wire Divisible;

    // simulation variables and signals
    integer twoDigitBcdNumber;

    integer fails = 0;
    reg expected = 1'b0;

    // Instantiate module under test
    DivisibleByFour dut 
    (
        .Divisible(Divisible),
        .YT(YT),
        .YO(YO)
    );

    initial
    begin
        $display("Starting DivisibleByFour module testbench");
    
        for (twoDigitBcdNumber = 0; twoDigitBcdNumber < 100; twoDigitBcdNumber++)
        begin
            // isolate the digit
            YO = twoDigitBcdNumber%10;
            YT = (twoDigitBcdNumber/10)%10;
            
            // Allow signals to propogate
            #1;

            // Calculate if divisible by 4
            if((twoDigitBcdNumber%4) == 0)
            begin
                expected = 1'b1;
            end
            else
            begin
                expected = 1'b0;
            end

            // compare DUT result against expected and if pass or fail
            if(expected === Divisible)
            begin
                $display("PASS, twoDigitBcdNumber is: %0d\n", twoDigitBcdNumber);
            end
            else
            begin
                $display("FAIL: twoDigitBcdNumber: %0d - Expected: %0d, got: %0d\n", twoDigitBcdNumber, expected, Divisible);
                fails++;
            end
        end
        $display("Testbench completed, %0d failures.\n", fails);
        $finish;
    end
endmodule