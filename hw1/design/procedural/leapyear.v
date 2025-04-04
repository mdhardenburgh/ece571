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

    always@(YM, YH, YT, YO)
    begin
        reg[16:0] year = (YM*16'd1000) + (YH*16'd100) + (YT*16'd10) + YO;

        if(((year%4 === 0)&&(year%100 !== 0)) || ((year%100 === 0)&&(year%400 === 0)))
        begin
            LY = 1;
        end
        else
        begin
            LY = 0;
        end
    end
endmodule