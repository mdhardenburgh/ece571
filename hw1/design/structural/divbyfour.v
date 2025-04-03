module DivisibleByFour(Divisible, YT, YO);
    input wire[3:0] YT, YO;
    output wire Divisible;

    wire[24:0] div;
    wire fromOr1_toFinalOr;
    wire fromOr2_toFinalOr;
    wire fromOr3_toFinalOr;
    wire fromOr4_toFinalOr;

    and and0(div[24], ~YT[3], ~YT[2], ~YT[1], ~YT[0], ~YO[3], ~YO[2], ~YO[1], ~YO[0]); // 4*0 = 0
    and and1(div[0], ~YT[3], ~YT[2], ~YT[1], ~YT[0], ~YO[3], YO[2], ~YO[1], ~YO[0]); // 4*1 = 4
    and and2(div[1], ~YT[3], ~YT[2], ~YT[1], ~YT[0], YO[3], ~YO[2], ~YO[1], ~YO[0]); // 4*2 = 8
    and and3(div[2], ~YT[3], ~YT[2], ~YT[1], YT[0], ~YO[3], ~YO[2], YO[1], ~YO[0]); // 4*3 = 12
    and and4(div[3], ~YT[3], ~YT[2], ~YT[1], YT[0], ~YO[3], YO[2], YO[1], ~YO[0]); // 4*4 = 16
    and and5(div[4], ~YT[3], ~YT[2], YT[1], ~YT[0], ~YO[3], ~YO[2], ~YO[1], ~YO[0]); // 4*5 = 20
    and and6(div[5], ~YT[3], ~YT[2], YT[1], ~YT[0], ~YO[3], YO[2], ~YO[1], ~YO[0]); // 4*6 = 24
    and and7(div[6], ~YT[3], ~YT[2], YT[1], ~YT[0], YO[3], ~YO[2], ~YO[1], ~YO[0]); // 4*7 = 28
    and and8(div[7], ~YT[3], ~YT[2], YT[1], YT[0], ~YO[3], ~YO[2], YO[1], ~YO[0]); // 4*8 = 32
    and and9(div[8], ~YT[3], ~YT[2], YT[1], YT[0], ~YO[3], YO[2], YO[1], ~YO[0]); // 4*9 = 36
    and and10(div[9], ~YT[3], YT[2], ~YT[1], ~YT[0], ~YO[3], ~YO[2], ~YO[1], ~YO[0]); // 4*10 = 40
    and and11(div[10], ~YT[3], YT[2], ~YT[1], ~YT[0], ~YO[3], YO[2], ~YO[1], ~YO[0]); // 4*11 = 44
    and and12(div[11], ~YT[3], YT[2], ~YT[1], ~YT[0], YO[3], ~YO[2], ~YO[1], ~YO[0]); // 4*12 = 48
    and and13(div[12], ~YT[3], YT[2], ~YT[1], YT[0], ~YO[3], ~YO[2], YO[1], ~YO[0]); // 4*13 = 52
    and and14(div[13], ~YT[3], YT[2], ~YT[1], YT[0], ~YO[3], YO[2], YO[1], ~YO[0]); // 4*14 = 56
    and and15(div[14], ~YT[3], YT[2], YT[1], ~YT[0], ~YO[3], ~YO[2], ~YO[1], ~YO[0]); // 4*15 = 60
    and and16(div[15], ~YT[3], YT[2], YT[1], ~YT[0], ~YO[3], YO[2], ~YO[1], ~YO[0]); // 4*16 = 64
    and and17(div[16], ~YT[3], YT[2], YT[1], ~YT[0], YO[3], ~YO[2], ~YO[1], ~YO[0]); // 4*17 = 68
    and and18(div[17], ~YT[3], YT[2], YT[1], YT[0], ~YO[3], ~YO[2], YO[1], ~YO[0]); // 4*18 = 72
    and and19(div[18], ~YT[3], YT[2], YT[1], YT[0], ~YO[3], YO[2], YO[1], ~YO[0]); // 4*19 = 76
    and and20(div[19], YT[3], ~YT[2], ~YT[1], ~YT[0], ~YO[3], ~YO[2], ~YO[1], ~YO[0]); // 4*20 = 80
    and and21(div[20], YT[3], ~YT[2], ~YT[1], ~YT[0], ~YO[3], YO[2], ~YO[1], ~YO[0]); // 4*21 = 84
    and and22(div[21], YT[3], ~YT[2], ~YT[1], ~YT[0], YO[3], ~YO[2], ~YO[1], ~YO[0]); // 4*22 = 88
    and and23(div[22], YT[3], ~YT[2], ~YT[1], YT[0], ~YO[3], ~YO[2], YO[1], ~YO[0]); // 4*23 = 92
    and and24(div[23], YT[3], ~YT[2], ~YT[1], YT[0], ~YO[3], YO[2], YO[1], ~YO[0]); // 4*24 = 96

    or or1(Divisible, div[0], div[1], div[2], div[3], div[4], div[5], div[6],
                      div[7], div[8], div[9], div[10], div[11], div[12], div[13],
                      div[14], div[15], div[16], div[17], div[18], div[19], div[20],
                      div[21], div[22], div[23], div[24]);
endmodule