module stop_watch_cascade
    (
        input wire clk,
        input wire go, clr,
        output wire [3:0] d2, d1, d0
    );

    localparam DVSR = 5000000; // 5 million

    reg [22:0] ms_reg;
    reg [22:0] ms_next;

    reg [3:0] d2_reg, d1_reg, d0_reg;
    reg [3:0] d2_next, d1_next, d0_next;


    always @(posedge clk)
    begin
        ms_reg <= ms_next;
        d2_reg <= d2_next;
        d1_reg <= d1_next;
        d0_reg <= d0_next;
    end

    always @*
    begin
        d2_next = d2_reg;
        d1_next = d1_reg;
        d0_next = d0_reg;

        if (clr) 
        begin
            ms_next = 0;
            d2_next = 0;
            d1_next = 0;
            d0_next = 0;
        end

        else if (go)
            ms_next = ms_reg + 1;
        else
            ms_next = ms_reg;
        

        if (ms_next == DVSR)
        begin
            ms_next = 0;
            d0_next = d0_reg + 1;
        end            

        if (d0_next == 4'd10)
        begin
            d0_next = 0;
            d1_next = d1_reg + 1;
        end
        
        if (d1_next == 4'd10)
        begin
            d1_next = 0;
            d2_next = d2_reg + 1;
        end
            
        if (d2_next == 4'd10)
            d2_next = 0;
        

    end



    assign d2 = d2_reg;
    assign d1 = d1_reg;
    assign d0 = d0_reg;


endmodule