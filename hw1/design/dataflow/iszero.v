// copyright (C) Matthew Hardenburgh
// matthew@hardenburgh.io

// @brief check if BCD digit is zero
// @output 1'b1 if BCD digit is zero, 1'b0 if not
// @input BCD digit
module IsZero(Zero, BCD);
    output Zero;
    input[3:0] BCD;

    assign Zero = (~BCD[3]) & (~BCD[2]) & (~BCD[1]) & (~BCD[0]);
endmodule