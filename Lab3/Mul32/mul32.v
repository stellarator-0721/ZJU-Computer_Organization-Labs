module mul32(
    input clk,
    input rst,
    input [31:0] multiplicand,
    input [31:0] multiplier,
    input start,
    output reg [63:0] product,
    output reg finish
);

reg [5:0] count;
reg [63:0] next_product;

always @(posedge clk or posedge rst) begin
    if (rst) begin // 重置
        product <= 64'b0;
        count <= 6'd0;
        finish <= 1'b0;
        next_product <= 64'b0;
    end
    else begin
        if (start) begin // 载入数据
            product <= {32'd0, multiplier};  
            count <= 6'd0;               
            finish <= 1'b0;          
        end
        else begin 
            if (count < 32) begin
                next_product = product; // 复制当前乘积寄存器

                if (next_product[0] == 1'b1) begin // 若最低位为1，加上被乘数
                    next_product[63:32] = next_product[63:32] + multiplicand; // 高32位加被乘数
                end
                
                next_product = next_product >> 1; 
                product <= next_product; // 更新乘积寄存器
                count <= count + 1;
            end
            else begin
                finish <= 1'b1;
            end
        end
    end
end

endmodule