module multiply #(parameter WIDTH = 8)
(
    input[WIDTH-1:0] multiplicand, // M
    input[WIDTH-1:0] multiplier, // Q
    output[(WIDTH*2)-1:0] product // P
);

    parameter productBitWidth = (WIDTH*2)-1;
    parameter lastCoutIndex = WIDTH-2;
    parameter numRCA = WIDTH-1;
    parameter lastRcaIndex = WIDTH-2;
    wire[WIDTH-1:0][WIDTH-1:0] partialProducts;
    wire[WIDTH-1:0][lastRcaIndex:0] rcaInputA;
    wire[WIDTH-1:0][lastRcaIndex:0] rcaInputB;
    wire[WIDTH-1:0][lastRcaIndex:0] rcaOutput;
    wire[lastCoutIndex:0] cOut;
    
    genvar i;
    //integer iter;
    generate
        for(i = 0; i < WIDTH; i++)
        begin: gen_partial_products
            assign #1 partialProducts[i] = multiplicand&{WIDTH{multiplier[i]}};
        end
    endgenerate

    generate
        for(i = 0; i < numRCA; i++)
        begin
            rca #(.WIDTH(WIDTH)) adder(rcaOutput[i], cOut[i], rcaInputA[i], rcaInputB[i], 1'b0);
        end
    endgenerate

    // assign to RCA 0 through WIDTH-1, input A partial products
    generate
        for(i = 0; i < numRCA; i++)
        begin
            assign rcaInputA[i] = partialProducts[i+1];
        end
    endgenerate

    // extract the zeroeth partial product
    wire[WIDTH-1:0] zeroethPp = partialProducts[0];
    // zeroeth RCA input B gets a 0 on the MSB and upper width-1 bits of the partial product
    assign rcaInputB[0] = {1'b0, zeroethPp[WIDTH-1:1]};

    // first through numRCA RCA input B gets cout on the MSB the the upper width-1 bits of the previous sum
    generate
        for(i = 1; i < numRCA; i++)
        begin
            wire[WIDTH-1:0] prevRcaSum = rcaOutput[i-1];
            assign rcaInputB[i] = {cOut[i-1], prevRcaSum[WIDTH-1:1]};
        end
    endgenerate

    // assign product outputs
    assign product[0] = zeroethPp[0];
    generate
        for(i = 1; i < (WIDTH-1); i++)
        begin
            //extract the current iter's RCA output
            wire[WIDTH-1:0] tempRca = rcaOutput[i];
            // extract the first RCA output, assign the prodcut to it
            assign product[i] = tempRca[0];
        end
    endgenerate
    // extract the last RCA output
    wire[WIDTH-1:0] lastRca = rcaOutput[lastRcaIndex];
    //assign product[productBitWidth:WIDTH-1] = {cOut[lastCoutIndex], lastRca};
    assign product[productBitWidth:WIDTH-1] = 0;
    
endmodule