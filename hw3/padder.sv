module PAdder
(
    input logic Clock,
    output logic[31:0] S,
    output logic CO,
    input logic[31:0] A, B,
    input logic CI
    `ifdef DEBUG
        ,
        output logic[31:0] A_debug0,
        output logic[31:0] A_debug1,
        output logic[31:0] A_debug2,
        output logic[31:0] A_debug3,

        output logic[31:0] B_debug0,
        output logic[31:0] B_debug1,
        output logic[31:0] B_debug2,
        output logic[31:0] B_debug3,

        output logic[31:0] S_debug0,
        output logic[31:0] S_debug1,
        output logic[31:0] S_debug2,
        output logic[31:0] S_debug3,

        output logic[3:0] C_debug
    `endif
);

    logic[7:0] sum0;
    logic[31:0] pipeline0Sum;
    logic carry0;
    logic pipeline0Carry;
    logic[31:0] pipeline0A;
    logic[31:0] pipeline0B;

    logic[7:0] sum1;
    logic[31:0] pipeline1Sum;
    logic carry1;
    logic pipeline1Carry;
    logic[31:0] pipeline1A;
    logic[31:0] pipeline1B;

    logic[7:0] sum2;
    logic carry2;
    logic[31:0] pipeline2Sum;
    logic pipeline2Carry;
    logic[31:0] pipeline2A;
    logic[31:0] pipeline2B;

    logic[7:0] sum3;
    logic carry3;
    logic[31:0] pipeline3A;
    logic[31:0] pipeline3B;

    `ifdef DEBUG
        assign A_debug0 = pipeline0A;
        assign A_debug1 = pipeline1A;
        assign A_debug2 = pipeline2A;
        assign A_debug3 = pipeline3A;

        assign B_debug0 = pipeline0B;
        assign B_debug1 = pipeline1B;
        assign B_debug2 = pipeline2B;
        assign B_debug3 = pipeline3B;

        assign S_debug0 = pipeline0Sum;
        assign S_debug1 = pipeline1Sum;
        assign S_debug2 = pipeline2Sum;
        assign S_debug3 = S;

        assign C_debug[0] = pipeline0Carry;
        assign C_debug[1] = pipeline1Carry;
        assign C_debug[2] = pipeline2Carry;
        assign C_debug[3] = CO;
    `endif

    rca adder0(sum0, carry0, A[7:0], B[7:0], CI);
    pipelineStage stage0(Clock, {24'b0, sum0}, carry0, A, B, pipeline0Sum, pipeline0Carry, pipeline0A, pipeline0B);

    rca adder1(sum1, carry1, pipeline0A[15:8], pipeline0B[15:8], pipeline0Carry);
    pipelineStage stage1(Clock, {16'b0, sum1, pipeline0Sum[7:0]}, carry1, pipeline0A, pipeline0B, pipeline1Sum, pipeline1Carry, pipeline1A, pipeline1B);

    rca adder2(sum2, carry2, pipeline1A[23:16], pipeline1B[23:16], pipeline1Carry);
    pipelineStage stage2(Clock, {8'b0, sum2, pipeline1Sum[15:0]}, carry2, pipeline1A, pipeline1B, pipeline2Sum, pipeline2Carry, pipeline2A, pipeline2B);

    rca adder3(sum3, carry3, pipeline2A[31:24], pipeline2B[31:24], pipeline2Carry);
    pipelineStage stage3(Clock, {sum3, pipeline2Sum[23:0]}, carry3, pipeline2A, pipeline2B, S, CO, pipeline3A, pipeline3B);

endmodule

module pipelineStage
(
    input logic Clock,
    input logic[31:0] inputSum,
    input logic carryOut,
    input logic[31:0] inputPipelineA,
    input logic[31:0] inputPipelineB,

    output logic[31:0] outputSum,
    output logic carryIn,
    output logic[31:0] outputPipelineA,
    output logic[31:0] outputPipelineB
);
    always@(posedge Clock)
    begin
        outputSum <= inputSum;
        carryIn <= carryOut;
        outputPipelineA <= inputPipelineA;
        outputPipelineB <= inputPipelineB;
    end
endmodule

