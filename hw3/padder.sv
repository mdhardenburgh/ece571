module PAdder
(
    input logic Clock,
    output logic[31:0] S,
    output logic CO,
    input logic[31:0] A, B,
    input logic CI
);
    logic[31:0] a_pipeline1;
    logic[31:0] b_pipeline1;
    logic[31:0] sum_pipeline1;
    logic[31:0] sum_pipeline2;
    logic[31:0] sum_pipeline3;

    logic[31:0] a_pipeline2;
    logic[31:0] b_pipeline2;

    logic[31:0] a_pipeline3;
    logic[31:0] b_pipeline3;

    logic[7:0] sum_adder1;
    logic[15:0] sum_adder2;
    logic[23:0] sum_adder3;
    logic[31:0] sum_adder4;

    rca adder1(sum_adder1, carryout_adder1, A[7:0], B[7:0], CI);
    pipelineReg pipeline1(Clock, A, B, carryout_adder1, {24'b0, sum_adder1}, a_pipeline1, b_pipeline1, sum_pipeline1, carryout_pipeline1);

    rca adder2(sum_adder2[7:0], carryOut_adder2, a_pipeline1[15:8], b_pipeline1[15:8], carryout_pipeline1);
    pipelineReg pipeline2(Clock, a_pipeline1, b_pipeline1, carryOut_adder2, {(sum_adder2<<8)|sum_pipeline1}, a_pipeline2, b_pipeline2, sum_pipeline2, carryout_pipeline2);

    rca adder3(sum_adder3[7:0], carryOut_adder3, a_pipeline2[23:16], b_pipeline2[23:16], carryout_pipeline2);
    pipelineReg pipeline3(Clock, a_pipeline2, b_pipeline2, carryOut_adder3, {(sum_adder3<<16)|sum_pipeline2}, a_pipeline3, b_pipeline3, sum_pipeline3, carryout_pipeline3);

    rca adder4(sum_adder4[7:0], carryOut_adder4, a_pipeline3[31:24], b_pipeline3[31:24], carryout_pipeline3);
    lastPipelineReg last(Clock, carryOut_adder4, {(sum_adder4<<24)|sum_pipeline3}, S, CI);

endmodule

module pipelineReg
(
    input logic Clock,
    input logic[31:0] Ain, Bin,
    input logic carryOutInput,
    input logic[31:0] inputSum,
    output logic[31:0] Aout, Bout,
    output logic[31:0] outputSum,
    output logic carryOutOutput
);
    always@(posedge Clock)
    begin
        Aout <= Ain;
        Bout <= Bin;
        carryOutOutput <= carryOutInput;
        outputSum <= inputSum;
    end
endmodule

module lastPipelineReg
(
    input logic Clock,
    input logic carryOutInput,
    input logic[31:0] inputSum,
    output logic[31:0] outputSum,
    output logic carryOutOutput
);
    always@(posedge Clock)
    begin
        carryOutOutput <= carryOutInput;
        outputSum <= inputSum;
    end
endmodule