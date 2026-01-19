module add_32(
    input  [31:0] a,      // 32位输入a
    input  [31:0] b,      // 32位输入b  
    output [31:0] c       // 32位输出c = a + b
);

    // 简单的行为级描述
    assign c = a + b;

endmodule