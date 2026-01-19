`timescale 1ns / 1ps

module SCPU_tb;
    reg clk;
    reg rst;
    reg MIO_ready;
    reg [31:0] inst_in;
    reg [31:0] Data_in;
    wire MemRW;
    wire CPU_MIO;
    wire [31:0] PC_out;
    wire [31:0] Data_out;
    wire [31:0] Addr_out;

    integer test_step;

    // === 实例化被测 CPU ===
    SCPU uut (
        .clk(clk),
        .rst(rst),
        .MIO_ready(MIO_ready),
        .inst_in(inst_in),
        .Data_in(Data_in),
        .MemRW(MemRW),
        .CPU_MIO(CPU_MIO),
        .PC_out(PC_out),
        .Data_out(Data_out),
        .Addr_out(Addr_out)
    );

    // === 时钟信号，每 5ns 翻转一次 ===
    always #5 clk = ~clk;

    initial begin
        // === 初始化信号 ===
        clk = 0;
        rst = 1;
        MIO_ready = 1;  // 假设总线随时准备好
        inst_in = 0;
        Data_in = 0;
        test_step = 0;

        // === 复位阶段 ===
        #25;  
        rst = 0;   // 释放复位
        #10;

        // === 指令测试序列 ===
        // 每条指令等待 20ns，之后打印当前 PC 和 地址信号 ===

        // ------------------ R 型指令 ------------------
        test_step = 1; inst_in = 32'h00c58633; #20; 
        // ADD x12, x11, x12   → x12 = x11 + x12
        $display("%0t step%0d ADD  PC=%h Addr=%h", $time, test_step, PC_out, Addr_out);

        test_step = 2; inst_in = 32'h40c58633; #20; 
        // SUB x12, x11, x12   → x12 = x11 - x12
        $display("%0t step%0d SUB  PC=%h Addr=%h", $time, test_step, PC_out, Addr_out);

        test_step = 3; inst_in = 32'h00c5f633; #20; 
        // AND x12, x11, x12   → x12 = x11 & x12
        $display("%0t step%0d AND  PC=%h Addr=%h", $time, test_step, PC_out, Addr_out);

        // ------------------ I 型指令（LW, ADDI） ------------------
        test_step = 4; inst_in = 32'h0045a603; #20; 
        // LW x12, 4(x11)      → x12 = Mem[x11 + 4]
        $display("%0t step%0d LW   PC=%h Addr=%h", $time, test_step, PC_out, Addr_out);

        // ------------------ S 型指令（SW） ------------------
        test_step = 5; inst_in = 32'h00c5a423; #20; 
        // SW x12, 8(x11)      → Mem[x11 + 8] = x12
        $display("%0t step%0d SW   PC=%h Addr=%h", $time, test_step, PC_out, Addr_out);

        // ------------------ B 型指令（BEQ） ------------------
        test_step = 6; inst_in = 32'h00c58663; #20; 
        // BEQ x11, x12, offset=12  → 若 x11==x12，则 PC += 12
        $display("%0t step%0d BEQ  PC=%h Addr=%h", $time, test_step, PC_out, Addr_out);

        // ------------------ J 型指令（JAL） ------------------
        test_step = 7; inst_in = 32'h010000ef; #20; 
        // JAL x1, 16           → x1 = PC + 4; PC += 16
        $display("%0t step%0d JAL  PC=%h Addr=%h", $time, test_step, PC_out, Addr_out);

        // ------------------ I 型指令（ADDI） ------------------
        test_step = 8; inst_in = 32'h00c58693; #20; 
        // ADDI x13, x11, 12    → x13 = x11 + 12
        $display("%0t step%0d ADDI PC=%h Addr=%h", $time, test_step, PC_out, Addr_out);

        // ------------------ I / S 型组合（再次测试加载与存储） ------------------
        test_step = 9; inst_in = 32'h0085a683; #20; 
        // LW x13, 8(x11)       → x13 = Mem[x11 + 8]
        $display("%0t step%0d LW2  PC=%h Addr=%h", $time, test_step, PC_out, Addr_out);

        test_step = 10; inst_in = 32'h00d5a623; #20; 
        // SW x13, 12(x11)      → Mem[x11 + 12] = x13
        $display("%0t step%0d SW2  PC=%h Addr=%h", $time, test_step, PC_out, Addr_out);

        // === 结束仿真 ===
        #100;
        $finish;
    end

    // === 实时监控信号变化 ===
    initial begin
        $monitor("%0t | PC=%h | Addr=%h | MemRW=%b | DataOut=%h", 
                 $time, PC_out, Addr_out, MemRW, Data_out);
    end
endmodule
