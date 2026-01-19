module Pipeline_Mem(
    input  wire zero_in_Mem,
    input  wire Branch_in_Mem,
    input  wire BranchN_in_Mem,
    input  wire Jump_in_Mem,   // 1-bit
    output wire PCSrc
);

assign PCSrc =
    Jump_in_Mem ||
    (Branch_in_Mem  &&  zero_in_Mem) ||
    (BranchN_in_Mem && ~zero_in_Mem);

endmodule
