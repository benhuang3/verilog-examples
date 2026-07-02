module reg_reset
    (
        input wire clk, reset,
        input wire [7:0] d,
        output reg [7:0] q
    );
    always @(posedge clk, posedge reset)
        if (reset)
            q <= 0;
        else
            q <= d;
endmodule

module reg_file
    #(
        parameter B = 8, // number of bits
        W = 2 // number of address bits
    )
    (
        input wire clk,
        input wire wr_en,
        input wire [W-1:0] w_addr, r_addr,
        input wire [B-1:0] w_data,
        output wire [B-1:0] r_data
    );

    reg [B-1:0] array_reg [2**W-1:0];
    
endmodule