`timescale 1ns / 1ps


module Pipeline_WB( 
    input wire[31:0] PC4_in_WB,
    input wire[31:0] ALU_in_WB,
    input wire[31:0] Dmem_data_WB,
    input wire[1:0] MemtoReg_in_WB,
    output  wire[31:0] Data_out_WB
);
assign Data_out_WB=(MemtoReg_in_WB==0)?ALU_in_WB:(MemtoReg_in_WB==1?Dmem_data_WB:PC4_in_WB);

endmodule