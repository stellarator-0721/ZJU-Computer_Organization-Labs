module float_add (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [1:0]  c,      // 00:+
    input  wire        en,     // 启动信号（可选）
    output reg  [31:0] result,
    output reg         fin     // 结果有效信号，保持1周期
);

// ============================================================
// 内部寄存器声明
// ============================================================
reg [31:0] A_prev, B_prev;
reg [1:0]  c_prev;
wire input_changed = (A != A_prev) || (B != B_prev) || (c != c_prev);

// === 以下为组合计算用的中间寄存器 ===
reg signA, signB;
reg [7:0] expA, expB;
reg [23:0] fracA, fracB;
reg [7:0] exp_large, exp_small;
reg [24:0] frac_large, frac_small;
reg sign_large, sign_small;
reg [25:0] frac_sum;
reg [24:0] frac_norm;
reg [7:0]  exp_res;
reg [7:0]  exp_norm;
reg        sign_res;

reg [31:0] result_comb;

// ============================================================
// 组合逻辑：浮点加法核心
// ============================================================
always @(*) begin
    // 默认输出
    result_comb = 32'h00000000;

    if (c == 2'b00) begin
        // 拆分字段
        signA = A[31];
        signB = B[31];
        expA  = A[30:23];
        expB  = B[30:23];
        fracA = (expA == 0) ? {1'b0, A[22:0]} : {1'b1, A[22:0]};
        fracB = (expB == 0) ? {1'b0, B[22:0]} : {1'b1, B[22:0]};

        // 对齐指数
        if (expA >= expB) begin
            exp_large  = expA;
            exp_small  = expB;
            frac_large = {1'b1, fracA};
            frac_small = {1'b1, fracB} >> (expA - expB);
            sign_large = signA;
            sign_small = signB;
        end else begin
            exp_large  = expB;
            exp_small  = expA;
            frac_large = {1'b1, fracB};
            frac_small = {1'b1, fracA} >> (expB - expA);
            sign_large = signB;
            sign_small = signA;
        end

        // 加/减法
        exp_res = exp_large;
        if (sign_large == sign_small) begin
            frac_sum = frac_large + frac_small;
            sign_res = sign_large;
        end else begin
            if (frac_large >= frac_small) begin
                frac_sum = frac_large - frac_small;
                sign_res = sign_large;
            end else begin
                frac_sum = frac_small - frac_large;
                sign_res = sign_small;
            end
        end

        // 规格化
        if (frac_sum[25]) begin
            frac_norm = frac_sum[25:1];
            exp_norm  = exp_res + 1;
        end else begin
            frac_norm = frac_sum[24:0];
            exp_norm  = exp_res;
            // 左规
            while (frac_norm[24] == 0 && exp_norm > 0 && frac_norm != 0) begin
                frac_norm = frac_norm << 1;
                exp_norm  = exp_norm - 1;
            end
        end

        // 简化舍入
        result_comb = {sign_res, exp_norm, frac_norm[22:0]};
    end
end

// ============================================================
// 时序逻辑：检测输入变化并锁存结果
// ============================================================
always @(posedge clk or posedge rst) begin
    if (rst) begin
        result   <= 32'b0;
        fin      <= 1'b0;
        A_prev   <= 32'b0;
        B_prev   <= 32'b0;
        c_prev   <= 2'b00;
    end else begin
        A_prev <= A;
        B_prev <= B;
        c_prev <= c;

        if (input_changed && en) begin
            result <= result_comb;
            fin    <= 1'b1;   // 拉高1周期
        end else begin
            fin <= 1'b0;
        end
    end
end

endmodule
