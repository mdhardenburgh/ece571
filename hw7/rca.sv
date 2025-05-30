// DO NOT SUBMIT!!

module FullAdder(output S, CO, input A, B, CI);
assign #1 S = A ^ B ^ CI;
assign #1 CO = A & B | A & CI | B & CI;
endmodule



module RippleCarryAdder(S, CO, A, B, CI);
parameter N = 16;
output [N-1:0] S;
output CO;
input [N-1:0] A,B;
input CI;

logic [N:0] C;

assign C[0] = CI;
assign CO = C[N];
// create array of instances
FullAdder FA[N-1:0](S, C[N:1], A, B, C[N-1:0]);
endmodule
