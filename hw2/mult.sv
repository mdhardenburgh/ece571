/**
    copyright (C) Matthew Hardenburgh
    matthew@hardenburgh.io
*/

/**
    @brief parameterized multipler, defaults to 8
    @input multiplicand M WIDTH wide
    @input multiplier Q WIDTH wide
    @output product P WIDTH wide
*/
module multiply #(parameter WIDTH = 8)
(
    input[WIDTH-1:0] multiplicand, // M
    input[WIDTH-1:0] multiplier, // Q
    output[(WIDTH*2)-1:0] product // P
);

    //wire[unpacked][packed] myWire
    //wire[packed] = mywire[unpacked][packed]
    parameter productBitWidth = (WIDTH*2)-1;
    parameter lastCoutIndex = WIDTH-2;
    parameter numRCA = WIDTH-1;
    parameter lastRcaIndex = WIDTH-2;
    wire[WIDTH-1:0][WIDTH-1:0] partialProducts;
    wire[lastRcaIndex:0][WIDTH-1:0] rcaInputA;
    wire[lastRcaIndex:0][WIDTH-1:0] rcaInputB;
    wire[lastRcaIndex:0][WIDTH-1:0] rcaOutput;
    wire[lastCoutIndex:0] cOut;
    
    genvar i;
    //integer iter;
    generate
        for(i = 0; i < WIDTH; i++)
        begin: gen_partial_products
            assign #1 partialProducts[i] = multiplicand&({WIDTH{multiplier[i]}});
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

    // zeroeth RCA input B gets a 0 on the MSB and upper width-1 bits of the partial product
    assign rcaInputB[0] = {1'b0, partialProducts[0][WIDTH-1:1]};

    // first through numRCA RCA input B gets cout on the MSB the the upper width-1 bits of the previous sum
    generate
        for(i = 1; i < numRCA; i++)
        begin
            assign rcaInputB[i] = {cOut[i-1], rcaOutput[i-1][WIDTH-1:1]};
        end
    endgenerate

    // assign product outputs
    assign product[0] = partialProducts[0][0];
    generate
        for(i = 1; i < (WIDTH-1); i++)
        begin
            // extract the first RCA output, assign the prodcut to it
            assign product[i] = rcaOutput[i-1][0];
        end
    endgenerate

    generate
        for(i = 0; i < WIDTH; i++)
        begin
            assign product[WIDTH-1+i] = rcaOutput[lastRcaIndex][i];
        end
    endgenerate
    assign product[productBitWidth] = cOut[lastCoutIndex];

endmodule