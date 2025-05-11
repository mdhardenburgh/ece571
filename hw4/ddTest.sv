`ifndef DD_TEST
`define DD_TEST

class DoubleDabbleTest #(parameter int m_N = 32);
    string m_className = "DoubleDabbleTest";
    localparam  m_ddVectorWidth = (4*(m_N+2)/3);
    localparam m_vectorWidth = m_N + m_ddVectorWidth;
    local int m_clockCycle;
    local int m_fd;
    local int m_totalFailures;

    typedef struct packed 
    {
        logic[m_ddVectorWidth-1:0] doubleDabbleValue;
        logic[m_N-1:0] binaryValue;
    } doubleDabble_t;

    function new(int fd, int clockCycle);
        m_fd = fd;
        m_clockCycle = clockCycle;
    endfunction
    
    //shift left, if 5 or more add 3
    local function automatic logic[m_ddVectorWidth-1:0] doubleDabble 
    (
        input logic[m_N-1:0] vector
    );
        doubleDabble_t doubleDabbleVector = {{ m_ddVectorWidth{ 1'b0 } }, vector};

        for(int iIter = 0; iIter < m_N-1; iIter++)
        begin
            // shift in binary
            doubleDabbleVector = doubleDabbleVector << 1;

            // start at N and stride every 4 and check for carries
            for(int jIter = 0; jIter < (m_ddVectorWidth/4); jIter++)
            begin

                // compute the bit-offset of this 4-bit group
                int base = m_N + 4*jIter;

                // grab a 4-bit nibble dynamically
                logic [3:0] nibble = doubleDabbleVector[base +: 4];

                // if it’s ≥ 5, add 3
                if (nibble >= 5)
                    doubleDabbleVector[base +: 4] = nibble + 3;
            end
        end
        doubleDabbleVector = doubleDabbleVector << 1;
        return doubleDabbleVector[m_vectorWidth-1:m_N];
    endfunction

    task automatic test_all_bits_high
    (
        ref logic Reset,
        ref logic Start,
        ref logic[m_N-1:0] V,
        input logic[m_ddVectorWidth-1:0] BCD,
        input logic Ready,
        ref int cycle_count
    );
        string testName = "test_all_bits_high";
        // replicate 1 for m_N number of times
        V = { m_N{ 1'b1 } };
        //V = $urandom_range(0, (2**m_N)-1);
        $display("V is %b", V);

        $fdisplay(m_fd, "Begin %s.%s", m_className, testName);
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

        $fdisplay(m_fd, "End %s.%s", m_className, testName);

        m_totalFailures++;
    endtask
endclass
`endif