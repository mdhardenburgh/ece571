typedef enum logic[2:0] 
{
    IDLE,
    DOUBLE,
    DABBLE,
    READY,
    RESET,
    EXCPETION
} states_t;

module DoubleDabble #(parameter N = 32)
    (
        input logic Clock,
        input logic Reset,
        input logic Start,
        input logic[N-1:0] V, // input vector
        output logic[((4*(N+2))/3)-1:0] BCD,
        output logic Ready
    );

    states_t stateCounter;

    always_ff@(posedge Clock)
    begin: nextStateLogic
        if
        case(stateCounter)
            RESET:
            begin
                if(Reset)
            end
        endcase
    end

    always_comb@(posedge Clock)
    begin: outputLogic
        case(stateCounter)
            RESET:
            begin
                if()
            end
        endcase
    end
endmodule

module pipelineStage
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