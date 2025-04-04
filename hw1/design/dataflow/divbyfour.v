// copyright (C) Matthew Hardenburgh
// matthew@hardenburgh.io

// @brief check if 2 BCD digits are divisible by 4
// @output 1'b1 if divisible by 4, 1'b0 if not
// @input tens place BCD digit
// @input ones place BCD digit
module DivisibleByFour(Divisible, YT, YO);
    input wire[3:0] YT, YO;
    output wire Divisible;

    wire[24:0] div;

    assign div[24] = ~YT[3] & (~YT[2]) & (~YT[1]) & (~YT[0]) & (~YO[3]) & (~YO[2]) & (~YO[1]) & (~YO[0]); // 4*0 = 0
    assign div[0] = (~YT[3]) & (~YT[2]) & (~YT[1]) & (~YT[0]) & (~YO[3]) & (YO[2]) & (~YO[1]) & (~YO[0]); // 4*1 = 4
    assign div[1] = (~YT[3]) & (~YT[2]) & (~YT[1]) & (~YT[0]) & (YO[3]) & (~YO[2]) & (~YO[1]) & (~YO[0]); // 4*2 = 8
    assign div[2] = ~YT[3] & ~YT[2] & ~YT[1] & YT[0] & ~YO[3] & ~YO[2] & YO[1] & (~YO[0]); // 4*3 = 12
    assign div[3] = ~YT[3] & ~YT[2] & ~YT[1] & YT[0] & ~YO[3] & YO[2] & YO[1] & (~YO[0]); // 4*4 = 16
    assign div[4] = ~YT[3] & ~YT[2] & YT[1] & ~YT[0] & ~YO[3] & ~YO[2] & ~YO[1] & (~YO[0]); // 4*5 = 20
    assign div[5] = ~YT[3] & ~YT[2] & YT[1] & ~YT[0] & ~YO[3] & YO[2] & ~YO[1] & (~YO[0]); // 4*6 = 24
    assign div[6] = ~YT[3] & ~YT[2] & YT[1] & ~YT[0] & YO[3] & ~YO[2] & ~YO[1] & (~YO[0]); // 4*7 = 28
    assign div[7] = ~YT[3] & ~YT[2] & YT[1] & YT[0] & ~YO[3] & ~YO[2] & YO[1] & (~YO[0]); // 4*8 = 32
    assign div[8] = ~YT[3] & ~YT[2] & YT[1] & YT[0] & ~YO[3] & YO[2] & YO[1] & (~YO[0]); // 4*9 = 36
    assign div[9] = ~YT[3] & YT[2] & ~YT[1] & ~YT[0] & ~YO[3] & ~YO[2] & ~YO[1] & (~YO[0]); // 4*10 = 40
    assign div[10] = ~YT[3] & YT[2] & ~YT[1] & ~YT[0] & ~YO[3] & YO[2] & ~YO[1] & (~YO[0]); // 4*11 = 44
    assign div[11] = ~YT[3] & YT[2] & ~YT[1] & ~YT[0] & YO[3] & ~YO[2] & ~YO[1] & (~YO[0]); // 4*12 = 48
    assign div[12] = ~YT[3] & YT[2] & ~YT[1] & YT[0] & ~YO[3] & ~YO[2] & YO[1] & (~YO[0]); // 4*13 = 52
    assign div[13] = ~YT[3] & YT[2] & ~YT[1] & YT[0] & ~YO[3] & YO[2] & YO[1] & (~YO[0]); // 4*14 = 56
    assign div[14] = ~YT[3] & YT[2] & YT[1] & ~YT[0] & ~YO[3] & ~YO[2] & ~YO[1] & (~YO[0]); // 4*15 = 60
    assign div[15] = ~YT[3] & YT[2] & YT[1] & ~YT[0] & ~YO[3] & (YO[2]) & ~YO[1] & (~YO[0]); // 4*16 = 64
    assign div[16] = ~YT[3] & YT[2] & YT[1] & ~YT[0] & YO[3] & (~YO[2]) & ~YO[1] & (~YO[0]); // 4*17 = 68
    assign div[17] = ~YT[3] & YT[2] & YT[1] & YT[0] & ~YO[3] & ~YO[2] & YO[1] & (~YO[0]); // 4*18 = 72
    assign div[18] = ~YT[3] & YT[2] & YT[1] & YT[0] & ~YO[3] & YO[2] & YO[1] & (~YO[0]); // 4*19 = 76
    assign div[19] = YT[3] & ~YT[2] & ~YT[1] & ~YT[0] & ~YO[3] & ~YO[2] & ~YO[1] & (~YO[0]); // 4*20 = 80
    assign div[20] = YT[3] & ~YT[2] & ~YT[1] & ~YT[0] & ~YO[3] & YO[2] & ~YO[1] & (~YO[0]); // 4*21 = 84
    assign div[21] = YT[3] & ~YT[2] & ~YT[1] & ~YT[0] & YO[3] & ~YO[2] & ~YO[1] & (~YO[0]); // 4*22 = 88
    assign div[22] = YT[3] & ~YT[2] & ~YT[1] & YT[0] & ~YO[3] & ~YO[2] & YO[1] & (~YO[0]); // 4*23 = 92
    assign div[23] = YT[3] & ~YT[2] & ~YT[1] & YT[0] & ~YO[3] & YO[2] & YO[1] & (~YO[0]); // 4*24 = 96

    assign Divisible = div[0] | div[1] | div[2] | div[3] | div[4] | div[5] | div[6] |
                      div[7] | div[8] | div[9] | div[10] | div[11] | div[12] | div[13] |
                      div[14] | div[15] | div[16] | div[17] | div[18] | div[19] | div[20] |
                      div[21] | div[22] | div[23] | div[24];
endmodule