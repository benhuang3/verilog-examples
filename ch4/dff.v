module d_ff
    (
        input wire clk,
        input wire d,
        output reg q
    );

    always @(posedge clk)
        q <= d;
endmodule


module d_ff_reset
    (
        input wire clk, reset,
        input wire d,
        output reg q
    );

    always @(posedge clk, posedge reset) 
        if (reset)
            q <= 1'b0;
        else
            q <= d;
endmodule


module d_ff_en_1seg
    (
        input wire clk, en, reset,
        input wire d,
        output reg q
    );

    always @(posedge clk, posedge reset)
        if (reset)
            q <= 1'b0;
        else if (en)
            q <= d;
endmodule


module d_ff_en_2seg
    (
        input wire clk, en, reset,
        input wire d,
        output reg q
    );

    reg r_reg, r_next;

    // DFF
    always @(posedge clk, posedge reset)
        if (reset)
            r_reg <= 1'b0;
        else if (en)
            r_reg <= r_next;


    // next-state logic
    always @*
        if (en)
            r_next = d;
        else
            r_next = r_reg;

    // output logic
    always @*
        q = r_reg;
endmodule