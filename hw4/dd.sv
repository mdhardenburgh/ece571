

module DoubleDabble #(parameter N = 32)
    (
        input logic Clock,
        input logic Reset,
        input logic Start,
        input logic[N-1:0] V, // input vector
        output logic[((4*(N+2))/3)-1:0] BCD,
        output logic Ready
    );
/*
    localparam vectorWidth = N + $rtoi($ceil((4*(N+2)/3)));
    localparam dabbleVectorWidth = $rtoi($ceil(4*(N+2)/3));

    logic[dabbleVectorWidth-1:0] emptyDabbleVector = 0;
    logic[vectorWidth-1:0] doubleDabbleVector = {emptyDabbleVector, vector};

*/
endmodule
/*
module pipelineStage #(parameter vectorWidth = 77)
(
    input logic Clock,
    input logic Reset,
    input logic[N-1:0] inputVector,
    output logic[N-1:0] outputVector,
    
);
    always_ff@(posedge Clock)
    begin
        if(Reset == 1)
        begin
            outputVector <= 0;
        end
        else
        begin
            outputVector <= inputVector;
        end
    end
endmodule

module shiftAndAddThree  #(parameter vectorWidth = 77)
(
    input logic[N-1:0] inputVector,
    output logic[N-1:0] outputVector,
    
);
    always_comb@(inputVector)
    begin
        inputVector = inputVector << 1;

        else
        begin
            outputVector = inputVector;
        end
    end
endmodule
*/