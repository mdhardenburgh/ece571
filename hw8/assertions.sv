`include "../svTest/testFramework.sv"
`CONCURENT_ASSERTIONS(ArbiterAssertions) #(parameter AGENTS = 8)
(
    input logic clock,
    input logic reset, 
    input logic[AGENTS-1:0] r,
    input logic[AGENTS-1:0] g
);

logic[9:0] myGrants[AGENTS-1:0];

logic [AGENTS-1:0] r_prev;

always_ff @(posedge clock) 
begin
    if (reset) 
    begin
        r_prev <= '0;
    end 
    else 
    begin
        r_prev <= r;
    end
end

always_ff @(posedge clock) 
begin
    if(reset)
    begin
        for(int iIter = 0; iIter < AGENTS; iIter++)
        begin
            myGrants[iIter] <= 'b0;
        end
    end
    else
    begin
        updateGrantVector($past(r), g, myGrants);
    end
end

`CONCURENT_PROPERTY_ERROR(ArbiterAssertions, request_vector_never_has_invalid_bits)
    @(posedge clock)
    !$isunknown(r);
`END_CONCURENT_PROPERTY_ERROR_PRINT(ArbiterAssertions, request_vector_never_has_invalid_bits)
    $display("rVector: %b, reset: %b, gVector: %b", r, reset, g);
`END_CONCURENT_PROPERTY_ERROR_PRINT_END_PRINT

`CONCURENT_PROPERTY_ERROR(ArbiterAssertions, except_reset_grant_never_has_invalid_bits)
    @(posedge clock)
    disable iff (reset)
    !$isunknown(g);
`END_CONCURENT_PROPERTY_ERROR_PRINT(ArbiterAssertions, except_reset_grant_never_has_invalid_bits)
    $display("rVector: %b, reset: %b, gVector: %b", r, reset, g);
`END_CONCURENT_PROPERTY_ERROR_PRINT_END_PRINT

`CONCURENT_PROPERTY_ERROR(ArbiterAssertions, arbiter_always_produces_grant_in_one_cycle)
    @(posedge clock)
    disable iff (reset)
    !$isunknown(r) |=> ##1 !$isunknown(g);
`END_CONCURENT_PROPERTY_ERROR_PRINT(ArbiterAssertions, arbiter_always_produces_grant_in_one_cycle)
    $display("rVector: %b, reset: %b, gVector: %b", r, reset, g);
`END_CONCURENT_PROPERTY_ERROR_PRINT_END_PRINT

`CONCURENT_PROPERTY_ERROR(ArbiterAssertions, never_more_than_one_grant)
    @(posedge clock)
    disable iff (reset)
    (r >= 1) |-> ##1 $onehot(g);
`END_CONCURENT_PROPERTY_ERROR_PRINT(ArbiterAssertions, never_more_than_one_grant)
    $display("rVector: %b, reset: %b, gVector: %b", r, reset, g);
`END_CONCURENT_PROPERTY_ERROR_PRINT_END_PRINT

`CONCURENT_PROPERTY_ERROR(ArbiterAssertions, single_requestor_always_recieves_grant)
    @(posedge clock)
    disable iff (reset)
    $onehot(r) |-> ##1 ($past(r) == g);
`END_CONCURENT_PROPERTY_ERROR_PRINT(ArbiterAssertions, single_requestor_always_recieves_grant)
    $display("rVector: %b, reset: %b, gVector: %b", (r), reset, g);
`END_CONCURENT_PROPERTY_ERROR_PRINT_END_PRINT

`CONCURENT_PROPERTY_ERROR(ArbiterAssertions, did_not_request_grant_grant_not_given)
    @(posedge clock)
    disable iff (reset)
    (checkIfNotReqGrantGiven(r, Arbiter.grants) == 1'b0);
`END_CONCURENT_PROPERTY_ERROR_PRINT(ArbiterAssertions, did_not_request_grant_grant_not_given)
    $display("rVector: %b, reset: %b, gVector: %b", r, reset, Arbiter.grants);
`END_CONCURENT_PROPERTY_ERROR_PRINT_END_PRINT

`CONCURENT_PROPERTY_ERROR(ArbiterAssertions, agent_contine_to_request_grant_agent_continue_to_get_grant)
    @(posedge clock)
    disable iff (reset)
    // if had grant before, requesting it again, it should be given grant again
    (checkIfRequestorHadGrantBefore(r, $past(g)) == 1'b1) |=>  ##1 (checkIfRequestorHadGrantBefore($past(r), g) == 1'b1);
`END_CONCURENT_PROPERTY_ERROR_PRINT(ArbiterAssertions, agent_contine_to_request_grant_agent_continue_to_get_grant);
    $display("rVector: %b, reset: %b, gVector: %b", r, reset, (g));
`END_CONCURENT_PROPERTY_ERROR_PRINT_END_PRINT

`CONCURENT_PROPERTY_ERROR(ArbiterAssertions, after_grant_agent_does_not_contine_to_request_after_256_cycles)
    @(posedge clock)
    disable iff (reset)
    checkGrantVector(myGrants) == 0;
`END_CONCURENT_PROPERTY_ERROR_PRINT(ArbiterAssertions, after_grant_agent_does_not_contine_to_request_after_256_cycles)
    $display("rVector: %b, reset: %b, gVector: %b", r, reset, g);
`END_CONCURENT_PROPERTY_ERROR_PRINT_END_PRINT

function automatic int checkIfNotReqGrantGiven(logic[AGENTS-1:0] rVector, logic[AGENTS-1:0] gVector);
    int volation = 0;

    for(int iIter = 0; iIter < AGENTS; iIter++)
    begin
        if((rVector[iIter] === 1'b0) && (gVector[iIter] === 1'b1))
        begin
            volation = 1;
            break;
        end
    end
    return volation;
endfunction

// if had grant before, requesting it again, it should be given grant again
function automatic int checkIfRequestorHadGrantBefore(logic[AGENTS-1:0] rVector, logic[AGENTS-1:0] gVector);
    int true = 0;

    for(int iIter = 0; iIter < AGENTS; iIter++)
    begin
        if((rVector[iIter] === 1'b1) && (gVector[iIter] === 1'b1))
        begin
            true = 1;
            break;
        end
    end
    return true;
endfunction

function automatic void updateGrantVector(logic[AGENTS-1:0] rVector, logic[AGENTS-1:0]gVector, ref logic[9:0] myGrants[AGENTS-1:0]);
    //$display("rVector: %b, gVector %b", rVector, gVector);
    for(int iIter = 0; iIter < AGENTS; iIter++)
    begin
        //$display("Agent: %d, myGrants: %d", iIter, myGrants[iIter]);
        if(rVector[iIter] === 1'b0)
        begin
            myGrants[iIter] = 'b0;
        end
        else if(myGrants[iIter] > 1'b0 && rVector[iIter] === 1'b1)
        begin
            myGrants[iIter]++;
        end
        else if(gVector[iIter] === 1'b1 && rVector[iIter] === 1'b1)
        begin
            myGrants[iIter] = 'b1;
        end
    end
endfunction

function automatic int checkGrantVector(logic[9:0] myGrants[AGENTS-1:0]);
    int true = 0;
    for(int iIter = 0; iIter < AGENTS; iIter++)
    begin
        if(myGrants[iIter] > 512)
        begin
            true = iIter;
            break;
        end
    end
    return true;
endfunction

`END_CONCURENT_ASSERTIONS