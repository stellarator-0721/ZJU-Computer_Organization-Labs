module SCPU(
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] inst_in,
    input  wire [31:0] Data_in,
    input  wire        MIO_ready,

    output wire        MemRW,
    output wire        CPU_MIO,
    output wire [31:0] PC_out,
    output wire [31:0] Addr_out,
    output wire [31:0] Data_out
);

    // ========= Instruction field split =========
    wire [4:0] OPcode  = inst_in[6:2];
    wire [2:0] Fun3    = inst_in[14:12];
    wire       Fun7    = inst_in[30];

    // ========= Control Signals =========
    wire [2:0] ImmSel;
    wire       ALUSrc_B;
    wire [1:0] MemtoReg;
    wire [1:0] Jump;
    wire       Branch, BranchN;
    wire       RegWrite;
    wire       MemRW_ctrl;
    wire [3:0] ALU_Control;

    assign MemRW = MemRW_ctrl;

    SCPU_ctrl_more U_CTRL (
        .OPcode(OPcode),
        .Fun3(Fun3),
        .Fun7(Fun7),
        .MIO_ready(MIO_ready),

        .ImmSel(ImmSel),
        .ALUSrc_B(ALUSrc_B),
        .MemtoReg(MemtoReg),
        .Jump(Jump),
        .Branch(Branch),
        .BranchN(BranchN),
        .RegWrite(RegWrite),
        .MemRW(MemRW_ctrl),
        .ALU_Control(ALU_Control),
        .CPU_MIO(CPU_MIO)
    );

    // ========= Datapath =========
    DataPath_more U_DP (
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

        .PC_out(PC_out),
        .ALU_out(Addr_out),
        .Data_out(Data_out)
    );

endmodule
