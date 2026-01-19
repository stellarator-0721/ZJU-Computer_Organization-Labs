`timescale 1ns / 1ps
module SCPU_ctrl(
    input [4:0] OPcode,        // 只取操作码高5位分类
    input [2:0] Fun3,          // funct3
    input       Fun7,          // funct7 bit 30
    input       MIO_ready,     // I/O握手信号（可不使用）
    output reg [1:0] ImmSel,   // 立即数选择
    output reg       ALUSrc_B, // ALU第二操作数来源
    output reg [1:0] MemtoReg, // 写回数据选择
    output reg       Jump,     // 跳转控制
    output reg       Branch,   // 分支控制
    output reg       RegWrite, // 寄存器写使能
    output reg       MemRW,    // 存储器读写控制
    output reg [2:0] ALU_Control, // ALU操作选择
    output reg       CPU_MIO   // CPU是否访问外设/存储器
);

    // ALU操作类型（主控译码）
    reg [1:0] ALUop;

    // 将所有主控信号打包统一赋值
    `define CPU_ctrl_signals {ALUSrc_B, MemtoReg, RegWrite, MemRW, Branch, Jump, ALUop, ImmSel}

    //=============================
    //  主控制信号译码
    //=============================
    always @* begin
        // 默认值（无效态）
        `CPU_ctrl_signals = {1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 2'b00};
        CPU_MIO = 1'b0;

        case (OPcode)
            // R-type: add, sub, and, or, xor, sll, srl...
            5'b01100: begin
                `CPU_ctrl_signals = {1'b0, 2'b00, 1'b1, 1'b0, 1'b0, 1'b0, 2'b10, 2'b00};
            end
            // Load: lw
            5'b00000: begin
                `CPU_ctrl_signals = {1'b1, 2'b01, 1'b1, 1'b0, 1'b0, 1'b0, 2'b00, 2'b00};
                CPU_MIO = 1'b1;
            end
            // Store: sw
            5'b01000: begin
                `CPU_ctrl_signals = {1'b1, 2'b00, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00, 2'b01};
                CPU_MIO = 1'b1;
            end
            // Branch: beq
            5'b11000: begin
                `CPU_ctrl_signals = {1'b0, 2'b00, 1'b0, 1'b0, 1'b1, 1'b0, 2'b01, 2'b10};
            end
            // Jump: jal
            5'b11011: begin
                `CPU_ctrl_signals = {1'b0, 2'b10, 1'b1, 1'b0, 1'b0, 1'b1, 2'b00, 2'b11};
            end
            // I-type (ALU imm)
            5'b00100: begin
                `CPU_ctrl_signals = {1'b1, 2'b00, 1'b1, 1'b0, 1'b0, 1'b0, 2'b11, 2'b00};
            end
            default: begin
                `CPU_ctrl_signals = {1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 2'b00};
            end
        endcase
    end

    //=============================
    //  ALU 控制信号译码
    //=============================
    // Fun 拼接: Fun3[2:0] + Fun7[0]
    wire [3:0] Fun;
    assign Fun = {Fun3, Fun7};

    // ALU 控制信号生成逻辑
    always @(*) begin
        ALU_Control = 3'bxxx;  // 默认无效

        case (ALUop)
            2'b00: begin
                // load / store, 地址加法
                ALU_Control = 3'b010; // ADD
            end

            2'b01: begin
                // branch，比较是否相等
                ALU_Control = 3'b110; // SUB
            end

            2'b10: begin
                // R-type 指令
                case (Fun)
                    4'b0000: ALU_Control = 3'b010; // ADD
                    4'b0001: ALU_Control = 3'b110; // SUB
                    4'b1110: ALU_Control = 3'b000; // AND
                    4'b1100: ALU_Control = 3'b001; // OR
                    4'b0100: ALU_Control = 3'b111; // XOR
                    4'b1010: ALU_Control = 3'b101; // SLT
                    4'b1000: ALU_Control = 3'b011; // SLL
                    4'b1011: ALU_Control = 3'b100; // SRL
                    default: ALU_Control = 3'bxxx;
                endcase
            end

            2'b11: begin
                // I-type 立即数指令
                case (Fun3)
                    3'b000: ALU_Control = 3'b010; // ADDI
                    3'b010: ALU_Control = 3'b101; // SLTI
                    3'b011: ALU_Control = 3'b101; // SLTIU
                    3'b100: ALU_Control = 3'b111; // XORI
                    3'b110: ALU_Control = 3'b001; // ORI
                    3'b111: ALU_Control = 3'b000; // ANDI
                    3'b001: ALU_Control = 3'b011; // SLLI
                    3'b101: begin
                        if (Fun7)
                            ALU_Control = 3'b100; // SRAI
                        else
                            ALU_Control = 3'b100; // SRLI (同控制码)
                    end
                    default: ALU_Control = 3'bxxx;
                endcase
            end

            default: ALU_Control = 3'bxxx;
        endcase
    end
endmodule