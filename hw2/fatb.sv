/**
    copyright (C) Matthew Hardenburgh
    matthew@hardenburgh.io
*/

module top;

    // inputs to dut should always be reg
    reg[3:0] myInput;
    wire y, cOut;
    integer fails = 0;

    fa dut
    (
        y,
        cOut,
        myInput[2], // A
        myInput[1], // B
        myInput[0]  // C
    );
    
    initial 
    begin
        $display("Starting full adder module testbench\n");
        for(myInput = 3'd0; myInput <= 3'd7; myInput++)
        begin
            #10 // let inputs percolate
            // y = C XOR (A XOR B)
            // cout = BC + AC + AB
            if
            (
                (myInput[0]^(myInput[2]^myInput[1]) === y) &&
                ((myInput[1]&myInput[0] | myInput[2]&myInput[0] | myInput[2]&myInput[1]) === cOut)
            )
            begin
                $display("PASS, myInput is: %0d\n", myInput);
            end
            else
            begin
                $display("FAIL, y is %b, cOut is %b, A is: %b, B is: %b, C is: %b\n", y, cOut, myInput[2], myInput[1], myInput[0]);
                fails++;
            end
        end
        $display("Testbench completed, %0d failures.\n", fails);
        $finish;
    end
endmodule