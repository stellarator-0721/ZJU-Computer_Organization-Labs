`timescale 1ns / 1ps
module SCPU(
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] inst_in,
    input  wire [31:0] Data_in,
    input  wire        MIO_ready,
    input  wire        INT0,

    output wire        MemRW,
    output wire        CPU_MIO,
    output wire [31:0] PC_out,
    output wire [31:0] Addr_out,
    output wire [31:0] Data_out
);

    // ========= Instruction field split (match your SCPU top) =========
    wire [4:0] OPcode     = inst_in[6:2];      // 5-bit slice as in your SCPU
    wire [2:0] Fun3       = inst_in[14:12];
    wire       Fun7       = inst_in[30];
    wire [2:0] Fun_ecall  = inst_in[22:20];    // KEEP 3 bits to match SCPU
    wire [1:0] Fun_mret   = inst_in[29:28];    // KEEP 2 bits to match SCPU

    // ========= Control Signals (wires) =========
    wire [2:0] ImmSel;
    wire       ALUSrc_B;
    wire [1:0] MemtoReg;
    wire [1:0] Jump;
    wire       Branch;
    wire       BranchN;
    wire       RegWrite;
    wire       MemRW_ctrl;
    wire [3:0] ALU_Control;

    // ecall/mret/ill signals from controller (declare)
    wire ecall;
    wire mret;
    wire ill_instr;

    // map internal mem control to module output
    assign MemRW = MemRW_ctrl;

    // ========= Control Unit Instance =========
    // Use the control module name that actually exists in your project.
    // Here I use SCPU_ctrl to match your earlier SCPU instantiation.
    SCPU_ctrl_Int U_CTRL (
        .OPcode(OPcode),
        .Fun3(Fun3),
        .Fun7(Fun7),
        .MIO_ready(MIO_ready),
        .Fun_ecall(Fun_ecall),
        .Fun_mret(Fun_mret),

        // outputs from control
        .ImmSel(ImmSel),
        .ALUSrc_B(ALUSrc_B),
        .MemtoReg(MemtoReg),
        .Jump(Jump),
        .Branch(Branch),
        .BranchN(BranchN),
        .RegWrite(RegWrite),
        .MemRW(MemRW_ctrl),
        .ALU_Control(ALU_Control),
        .CPU_MIO(CPU_MIO),
        .ecall(ecall),
        .mret(mret),
        .ill_instr(ill_instr)
    );

    // ========= Datapath Instance =========
    // Make sure port names/order match your DataPath_Int declaration
    DataPath_Int U_DP (
        .clk(clk),
        .rst(rst),
        .inst_field(inst_in),
        .Data_in(Data_in),

        .ALUSrc_B(ALUSrc_B),
        .ImmSel(ImmSel),
        .MemtoReg(MemtoReg),
        .Jump(Jump),
        .Branch(Branch),
        .BranchN(BranchN),
        .RegWrite(RegWrite),
        .ALU_Control(ALU_Control),

        .INT0(INT0),
        .ecall(ecall),
        .mret(mret),
        .ill_instr(ill_instr),

        .PC_out(PC_out),
        .Addr_out(Addr_out),
        .Data_out(Data_out)
    );

endmodule
