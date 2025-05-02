`ifndef DD_ALGORITHM
`define DD_ALGORITHM
package ddAlgorithm;

    parameter N = 32;
    parameter functionVectorWidth = $rtoi($ceil((4*(N+2)/3)));
    
    //shift left, if 5 or more add 3
    function automatic logic[functionVectorWidth-1:0] DoubleDabble_A //#(parameter int N = 32)
    (
        input logic[N-1:0] vector
        //output logic[(4*(N+2)/3)-1:0] bcd
    );
        localparam vectorWidth = N + $rtoi($ceil((4*(N+2)/3)));
        localparam dabbleVectorWidth = $rtoi($ceil(4*(N+2)/3));
        logic[dabbleVectorWidth-1:0] emptyDabbleVector = 0;
        logic[vectorWidth-1:0] doubleDabbleVector = {emptyDabbleVector, vector};

        $display("doubleDabbleVector: %b", doubleDabbleVector);
        $display("vectorWidth: %0d", vectorWidth);
        $display("dabbleVectorWidth: %0d", dabbleVectorWidth);

        for(int iIter = 0; iIter < N-1; iIter++)
        begin
            // shift in binary
            //$display("doubleDabbleVector before shift %b", doubleDabbleVector);
            doubleDabbleVector = doubleDabbleVector << 1;
            //$display("doubleDabbleVector after shift %b", doubleDabbleVector);

            // start at N and stride every 4 and check for carries
            for(int jIter = 0; jIter < (dabbleVectorWidth/4); jIter++)
            begin

                // compute the bit-offset of this 4-bit group
                int base = N + 4*jIter;

                // grab a 4-bit nibble dynamically
                logic [3:0] nibble = doubleDabbleVector[base +: 4];

                // if it’s ≥ 5, add 3
                if (nibble >= 5)
                    doubleDabbleVector[base +: 4] = nibble + 3;
            end
            $display("doubleDabbleVector after shift and carry %b", doubleDabbleVector);
        end
        doubleDabbleVector = doubleDabbleVector << 1;
        $display("N is %d: ", N);
        $display("vectorWidth is %d: ", vectorWidth);
        return doubleDabbleVector[vectorWidth-1:N];
    endfunction

    task test_verify_algorithm_nibble
    endtask

endpackage
`endif