module ch3
    (
        input wire [7:0] i0, i1,
        output wire [7:0] out
    );

    wire [7:0] add, sub, rshift_a, rshift_l;

    wire eq, gt;


    // addition and subtraction
    assign add = i0 + i1;
    assign sub = i0 - i1; 

    // right shift logical and arithmetic
    assign rshift_l = add >> 2;
    assign rshift_a = add >>> 2;

    // equal, greater than
    assign eq = (i0 == i1);
    assign gt = (i0 > i1);


    // Bitwise and, or, and not
    wire [7:0] bit_and, bit_or, bit_not;
    assign bit_and = i0 & i1;
    assign bit_or = i0 | i1;
    assign bit_not = ~i0;

    // Logical and, or
    wire log_and, log_or;
    assign log_and = i0 && i1;
    assign log_and = i0 || i1;

    // Reduction and, or
    wire red_and, red_or;
    assign red_and = &i0;
    assign red_or = &i1;

    // Concatenation
    wire rot, shl;
    assign rot = {i0[3:0], i0[7:4]};
    assign shl = {i0[3:0], 4'b0000};

    assign {i0[3:0]. i0[7:4]} = rot; 

    // Conditional Operator

    wire [7:0] max;
    assign max = (i0  > i1) ? i0 : i1;

    wire [7:0] i2;

    assign max = (i0 > i1) ?
        ((i0 > i2) ? i0 : i2) :
        ((i1 > i2) ? i1 : i2);


    assign out = add | sub;

    // z output
    

endmodule