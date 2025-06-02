`include "../svTest/testFramework.sv"
`CONCURENT_ASSERTIONS(ArbiterAssertions) #(parameter AGENTS = 8)
(
    input logic clock,
    input logic reset, 
    input logic[AGENTS-1:0] r,
    input logic[AGENTS-1:0] g
);

logic[9:0] grants[AGENTS-1:0];

always_ff @(posedge clock) 
begin
    if (!reset) 
    begin
        updateGrantVector($past(r), g, grants);
    end
end

`CONCURENT_PROPERTY_ERROR(ArbiterAssertions, request_vector_never_has_invalid_bits)
    @(posedge clock)
    !$isunknown(r);
    //!$isunknown(A) && !$isunknown(B) && !$isunknown(CI) |-> ##STAGES !$isunknown(S) && !$isunknown(CO);
`END_CONCURENT_PROPERTY_ERROR(ArbiterAssertions, request_vector_never_has_invalid_bits)

`CONCURENT_PROPERTY_ERROR(ArbiterAssertions, except_reset_grant_never_has_invalid_bits)
    @(posedge clock)
    disable iff (!reset)
    !$isunknown(g);
`END_CONCURENT_PROPERTY_ERROR(ArbiterAssertions, except_reset_grant_never_has_invalid_bits)

`CONCURENT_PROPERTY_ERROR(ArbiterAssertions, arbiter_always_produces_grant_in_one_cycle)
    @(posedge clock)
    disable iff (!reset)
    !$isunknown(r) |=> !$isunknown(g);
`END_CONCURENT_PROPERTY_ERROR(ArbiterAssertions, arbiter_always_produces_grant_in_one_cycle)

`CONCURENT_PROPERTY_ERROR(ArbiterAssertions, never_more_than_one_grant)
    @(posedge clock)
    disable iff (!reset)
    (r >= 1) |=> (checkIfOneHot(g) == 1);
`END_CONCURENT_PROPERTY_ERROR(ArbiterAssertions, never_more_than_one_grant)

`CONCURENT_PROPERTY_ERROR(ArbiterAssertions, single_requestor_always_recieves_grant)
    @(posedge clock)
    disable iff (!reset)
    (checkIfOneHot(r) == 1) |=> ($past(r) == g);
`END_CONCURENT_PROPERTY_ERROR(ArbiterAssertions, single_requestor_always_recieves_grant)

`CONCURENT_PROPERTY_ERROR(ArbiterAssertions, did_not_request_grant_grant_not_given)
    @(posedge clock)
    disable iff (!reset)
    checkIfNotReqGrantGiven($past(r), g) == 1'b1;
`END_CONCURENT_PROPERTY_ERROR(ArbiterAssertions, did_not_request_grant_grant_not_given)

`CONCURENT_PROPERTY_ERROR(ArbiterAssertions, agent_contine_to_request_grant_agent_continue_to_get_grant)
    @(posedge clock)
    disable iff (!reset)
    // if had grant before, requesting it again, it should be given grant again
    (checkIfRequestorHadGrantBefore(r, $past(g)) == 1'b1) |=>  (checkIfRequestorHadGrantBefore($past(r), g) == 1'b1);
`END_CONCURENT_PROPERTY_ERROR(ArbiterAssertions, agent_contine_to_request_grant_agent_continue_to_get_grant);

`CONCURENT_PROPERTY_ERROR(ArbiterAssertions, after_grant_agent_does_not_contine_to_request_after_256_cycles)
    @(posedge clock)
    disable iff (!reset)
    checkGrantVector(grants) == 0;
`END_CONCURENT_PROPERTY_ERROR(ArbiterAssertions, after_grant_agent_does_not_contine_to_request_after_256_cycles)

function automatic int checkIfOneHot(logic[AGENTS-1:0] vector);
    int sum = 0;
    
    for(int iIter = 0; iIter < AGENTS; iIter++)
    begin
        sum = sum + vector[iIter];
    end

    return sum;
endfunction

function automatic int checkIfNotReqGrantGiven(logic[AGENTS-1:0] rVector, logic[AGENTS-1:0] gVector);
    int true = 0;

    for(int iIter = 0; iIter < AGENTS; iIter++)
    begin
        if((rVector[iIter] === 1'b0) && (gVector[iIter] === 1'b1))
        begin
            true = 1;
            break;
        end
        return true;
    end
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
        return true;
    end
endfunction

function automatic void updateGrantVector(logic[AGENTS-1:0] rVector, logic[AGENTS-1:0]gVector, ref logic[9:0] grants[AGENTS-1:0]);
    for(int iIter = 0; iIter < AGENTS; iIter++)
    begin
        if(rVector[iIter] === 1'b0)
        begin
            grants[iIter] = 'b0;
        end
        else if(gVector[iIter] === 1'b1 && rVector[iIter] === 1'b1)
        begin
            grants[iIter] = 'b1;
        end
        else if(grants[iIter] >= 1'b1 && rVector[iIter] === 1'b1)
        begin
            grants[iIter]++;
        end
    end
endfunction

function automatic int checkGrantVector(logic[9:0] grants[AGENTS-1:0]);
    int true = 0;
    for(int iIter = 0; iIter < AGENTS; iIter++)
    begin
        if(grants[iIter] > 256)
        begin
            true = iIter;
            break;
        end
    end
    return true;
endfunction

`END_CONCURENT_ASSERTIONS