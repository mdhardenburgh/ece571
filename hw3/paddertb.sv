module top

    logic Clock;
    logic[31:0] S;
    logic CO;
    logic[31:0] A, B;
    logic CI;
    
    // A, B, CI
    logic[64:0] iter;
    // S, CO
    logic[32:0] expectedResult;
    integer fails = 0;

    PAdder dut
    (
        .Clock(Clock),
        .S(S),
        .CO(CO),
        .A(A),
        .B(B),
        .CI(CI)
    );

    initial
    begin
        Clock = 1'b0;
        forever Clock = ~Clock;
    end

    initial
    begin
        always@(posedge Clock)
        begin
        end
    end
    
endmodule