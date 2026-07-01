module prio_encoder_if
    (
        input wire [4:1] r,
        output reg [2:0] y
    );

    always @*
        if (r[4])
        begin
            y = 3'b100;
        end
        else if  (r[3])
        begin
            y = 3'b011;
        end
        else if  (r[2])
        begin
            y = 3'b010;
        end
        else if  (r[1])
        begin
            y = 3'b001;
        end
        else
        begin
            y = 3'b000;
        end
endmodule