module DataPath(
    input clk, 
    input rst, 
    input [31:0] inst_field,
    input [31:0] Data_in,
    input [2:0] ALU_Control,
    input [1:0] ImmSel,
    input [1:0] MemtoReg,
    input ALUSrc_B,
    input Jump,
    input Branch,
    input RegWrite,
    output [31:0] PC_out,
    output [31:0] Data_out,
    output [31:0] ALU_out
);

wire [31:0] Cout_0;
wire [31:0] Cout_1;
wire [31:0] Imm_out;
wire Zero;

wire [31:0] output_0;
wire [31:0] output_1;
wire [31:0] output_3;

ImmGen ImmGen_0(
    .inst_field(inst_field),
    .ImmSel(ImmSel),
    .Imm_out(Imm_out)
    );


add_32 ADD_32_0(
    .a(PC_out),
    .b(32'd4),
    .c(Cout_0)
    );

add_32 ADD_32_1(
    .a(PC_out),
    .b(Imm_out),
    .c(Cout_1)
    );

REG32 REG32_1(
    .clk(clk),
    .rst(rst),
    .D(output_3),
    .CE(1'b1),
    .Q(PC_out)
    );

MUX2T1_32 MUX2T1_32_0(
    .I0(Data_out),
    .I1(Imm_out),
    .s(ALUSrc_B),
    .o(output_0)
    );

MUX2T1_32 MUX2T1_32_1(
    .I0(Cout_0),
    .I1(Cout_1),
    .s(Branch & Zero),
    .o(output_1)
    );

MUX2T1_32 MUX2T1_32_3(
    .I0(output_1),
    .I1(Cout_1),
    .s(Jump),
    .o(output_3)
    );

wire [31:0] Wt_data;
 
MUX4T1_32 MUX4T1_32_0(
    .I0(ALU_out),
    .I1(Data_in),
    .I2(Cout_0),
    .I3(Cout_0),
    .s(MemtoReg),
    .o(Wt_data)
    );

wire [31:0] Rs1_addr;

Regs Regs_0(
    .clk(clk),
    .rst(rst),
    .Rs1_addr(inst_field[19:15]),
    .Rs2_addr(inst_field[24:20]),
    .Wt_addr(inst_field[11:7]),
    .Wt_data(Wt_data),
    .RegWrite(RegWrite),
    .Rs1_data(Rs1_addr),
    .Rs2_data(Data_out)
    );

ALU ALU_0(
    .A(Rs1_addr),
    .B(output_0),
    .ALU_Control(ALU_Control),
    .res(ALU_out),
    .Zero(Zero)
    );

endmodule