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
    assign  y = c^(a^b);
    assign  cOut = (a&b) | (a&c) | (b&c);
endmodule