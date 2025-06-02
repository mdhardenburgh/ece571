module arbiterCell(request, carryIn, grant, carryOut);
    input logic request;
    input logic carryIn;
    output logic grant;
    output logic carryOut;

    assign grant = carryIn & request;
    assign carryOut = carryIn & ~grant;
endmodule

module Arbiter #(parameter AGENTS = 8)
(
    clock, 
    reset, 
    r, 
    g
);
    input logic clock;
    input logic reset;
    input logic[AGENTS-1:0] r;
    output logic[AGENTS-1:0] g;

    logic[AGENTS-1:0] carryWire;
    logic[AGENTS-1:0] request;

    genvar iIter;
    generate
        for(iIter = 0; iIter < AGENTS; iIter++)
        begin
            if(iIter == 0)
            begin
                assign g[iIter] = request[iIter];
                assign carryWire[iIter] = ~request[iIter];
            end
            else
            begin
                arbiterCell arbCell(request[iIter], carryWire[iIter-1], g[iIter], carryWire[iIter]);
            end
        end
    endgenerate

    always_ff @(posedge clock) 
    begin
        if(reset == 1'b1)
        begin
            g <= 'b0;
        end
        else
        begin
            request <= r;
        end
    end
endmodule