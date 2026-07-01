module prio_encoder_casez
    (
        input wire [4:1] r,
        output reg [2:0] y
    );
    always @*
        casez (r)
            4'b1???: y = 3'b100;
            4'b01??: y = 3'b011;
            4'b001?: y = 3'b010;
            4'b0001: y = 3'b001;
            default: y = 3'b000;
        endcase
endmodule