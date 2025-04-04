// copyright (C) Matthew Hardenburgh
// matthew@hardenburgh.io

`timescale 1ns / 1ps //`timescale <unit_time> / <resolution>

module iszerotb;
    // Inputs to DUT
	reg [3:0] BCD;
    // Outputs from DUT
    wire Zero;

    // simulation variables and signals
    integer oneDigitBcd;

    integer fails = 0;
    reg expected = 1'b0;

    // Instantiate module under test
    IsZero dut 
    (
        .Zero(Zero),
        .BCD(BCD)
    );

    initial
    begin
        $display("Starting IsZero module testbench");
    
        for (oneDigitBcd = 0; oneDigitBcd < 10; oneDigitBcd++)
        begin
            // isolate the digit
            BCD = oneDigitBcd%10;
            
            // Allow signals to propogate
            #1;

            // Calculate if zero
            if(oneDigitBcd == 4'b0000)
            begin
                expected = 1'b1;
            end
            else
            begin
                expected = 1'b0;
            end

            // compare DUT result against expected and if pass or fail
            if(expected === Zero)
            begin
                $display("PASS, oneDigitBcd is: %0d\n", oneDigitBcd);
            end
            else
            begin
                $display("FAIL: oneDigitBcd: %0d - Expected: %0d, got: %0d\n", oneDigitBcd, expected, Zero);
                fails++;
            end
        end
        $display("Testbench completed, %0d failures.\n", fails);
        $finish;
    end
endmodule