`timescale 1ns/10ps
`include "ch4_ex.v"

module bin_counter_tb();
 
    initial begin
        $dumpfile("bin_counter_tb.vcd");
        $dumpvars(0, bin_counter_tb);
    end
    localparam T=20;
    reg clk, reset;
    reg syn_clr, load, en, up;
    reg [2:0] d;
    wire max_tick, min_tick;
    wire [2:0] q;

    univ_bin_counter #(.N(3)) uut (.clk(clk), .reset(reset), .syn_clr(syn_clr), 
    .load(load), .en(en), .up(up), .d(d), .max_tick(max_tick), .min_tick(min_tick)  , .q(q));

    always
    begin
        clk = 1'b1;
        #(T/2);
        clk = 1'b0;
        #(T/2);
    end

    initial
    begin
        $dumpfile("bin_counter_tb.vcd");
        $dumpvars(0, bin_counter_tb);
    end

    initial
    begin
        reset = 1'b1;
        #(T/2);
        reset = 1'b0;
    end

    initial
    begin

        // setup
        syn_clr = 1'b0;
        load = 1'b0;
        en = 1'b0;
        up = 1'b1;
        d = 3'b000;

        @(negedge reset);
        @(negedge clk);

        // test load
        load = 1'b1;
        d = 3'b011;
        @(negedge clk);
        load = 1'b0;

        repeat(2) @(negedge clk);

        // test syn_clr
        syn_clr = 1'b1;
        @(negedge clk);
        syn_clr = 1'b0;

        // test up counter and puase
        en = 1'b1;
        up = 1'b1;
        repeat(10) @(negedge clk);
        en = 1'b0;
        repeat(2) @(negedge clk);
        en = 1'b1;
        repeat(2) @(negedge clk);
        // test down counter
        up = 1'b0;
        repeat(10) @(negedge clk);
        // wait until q=2
        wait (q==2)
        @(negedge clk);
        up = 1'b1;
        // continue until min_tick is 1

        @(negedge clk);
        wait(min_tick);
        @(negedge clk);
        up = 1'b0;
        // absolute delay
        #(4*T);
        en = 1'b0;
        #(4*T);
        // stop sim
        $stop;
    end
endmodule   