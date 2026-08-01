module fifo 
    #(
        parameter B = 8, // bits in word
                  W = 4  // address bits
    ) 
    (
        input wire clk, reset,
        input wire wr, rd,
        input wire [B-1:0] w_data,
        output wire empty, full,
        output wire [B-1:0] r_data
    );

    reg [B-1:0] array_reg [2**W-1:0]; // register array
    reg [W-1:0] w_ptr_reg, w_ptr_next, w_ptr_succ;
    reg [W-1:0] r_ptr_reg, r_ptr_next, r_ptr_succ;
    reg full_reg, empty_reg, full_next, empty_next;

    wire wr_en = wr & ~full_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            w_ptr_reg <= 0;
            r_ptr_reg <= 0;
            full_reg <= 0;
            empty_reg <= 1;
        end

        else begin
            w_ptr_reg <= w_ptr_next;
            r_ptr_reg <= r_ptr_next;
            full_reg <= full_next;
            empty_reg <= empty_next;

            if (wr_en)
                array_reg[w_ptr_reg] = w_data;
        end
    end

    assign r_data = array_reg[r_ptr_reg];

    always @* begin
        w_ptr_next = w_ptr_reg;
        r_ptr_next = r_ptr_reg;
        empty_next = empty_reg;
        full_next = full_reg;

        case ({wr, rd})
            2'b10: begin
                if (~full_reg) begin
                    w_ptr_next = w_ptr_reg + 1;
                    full_next = (w_ptr_next == r_ptr_next);
                    empty_next = 0;
                end
            end
            2'b01: begin
                if (~empty_reg) begin
                    r_ptr_next = r_ptr_reg + 1;
                    empty_next = (w_ptr_next == r_ptr_next);
                    full_next = 0;
                end
            end
            2'b11: begin
                w_ptr_next = w_ptr_reg + 1;
                r_ptr_next = r_ptr_reg + 1;
            end
        endcase
    end

    assign full = full_reg;
    assign empty = empty_reg;
    
endmodule