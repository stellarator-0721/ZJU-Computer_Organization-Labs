module MUX8T1_8(
    input [2:0] s,
    input [8:0] I0,
    input [8:0] I1,
    input [8:0] I2,
    input [8:0] I3,
    input [8:0] I4,
    input [8:0] I5,
    input [8:0] I6,
    input [8:0] I7,
    output [8:0] o
);
    
    reg [8:0] o_reg;
    
    always @(*) begin
        case(s)
            3'b000: o_reg = I0;
            3'b001: o_reg = I1;
            3'b010: o_reg = I2;
            3'b011: o_reg = I3;
            3'b100: o_reg = I4;
            3'b101: o_reg = I5;
            3'b110: o_reg = I6;
            3'b111: o_reg = I7;
            default: o_reg = 9'b0;
        endcase
    end
    
    assign o = o_reg;

endmodule
