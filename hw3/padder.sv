module PAdder
(
    input logic Clock,
    output logic[31:0] S,
    output logic CO,
    input logic[31:0] A, B,
    input logic CI
);
    wire[31:0] firstToSecond_Aout;
    wire[31:0] firstToSecond_Bout;
    wire[31:0] firstToSecond_sum;
    wire firstToSecond_carryOut;

    wire[31:0] secondToThird_Aout;
    wire[31:0] secondToThird_Bout;
    wire[31:0] secondToThird_sum;
    wire secondToThird_carryOut;

    wire[31:0] thirdToFourth_Aout;
    wire[31:0] thirdToFourth_Bout;
    wire[31:0] thirdToFourth_sum;
    wire thirdToFourth_carryOut;
    
    firstPipelineReg first(Clock, A, B, CI, firstToSecond_Aout, firstToSecond_Bout, firstToSecond_sum, firstToSecond_carryOut);
    secondPipelineReg second(Clock, firstToSecond_Aout, firstToSecond_Bout, firstToSecond_carryOut, firstToSecond_sum, secondToThird_Aout, secondToThird_Bout, secondToThird_sum, secondToThird_carryOut);
    thirdPipelineReg third(Clock, secondToThird_Aout, secondToThird_Bout, secondToThird_carryOut, secondToThird_sum, thirdToFourth_Aout, thirdToFourth_Bout, thirdToFourth_sum, thirdToFourth_carryOut);
    fourthPipelineReg fourth(Clock, thirdToFourth_Aout, thirdToFourth_Bout, thirdToFourth_carryOut, thirdToFourth_sum, S, CO);

endmodule

module firstPipelineReg
(
    input logic Clock,
    input logic[31:0] Ain, Bin,
    input logic CI,
    output logic[31:0] Aout, Bout,
    output logic[31:0] S,
    output logic CO
)
    logic[7:0] adder_out;
    logic carryOut;
    rca adder(adder_out, carryOut, Ain[7:0], Bin[7:0], CI)
    
    always@(posedge Clock)
    begin
        Aout <= Ain;
        Bout <= Bin;
        S[7:0] <= adder_out;
        CO <= carryOut;
    end
endmodule

module secondPipelineReg
(
    input logic Clock,
    input logic[31:0] Ain, Bin,
    input logic CI,
    input logic[31:0] sumIn,
    output logic[31:0] Aout, Bout,
    output logic[31:0] S,
    output logic CO
)
    logic[7:0] adder_out;
    logic carryOut;
    rca adder(adder_out, carryOut, Ain[15:8], Bin[15:8], CI)
    
    always@(posedge Clock)
    begin
        Aout <= Ain;
        Bout <= Bin;
        S[7:0] <= sumIn[7:0];
        S[15:8] <= adder_out;
        CO <= carryOut;
    end
endmodule

module thirdPipelineReg
(
    input logic Clock,
    input logic[31:0] Ain, Bin,
    input logic CI,
    input logic[31:0] sumIn,
    output logic[31:0] Aout, Bout,
    output logic[31:0] S,
    output logic CO
)
    logic[7:0] adder_out;
    logic carryOut;
    rca adder(adder_out, carryOut, Ain[23:16], Bin[23:16], CI)
    
    always@(posedge Clock)
    begin
        Aout <= Ain;
        Bout <= Bin;
        S[7:0] <= sumIn[7:0];
        S[15:8] <= sumIn[15:8];
        S[23:16] <= adder_out;
        CO <= carryOut;
    end
endmodule

module fourthPipelineReg
(
    input logic Clock,
    input logic[31:0] Ain, Bin,
    input logic CI,
    input logic[31:0] sumIn,
    output logic[31:0] S,
    output logic CO
)
    logic[7:0] adder_out;
    logic carryOut;
    rca adder(adder_out, carryOut, Ain[31:24], Bin[31:24], CI)
    
    always@(posedge Clock)
    begin
        S[7:0] <= sumIn[7:0];
        S[15:8] <= sumIn[15:8];
        S[23:16] <= sumIn[23:16];
        S[31:24] <= adder_out;
        CO <= carryOut;
    end
endmodule
