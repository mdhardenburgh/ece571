module PAdder
(
    input logic Clock,
    output logic[31:0] S,
    output logic CO,
    input logic[31:0] A, B,
    input logic CI,
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

    output logic[6:0] C_debug
);

    // 4‑deep array of 32‑bit regs
    logic[2:0][31:0] pipelineA;
    logic[2:0][31:0] pipelineB;
    logic[3:0][31:0] sum;
    logic[6:0] carry;

    assign sum[0][31:8] = 24'b0;

    assign C_debug[0] = carry[0];
    assign C_debug[1] = carry[1];
    assign C_debug[2] = carry[2];
    assign C_debug[3] = carry[3];
    assign C_debug[4] = carry[4];
    assign C_debug[5] = carry[5];
    assign C_debug[6] = carry[6];

    rca adder1(sum[0][7:0], carry[0], A[7:0], B[7:0], CI);
    rca adder2(sum[1][15:8], carry[2], pipelineA[0][15:8], pipelineB[0][15:8], carry[1]);
    rca adder3(sum[2][23:16], carry[4], pipelineA[1][23:16], pipelineB[1][23:16], carry[3]);
    rca adder4(sum[3][31:24], carry[6], pipelineA[2][31:24], pipelineB[2][31:24], carry[5]);

    assign A_debug0 = pipelineA[0];
    assign A_debug1 = pipelineA[1];
    assign A_debug2 = pipelineA[2];

    assign B_debug0 = pipelineB[0];
    assign B_debug1 = pipelineB[1];
    assign B_debug2 = pipelineB[2];

    assign S_debug0 = sum[0];
    assign S_debug1 = sum[1];
    assign S_debug2 = sum[2];
    assign S_debug3 = sum[3];

    always@(posedge Clock)
    begin
        //pipelineA[3] <= pipelineA[2];
        pipelineA[2] <= pipelineA[1];
        pipelineA[1] <= pipelineA[0];
        pipelineA[0] <= A;

        //pipelineB[3] <= pipelineB[2];
        pipelineB[2] <= pipelineB[1];
        pipelineB[1] <= pipelineB[0];
        pipelineB[0] <= B;

        S <= sum[3];
        sum[3] <= sum[2];
        sum[2] <= sum[1];
        sum[1] <= sum[0];

        CO <= carry[6];
        carry[6] <= carry[5];
        carry[5] <= carry[4];
        carry[4] <= carry[3];
        carry[3] <= carry[2];
        carry[2] <= carry[1];
        carry[1] <= carry[0];
    end

endmodule

