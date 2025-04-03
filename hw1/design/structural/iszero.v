module IsZero(Zero, BCD);
    output Zero;
    input[3:0] BCD;

    wire[3:0] notBCDwire;

    not notBCD0(notBCDwire[0], BCD[0]);
    not notBCD1(notBCDwire[1], BCD[1]);
    not notBCD2(notBCDwire[2], BCD[2]);
    not notBCD3(notBCDwire[3], BCD[3]);

    and and0(Zero, notBCDwire[3], notBCDwire[2], notBCDwire[1], notBCDwire[0]);
endmodule