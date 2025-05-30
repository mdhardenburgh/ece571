// copyright (C) Matthew Hardenburgh
// matthew@hardenburgh.io

// @brief check if 4 BCD digits are a leap year
// @output 1'b1 if leap year, 1'b0 if not
// @input thousandths (milenium) place BCD digit
// @input hundredths (centry) place BCD digit
// @input tens (decade) place BCD digit
// @input ones place BCD digit
module LeapYear(LY, YM, YH, YT, YO);
    input wire[3:0] YM, YH, YT, YO;
    output reg LY;

    // Basic Idea here
    // if(((year%4 === 0)&&(year%100 !== 0)) || ((year%100 === 0)&&(year%400 === 0)))
    // DivisibleByFour(outputWire1, YT, YO) NAND IsZero(outputWire2, YO) NAND IsZero(outputWire3, YT) true when bottom 2 are BOTH not zero, but one or the other could
    // DivisibleByFour(outputWire4, YM, YH) && (IsZero(outputWire5, YO) && IsZero(outputWire6, YT))

    wire[2:0] lowerDigits;
    wire lowerNotWire;
    wire lowerAndWire;
    wire[2:0] upperDigits;
    wire[1:0] finalOrWire;

    //lower digit check
    DivisibleByFour lowerDigDiv(lowerDigits[0], YT, YO);
    IsZero isYOzero(lowerDigits[1], YO);
    IsZero isYTzero(lowerDigits[2], YT);
    and lowerAnd0(lowerNotWire, lowerDigits[1], lowerDigits[2]);
    not lowerNot(lowerAndWire, lowerNotWire);
    and lowerAnd1(finalOrWire[0], lowerDigits[0], lowerAndWire);

    //upper digit check
    DivisibleByFour upperDigDiv(upperDigits[0], YM, YH);
    IsZero isYHzero(upperDigits[1], YO);
    IsZero isYMzero(upperDigits[2], YT);
    and upperAnd(finalOrWire[1], upperDigits[0], upperDigits[1], upperDigits[2]);

    or finalOr(LY, finalOrWire[0], finalOrWire[1]);

endmodule