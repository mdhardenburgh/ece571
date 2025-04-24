module top;

    logic Clock;
    logic Reset;
    logic In;
    logic Done;
    logic[7:0] BytesRecieved;
    integer cycle_count = 0;
    logic[7:0] bytesSend = 0;
    `ifdef DEBUG
    logic[31:0] recieveCounter;
    `endif
    integer fails = 0;
    integer partialRange = 0;

    parameter clockCycle = 10;
    
    Reciever myReciever
    (
        .Clock(Clock),
        .Reset(Reset),
        .In(In),
        .Done(Done),
        .BytesRecieved(BytesRecieved)
        `ifdef DEBUG
        , .recieveCounter(recieveCounter)
        `endif
    );
    
    initial
    begin
        Clock = 1'b0;
        forever #(clockCycle/2) Clock <= ~Clock;
    end

    initial
    begin
        forever @(posedge Clock) cycle_count++;
    end

    `ifdef DEBUG
    initial
    begin
        forever @(posedge Clock)
        begin
            `ifdef DEBUG
            $display("Cycle #: %0d, Reset: %b, In: %b, Done: %b, BytesReceived: %b, recieveCounter: %0d", cycle_count, Reset, In, Done, BytesRecieved, recieveCounter);
            `else
            $display("Cycle #: %0d, Reset: %b, In: %b, Done: %b, BytesReceived: %b", cycle_count, Reset, In, Done, BytesRecieved);
            `endif
        end
    end
    `endif

    task automatic test_basicSerialInput;
    begin
        $display("test_basicSerialInput begin");
        bytesSend = $urandom_range(0, 255);
        $display("bytesSend: %b", bytesSend);
        cycle_count = 0;
        Reset = 1;
        In = 1;

        #clockCycle;

        Reset = 0;
        In = 0;
        #clockCycle;
        for(int iter = 0; iter<8; iter++)
        begin
            In = bytesSend[iter];
            #clockCycle;
        end

        In = 1; // Stop bit
        #clockCycle;
        if((Done === 1) && (bytesSend === BytesRecieved))
        begin
            `ifdef DEBUG
                $display("PASS test_basicSerialInput bytesSend, %b, equals BytesRecieved, %b, done bit %b, cycle %0d", bytesSend, BytesRecieved, Done, cycle_count);
            `endif
        end
        else
        begin
            $display("FAIL test_basicSerialInput bytesSend, %b, equals BytesRecieved, %b, done bit %b, cycle %0d", bytesSend, BytesRecieved, Done, cycle_count);
            fails++;
        end

        #(3*clockCycle);
        if((Done === 0) && (bytesSend === BytesRecieved))
        begin
            `ifdef DEBUG
                $display("PASS test_basicSerialInput bytesSend, %b, equals BytesRecieved, %b, done bit %b, cycle %0d", bytesSend, BytesRecieved, Done, cycle_count);
            `endif
        end
        else
        begin
            $display("FAIL test_basicSerialInput bytesSend, %b, equals BytesRecieved, %b, done bit %b, cycle %0d", bytesSend, BytesRecieved, Done, cycle_count);
            fails++;
        end

        $display("test_basicSerialInput end\n");
    end
    endtask

    task automatic test_twoBytes;
        $display("test_twoBytes begin");
        bytesSend = $urandom_range(0, 255);
        $display("bytesSend: %b", bytesSend);

        cycle_count = 0;
        Reset = 1;
        In = 1;

        #clockCycle;

        Reset = 0;
        In = 0; // start bit
        #clockCycle;
        for(int iter = 0; iter<8; iter++)
        begin
            In = bytesSend[iter];
            #clockCycle;
        end

        In = 1; // Stop bit
        #(clockCycle);
        if((Done === 1) && (bytesSend === BytesRecieved))
        begin
            `ifdef DEBUG
                $display("PASS in test_twoBytes, bytesSend, %b, equals BytesRecieved, %b, done bit %b, cycle %0d", bytesSend, BytesRecieved, Done, cycle_count);
            `endif
        end
        else
        begin
            $display("FAIL in test_twoBytes, bytesSend, %b, equals BytesRecieved, %b, done bit %b, cycle %0d", bytesSend, BytesRecieved, Done, cycle_count);
            fails++;
        end

        bytesSend = $urandom_range(0, 255);
        $display("bytesSend: %b", bytesSend);
        In = 0; // Start bit
        #clockCycle;

        for(int iter = 0; iter<8; iter++)
        begin
            In = bytesSend[iter];
            #clockCycle;
        end

        In = 1; // Stop bit
        #(clockCycle);
        if((Done === 1) && (bytesSend === BytesRecieved))
        begin
            `ifdef DEBUG
                $display("PASS in test_twoBytes, bytesSend, %b, equals BytesRecieved, %b, done bit %b, cycle %0d", bytesSend, BytesRecieved, Done, cycle_count);
            `endif
        end
        else
        begin
            $display("FAIL in test_twoBytes, bytesSend, %b, equals BytesRecieved, %b, done bit %b, cycle %0d", bytesSend, BytesRecieved, Done, cycle_count);
            fails++;
        end
        $display("test_twoBytes end\n");
    endtask

    task automatic test_resetInMiddle;
        $display("test_resetInMiddle begin");
        bytesSend = $urandom_range(0, 255);
        $display("bytesSend: %b", bytesSend);
        partialRange = $urandom_range(1, 8);
        $display("Pick a spot in range %0d", partialRange);

        cycle_count = 0;
        Reset = 1;
        In = 1;

        #clockCycle;

        Reset = 0; // lift reset
        In = 0; // start bit
        #clockCycle;

        for(int iter = 0; iter<partialRange; iter++)
        begin
            In = bytesSend[iter];
            if(iter == (partialRange-1))
            begin
                Reset = 1;
            end
            #clockCycle;
        end

        bytesSend = $urandom_range(0, 255);
        $display("bytesSend: %b", bytesSend);
        Reset = 0; // lift reset
        In = 0; // restart sending
        #clockCycle;

        for(int iter = 0; iter<8; iter++)
        begin
            In = bytesSend[iter];
            #clockCycle;
        end

        In = 1; // Stop bit
        #(clockCycle);
        if((Done === 1) && (bytesSend === BytesRecieved))
        begin
            `ifdef DEBUG
                $display("PASS in test_resetInMiddle, bytesSend, %b, equals BytesRecieved, %b, done bit %b, cycle %0d", bytesSend, BytesRecieved, Done, cycle_count);
            `endif
        end
        else
        begin
            $display("FAIL in test_resetInMiddle, bytesSend, %b, equals BytesRecieved, %b, done bit %b, cycle %0d", bytesSend, BytesRecieved, Done, cycle_count);
            fails++;
        end

        #clockCycle;
        #clockCycle;

        $display("test_resetInMiddle end\n");
    endtask

    task automatic test_noStopBit;
        $display("test_noStopBit begin");
        bytesSend = $urandom_range(0, 255);
        $display("bytesSend: %b", bytesSend);

        //initial state
        cycle_count = 0;
        Reset = 1;
        In = 1;

        #clockCycle;

        Reset = 0; // lift reset
        In = 0; // start bit

        #clockCycle;

        for(int iter = 0; iter<8; iter++)
        begin
            In = bytesSend[iter];
            #clockCycle;
        end

        if((Done === 0) && (bytesSend === BytesRecieved))
        begin
            `ifdef DEBUG
                $display("PASS in test_noStopBit, bytesSend, %b, equals BytesRecieved, %b, done bit %b, cycle %0d", bytesSend, BytesRecieved, Done, cycle_count);
            `endif
        end
        else
        begin
            $display("FAIL in test_noStopBit, bytesSend, %b, equals BytesRecieved, %b, done bit %b, cycle %0d", bytesSend, BytesRecieved, Done, cycle_count);
            fails++;
        end

        In = 0; // no stop bit for a few cycles
        #(4*clockCycle);

        if((Done === 0) && (bytesSend === BytesRecieved))
        begin
            `ifdef DEBUG
                $display("PASS in test_noStopBit, bytesSend, %b, equals BytesRecieved, %b, done bit %b, cycle %0d", bytesSend, BytesRecieved, Done, cycle_count);
            `endif
        end
        else
        begin
            $display("FAIL in test_noStopBit, bytesSend, %b, equals BytesRecieved, %b, done bit %b, cycle %0d", bytesSend, BytesRecieved, Done, cycle_count);
            fails++;
        end
        In = 1; // Now set the stop bit
        #clockCycle;

        bytesSend = $urandom_range(0, 255);
        $display("bytesSend: %b", bytesSend);

        In = 0; //Start bit

        #clockCycle;

        for(int iter = 0; iter<8; iter++)
        begin
            In = bytesSend[iter];
            #clockCycle;
        end

        In = 1; // Stop bit
        #(clockCycle);

        if((Done === 1) && (bytesSend === BytesRecieved))
        begin
            `ifdef DEBUG
                $display("PASS in test_noStopBit, bytesSend, %b, equals BytesRecieved, %b, done bit %b, cycle %0d", bytesSend, BytesRecieved, Done, cycle_count);
            `endif
        end
        else
        begin
            $display("FAIL in test_noStopBit, bytesSend, %b, equals BytesRecieved, %b, done bit %b, cycle %0d", bytesSend, BytesRecieved, Done, cycle_count);
            fails++;
        end
        #clockCycle;
        #clockCycle;

        $display("test_noStopBit end\n");
    endtask

    initial
    begin
        //$monitor("Cycle #: %0d, Reset: %b, In: %b, Done: %b, BytesReceived: %b", cycle_count, Reset, In, Done, BytesRecieved);
        $display("Cycle #: %0d, Reset: %b, In: %b, Done: %b, BytesReceived: %b", cycle_count, Reset, In, Done, BytesRecieved);
        test_basicSerialInput();
        test_twoBytes();
        test_resetInMiddle();
        test_noStopBit();
        $display("%0d total failures", fails);
        $finish;
    end

endmodule