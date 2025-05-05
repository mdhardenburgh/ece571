`ifndef DD_TEST
`define DD_TEST

class DoubleDabbleTest #(parameter int m_N = 32);
    string className = "DoubleDabbleTest";
    localparam  m_ddVectorWidth = (4*(m_N+2)/3);
    local int m_clockCycle;
    local int m_fd;

    function new(int fd, int clockCycle);
        m_fd = fd;
        m_clockCycle = clockCycle;
    endfunction
    
    //shift left, if 5 or more add 3
    local function automatic logic[m_ddVectorWidth-1:0] doubleDabble 
    (
        input logic[m_N-1:0] vector
    );
        localparam vectorWidth = m_N + m_ddVectorWidth;
        localparam dabbleVectorWidth = m_ddVectorWidth;
        logic[dabbleVectorWidth-1:0] emptyDabbleVector = 0;
        logic[vectorWidth-1:0] doubleDabbleVector = {emptyDabbleVector, vector};

        $display("doubleDabbleVector: %b", doubleDabbleVector);
        $display("vectorWidth: %0d", vectorWidth);
        $display("dabbleVectorWidth: %0d", dabbleVectorWidth);

        for(int iIter = 0; iIter < m_N-1; iIter++)
        begin
            // shift in binary
            //$display("doubleDabbleVector before shift %b", doubleDabbleVector);
            doubleDabbleVector = doubleDabbleVector << 1;
            //$display("doubleDabbleVector after shift %b", doubleDabbleVector);

            // start at N and stride every 4 and check for carries
            for(int jIter = 0; jIter < (dabbleVectorWidth/4); jIter++)
            begin

                // compute the bit-offset of this 4-bit group
                int base = m_N + 4*jIter;

                // grab a 4-bit nibble dynamically
                logic [3:0] nibble = doubleDabbleVector[base +: 4];

                // if it’s ≥ 5, add 3
                if (nibble >= 5)
                    doubleDabbleVector[base +: 4] = nibble + 3;
            end
            //$display("doubleDabbleVector after shift and carry %b", doubleDabbleVector);
        end
        doubleDabbleVector = doubleDabbleVector << 1;
        $display("N is %d: ", m_N);
        $display("vectorWidth is %d: ", vectorWidth);
        return doubleDabbleVector[vectorWidth-1:m_N];
    endfunction

    task automatic test_all_bits_high
    (
        output logic Reset,
        output logic Start,
        inout logic[m_N-1:0] V,
        input logic[m_ddVectorWidth-1:0] BCD,
        input logic Ready,
        ref int cycle_count,
        ref int totalFailures
    );
        int errors = 0;

        V = 0;
        //V = $urandom_range(0, (2**m_N)-1);
        $display("V is %b", V);

        $fdisplay(m_fd, "Begin DoubleDabbleTest.test_verify_dd");
        cycle_count = 0;

        Start = 1;
        Reset = 1;

        #m_clockCycle; 

        // should be ready after a reset
        Reset = 0;

        #(m_N * m_clockCycle);

        if((Ready === 1) && (doubleDabble(V) === BCD))
        begin
            $fdisplay(m_fd, "PASS");
        end
        else
        begin
            $fdisplay(m_fd, "FAIL, expected Ready === 1, Ready === %b. Expected BCD %b, Result BCD %b", Ready, doubleDabble(V), BCD);
        end

        $fdisplay(m_fd, "End DoubleDabbleTest.test_verify_dd", className);

        totalFailures++;
    endtask
endclass
`endif