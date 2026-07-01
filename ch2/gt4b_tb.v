`timescale 1ns/10ps

module gt4b_tb;
    // Module to compare which 4 bit number is greater
    reg [3:0] test_i0, test_i1;
    wire test_gt;

    gt4b uut (.i0(test_i0), .i1(test_i1), .gt(test_gt));

    initial
    begin
        $dumpfile("gt4b.vcd");
        $dumpvars(0, gt4b_tb);

        test_i0 = 4'b0000;
        test_i1 = 4'b0000;
        #200;

        test_i0 = 4'b1111;
        test_i1 = 4'b1111;
        #200;

        test_i0 = 4'b1111;
        test_i1 = 4'b1100;
        #200;

        test_i0 = 4'b0000;
        test_i1 = 4'b1100;
        #200;

        test_i0 = 4'b0011;
        test_i1 = 4'b1111;
        #200;

        test_i0 = 4'b1011;
        test_i1 = 4'b1010;
        #200;

        $finish;
    end

endmodule