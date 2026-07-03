module free_run_shift_reg
    #(parameter N=8)
    (
        input wire clk, reset,
        input wire s_in,
        output wire s_out
    );

    reg [N-1:0] r_reg;
    wire [N-1:0] r_next;

    always @(posedge clk, posedge reset)
        if (reset)
            r_reg <= 0;
        else
            r_reg <= r_next;
    
    assign r_next = {s_in, r_reg[N-1:1]};
    assign s_out = r_reg[0];
endmodule


module univ_shift_reg
    #(parameter N=8)
    (
        input wire clk, reset,
        input wire [1:0] ctrl,
        input wire [N-1:0] d,
        output wire [N-1:0] q
    );

    reg [N-1:0] r_reg, r_next;

    always @(posedge clk, posedge reset)
        if (reset)
            r_reg <= 0;
        else
            r_reg <= r_next;
    always @*
        case(ctrl)
            2'b00: r_next = r_reg; // no op
            2'b01: r_next = {r_reg[N-2:0], d[0]}; // left shift
            2'b10: r_next = {d[N-1], r_reg[N-2:0]}; // right shift
            default: r_next = d;
        endcase

    assign q = r_reg;
endmodule


module free_run_bin_counter
    #(parameter N = 8)
    (
        input wire clk, reset,
        output wire max_tick,
        output wire [N-1:0] q
    );

    reg [N-1:0] r_reg;
    wire [N-1:0] r_next;

    always @(posedge clk, posedge reset)
        if (reset)
            r_reg <= 0;
        else
            r_reg <= r_next;
    
    assign r_next = r_next + 1;

    assign q = r_reg;
    assign max_tick = (r_reg == 2 ** N-1);

    
endmodule

