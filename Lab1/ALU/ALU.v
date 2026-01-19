module ALU(
    input [31:0] A,
    input [31:0] B,
    input [2:0] ALU_Control, 
    output reg [31:0] res,
    output Zero
);

assign Zero = (res == 32'b0);

always @ (*) begin
    case (ALU_Control)
        3'b000: res = A & B;
        3'b001: res = A | B;
        3'b010: res = A + B;
        3'b110: res = A - B;
        3'b111: res = (A < B) ? 32'b1 : 32'b0;
        3'b100: res = ~(A | B);
        3'b101: res = A >> B[4:0];
        3'b011: res = A ^ B;
        default: res = 32'b0;
    endcase
end

endmodule
