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

    wire[2:0] lowerDigits;
    wire[2:0] upperDigits;
    wire[1:0] finalOrWire;

    //lower digit check
    DivisibleByFour lowerDigDiv(lowerDigits[0], YT, YO);
    IsZero isYOzero(lowerDigits[1], YO);
    IsZero isYTzero(lowerDigits[2], YT);
    assign finalOrWire[0] = lowerDigits[0] & (~(lowerDigits[1] & lowerDigits[2]));

    //upper digit check
    DivisibleByFour upperDigDiv(upperDigits[0], YM, YH);
    IsZero isYHzero(upperDigits[1], YO);
    IsZero isYMzero(upperDigits[2], YT);
    assign finalOrWire[1] = upperDigits[0] & upperDigits[1] & upperDigits[2];

    assign LY = finalOrWire[0] | finalOrWire[1];

endmodule