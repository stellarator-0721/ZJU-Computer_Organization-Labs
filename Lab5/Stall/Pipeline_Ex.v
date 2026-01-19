
module Pipeline_Ex( 
    input wire[31:0] PC_in_EX,
    input wire[31:0] Rs1_in_EX,
    input wire[31:0] Rs2_in_EX,
    input wire[31:0] Imm_in_EX,
    input wire ALUSrc_B_in_EX,
    input wire [3:0] ALU_control_in_EX,
    output wire [31:0] PC_out_EX,
    output wire [31:0] PC4_out_EX,
    output wire zero_out_EX,
    output wire [31:0] ALU_out_EX,
    output wire [31:0] Rs2_out_EX
);

wire [31:0] o_0=(ALUSrc_B_in_EX==1)?Imm_in_EX:Rs2_in_EX;

assign PC4_out_EX=32'h4+PC_in_EX;
assign PC_out_EX=PC_in_EX+Imm_in_EX;
assign Rs2_out_EX=Rs2_in_EX;

ALU ALU_0(.A(Rs1_in_EX),.ALU_operation(ALU_control_in_EX),.B(o_0),.res(ALU_out_EX),.zero(zero_out_EX));

endmodule