// DO NOT SUBMIT
module PAdder(Clock, S, CO, A, B, CI);
parameter N = 32;
localparam ADDERN = 8;
localparam STAGES = N/ADDERN;

input logic Clock;
output logic CO;
output logic [N-1:0] S;
input logic [N-1:0] A, B;
input logic CI;

// Pipeline register (bigger than we need because carrying entire A, B, S values)
struct packed {
  logic [N-1:0] A, B;
  logic C;
  logic [N-1:0] S;
 } R [0:STAGES];

// inputs for first state of combinational logic -- not actually in registers
assign R[0].A = A;
assign R[0].B = B;
assign R[0].C = CI;

// module outputs from last pipeline stage
assign S =  R[STAGES].S;
assign CO = R[STAGES].C;

wire [ADDERN-1:0] IS [0:STAGES-1];		// intermediate S output for combinational logic
wire         	  IC [0:STAGES-1];		// intermediate CO output for combinational logic 

genvar i;
generate
for (i = 0; i < STAGES; i++)
  begin
  always_ff @(posedge Clock)
    begin
    R[i+1].A <= R[i].A;
    R[i+1].B <= R[i].B;
    R[i+1].C <= IC[i];
	  R[i+1].S <= R[i].S;							// copy intermediate S
    R[i+1].S[i*ADDERN +: ADDERN] <= IS[i];		// add newly generated part of S
    end 
  RippleCarryAdder #(ADDERN) RCA(IS[i], IC[i], R[i].A[i*ADDERN +:ADDERN], R[i].B[i*ADDERN +:ADDERN], R[i].C);
  end
endgenerate
endmodule
