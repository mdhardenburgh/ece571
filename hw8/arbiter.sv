module arbiterCell(request, carryIn, grant, carryOut);
    input logic request;
    input logic carryIn;
    output logic grant;
    output logic carryOut;

    always_comb 
    begin
        grant = carryIn & request;
        `ifdef cause_single_requestor_always_recieves_grant
        carryOut = carryIn & grant;
        `else
        carryOut = carryIn & ~grant;
        `endif
    end
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
    logic[AGENTS-1:0] grants;
    logic[AGENTS-1:0] prevGrants;

    `ifdef cause_arbiter_always_produces_grant_in_one_cycle
        logic[AGENTS-1:0] holdGrants;
    `endif 

    genvar iIter;
    generate
        for(iIter = 0; iIter < AGENTS; iIter++)
        begin
            if(iIter == 0)
            begin
                always_comb
                begin
                    `ifdef cause_never_more_than_one_grant
                    grants[iIter] = 1'b1;
                    `else
                    grants[iIter] = r[iIter];
                    `endif
                    carryWire[iIter] = ~r[iIter];
                end
            end
            else
            begin
                arbiterCell arbCell(r[iIter], carryWire[iIter-1], grants[iIter], carryWire[iIter]);
            end
        end
    endgenerate

    always_ff @(posedge clock) 
    begin
        if(reset == 1'b1)
        begin
            g <= 'b0;
            prevGrants <= 'b0;
        end
        else
        begin
            `ifdef cause_agent_contine_to_request_grant_agent_continue_to_get_grant
            g <= grants;
            `else
            prevGrants <= g;
            if(prevGrants & r)
            begin
                g <= prevGrants;
            end
            else
            begin
                `ifdef cause_except_reset_grant_never_has_invalid_bits
                g <= 'bx;
                `elsif cause_arbiter_always_produces_grant_in_one_cycle
                holdGrants <= grants;
                g <= holdGrants;
                `elsif cause_did_not_request_grant_grant_not_given
                g <= ~r;
                `else
                g <= grants;
                `endif
            end
            `endif
        end
    end
endmodule