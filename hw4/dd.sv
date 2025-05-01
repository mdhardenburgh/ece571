typedef enum logic[1:0] 
{
    IDLE,
    DOUBLE,
    DABBLE,
    EXCPETION
} states_t;

module DoubleDabble #(parameter  N = 32)
    (
        input logic Clock,
        input logic Reset,
        input logic Start,
        input logic[N-1:0] V, // input vector
        output logic[((4*(N+2))/3)-1:0] BCD,
        output logic Ready
    );
endmodule