`timescale 1ns / 1ps

module PC (
    input wire clk,     
    input wire rst,   
    input wire CE,     
    input wire [31:0] D,  
    output reg [31:0] Q  
);
always @(posedge clk  or posedge rst) begin
    if (rst) begin
        Q <= 32'b0;   
    end
    else if (CE) 
        Q <= D;       
end

endmodule