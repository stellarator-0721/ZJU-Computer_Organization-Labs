module Pipeline_CPU(
    input clk, //时钟
    input rst, //复位
    input[31:0] Data_in, //存储器数据输入
    input[31:0] inst_IF, //取指阶段指令
    output [31:0] PC_out_IF, //取指阶段PC输出
    output [31:0] PC_out_ID, //译码阶段PC输出
    output [31:0] inst_ID, //译码阶段指令
    output [31:0] PC_out_Ex, //执行阶段PC输出
    output [31:0] MemRW_Ex, //执行阶段存储器读写
    output [31:0] MemRW_Mem, //访存阶段存储器读写
    output [31:0] Addr_out, //地址输出
    output [31:0] Data_out, //CPU数据输出
    output [31:0] Data_out_WB //写回数据输出
    );

    wire PCSrc;
    wire [31:0] PC_out_EXMem;
    wire RegWrite_out_MemWB;
    wire [4:0] Rd_addr_out_MemWB;
    wire [31:0] Rd_addr_ID;  // 改为32位
    wire [31:0] Rs1_out, Rs2_out;
    wire [31:0] Imm_out;
    wire ALUSrc_B;
    wire [2:0] ALU_control;
    wire Branch, BranchN;
    wire MemRW;  // 改为1位（根据模块声明）
    wire Jump;
    wire [1:0] MemtoReg;  // 改为2位
    wire RegWrite_ID;
    
    wire [31:0] PC_IDEX;
    wire [4:0] Rd_addr_IDEX;
    wire [31:0] Rs1_IDEX, Rs2_IDEX;
    wire [31:0] Imm_IDEX;
    wire ALUSrc_B_IDEX;
    wire [2:0] ALU_control_IDEX;
    wire Branch_IDEX, BranchN_IDEX;
    wire MemRW_EX;  // 改为1位
    wire Jump_IDEX;
    wire [1:0] MemtoReg_IDEX;  // 改为2位
    wire RegWrite_IDEX;
    
    wire [31:0] PC_Ex;
    wire [31:0] PC4_EX;
    wire zero_EX;
    wire [31:0] ALU_EX;
    wire [31:0] Rs2_EX;
    
    wire [31:0] PC4_EXMem;
    wire [4:0] Rd_addr_EXMem;
    wire zero_EXMem;
    wire [31:0] ALU_EXMem;  // 新增，用于连接到EXMem输出
    wire [31:0] Rs2_EXMem;
    wire Branch_EXMem, BranchN_EXMem;
    wire Jump_EXMem;
    wire [1:0] MemtoReg_EXMem;  // 改为2位
    wire RegWrite_EXMem;
    wire MemRW_EXMem;  // 新增
    
    wire [31:0] PC4_MemWB;
    wire [4:0] Rd_addr_MemWB;
    wire [31:0] ALU_MemWB;
    wire [31:0] DMem_data_WB;
    wire [1:0] MemtoReg_MemWB;  // 改为2位
    wire RegWrite_MemWB;
    
    Pipeline_IF Instruction_Fetch(
        .clk_IF(clk),
        .rst_IF(rst),
        .en_IF(1'b1),
        .PC_in_IF(PC_out_EXMem),
        .PCSrc(PCSrc), 
        .PC_out_IF(PC_out_IF)
    );
    
    IF_reg_ID IF_reg_ID(
        .clk_IFID(clk),
        .rst_IFID(rst),
        .en_IFID(1'b1),
        .PC_in_IFID(PC_out_IF),
        .inst_in_IFID(inst_IF),
        .PC_out_IFID(PC_out_ID),
        .inst_out_IFID(inst_ID)
    );
    
    Pipeline_ID Instruction_Decode(
        .clk_ID(clk),
        .rst_ID(rst),
        .RegWrite_in_ID(RegWrite_out_MemWB),
        .Rd_addr_ID(Rd_addr_out_MemWB),
        .Wt_data_ID(Data_out_WB),
        .Inst_in_ID(inst_ID),
        .Rd_addr_out_ID(Rd_addr_ID),  // 32位
        .Rs1_out_ID(Rs1_out),
        .Rs2_out_ID(Rs2_out),
        .Imm_out_ID(Imm_out),
        .ALUSrc_B_ID(ALUSrc_B),
        .ALU_control_ID(ALU_control),
        .Branch_ID(Branch),
        .BranchN_ID(BranchN),
        .MemRW_ID(MemRW),  // 1位输出
        .Jump_ID(Jump),
        .MemtoReg_ID(MemtoReg),  // 2位输出
        .RegWrite_out_ID(RegWrite_ID)
    );

    ID_reg_Ex ID_reg_Ex_inst(
        .clk_IDEX(clk),
        .rst_IDEX(rst),
        .en_IDEX(1'b1),
        .PC_in_IDEX(PC_out_ID),
        .Rd_addr_IDEX(Rd_addr_ID[4:0]),  // 取低5位
        .Rs1_in_IDEx(Rs1_out),
        .Rs2_in_IDEX(Rs2_out),
        .Imm_in_IDEX(Imm_out),
        .ALUSrc_B_in_IDEX(ALUSrc_B),
        .ALU_control_in_IDEX(ALU_control),
        .Branch_in_IDEX(Branch),
        .BranchN_in_IDEX(BranchN),
        .MemRW_in_IDEX(MemRW),
        .Jump_in_IDEX(Jump),
        .MemtoReg_in_IDEX(MemtoReg),
        .RegWrite_in_IDEX(RegWrite_ID),
        .PC_out_IDEX(PC_IDEX),
        .Rd_addr_out_IDEX(Rd_addr_IDEX),
        .Rs1_out_IDEX(Rs1_IDEX),
        .Rs2_out_IDEX(Rs2_IDEX),
        .Imm_out_IDEX(Imm_IDEX),
        .ALUSrc_B_out_IDEX(ALUSrc_B_IDEX),
        .ALU_control_out_IDEX(ALU_control_IDEX),
        .Branch_out_IDEX(Branch_IDEX),
        .BranchN_out_IDEX(BranchN_IDEX),
        .MemRW_out_IDEX(MemRW_EX),
        .Jump_out_IDEX(Jump_IDEX),
        .MemtoReg_out_IDEX(MemtoReg_IDEX),
        .RegWrite_out_IDEX(RegWrite_IDEX)
    );

    Pipeline_Ex Execute(
        .PC_in_EX(PC_IDEX),
        .Rs1_in_EX(Rs1_IDEX),
        .Rs2_in_EX(Rs2_IDEX),
        .Imm_in_EX(Imm_IDEX),
        .ALUSrc_B_in_EX(ALUSrc_B_IDEX),
        .ALU_control_in_EX(ALU_control_IDEX),
        .PC_out_EX(PC_Ex),
        .PC4_out_EX(PC4_EX),
        .zero_out_EX(zero_EX),
        .ALU_out_EX(ALU_EX),
        .Rs2_out_EX(Rs2_EX)
    );

    Ex_reg_Mem Ex_reg_Mem_inst(
        .clk_EXMem(clk),
        .rst_EXMem(rst),
        .en_EXMem(1'b1),
        .PC_in_EXMem(PC_Ex),
        .PC4_in_EXMem(PC4_EX),
        .Rd_addr_EXMem(Rd_addr_IDEX),
        .zero_in_EXMem(zero_EX),
        .ALU_in_EXMem(ALU_EX),
        .Rs2_in_EXMem(Rs2_EX),
        .Branch_in_EXMem(Branch_IDEX),
        .BranchN_in_EXMem(BranchN_IDEX),
        .MemRW_in_EXMem(MemRW_EX),
        .Junp_in_EXMem(Jump_IDEX),  // 保持原样（模块声明有拼写错误）
        .MemtoReg_in_EXMem(MemtoReg_IDEX),
        .RegWrite_in_EXMem(RegWrite_IDEX),
        .PC_out_EXMem(PC_out_EXMem),
        .PC4_out_EXMem(PC4_EXMem),
        .Rd_addr_out_EXMem(Rd_addr_EXMem),
        .zero_out_EXMem(zero_EXMem),
        .ALU_out_EXMem(ALU_EXMem),  // 连接到内部wire
        .Rs2_out_EXMem(Data_out),   // 直接连接到Data_out
        .Branch_out_EXMem(Branch_EXMem),
        .BranchN_out_EXMem(BranchN_EXMem),
        .MemRW_out_EXMem(MemRW_EXMem),
        .Jump_out_EXMem(Jump_EXMem),
        .MemtoReg_out_EXMem(MemtoReg_EXMem),
        .RegWrite_out_EXMem(RegWrite_EXMem)
    );
    
    // 注意：需要修改顶层端口连接
    assign Addr_out = ALU_EXMem;  // 将ALU结果作为地址输出
    assign MemRW_Mem = {31'b0, MemRW_EXMem};  // 1位扩展为32位
    
    Pipeline_Mem Memory_Access(
        .zero_in_Mem(zero_EXMem),
        .Branch_in_Mem(Branch_EXMem),
        .BranchN_in_Mem(BranchN_EXMem),
        .Jump_in_Mem(Jump_EXMem),
        .PCSrc(PCSrc)  // 输出
    );

    Mem_reg_WB Mem_reg_WB_inst(
        .clk_MemWB(clk),
        .rst_MemWB(rst),
        .en_MemWB(1'b1),
        .PC4_in_MemWB(PC4_EXMem),
        .Rd_addr_MemWB(Rd_addr_EXMem),
        .ALU_in_MemWB(ALU_EXMem),  // 使用内部wire
        .DMem_data_MemWB(Data_in),
        .MemtoReg_in_MemWB(MemtoReg_EXMem),
        .RegWrite_in_MemWB(RegWrite_EXMem),
        .PC4_out_MemWB(PC4_MemWB),
        .Rd_addr_out_MemWB(Rd_addr_out_MemWB),
        .ALU_out_MemWB(ALU_MemWB),
        .DMem_data_out_MemWB(DMem_data_WB),
        .MemtoReg_out_MemWB(MemtoReg_MemWB),
        .RegWrite_out_MemWB(RegWrite_out_MemWB)
    );

    Pipeline_WB Write_Back(
        .PC4_in_WB(PC4_MemWB),
        .ALU_in_WB(ALU_MemWB),
        .DMem_data_WB(DMem_data_WB),
        .MemtoReg_in_WB(MemtoReg_MemWB),
        .Data_out_WB(Data_out_WB)
    );

    assign PC_out_Ex = PC_Ex;
    assign MemRW_Ex = {31'b0, MemRW_EX};  // 1位扩展为32位
    
endmodule