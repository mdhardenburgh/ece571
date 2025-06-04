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
    logic[AGENTS-1:0] grants;

    logic setGrant;

    assign g = setGrant?grants:'b0;

    genvar iIter;
    generate
        for(iIter = 0; iIter < AGENTS; iIter++)
        begin
            if(iIter == 0)
            begin
                assign grants[iIter] = request[iIter];
                assign carryWire[iIter] = ~request[iIter];
            end
            else
            begin
                arbiterCell arbCell(request[iIter], carryWire[iIter-1], grants[iIter], carryWire[iIter]);
            end
        end
    endgenerate

    always_ff @(posedge clock) 
    begin
        if(reset == 1'b1)
        begin
            setGrant <= 1'b0;
        end
        else
        begin
            setGrant <= 1'b1;
            request <= r;
        end
    end
endmodule