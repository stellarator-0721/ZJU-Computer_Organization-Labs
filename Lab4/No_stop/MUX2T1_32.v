module MUX2T1_32(
    input  [31:0] I0,     // 32位输入0
    input  [31:0] I1,     // 32位输入1
    input         s,      // 选择信号
    output [31:0] o       // 32位输出
);

    // 当s=0时选择I0，s=1时选择I1
    assign o = s ? I1 : I0;

endmodule