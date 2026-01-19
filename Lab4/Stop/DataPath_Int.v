`timescale 1ns / 1ps

module DataPath_Int(
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] inst_field,
    input  wire [31:0] Data_in,
    input  wire [3:0]  ALU_Control,
    input  wire [2:0]  ImmSel,
    input  wire [1:0]  MemtoReg,
    input  wire        ALUSrc_B,
    input  wire [1:0]  Jump,
    input  wire        Branch,
    input  wire        BranchN,
    input  wire        RegWrite,

    input  wire        INT0,
    input  wire        ecall,
    input  wire        mret,
    input  wire        ill_instr,

    output wire [31:0] PC_out,
    output wire [31:0] Data_out,
    output wire [31:0] Addr_out      
);

    // ----- internal wires -----
    wire [31:0] Imm_out;
    wire [31:0] pc_plus_4;
    wire [31:0] pc_plus_imm;
    wire [31:0] branch_mux_out;
    wire [31:0] jump_mux_out;
    wire [31:0] alu_B;
    wire [31:0] reg_write_data;
    wire        Zero;

    wire [31:0] pc_after_rvint;
    wire [31:0] pc_next_raw;

    // ImmGen
    ImmGen_more ImmGen_0 (
        .ImmSel(ImmSel),
        .inst_field(inst_field),
        .Imm_out(Imm_out)
    );

    // PC + 4
    add_32 add_32_0 (.a(PC_out), .b(32'd4), .c(pc_plus_4));

    // PC + Imm
    add_32 add_32_1 (.a(PC_out), .b(Imm_out), .c(pc_plus_imm));

    // Branch mux
    MUX2T1_32 MUX2T1_branch (
        .I0(pc_plus_4),
        .I1(pc_plus_imm),
        .s((Branch & Zero) | (BranchN & ~Zero)),
        .o(branch_mux_out)
    );

    // Jump mux 
    MUX4T1_32 MUX4T1_jump (
        .s(Jump),
        .I0(branch_mux_out),
        .I1(pc_plus_imm),
        .I2(Addr_out),         
        .I3(branch_mux_out),
        .o(jump_mux_out)
    );

    assign pc_next_raw = jump_mux_out;

    // RV_Int module
    RV_Int RV_Int_0(
        .clk(clk),
        .reset(rst),
        .INT(INT0),
        .ecall(ecall),
        .mret(mret),
        .ill_instr(ill_instr),
        .PC_next(pc_next_raw),
        .PC(pc_after_rvint)
    );

    // PC register
    REG32 REG32_PC (
        .clk(clk),
        .rst(rst),
        .D(pc_after_rvint),
        .CE(1'b1),
        .Q(PC_out)
    );

    // ALUSrc_B MUX
    MUX2T1_32 MUX2T1_ALUSrc (
        .I0(Data_out),
        .I1(Imm_out),
        .s(ALUSrc_B),
        .o(alu_B)
    );

    // Writeback MUX 
    MUX4T1_32 MUX4T1_WB (
        .I0(Addr_out),       
        .I1(Data_in),
        .I2(pc_plus_4),
        .I3(Imm_out),
        .s(MemtoReg),
        .o(reg_write_data)
    );

    // Register file
    wire [31:0] Rs1_data, Rs2_data;
    Regs_Int Regs_0(
        .clk(clk),
        .rst(rst),
        .Rs1_addr(inst_field[19:15]),
        .Rs2_addr(inst_field[24:20]),
        .Wt_addr(inst_field[11:7]),
        .Wt_data(reg_write_data),
        .RegWrite(RegWrite),
        .Rs1_data(Rs1_data),
        .Rs2_data(Rs2_data)
    );

    assign Data_out = Rs2_data;

    ALU_more ALU_0(
        .A(Rs1_data),
        .B(alu_B),
        .ALU_Control(ALU_Control),
        .res(Addr_out),  
        .Zero(Zero)
    );

endmodule
