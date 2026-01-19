`timescale 1ns / 1ps

module div32(
    input clk,
    input rst,
    input start,
    input [31:0] dividend,
    input [31:0] divisor,
    output [31:0] quotient,
    output [31:0] remainder,
    output reg finish
);

reg [63:0] rem_reg;
reg [31:0] divisor_reg;
reg [5:0] count;
reg running;

// 输出赋值
assign quotient = rem_reg[31:0];
assign remainder = rem_reg[63:32];

// 组合逻辑计算减法
wire [63:0] rem_shifted = rem_reg << 1;
wire [32:0] sub_temp = {1'b0, rem_shifted[63:32]} - {1'b0, divisor_reg};//加一位防止溢出
wire sub_borrow = sub_temp[32];
wire [31:0] sub_result = sub_temp[31:0];

always @(posedge clk or posedge rst) begin
    if (rst) begin
        rem_reg <= 64'b0;
        divisor_reg <= 32'b0;
        finish <= 1'b0;
        running <= 1'b0;
        count <= 6'b0;
    end else begin
        if (start) begin // 载入数据
            if (divisor == 32'b0) begin  // 特殊情况：除数为0
                rem_reg <= 64'b0;
                finish <= 1'b1;
                running <= 1'b0;
            end 
            else if (dividend < divisor) begin // 特殊情况：被除数小于除数
                rem_reg <= {32'b0, dividend};
                finish <= 1'b1;
                running <= 1'b0;
            end 
            else begin // 正常情况
                rem_reg <= {32'b0, dividend}; // 高32位余数，低32位商
                divisor_reg <= divisor;
                finish <= 1'b0;
                running <= 1'b1;
                count <= 6'b0;
            end
        end 
        else if (running) begin
            if (count < 32) begin
                if (sub_borrow) begin // 若减法结果为负
                    rem_reg <= {rem_shifted[63:32], rem_shifted[31:1], 1'b0}; // 商位补0
                end 
                else begin
                    rem_reg <= {sub_result, rem_shifted[31:1], 1'b1}; // 商位补1
                end
                count <= count + 1;
            end 
            else begin
                finish <= 1'b1;
                running <= 1'b0;
            end
        end
    end
end

endmodule