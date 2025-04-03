module IsZero(Zero, BCD);
    output Zero;
    input[3:0] BCD;

    and and0(Zero, ~BCD[3], ~BCD[2], ~BCD[1], ~BCD[0]);
endmodule