module Pipeline_CPU( 
    input clk,                 // 时钟
    input rst,                 // 复位
    input [31:0] Data_in,      // 存储器数据输入
    input [31:0] inst_IF,      // 取指阶段指令

    output [31:0] PC_out_IF,   // 取指阶段PC输出
    output [31:0] PC_out_ID,   // 译码阶段PC输出
    output [31:0] inst_ID,     // 译码阶段指令
    output [31:0] PC_out_Ex,   // 执行阶段PC输出
    output MemRW_Ex,    // 执行阶段存储器读写
    output MemRW_Mem,   // 访存阶段存储器读写
    output [31:0] Addr_out,    // 地址输出
    output [31:0] Data_out,    // CPU数据输出
    output [31:0] Data_out_WB  // 写回数据输出
);

wire [31:0] PC_out_EXMem;
wire PCSrc;
wire RegWriwte_out_MemWB;
wire [4:0] Rd_addr_out_MemWB;

    Pipeline_IF u_Pipeline_IF (
        .clk_IF(clk),
        .rst_IF(rst),
        .en_IF(en_IF),
        .PC_in_IF(PC_imm_out_EXMem),
        .PCSrc(PCSrc),
        .PC_out_IF(PC_out_IF)
    );

wire NOP_IFID;
wire valid_IFID;

    IF_reg_ID u_IF_reg_ID (
        .clk_IFID(clk),
        .rst_IFID(rst),
        .en_IFID(en_IFID),
        .PC_in_IFID(PC_out_IF),
        .NOP_IFID(NOP_IFID),
        .inst_in_IFID(inst_IF),
        .PC_out_IFID(PC_out_ID),
        .inst_out_IFID(inst_ID),
        .valid_IFID(valid_IFID)
    );

wire [4:0] Rd_addr_out_ID;
wire [31:0] Rs1_out_ID;
wire [31:0] Rs2_out_ID;
wire [31:0] Imm_out_ID;
wire ALUSrc_B_ID;
wire [3:0] ALU_control_ID;
wire Branch_ID;
wire BranchN_ID;
wire MemRW_ID;
wire [1:0] Jump_ID;
wire [1:0] MemtoReg_ID;
wire RegWrite_out_ID;

wire Rs1_used;
wire Rs2_used;
wire [4:0] Rs1_addr_ID;
wire [4:0] Rs2_addr_ID;

    Pipeline_ID u_Pipeline_ID (
        .clk_ID(clk),
        .rst_ID(rst),
        .RegWrite_in_ID(RegWrite_out_MemWB),
        .Rd_addr_ID(Rd_addr_out_MemWB),
        .Wt_data_ID(Data_out_WB),
        .Inst_in_ID(inst_ID),

        .Rd_addr_out_ID(Rd_addr_out_ID),
        .Rs1_out_ID(Rs1_out_ID),
        .Rs2_out_ID(Rs2_out_ID),
        .Rs1_addr_ID(Rs1_addr_ID),
        .Rs2_addr_ID(Rs2_addr_ID),
        .Rs1_used(Rs1_used),
        .Rs2_used(Rs2_used),
        .Imm_out_ID(Imm_out_ID),
        .ALUSrc_B_ID(ALUSrc_B_ID),
        .ALU_control_ID(ALU_control_ID),
        .Branch_ID(Branch_ID),
        .BranchN_ID(BranchN_ID),
        .MemRW_ID(MemRW_ID),
        .Jump_ID(Jump_ID),
        .MemtoReg_ID(MemtoReg_ID),
        .RegWrite_out_ID(RegWrite_out_ID)
    );

wire [31:0] PC_out_IDEX;
wire [4:0] Rd_addr_out_IDEX;
wire [31:0] Rs1_out_IDEX;
wire [31:0] Rs2_out_IDEX;
wire [31:0] Imm_out_IDEX;
wire ALUSrc_B_out_IDEX;
wire [2:0] ALU_control_out_IDEX;
wire Branch_out_IDEX;
wire BranchN_out_IDEX;
wire [1:0] Jump_out_IDEX;
wire [1:0] MemtoReg_out_IDEX;
wire RegWrite_out_IDEX;

wire NOP_IDEX;
wire valid_out_IDEX;

    ID_reg_Ex u_ID_reg_Ex (
        .clk_IDEX(clk),
        .rst_IDEX(rst),
        .en_IDEX(1'b1),

        .NOP_IDEX(NOP_IDEX),
        .valid_in_IDEX(valid_IFID),
        .inst_in_IDEX(inst_ID),

        .PC_in_IDEX(PC_out_ID),
        .Rd_addr_IDEX(Rd_addr_out_ID),
        .Rs1_in_IDEX(Rs1_out_ID),
        .Rs2_in_IDEX(Rs2_out_ID),
        .Imm_in_IDEX(Imm_out_ID),
        .ALUSrc_B_in_IDEX(ALUSrc_B_ID),
        .ALU_control_in_IDEX(ALU_control_ID),
        .Branch_in_IDEX(Branch_ID),
        .BranchN_in_IDEX(BranchN_ID),
        .MemRW_in_IDEX(MemRW_ID),
        .Jump_in_IDEX(Jump_ID),
        .MemtoReg_in_IDEX(MemtoReg_ID),
        .RegWrite_in_IDEX(RegWrite_out_ID),

        .PC_out_IDEX(PC_out_IDEX),
        .inst_out_IDEX(inst_out_IDEX),
        .Rd_addr_out_IDEX(Rd_addr_out_IDEX),
        .Rs1_out_IDEX(Rs1_out_IDEX),
        .Rs2_out_IDEX(Rs2_out_IDEX),
        .Imm_out_IDEX(Imm_out_IDEX),
        .ALUSrc_B_out_IDEX(ALUSrc_B_out_IDEX),
        .ALU_control_out_IDEX(ALU_control_out_IDEX),
        .Branch_out_IDEX(Branch_out_IDEX),
        .BranchN_out_IDEX(BranchN_out_IDEX),
        .MemRW_out_IDEX(MemRW_Ex),
        .Jump_out_IDEX(Jump_out_IDEX),
        .MemtoReg_out_IDEX(MemtoReg_out_IDEX),
        .RegWrite_out_IDEX(RegWrite_out_IDEX),
        .valid_out_IDEX(valid_out_IDEX)
    );

    stall( 
        .rst_stall(rst), 
        .RegWrite_out_IDEX(RegWrite_out_IDEX), 
        .Rd_addr_out_IDEX(Rd_addr_out_IDEX), 
        .RegWrite_out_EXMem(RegWrite_out_EXMem), 
        .Rd_addr_out_EXMem(Rd_addr_out_EXMem), 
        .Rs1_addr_ID(Rs1_addr_ID),
        .Rs2_addr_ID(Rs2_addr_ID), 
        .Rs1_used(Rs1_used), 
        .Rs2_used(Rs2_used),
        .Branch_ID(Branch_ID),
        .BranchN_ID(BranchN_ID), 
        .Jump_ID(Jump_ID), 
        .Branch_out_IDEX(Branch_out_IDEX),
        .BranchN_out_IDEX(BranchN_out_IDEX),
        .Jump_out_IDEX(Jump_out_IDEX), 
        .Branch_out_EXMem(Branch_out_EXMem),
        .BranchN_out_EXMem(BranchN_out_EXMem), 
        .Jump_out_EXMem(Jump_out_EXMem), 
        .en_IF(en_IF),
        .en_IFID(en_IFID),
        .NOP_IFID(NOP_IFID),
        .NOP_IDEX(NOP_IDEX)
    ); 

wire [31:0] PC4_out_EX;
wire zero_out_EX;
wire [31:0] ALU_out_EX;
wire [31:0] Rs2_out_EX;

    Pipeline_Ex u_Pipeline_Ex (
        .PC_in_EX(PC_out_IDEX),
        .Rs1_in_EX(Rs1_out_IDEX),
        .Rs2_in_EX(Rs2_out_IDEX),
        .Imm_in_EX(Imm_out_IDEX),
        .ALUSrc_B_in_EX(ALUSrc_B_out_IDEX),
        .ALU_control_in_EX(ALU_control_out_IDEX),

        .PC_out_EX(PC_out_EX),
        .PC4_out_EX(PC4_out_EX),
        .zero_out_EX(zero_out_EX),
        .ALU_out_EX(ALU_out_EX),
        .Rs2_out_EX(Rs2_out_EX)
    );

wire [31:0] PC4_out_EXMem;
wire zero_out_EXMem;
wire [1:0] MemtoReg_out_EXMem;
wire valid_out_EXMem;
wire [31:0] inst_out_EXMem;

    Ex_reg_Mem u_Ex_reg_Mem (
        .clk_EXMem(clk),
        .rst_EXMem(rst),
        .en_EXMem(1'b1),
        .PC_in_EXMem(PC_out_IDEX),
        .PC4_in_EXMem(PC4_out_EX),

        .PC_imm_EXMem(PC_out_EX),
        .valid_in_EXMem(valid_out_IDEX),
        .inst_in_EXMem(inst_out_IDEX),

        .Rd_addr_EXMem(Rd_addr_out_IDEX),
        .zero_in_EXMem(zero_out_EX),
        .ALU_in_EXMem(ALU_out_EX),
        .Rs2_in_EXMem(Rs2_out_EX),
        .Branch_in_EXMem(Branch_out_IDEX),
        .BranchN_in_EXMem(BranchN_out_IDEX),
        .MemRW_in_EXMem(MemRW_Ex),
        .Jump_in_EXMem(Jump_out_IDEX),
        .MemtoReg_in_EXMem(MemtoReg_out_IDEX),
        .RegWrite_in_EXMem(RegWrite_out_IDEX),

        .PC_out_EXMem(PC_out_EXMem),
        .PC4_out_EXMem(PC4_out_EXMem),

        .PC_imm_out_EXMem(PC_imm_out_EXMem),
        .valid_out_EXMem(valid_out_EXMem),
        .inst_out_EXMem(inst_out_EXMem),

        .Rd_addr_out_EXMem(Rd_addr_out_EXMem),
        .zero_out_EXMem(zero_out_EXMem),
        .ALU_out_EXMem(Addr_out),
        .Rs2_out_EXMem(Data_out),
        .Branch_out_EXMem(Branch_out_EXMem),
        .BranchN_out_EXMem(BranchN_out_EXMem),
        .MemRW_out_EXMem(MemRW_Mem),
        .Jump_out_EXMem(Jump_out_EXMem),
        .MemtoReg_out_EXMem(MemtoReg_out_EXMem),
        .RegWrite_out_EXMem(RegWrite_out_EXMem)
    );

    Pipeline_Mem u_Pipeline_Mem (
        .zero_in_Mem(zero_out_EXMem),
        .Branch_in_Mem(Branch_out_EXMem),
        .BranchN_in_Mem(BranchN_out_EXMem),
        .Jump_in_Mem(Jump_out_EXMem),
        .PCSrc(PCSrc)
    );

wire [31:0] PC4_out_MemWB;
wire [31:0] ALU_out_MemWB;
wire [31:0] DMem_data_out_MemWB;
wire [1:0] MemtoReg_out_MemWB;


    Mem_reg_WB u_Mem_reg_WB (
        .clk_MemWB(clk),
        .rst_MemWB(rst),
        .en_MemWB(1'b1),
        .PC4_in_MemWB(PC4_out_EXMem),
        .PC_in_MemWB(PC_out_EXMem),
        .inst_in_MemWB(inst_out_EXMem),
        .valid_in_MemWB(valid_out_EXMem),

        .Rd_addr_MemWB(Rd_addr_out_EXMem),
        .ALU_in_MemWB(Addr_out),
        .Dmem_data_MemWB(Data_in),
        .MemtoReg_in_MemWB(MemtoReg_out_EXMem),
        .RegWrite_in_MemWB(RegWrite_out_EXMem),
        .PC4_out_MemWB(PC4_out_MemWB),
        .inst_out_MemWB(),
        .valid_out_MemWB(),
        .PC_out_MemWB(),
        .Rd_addr_out_MemWB(Rd_addr_out_MemWB),
        .ALU_out_MemWB(ALU_out_MemWB),
        .DMem_data_out_MemWB(DMem_data_out_MemWB),
        .MemtoReg_out_MemWB(MemtoReg_out_MemWB),
        .RegWrite_out_MemWB(RegWrite_out_MemWB)
    );

    Pipeline_WB u_Pipeline_WB (
        .PC4_in_WB(PC4_out_MemWB),
        .ALU_in_WB(ALU_out_MemWB),
        .Dmem_data_WB(DMem_data_out_MemWB),
        .MemtoReg_in_WB(MemtoReg_out_MemWB),
        .Data_out_WB(Data_out_WB)
    );

endmodule