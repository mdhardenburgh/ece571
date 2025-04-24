/**
    copyright (C) Matthew Hardenburgh
    matthew@hardenburgh.io
*/

typedef enum logic[1:0] 
{
    IDLE,
    RECIEVE
} states_t;

/**
    @brief serial reciever module
    @input Clock
    @input Reset input
    @output Done bit, start bit + 8 data bits + stop bit are recieved this goes high
    @output BytesRecieved, output only valid when done bit is high 
*/
module Reciever
(
    input logic Clock,
    input logic Reset,
    input logic In,
    output logic Done,
    output logic[7:0] BytesRecieved
    `ifdef DEBUG
    ,output logic[31:0] recieveCounter
    `endif
);

    states_t stateCounter = IDLE;
    `ifndef DEBUG
        logic[31:0] recieveCounter;
    `endif

    always@(posedge Clock)
    begin
        case(stateCounter)
            IDLE:
            begin
                if(Reset == 1)
                begin
                    Done <= 1'b0;
                    BytesRecieved <= 8'b0;
                    recieveCounter <= 0;

                    if(In == 0)
                    begin
                        stateCounter <= RECIEVE;
                    end
                    else if(In == 1)
                    begin
                        stateCounter <= IDLE;
                    end
                end
                else if(Reset == 0)
                begin
                    Done <= 1'b0;
                    recieveCounter <= 0;

                    if(In == 0)
                    begin
                        stateCounter <= RECIEVE;
                    end
                    else if(In == 1)
                    begin
                        stateCounter <= IDLE;
                    end
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
                end
                else if(Reset == 0)
                begin
                    if(recieveCounter<8)
                    begin
                        BytesRecieved <= (BytesRecieved>>1)|(In<<7);
                        recieveCounter++;
                        stateCounter <= RECIEVE;
                        Done <= 1'b0;
                    end
                    else if(recieveCounter == 8)
                    begin
                        stateCounter <= RECIEVE;

                        // have recived stop bit
                        if(In == 1)
                        begin
                            recieveCounter++;
                            Done <= 1'b1;
                        end
                        else // have not recieved stop bit
                        begin
                            recieveCounter++;
                            Done <= 1'b0;
                        end
                    end
                    // recieved stop bit after 8 or check done bit
                    else if(recieveCounter > 8)
                    begin
                        if(Done == 1'b1)
                        begin
                            Done <= 1'b0;

                            if(In == 0)
                            begin
                                recieveCounter <= 0;
                                stateCounter <= RECIEVE;
                            end
                            else if(In == 1)
                            begin
                                recieveCounter++;
                                stateCounter <= IDLE;
                            end
                        end
                        else
                        begin
                            // recieved stop bit
                            if(In == 1)
                            begin
                                recieveCounter <= 0;
                                stateCounter <= IDLE;
                            end
                            else if(In == 0)
                            begin
                                recieveCounter++;
                                stateCounter <= RECIEVE;
                            end
                        end
                    end
                    
                end
            end
        endcase
    end

endmodule