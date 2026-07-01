module eq2
    (
        input wire [1:0] a, b,
        output wire aeqb
    );
    wire e0, e1;
    eq1 eq_bit0_unit (.i0(a[0]), .i1(b[0]), .eq(e0));
    eq1 eq_bit1_unit (a[1], b[1], e1);

    assign aeqb = e0 & e1;

endmodule
