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
    wire[3:0] notYTWire;
    wire[3:0] notYOWire;

    not notYT0(notYTWire[0], YT[0]);
    not notYT1(notYTWire[1], YT[1]);
    not notYT2(notYTWire[2], YT[2]);
    not notYT3(notYTWire[3], YT[3]);

    not notYO0(notYOWire[0], YO[0]);
    not notYO1(notYOWire[1], YO[1]);
    not notYO2(notYOWire[2], YO[2]);
    not notYO3(notYOWire[3], YO[3]);

    and and0(div[24], notYTWire[3], notYTWire[2], notYTWire[1], notYTWire[0], notYOWire[3], notYOWire[2], notYOWire[1], notYOWire[0]); // 4*0 = 0
    and and1(div[0], notYTWire[3], notYTWire[2], notYTWire[1], notYTWire[0], notYOWire[3], YO[2], notYOWire[1], notYOWire[0]); // 4*1 = 4
    and and2(div[1], notYTWire[3], notYTWire[2], notYTWire[1], notYTWire[0], YO[3], notYOWire[2], notYOWire[1], notYOWire[0]); // 4*2 = 8
    and and3(div[2], notYTWire[3], notYTWire[2], notYTWire[1], YT[0], notYOWire[3], notYOWire[2], YO[1], notYOWire[0]); // 4*3 = 12
    and and4(div[3], notYTWire[3], notYTWire[2], notYTWire[1], YT[0], notYOWire[3], YO[2], YO[1], notYOWire[0]); // 4*4 = 16
    and and5(div[4], notYTWire[3], notYTWire[2], YT[1], notYTWire[0], notYOWire[3], notYOWire[2], notYOWire[1], notYOWire[0]); // 4*5 = 20
    and and6(div[5], notYTWire[3], notYTWire[2], YT[1], notYTWire[0], notYOWire[3], YO[2], notYOWire[1], notYOWire[0]); // 4*6 = 24
    and and7(div[6], notYTWire[3], notYTWire[2], YT[1], notYTWire[0], YO[3], notYOWire[2], notYOWire[1], notYOWire[0]); // 4*7 = 28
    and and8(div[7], notYTWire[3], notYTWire[2], YT[1], YT[0], notYOWire[3], notYOWire[2], YO[1], notYOWire[0]); // 4*8 = 32
    and and9(div[8], notYTWire[3], notYTWire[2], YT[1], YT[0], notYOWire[3], YO[2], YO[1], notYOWire[0]); // 4*9 = 36
    and and10(div[9], notYTWire[3], YT[2], notYTWire[1], notYTWire[0], notYOWire[3], notYOWire[2], notYOWire[1], notYOWire[0]); // 4*10 = 40
    and and11(div[10], notYTWire[3], YT[2], notYTWire[1], notYTWire[0], notYOWire[3], YO[2], notYOWire[1], notYOWire[0]); // 4*11 = 44
    and and12(div[11], notYTWire[3], YT[2], notYTWire[1], notYTWire[0], YO[3], notYOWire[2], notYOWire[1], notYOWire[0]); // 4*12 = 48
    and and13(div[12], notYTWire[3], YT[2], notYTWire[1], YT[0], notYOWire[3], notYOWire[2], YO[1], notYOWire[0]); // 4*13 = 52
    and and14(div[13], notYTWire[3], YT[2], notYTWire[1], YT[0], notYOWire[3], YO[2], YO[1], notYOWire[0]); // 4*14 = 56
    and and15(div[14], notYTWire[3], YT[2], YT[1], notYTWire[0], notYOWire[3], notYOWire[2], notYOWire[1], notYOWire[0]); // 4*15 = 60
    and and16(div[15], notYTWire[3], YT[2], YT[1], notYTWire[0], notYOWire[3], YO[2], notYOWire[1], notYOWire[0]); // 4*16 = 64
    and and17(div[16], notYTWire[3], YT[2], YT[1], notYTWire[0], YO[3], notYOWire[2], notYOWire[1], notYOWire[0]); // 4*17 = 68
    and and18(div[17], notYTWire[3], YT[2], YT[1], YT[0], notYOWire[3], notYOWire[2], YO[1], notYOWire[0]); // 4*18 = 72
    and and19(div[18], notYTWire[3], YT[2], YT[1], YT[0], notYOWire[3], YO[2], YO[1], notYOWire[0]); // 4*19 = 76
    and and20(div[19], YT[3], notYTWire[2], notYTWire[1], notYTWire[0], notYOWire[3], notYOWire[2], notYOWire[1], notYOWire[0]); // 4*20 = 80
    and and21(div[20], YT[3], notYTWire[2], notYTWire[1], notYTWire[0], notYOWire[3], YO[2], notYOWire[1], notYOWire[0]); // 4*21 = 84
    and and22(div[21], YT[3], notYTWire[2], notYTWire[1], notYTWire[0], YO[3], notYOWire[2], notYOWire[1], notYOWire[0]); // 4*22 = 88
    and and23(div[22], YT[3], notYTWire[2], notYTWire[1], YT[0], notYOWire[3], notYOWire[2], YO[1], notYOWire[0]); // 4*23 = 92
    and and24(div[23], YT[3], notYTWire[2], notYTWire[1], YT[0], notYOWire[3], YO[2], YO[1], notYOWire[0]); // 4*24 = 96

    or or1(Divisible, div[0], div[1], div[2], div[3], div[4], div[5], div[6],
                      div[7], div[8], div[9], div[10], div[11], div[12], div[13],
                      div[14], div[15], div[16], div[17], div[18], div[19], div[20],
                      div[21], div[22], div[23], div[24]);
endmodule