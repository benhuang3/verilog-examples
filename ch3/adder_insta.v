module adder_insta
    (
        input wire [3:0] a4, b4,
        output wire [3:0] sum4,
        output wire c4,

        input wire [7:0] a8, b8,
        output wire [7:0] sum8,
        output wire c8
    );

    adder_carry_para #(.N(4)) unit4(.a(a4), .b(b4), .sum(sum4));

    adder_carry_para #(.N(8)) unit8(.a(a8), .b(b8), .sum(sum8));
endmodule