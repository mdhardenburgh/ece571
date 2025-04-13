module multiply #(parameter WIDTH = 8)
(
    input[WIDTH-1:0] multiplicand, // M
    input[WIDTH-1:0] multiplier, // Q
    output[(WIDTH*2)-1:0] product // P
);
    
    // set of wires for the zeroeth partial product because its special.
    // you dont need WIDTH-1 because the zeroeth partial product is assigned to the zeroeth output
    parameter firstThroughN = WIDTH-2;
    parameter firstThroughNminusOne = WIDTH-3;
    // Index for last RCA
    parameter lastRcaEndIndex = (WIDTH*2)-2;
    parameter lastRcaBeginIndex = ((WIDTH*2)-1)-WIDTH;
    parameter lastRcaCarryIndex = (WIDTH*2)-1;
    parameter lastPartialProduct = WIDTH-3;
    parameter lastPartialSum = WIDTH-2;
    parameter lastCarry = WIDTH-2;
    parameter numRcas = WIDTH-1;

    wire[firstThroughN:0] initialPartialProduct;

    // WIDTH-1 packed AND gates X WIDTH-2 number of iters
    wire[WIDTH-1:0][firstThroughN:0] partialProduct;
    wire[firstThroughNminusOne:0] carryOut;
    // first sum result becomes a product, unless its the last set of RCAs
    wire[firstThroughN:0][firstThroughNminusOne:0] partialSum;

    // initial set of ANDS
    assign #1 product[0] = (multiplicand[0]&multiplier[0]);
    
    genvar i, j;
    generate
        for(i = 1; i < (WIDTH-1); i++)
        begin: gen_partial_products
            assign initialPartialProduct[i] = multiplicand[i]&multiplier[0];
        end
    endgenerate
    
    // generate WIDTH-1 number of ANDS, WIDTH-2 times
    generate
        for(i = 0; i < (firstThroughN); i++) // 1 - Full width (2 - WIDTH when thinking zero indexed)
        begin
            for(j = 0; j < (WIDTH - 1); j++) // full width (1 - WIDTH when thinking zero indexed)
            begin
                assign partialProduct[j][i] = multiplicand[j]&multiplier[i];
            end
        end
    endgenerate
    
    // first adder
    rca #(.WIDTH(WIDTH)) firstAdder({partialSum[0], product[1]}, carryOut[0], partialProduct[0], {1'b0, initialPartialProduct}, 1'b0);
    // last adder
    rca #(.WIDTH(WIDTH)) lastAdder(product[lastRcaEndIndex:lastRcaBeginIndex], product[lastRcaCarryIndex], partialProduct[lastPartialProduct], {carryOut[lastCarry], partialSum[lastPartialSum]}, 1'b0);
    generate
        for(i = 0; i < numRcas; i++)
        begin: gen_adders
            // Middle adders
            rca #(.WIDTH(WIDTH)) adder({partialSum[i], product[i+1]}, carryOut[i], partialProduct[i], {carryOut[i-1], partialSum[i-1]}, 1'b0);
        end
    endgenerate
    
endmodule