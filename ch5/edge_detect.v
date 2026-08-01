module edge_detect_moore 
    (
        input wire clk, reset,
        input wire level,
        output reg tick
    );

    localparam [1:0] zero = 2'b00,
                     edg = 2'b01,
                     one = 2'b10;

    reg [1:0] state_reg, state_next;

    always @(posedge clk, posedge reset) begin
        if (reset)
            state_reg <= zero;
        else
            state_reg <= state_next;
    end

    always @* begin
        state_next = state_reg;
        tick = 1'b0;

        case (state_reg)
            zero: 
                if (level)
                    state_next = edg;
            edg:
                begin
                    tick = 1'b1;
                    if (level)
                        state_next = one;
                    else
                        state_next = zero;
                end
            one: 
                if (~level)
                    state_next = zero;

            default:  state_next = 0;
        endcase
    end
    
endmodule

module edge_detect_mealy
     (
        input wire clk, reset,
        input wire level,
        output reg tick
    );

    localparam zero = 1'b0,
               one = 1'b1;

    reg state_reg, state_next;

    always @(posedge clk, posedge reset) begin
        if (reset)
            state_reg <= zero;
        else
            state_reg <= state_next;
    end

    always @*
        begin
            state_next = state_reg;
            tick = 1'b0;

            case (state_reg)
                zero:
                    if (level)
                        begin
                            tick = 1'b1;
                            state_next = one;
                        end
                one:
                    if (~level)
                        state_next = zero;
            endcase
        end
endmodule


module edge_detect_gate
    (
        input wire clk, reset,
        input wire level,
        output wire tick
    );

    reg delay_reg;
    always @(posedge clk, posedge reset) begin
        if (reset)
            delay_reg <= 1'b0;
        else
            delay_reg <= level;
    end

    assign tick = ~delay_reg & level;
endmodule