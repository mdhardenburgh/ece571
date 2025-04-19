typedef enum logic[2:0] 
{
    IDLE,
    RECIEVE,
    END_,
    RESET,
    EXCEPTION
} states_t;

module Reciever
(
    input logic Clock,
    input logic Reset,
    input logic In,
    output logic Done,
    output logic[7:0] BytesRecieved
);

    states_t stateCounter = RESET;
    logic[3:0] recieveCounter;

    always@(posedge Clock)
    begin
        case(stateCounter)

            RESET:
            begin
                BytesRecieved <= 0;
                Done <= 0;
                recieveCounter <= 0;
                if(Reset == 1)
                begin
                    stateCounter <= RESET;
                end
                else if(Reset == 0)
                begin
                    stateCounter <= IDLE;
                end
                else
                begin
                    stateCounter <= EXCEPTION;
                end
            end

            IDLE:
            begin
                if(Reset == 1)
                begin
                    stateCounter <= RESET;
                end
                else if(Reset == 0)
                begin
                    if(In == 0)
                    begin
                        stateCounter <= RECIEVE;
                    end
                    else if(In == 1)
                    begin
                        stateCounter <= IDLE;
                    end
                    else
                    begin
                        stateCounter <= EXCEPTION;
                    end
                end
                else
                begin
                    stateCounter <= EXCEPTION;
                end
            end

            RECIEVE:
            begin
                if(Reset == 1)
                begin
                    stateCounter <= RESET;
                end
                else if(Reset == 0)
                begin
                    if(recieveCounter<8)
                    begin
                        BytesRecieved = BytesRecieved<<1;
                        BytesRecieved |= In;
                        recieveCounter++;
                        stateCounter = RECIEVE;
                    end
                    else
                    begin
                        // have recived stop bit
                        if((In == 1) && (recieveCounter == 8))
                        begin
                            recieveCounter <= 0;
                            Done <= 1;
                            stateCounter <= END_;
                        end
                        else if(In == 0) // have not recieved stop bit
                        begin
                            recieveCounter++;
                            stateCounter <= RECIEVE;
                        end
                        else if((In == 1) && (recieveCounter > 8))
                        begin
                            BytesRecieved <= 0;
                            recieveCounter <= 0;
                            stateCounter <= IDLE;
                        end
                        else
                        begin
                            stateCounter <= EXCEPTION;
                        end
                    end
                end
                else
                begin
                    stateCounter <= EXCEPTION;
                end
            end

            END_:
            begin
                if(Reset == 1)
                begin
                    stateCounter <= RESET;
                end
                else if(Reset == 0)
                begin
                    Done = 0;
                    if(In == 0)
                    begin
                        stateCounter <= RECIEVE;
                    end
                    else if(In == 1)
                    begin
                        stateCounter <= IDLE;
                    end
                    else
                    begin
                        stateCounter <= EXCEPTION;
                    end
                end
                else
                begin
                    stateCounter <= EXCEPTION;
                end
            end

            EXCEPTION:
            begin
                if(Reset == 1)
                begin
                    stateCounter <= RESET;
                end
                else
                begin
                    stateCounter <= EXCEPTION;
                end
            end
        endcase
    end

endmodule