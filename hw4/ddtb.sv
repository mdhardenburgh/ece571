`include "ddAlgorithm.sv"

module Top #(parameter N = 32);

    import ddAlgorithm::DoubleDabble_A;
    
    // Input
    logic Clock;
    logic Reset;
    logic Start;
    logic[N-1:0] V;
    // Output
    logic[(4*(N+2))/(3-1):0][3:0] BCD;
    logic Ready;
    
    DoubleDabble #(.N(N))DUT
    (
        .Clock(Clock),
        .Reset(Reset),
        .Start(Start),
        .V(V),
        .BCD(BCD),
        .Ready(Ready)
    );
    /*
    // Create free running clock
    initial
    begin
        Clock = 1'b0;
        forever #(clockCycle/2) Clock <= ~Clock;
    end

    `ifdef DEBUG
    // create cycle counter for debugging
    initial
    begin
        forever @(posedge Clock) cycle_count++;
    end
    `endif

    `ifdef DEBUG
    initial
    begin
        forever @(posedge Clock)
        begin
            $display("Cycle #: %0d, Reset: %b, Start: %b, V: %b, BCD: %b, Ready: %b", cycle_count, Reset, Start, V, BCD, Ready);
        end
    end
    `endif

    // First do a sanity check on how we expect it to work.
    task automatic test_valid_input;
        $display("test_valid_input begin");
        
        $display("test_valid_input end\n");
    endtask
    */
    initial
    begin
        //`ifdef DEBUG
        //    $display("Cycle #: %0d, Reset: %b, Start: %b, V: %b, BCD: %b, Ready: %b", cycle_count, Reset, Start, V, BCD, Ready);
        //`endif

        $display("V: %b, BCD: %b", V, ddAlgorithm::DoubleDabble_A (V));

    end

endmodule