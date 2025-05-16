`include "doubleDabblePkg.sv"

typedef enum logic[2:0] 
{
    IDLE,
    DOUBLE,
    DABBLE,
    RESET
} states_t;

module DoubleDabble #(parameter N = 32)
    (
        input logic Clock,
        input logic Reset,
        input logic Start,
        input logic[N-1:0] V, // input vector
        output logic[doubleDabblePkg::m_ddVectorWidth-1:0] BCD,
        output logic Ready
    );

    states_t stateCounter;
    states_t currentState;
    logic numShifts;
    doubleDabblePkg::doubleDabble_t doubleDabbleVector;

    assign Ready = (stateCounter == IDLE);
    assign BCD = doubleDabbleVector.doubleDabbleValue;

    always_ff@(posedge Clock)
    begin
        if(Reset == 1'b1)
        begin
            stateCounter <= IDLE;
            numShifts <= 0;
        end
        else
        begin
            stateCounter <= currentState;
        end
    end

    always_comb
    begin
        unique0 case(stateCounter)
            IDLE:
            begin
                doubleDabbleVector = {{doubleDabblePkg::m_ddVectorWidth{1'b0}}, V};
                if(Start == 1'b1)
                begin
                    currentState = DOUBLE;
                end
                if(Start == 1'b0)
                begin
                    currentState = IDLE;
                end
            end
            DOUBLE:
            begin
                numShifts++;
                doubleDabbleVector = doubleDabbleVector << 1;
                if(numShifts < N-1)
                begin
                    currentState = DABBLE;
                end
                else
                begin
                    currentState = IDLE;
                end
            end
            DABBLE:
            begin
                currentState = DOUBLE;
                // stride every 4 and check for carries
                for(int iIter = 0; iIter < doubleDabblePkg::m_ddVectorWidth; iIter += 4)
                begin
                    if (doubleDabbleVector.doubleDabbleValue[iIter+:4] >= 3'd5)
                        doubleDabbleVector.doubleDabbleValue[iIter+:4] = doubleDabbleVector.doubleDabbleValue[iIter+:4] + 3'd3;
                end
            end
        endcase
    end
endmodule
