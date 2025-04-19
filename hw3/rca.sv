/**
    copyright (C) Matthew Hardenburgh
    matthew@hardenburgh.io
*/

/**
    @brief 1-bit full adder
    @output y sum
    @output cOut carry out bit
    @input a single bit aguend
    @input b single bit addend
    @input c carry in bit
*/
module fa(y, cOut, a, b, c);
    input wire a, b, c;
    output wire y, cOut;

    // y = C XOR (A XOR B)
    // cout = BC + AC + AB
    assign #1 y = c^(a^b);
    assign #1 cOut = (a&b) | (a&c) | (b&c);
endmodule

/**
    @brief parameterized ripple carry adder, defaults to 8
    @output y WIDTH wide sum
    @output cOut carry output bit
    @input a WIDTH wide aguend
    @input b WIDTH wide addend
    @input c carry in bit
*/
module rca #(parameter  WIDTH = 8)
(
    output wire[WIDTH-1:0] y, 
    output wire cOut,
    input wire[WIDTH-1:0] a, 
    input wire[WIDTH-1:0] b,
    input wire c
);
    wire[WIDTH-2:0] carry;
    fa first(.y(y[0]), .cOut(carry[0]), .a(a[0]), .b(b[0]), .c(c));
    genvar i;
    generate
        for(i = 1; i < (WIDTH - 1); i++)
        begin: gen_adders
            fa adder(.y(y[i]), .cOut(carry[i]), .a(a[i]), .b(b[i]), .c(carry[i-1]));
        end
    endgenerate
    fa last(.y(y[WIDTH-1]), .cOut(cOut), .a(a[WIDTH-1]), .b(b[WIDTH-1]), .c(carry[WIDTH-2]));
endmodule