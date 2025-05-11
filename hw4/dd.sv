
typedef struct packed 
{
    logic[m_ddVectorWidth-1:0] doubleDabbleValue;
    logic[m_N-1:0] binaryValue;
} doubleDabble_t;

module DoubleDabble #(parameter N = 32)
    (
        input logic Clock,
        input logic Reset,
        input logic Start,
        input logic[N-1:0] V, // input vector
        output logic[((4*(N+2))/3)-1:0] BCD,
        output logic Ready
    );
    localparam ddVectorWidth = ((4*(N+2))/3);
    localparam vectorWidth = ddVectorWidth + N

    logic[vectorWidth-1:0][N-1:0] pipelineVector;
    logic[vectorWidth-1:0][N-1:0] satVector;

    logic[N-1:0] startVector;

    genvar iIter;
    generate
        for(iIter = 0; iIter < N; iIter++)
        begin
            if(iIter == 0)
            begin
                pipelineStage pls(Clock, Start, Reset, {{ ddVectorWidth{ 1'b0 } }, V}, pipelineVector[iIter], startVector[iIter]);
                shiftAndAddThree sat(startVector[iIter], pipelineVector[iIter], satVector[iIter]);
            end
            else if(iIter == N-1)
            begin
                pipelineStage pls(Clock, startVector[iIter-1], Reset, pipelineVector[iIter-1], pipelineVector[iIter], startVector[iIter]);
                shift slast(startVector[iIter], pipelineVector[iIter], BCD, Read);
            end
            else
            begin
                pipelineStage pls(Clock, startVector[iIter-1], Reset, pipelineVector[iIter-1], pipelineVector[iIter], startVector[iIter]);
                shiftAndAddThree sat(startVector[iIter], pipelineVector[iIter], satVector[]);
            end
        end
    endgenerate


endmodule

module pipelineStage #(parameter N = 32)
(
    input logic Clock,
    input logic inputStart,
    input logic Reset,
    input logic[(((4*(N+2))/3) + N):0] inputVector,
    output logic[(((4*(N+2))/3) + N)-1:0] outputVector
    output logic ouputStart
    
);

    always_ff@(posedge Clock)
    begin
        
        // if reset, flush
        if(Reset == 1)
        begin
            outputVector <= 0;
            ouputStart <= 0;
        end
        else
        begin
            outputVector <= inputVector;
            ouputStart <= inputStart;
        end
    end
endmodule

module shiftAndAddThree  #(parameter N = 32)
(
    input logic Start,
    input logic[(((4*(N+2))/3) + N)-1:0] inputVector,
    output logic[(((4*(N+2))/3) + N)-1:0] outputVector
    
);
    localparam  ddVectorWidth = (4*(m_N+2)/3);
    
    always_comb@(inputVector)
    begin

        if(Start == 1)
        begin
            outputVector = inputVector << 1;

            for(int jIter = 0; jIter < (ddVectorWidth/4); jIter++)
            begin

                // compute the bit-offset of this 4-bit group
                int base = m_N + 4*jIter;

                // grab a 4-bit nibble dynamically
                logic [3:0] nibble = outputVector[base +: 4];

                // if it’s ≥ 5, add 3
                if (nibble >= 5)
                begin
                    outputVector[base +: 4] = nibble + 3;
                end
            end
        end
        else if(Start == 0)
        begin
            outputVector = 0;
        end
    end
endmodule

module shift  #(parameter N = 32)
(
    input logic Start,
    input logic[(((4*(N+2))/3) + N)-1:0] inputVector,
    output logic[(((4*(N+2))/3))-1:0] bcdVector,
    output logic Ready
    
);
    localparam  vectorWidth = (4*(N+2)/3) + N;

    always_comb@(inputVector)
    begin

        if(Start == 1)
        begin
            inputVector = inputVector << 1;
            bcdVector = inputVector[vectorWidth-1:N]
            Ready = 1;
        end
        else if(Start == 0)
        begin
            bcdVector = 0;
            Ready = 0;
        end
    end
endmodule
