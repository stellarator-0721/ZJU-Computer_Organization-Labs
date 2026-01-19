`timescale 1ns / 1ps


module Pipeline_Mem( 
    input wire zero_in_Mem,
    input wire Branch_in_Mem,
    input wire BranchN_in_Mem,
    input wire [1:0]Jump_in_Mem,
    output wire PCSrc
);

assign PCSrc=Jump_in_Mem[0]||Jump_in_Mem[1]||(Branch_in_Mem&&zero_in_Mem)||(BranchN_in_Mem&&~zero_in_Mem);

endmodule