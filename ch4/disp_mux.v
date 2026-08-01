module disp_mux
    (
    input wire clk, reset,
    input [7:0] in3, in2, in1, in0,
    output reg [3:0] an,
    output reg [7:0] sseg
    );

    localparam N = 18;

    reg [N-1:0] q_reg;
    wire [N-1:0] q_next;

    wire [1:0] in_sel;

    always @(posedge clk, posedge reset) begin
        if (reset)
            q_reg <= 0;
        else
            q_reg <= q_next;
    end

    assign q_next = q_reg + 1;
    assign in_sel = q_reg[N-1:N-2];

    always @* begin
        case (in_sel)
            2'b00: 
                begin    
                    sseg = in0;
                    an = 4'b1110;
                end
            2'b01:
                begin
                    sseg = in1;
                    an = 4'b1101;
                end
            2'b10:
                begin
                    sseg = in2;
                    an = 4'b1011;
                end
            default: 
                begin
                    sseg = in3;
                    an = 4'b0111;
                end
        endcase 
    end
endmodule

module disp_mux_hex
    (
        input wire clk, reset,
        input wire [3:0] hex3, hex2, hex1, hex0,
        input wire [3:0] dp_in,
        output reg [3:0] an,
        output reg [7:0] sseg
    );

    localparam N = 18;
    
    reg [N-1:0] q_reg;
    wire [N-1:0] q_next;

    reg [3:0] hex_in;
    reg dp;

    always @(posedge clk, posedge reset) begin
        if (reset)
            q_reg <= 0;
        else
            q_reg <= q_next;
    end

    assign q_next = q_reg + 1;

    always @* begin
        case (q_reg[N-1:N-2])
            2'b00: begin
                hex_in = hex0;
                dp = dp_in[0];
                an = 4'b1110;
            end
            2'b01: begin
                hex_in = hex1;
                dp = dp_in[1];
                an = 4'b1101;
            end
            2'b10: begin
                hex_in = hex2;
                dp = dp_in[2];
                an = 4'b1011;
            end
            default: begin
                hex_in = hex3;
                dp = dp_in[3];
                an = 4'b0111;
            end
        endcase
    end

    always @* begin
        case (hex_in)
            4'h0: sseg[6:0] = 7'b0000001;
            4'h1: sseg[6:0] = 7'b1001111;
            4'h2: sseg[6:0] = 7'b0010010;
            4'h3: sseg[6:0] = 7'b0000110;
            4'h4: sseg[6:0] = 7'b1001100;
            4'h5: sseg[6:0] = 7'b0100100;
            4'h6: sseg[6:0] = 7'b0100000;
            4'h7: sseg[6:0] = 7'b0001111;
            4'h8: sseg[6:0] = 7'b0000000;
            4'h9: sseg[6:0] = 7'b0000100;
            4'ha: sseg[6:0] = 7'b0001000;
            4'hb: sseg[6:0] = 7'b1100000;
            4'hc: sseg[6:0] = 7'b0110001;
            4'hd: sseg[6:0] = 7'b1000010;
            4'he: sseg[6:0] = 7'b0110000;
            default: sseg[6:0] = 7'b0111000;
        endcase
        sseg[7] = dp;
    end
endmodule