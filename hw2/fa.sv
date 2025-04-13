
module fa(y, cOut, a, b, c);
    input wire a, b, c;
    output wire y, cOut;

    // y = C XOR (A XOR B)
    // cout = BC + AC + AB
    assign  y = c^(a^b);
    assign  cOut = (a&b) | (a&c) | (b&c);
endmodule