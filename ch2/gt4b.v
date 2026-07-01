module gt4b
    (
        input wire [3:0] i0, i1,
        output wire gt
    );

    wire gt_bit10, eq_bit32, gt_bit32;

    gt2b gt_bit10_unit (.i0(i0[1:0]), .i1(i1[1:0]), .gt(gt_bit10));
    gt2b gt_bit32_unit (.i0(i0[3:2]), .i1(i1[3:2]), .gt(gt_bit32));

    assign eq_bit32 = ~(i0[3] ^ i1[3]) & ~(i0[2] ^ i1[2]);

    assign gt = gt_bit32 | (eq_bit32 & gt_bit10);

endmodule