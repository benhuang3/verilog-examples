`timescale 1 ns/10 ps

module gt2b_tb;
    reg [1:0] test_in0, test_in1;
    wire test_out;

    gt2b uut (.i0(test_in0), .i1(test_in1), .gt(test_out));

    initial
    begin
        // test vector 1
        test_in0 = 2'b00;
        test_in1 = 2'b00;
        #200;
        // test vector 2
        test_in0 = 2'b01;
        test_in1 = 2'b00;
        #200;
        // test vector 3
        test_in0 = 2'b01;
        test_in1 = 2'b11;
        #200;
        // test vector 4
        test_in0 = 2'b10;
        test_in1 = 2'b10;
        #200;
        // test vector 5
        test_in0 = 2'b10;
        test_in1 = 2'b00;
        #200;
        // test vector 6
        test_in0 = 2'b11;
        test_in1 = 2'b11;
        #200;
        // test vector 7
        test_in0 = 2'b11;
        test_in1 = 2'b01;
        #200;

        $stop;
    end
endmodule
