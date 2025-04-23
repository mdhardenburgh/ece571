typedef enum logic[2:0] 
{
    IDLE,
    RECIEVE,
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

    states_t stateCounter = IDLE;
    logic[3:0] recieveCounter;

    always@(posedge Clock)
    begin
        case(stateCounter)
            IDLE:
            begin
                if(Reset == 1)
                begin
                    Done <= 1'b0;
                    BytesRecieved <= 8'b0;
                    stateCounter <= IDLE;
                end
                else if(Reset == 0)
                begin
                    Done <= 1'b0;
                    BytesRecieved <= BytesRecieved;
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
                    Done <= 1'b0;
                    BytesRecieved <= BytesRecieved;
                    stateCounter <= EXCEPTION;
                end
            end

            RECIEVE:
            begin
                if(Reset == 1)
                begin
                    Done <= 1'b0;
                    recieveCounter <= 0;
                    BytesRecieved <= 0;

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
                else if(Reset == 0)
                begin
                    if(recieveCounter<8)
                    begin
                        BytesRecieved = BytesRecieved>>1;
                        BytesRecieved |= (In<<7);
                        recieveCounter++;
                        stateCounter = RECIEVE;
                        Done <= 1'b0;
                    end
                    else if(Done == 1'b1)
                    begin
                        Done <= 1'b0;
                        BytesRecieved <= BytesRecieved;
                        recieveCounter <= 0;

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
                        BytesRecieved <= BytesRecieved;
                        // have recived stop bit
                        if((In == 1) && (recieveCounter == 8))
                        begin
                            recieveCounter <= 0;
                            Done <= 1'b1;
                            stateCounter <= RECIEVE;
                        end
                        else if(In == 0) // have not recieved stop bit
                        begin
                            recieveCounter++;
                            Done <= 1'b0;
                            stateCounter <= RECIEVE;
                        end
                        // recieved stop bit after 8
                        else if((In == 1) && (recieveCounter > 8))
                        begin
                            Done <= 1'b0;
                            recieveCounter <= 0;
                            stateCounter <= IDLE;
                        end
                        else
                        begin
                            Done <= 1'b0;
                            stateCounter <= EXCEPTION;
                        end
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
                    stateCounter <= IDLE;
                end
                else
                begin
                    stateCounter <= EXCEPTION;
                end
            end
        endcase
    end

endmodule