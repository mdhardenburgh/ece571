`ifndef DD_ALGORITHM
`define DD_ALGORITHM
package ddAlgorithm;

    parameter N = 32;
    
    //shift left, if 5 or more add 3
    function automatic logic[(4*(N+2)/3)-1:0] DoubleDabble_A //#(parameter int N = 32)
    (
        input logic[N-1:0] vector
        //output logic[(4*(N+2)/3)-1:0] bcd
    );
        localparam vectorWidth = N + (4*(N+2)/3);
        localparam dabbleVectorWidth = (4*(N+2)/3);
        logic[dabbleVectorWidth-1:0] emptyDabbleVector;
        logic[vectorWidth-1:0] doubleDabbleVector = {emptyDabbleVector, vector};

        for(int iIter = 0; iIter < N; iIter++)
        begin
            // shift in binary
            doubleDabbleVector = doubleDabbleVector << 1;

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
            // int decimalPlace = $rtoi(ceil(iter/4));
            // logic[dabbleVectorWidth] dabbleVector = doubleDabbleVector[vectorWidth-1:dabbleVectorWidth]
        end
        return doubleDabbleVector;
    endfunction

endpackage
`endif