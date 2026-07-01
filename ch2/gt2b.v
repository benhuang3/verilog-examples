module gt2b
    (
        input wire [1:0] i0, i1,
        output wire gt
    );

    wire msb_gt, msb_eq, lsb_gt;

    assign msb_gt = i0[1] & ~i1[1];
    assign msb_eq = ~(i0[1] ^ i1[1]);
    assign lsb_gt = i0[0] & ~i1[0];

    assign gt = msb_gt | (msb_eq & lsb_gt);

endmodule
