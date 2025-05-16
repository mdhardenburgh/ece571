`ifndef DD_TEST
`define DD_TEST

package doubleDabblePkg;

    parameter int N = 32;
    localparam  m_ddVectorWidth = (4*(N+2)/3);
    localparam m_vectorWidth = N + m_ddVectorWidth;

    typedef struct packed 
    {
        logic[m_ddVectorWidth-1:0] doubleDabbleValue;
        logic[N-1:0] binaryValue;
    } doubleDabble_t;

    function automatic logic[m_ddVectorWidth-1:0] doubleDabble 
        (
            input logic[N-1:0] vector
        );
        doubleDabble_t doubleDabbleVector = {{ m_ddVectorWidth{ 1'b0 } }, vector};

        for(int iIter = 0; iIter < N-1; iIter++)
        begin
            // shift in binary
            doubleDabbleVector = doubleDabbleVector << 1;

            // start at N and stride every 4 and check for carries
            for(int jIter = 0; jIter < (m_ddVectorWidth/4); jIter++)
            begin

                // compute the bit-offset of this 4-bit group
                int base = N + 4*jIter;

                // grab a 4-bit nibble dynamically
                logic [3:0] nibble = doubleDabbleVector[base +: 4];

                // if it’s ≥ 5, add 3
                if (nibble >= 5)
                    doubleDabbleVector[base +: 4] = nibble + 3;
            end
        end
        doubleDabbleVector = doubleDabbleVector << 1;
        return doubleDabbleVector[m_vectorWidth-1:N];
    endfunction
endpackage
`endif
