module stall( 
    input wire rst_stall,                //复位

    // 数据冒险检测相关
    input wire RegWrite_out_IDEX,
    input wire [4:0] Rd_addr_out_IDEX,
    input wire RegWrite_out_EXMem,
    input wire [4:0] Rd_addr_out_EXMem,
    input wire [4:0] Rs1_addr_ID,
    input wire [4:0] Rs2_addr_ID,
    input wire Rs1_used,
    input wire Rs2_used,

    // 控制冒险检测相关
    input wire Branch_ID,
    input wire BranchN_ID,
    input wire Jump_ID,
    input wire Branch_out_IDEX,
    input wire BranchN_out_IDEX,
    input wire Jump_out_IDEX,
    input wire Branch_out_EXMem,
    input wire BranchN_out_EXMem,
    input wire Jump_out_EXMem,

    // 控制输出
    output reg en_IF,
    output reg en_IFID,
    output reg NOP_IFID,
    output reg NOP_IDEX
); 

    reg Data_stall;
    reg Control_stall;

    always @(*) begin
        //==========================================================
        // 数据冒险检测 （ID阶段的Rs1/Rs2 与 IDEX/EXMEM 冲突）
        //==========================================================
        Data_stall = 0;

        // EX/MEM → ID
        if (RegWrite_out_EXMem && Rs1_used && (Rd_addr_out_EXMem == Rs1_addr_ID) && (Rs1_addr_ID != 0))
            Data_stall = 1;
        else if (RegWrite_out_EXMem && Rs2_used && (Rd_addr_out_EXMem == Rs2_addr_ID) && (Rs2_addr_ID != 0))
            Data_stall = 1;

        // ID/EX → ID（load-use 冒险）
        else if (RegWrite_out_IDEX && Rs1_used && (Rd_addr_out_IDEX == Rs1_addr_ID) && (Rs1_addr_ID != 0))
            Data_stall = 1;
        else if (RegWrite_out_IDEX && Rs2_used && (Rd_addr_out_IDEX == Rs2_addr_ID) && (Rs2_addr_ID != 0))
            Data_stall = 1;


        //==========================================================
        // 控制冒险检测（branch/jump）
        //==========================================================
        Control_stall = 
               Branch_ID        | BranchN_ID        | Jump_ID
            |  Branch_out_IDEX  | BranchN_out_IDEX  | Jump_out_IDEX
            |  Branch_out_EXMem | BranchN_out_EXMem | Jump_out_EXMem;


        //==========================================================
        // 输出控制逻辑（关键：每个信号只赋值一次）
        //==========================================================
        if (rst_stall) begin
            en_IF     = 1;
            en_IFID   = 1;
            NOP_IFID  = 0;
            NOP_IDEX  = 0;
        end
        else if (Data_stall) begin
            // 数据冒险：阻塞 IF 和 IFID，IDEX 插入气泡
            en_IF     = 0;
            en_IFID   = 0;
            NOP_IFID  = 0;
            NOP_IDEX  = 1;
        end
        else if (Control_stall) begin
            // 控制冒险：刷新 IFID（丢掉错误指令）
            en_IF     = 1;
            en_IFID   = 1;
            NOP_IFID  = 1;   // flush IFID
            NOP_IDEX  = 0;
        end
        else begin
            // 正常情况：全部向前流动
            en_IF     = 1;
            en_IFID   = 1;
            NOP_IFID  = 0;
            NOP_IDEX  = 0;
        end
    end

endmodule
