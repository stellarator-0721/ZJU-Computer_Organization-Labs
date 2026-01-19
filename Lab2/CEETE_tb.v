`timescale 1ns / 1ps

module SCPU_Testbench;

    // 时钟和复位
    reg clk_100mhz;
    reg RSTN;
    
    // 输入信号
    reg [3:0] BTN_y;
    reg [15:0] SW;
    
    // 输出信号
    wire [3:0] Blue, Green, Red;
    wire HSYNC, VSYNC;
    wire [7:0] AN, segment;
    wire [15:0] LED_out;
    
    // 测试指令存储器
    reg [31:0] instruction_memory [0:63];
    integer i;
    
    // 实例化CSSTE
    CSSTE uut (
        .clk_100mhz(clk_100mhz),
        .RSTN(RSTN),
        .BTN_y(BTN_y),
        .SW(SW),
        .Blue(Blue),
        .Green(Green),
        .Red(Red),
        .HSYNC(HSYNC),
        .VSYNC(VSYNC),
        .AN(AN),
        .segment(segment),
        .LED_out(LED_out)
    );
    
    // 时钟生成 - 100MHz
    always #5 clk_100mhz = ~clk_100mhz;
    
    // 初始化测试指令
    initial begin
        // R-type 指令
        instruction_memory[0] = 32'h00500193;  // addi x3, x0, 5     -> x3 = 5
        instruction_memory[1] = 32'h00600213;  // addi x4, x0, 6     -> x4 = 6
        instruction_memory[2] = 32'h004181b3;  // add x3, x3, x4     -> x3 = 11 (R-type)
        instruction_memory[3] = 32'h40418233;  // sub x4, x3, x4     -> x4 = 5 (R-type)
        instruction_memory[4] = 32'h0031f2b3;  // and x5, x3, x3     -> x5 = 11 (R-type)
        
        // I-type 指令
        instruction_memory[5] = 32'h00208313;  // addi x6, x1, 2     -> x6 = rs1 + 2
        instruction_memory[6] = 32'h0030c393;  // xori x7, x1, 3     -> x7 = rs1 ^ 3
        instruction_memory[7] = 32'h0040de13;  // srai x28, x1, 4    -> 算术右移
        
        // Load/Store 指令
        instruction_memory[8] = 32'h0080a403;  // lw x8, 8(x1)      -> 从内存加载
        instruction_memory[9] = 32'h0080a223;  // sw x8, 4(x1)      -> 存储到内存
        
        // Branch 指令
        instruction_memory[10] = 32'h00318463; // beq x3, x3, 8     -> 相等跳转
        instruction_memory[11] = 32'h00419463; // bne x3, x4, 8     -> 不等跳转
        
        // Jump 指令
        instruction_memory[12] = 32'h010000ef; // jal x1, 16        -> 跳转并链接
        
        // 填充剩余为nop
        for (i = 13; i < 64; i = i + 1) begin
            instruction_memory[i] = 32'h00000013; // nop
        end
    end
    
    // 测试过程
    initial begin
        // 初始化
        clk_100mhz = 0;
        RSTN = 0;
        BTN_y = 4'b0000;
        SW = 16'h0000;
        
        // 复位
        #100;
        RSTN = 1;
        #50;
        
        $display("复位完成，开始执行指令...");
        
        // 运行足够长时间观察执行
        #5000;
        
        $display("=== 仿真测试完成 ===");
        $finish;
    end
 

endmodule