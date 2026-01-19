module MUX4T1_32(
    input  [31:0] I0,     // 32位输入0
    input  [31:0] I1,     // 32位输入1
    input  [31:0] I2,     // 32位输入2
    input  [31:0] I3,     // 32位输入3
    input  [1:0]  s,      // 2位选择信号
    output [31:0] o       // 32位输出
);

    // 根据2位选择信号s选择4个输入之一
    assign o = (s == 2'b00) ? I0 :
               (s == 2'b01) ? I1 :
               (s == 2'b10) ? I2 :
               I3;  // s == 2'b11

endmodule