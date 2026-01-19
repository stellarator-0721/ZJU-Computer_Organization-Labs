`timescale 1ns / 1ps

module Regs(    
        input wire clk,
				input wire rst,
				input wire [4:0] Rs1_addr, 
				input wire [4:0] Rs2_addr, 
				input wire[4:0] Wt_addr, 
				input wire[31:0]Wt_data, 
				input wire RegWrite, 
				output wire[31:0] Rs1_data, 
				output wire[31:0] Rs2_data
    );
    reg [31:0] register [1:31]; 			
    integer i;
    
        assign Rs1_data = (Rs1_addr == 0)? 0 : register[Rs1_addr];
        assign Rs2_data = (Rs2_addr == 0)? 0 : register[Rs2_addr];  

        always @(posedge clk or posedge rst) 
          begin
            if (rst==1)      begin              // reset
                for (i=1; i<32; i=i+1)
                register[i] <= 0;    //i;
            end 
            else begin
                 if ((Wt_addr != 0) && (RegWrite == 1)) 
                 register[Wt_addr] <= Wt_data;
            end
        end
endmodule