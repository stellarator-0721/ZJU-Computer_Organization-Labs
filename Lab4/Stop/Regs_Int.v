`timescale 1ns / 1ps

module Regs_Int(
    input clk, 
    input rst, 
    input RegWrite, 
    input [4:0] Rs1_addr, 
    input [4:0] Rs2_addr, 
    input [4:0] Wt_addr, 
    input [31:0] Wt_data,
    output [31:0] Rs1_data, 
    output [31:0] Rs2_data
);

reg [31:0] register [0:31]; // r0 - r31
integer i;

// 异步读
assign Rs1_data = (Rs1_addr == 0) ? 32'b0 : register[Rs1_addr];
assign Rs2_data = (Rs2_addr == 0) ? 32'b0 : register[Rs2_addr];

// 同步写
always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < 32; i = i + 1)
            register[i] <= 32'b0;
    end else if (RegWrite && (Wt_addr != 0)) begin
        register[Wt_addr] <= Wt_data;
    end
end

endmodule
