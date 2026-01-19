`timescale 1ns / 1ps

module SCPU_ctrl_more(
    input [4:0] OPcode,
    input [2:0] Fun3,
    input Fun7,
    input MIO_ready,
    output reg [2:0] ImmSel,
    output reg ALUSrc_B,
    output reg [1:0] MemtoReg,
    output reg [1:0] Jump,
    output reg Branch,
    output reg BranchN,
    output reg RegWrite,
    output reg MemRW,
    output reg [3:0] ALU_Control,
    output reg CPU_MIO
);

    wire [3:0] Fun;
    assign Fun = {Fun3, Fun7};
    
    // 控制信号定义: {ALUSrc_B, MemtoReg, RegWrite, MemRW, Branch, BranchN, Jump, ALU_Control, ImmSel}
    `define CPU_ctrl_signals {ALUSrc_B, MemtoReg, RegWrite, MemRW, Branch, BranchN, Jump, ALU_Control, ImmSel}
    
    always @* begin
        case (OPcode)
            // I-type load指令
            5'b00000: begin
                `CPU_ctrl_signals = 16'b1_01_1_0_0_0_00_0010_000;
            end
            
            // R-type ALU指令
            5'b01100: begin
                `CPU_ctrl_signals = 16'b0_00_1_0_0_0_00_xxxx_000;
                case (Fun)
                    4'b0000: ALU_Control = 4'b0010; // add
                    4'b1000: ALU_Control = 4'b0110; // sub
                    4'b0111: ALU_Control = 4'b0000; // and
                    4'b0110: ALU_Control = 4'b0001; // or
                    4'b0100: ALU_Control = 4'b1100; // xor
                    4'b0001: ALU_Control = 4'b1110; // sll
                    4'b0101: ALU_Control = 4'b1101; // srl
                    4'b1101: ALU_Control = 4'b1111; // sra
                    4'b0010: ALU_Control = 4'b0111; // slt
                    4'b0011: ALU_Control = 4'b1001; // sltu
                    default: ALU_Control = 4'b0010;
                endcase
            end
            
            // S-type store指令
            5'b01000: begin
                `CPU_ctrl_signals = 16'b1_00_0_1_0_0_00_0010_010;
            end
            
            // I-type ALU立即数指令
            5'b00100: begin
                `CPU_ctrl_signals = 16'b1_00_1_0_0_0_00_xxxx_000;
                case (Fun3)
                    3'b000: ALU_Control = 4'b0010; // addi
                    3'b010: ALU_Control = 4'b0111; // slti
                    3'b011: ALU_Control = 4'b1001; // sltiu
                    3'b100: ALU_Control = 4'b1100; // xori
                    3'b110: ALU_Control = 4'b0001; // ori
                    3'b111: ALU_Control = 4'b0000; // andi
                    3'b001: ALU_Control = 4'b1110; // slli
                    3'b101: begin
                        if (Fun7 == 1'b0)
                            ALU_Control = 4'b1101; // srli
                        else 
                            ALU_Control = 4'b1111; // srai
                    end
                    default: ALU_Control = 4'b0010;
                endcase
            end
            
            // I-type jalr指令
            5'b11001: begin
                `CPU_ctrl_signals = 16'b1_10_1_0_0_0_01_0010_000;
            end
            
            // B-type 分支指令
            5'b11000: begin
                `CPU_ctrl_signals = 16'b0_00_0_0_0_0_00_0110_011;
                case (Fun3)
                    3'b000: begin // beq
                        Branch = 1'b1;
                        BranchN = 1'b0;
                    end
                    3'b001: begin // bne
                        Branch = 1'b0;
                        BranchN = 1'b1;
                    end
                    default: begin
                        Branch = 1'b0;
                        BranchN = 1'b0;
                    end
                endcase
            end
            
            // J-type jal指令
            5'b11011: begin
                `CPU_ctrl_signals = 16'b0_10_1_0_0_0_10_0010_100;
            end
            
            // U-type auipc指令
            5'b00101: begin
                `CPU_ctrl_signals = 16'b1_00_1_0_0_0_00_0010_000;
            end
            
            // U-type lui指令
            5'b01101: begin
                `CPU_ctrl_signals = 16'b1_00_1_0_0_0_00_0010_000;
            end
            
            default: begin
                `CPU_ctrl_signals = 16'b0_00_0_0_0_0_00_0010_000;
            end
        endcase
    end
    
    // MIO控制信号
    always @* begin
        CPU_MIO = (OPcode == 5'b00000 || OPcode == 5'b01000) ? 1'b1 : 1'b0;
    end

endmodule