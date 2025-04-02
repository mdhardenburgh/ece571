`timescale 1ns / 1ps //`timescale <unit_time> / <resolution>

module leapyeartb
    // Inputs to DUT
	reg [3:0] YM YH, YT, YO;
    // Outputs from DUT
    wire LY;

    // simulation variables and signals
    integer year;
    reg expected = 1'b0;

    // Instantiate module under test
    LeapYear dut 
    (
        .LY(LY),
        .YM(YM),
        .YH(YH),
        .YT(YT),
        .YO(YO)
    );

    initial
    begin
        $display("Starting LeapYear module testbench")
    end

    for (year = 1582; year <= 4818; year++)
    begin
        // isolate the digit
        YO = year%10;
        YT = (year/10)%10;
        YH = (year/100)%10;
        YM = (year/1000)%10;
        
        // Allow signals to propogate
        #1;
        // Calculate if leap year
        if(((year%4 == 0)||(year%100 == 0)) && (year%400 != 0))
        begin
            expected = 1'b1;
        end
        else
        begin
            expected = 1'b0;
        end

        // compare DUT result against expected and if pass or fail
        if(expected == LY)
        begin
            $display("PASS, Year %0d \n", year);
        end
        else
        begin
            $display("FAIL: Year %0d - Expected %0d, got %0d", year, expected, LY);
        end
    end
    $display("Testbench completed.");
    $finish;
endmodule