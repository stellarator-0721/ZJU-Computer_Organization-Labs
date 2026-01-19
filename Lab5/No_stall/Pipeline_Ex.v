module Pipeline_Ex(
    input [31:0] PC_in_EX,
    input [31:0] Rs1_in_EX,
    input [31:0] Rs2_in_EX,
    input [31:0] Imm_in_EX,
    input ALUSrc_B_in_EX,
    input [2:0] ALU_control_in_EX,
    output [31:0] PC_out_EX,      // 跳转目标地址（PC + Imm）
    output [31:0] PC4_out_EX,     // PC + 4
    output zero_out_EX,
    output [31:0] ALU_out_EX,     // ALU计算结果
    output [31:0] Rs2_out_EX
);

    // PC + 4
    add_32 uu1(
        .a(32'd4),
        .b(PC_in_EX),
        .c(PC4_out_EX)
    );

    // 跳转目标地址：PC + 立即数偏移
    // 注意：Imm_in_EX 应该已经是左移1位后的偏移量
    add_32 uu2(
        .a(PC_in_EX),
        .b(Imm_in_EX),
        .c(PC_out_EX)
    );

    // ALU操作数选择
    wire [31:0] B_operand;
    MUX2T1_32 u_MUX2T1_32(
        .I0(Rs2_in_EX),
        .I1(Imm_in_EX),
        .s(ALUSrc_B_in_EX),
        .o(B_operand)
    );

    // ALU计算
    ALU u_ALU(
        .A(Rs1_in_EX),
        .B(B_operand),
        .ALU_Control(ALU_control_in_EX),
        .res(ALU_out_EX),
        .Zero(zero_out_EX)
    );

    assign Rs2_out_EX = Rs2_in_EX;

endmodule