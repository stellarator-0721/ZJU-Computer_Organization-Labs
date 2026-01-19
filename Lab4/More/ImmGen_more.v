module ImmGen_more(
    input wire [2:0] ImmSel,       // 立即数操作控制
    input wire [31:0] inst_field,  // 指令数据域[31:7]
    output reg [31:0] Imm_out      // 立即数输出
);

    always @(*) begin
        case (ImmSel)
        3'b001: Imm_out = {{20{inst_field[31]}}, inst_field[31:20]}; // addi, lw (I-type)
        3'b010: Imm_out = {{20{inst_field[31]}}, inst_field[31:25], inst_field[11:7]}; // sw (S-type)
        3'b011: Imm_out = {{19{inst_field[31]}}, inst_field[31], inst_field[7], inst_field[30:25], inst_field[11:8], 1'b0}; // beq, bne (B-type)
        3'b100: Imm_out = {{12{inst_field[31]}}, inst_field[19:12], inst_field[20], inst_field[30:21], 1'b0}; // jal (J-type)
        3'b000: Imm_out = {inst_field[31:12],12'h0};
            default: Imm_out = 32'b0;
        endcase
    end

endmodule