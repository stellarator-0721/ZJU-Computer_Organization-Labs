`timescale 1ns / 1ps

module tb_SCPU_ctrl;
    // Inputs
    reg [4:0] OPcode;
    reg [2:0] Fun3;
    reg Fun7;
    reg MIO_ready;

    // Outputs
    wire [1:0] ImmSel;
    wire ALUSrc_B;
    wire [1:0] MemtoReg;
    wire Jump;
    wire Branch;
    wire RegWrite;
    wire MemRW;
    wire [2:0] ALU_Control;
    wire CPU_MIO;

    // Instantiate the Unit Under Test (UUT)
    SCPU_ctrl uut (
        .OPcode(OPcode),
        .Fun3(Fun3),
        .Fun7(Fun7),
        .MIO_ready(MIO_ready),
        .ImmSel(ImmSel),
        .ALUSrc_B(ALUSrc_B),
        .MemtoReg(MemtoReg),
        .Jump(Jump),
        .Branch(Branch),
        .RegWrite(RegWrite),
        .MemRW(MemRW),
        .ALU_Control(ALU_Control),
        .CPU_MIO(CPU_MIO)
    );

    initial begin
        // Initialize Inputs
        OPcode = 0;
        Fun3 = 0;
        Fun7 = 0;
        MIO_ready = 0;
        #40;
        // Wait 40 ns for global reset to finish
        
        // Add stimulus here
        // 检查输出信号和关键信号输出是否满足真值表
        
        $display("=== 开始ALU指令测试 ===");
        OPcode = 5'b01100; // ALU指令，检查 ALUop相关的ALU_Control; RegWrite=1
        Fun3 = 3'b000; Fun7 = 1'b0; // add, 检查ALU_Control=3'b010
        #20;
        Fun3 = 3'b000; Fun7 = 1'b1; // sub, 检查ALU_Control=3'b110
        #20;
        Fun3 = 3'b111; Fun7 = 1'b0; // and, 检查ALU_Control=3'b000
        #20;
        Fun3 = 3'b110; Fun7 = 1'b0; // or, 检查ALU_Control=3'b001
        #20;
        Fun3 = 3'b010; Fun7 = 1'b0; // slt, 检查ALU_Control=3'b111
        #20;
        Fun3 = 3'b101; Fun7 = 1'b0; // srl, 检查ALU_Control=3'b101
        #20;
        Fun3 = 3'b100; Fun7 = 1'b0; // xor, 检查ALU_Control=3'b011
        #20;
        
        $display("=== 测试其他指令类型 ===");
        Fun3 = 3'b111; Fun7 = 1'b1; // 间隔
        #1;
        OPcode = 5'b00000; // load指令，检查 ALUSrc_B=1, MemtoReg=2'b01, RegWrite=1
        #20;
        OPcode = 5'b01000; // store指令，检查 MemRW=1, ALUSrc_B=1
        #20;
        OPcode = 5'b11000; // beq指令，检查 Branch=1
        #20;
        OPcode = 5'b11011; // jump指令，检查 Jump=1
        #20;
        
        $display("=== 测试I-type立即数指令 ===");
        OPcode = 5'b00100; // I指令，检查 RegWrite=1
        #20;
        Fun3 = 3'b000; // addi, 检查ALU_Control=3'b010
        #20;
        Fun3 = 3'b010; // slti, 检查ALU_Control=3'b101
        #20;
        Fun3 = 3'b011; // sltiu, 检查ALU_Control=3'b101
        #20;
        Fun3 = 3'b100; // xori, 检查ALU_Control=3'b111
        #20;
        Fun3 = 3'b110; // ori, 检查ALU_Control=3'b001
        #20;
        Fun3 = 3'b111; // andi, 检查ALU_Control=3'b000
        #20;
        Fun3 = 3'b001; // slli, 检查ALU_Control=3'b011
        #20;
        Fun3 = 3'b101; Fun7 = 1'b0; // srli, 检查ALU_Control=3'b100
        #20;
        Fun3 = 3'b101; Fun7 = 1'b1; // srai, 检查ALU_Control=3'b100
        #20;
        
        $display("=== 测试MIO_ready信号 ===");
        MIO_ready = 1'b1;
        #20;
        MIO_ready = 1'b0;
        #20;
        
        $display("=== 测试结束 ===");
        OPcode = 5'h1f; // 间隔
        Fun3 = 3'b000; Fun7 = 1'b0; // 间隔
        #20;
        $finish;
    end


endmodule