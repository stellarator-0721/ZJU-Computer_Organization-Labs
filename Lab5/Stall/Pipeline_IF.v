`timescale 1ns / 1ps

module Pipeline_IF( 
    input wire clk_IF,
    input wire rst_IF,
    input wire en_IF,
    input wire [31:0] PC_in_IF,
    input wire PCSrc,
    input wire Control_stall_IF,
    output reg [31:0] PC_out_IF
); 

  wire [31:0] Q_0;
  wire [31:0] I0=32'h4+Q_0;
  wire [31:0] o=(PCSrc==1)?PC_in_IF:I0;
  
  PC PC_0(.clk(clk_IF),.rst(rst_IF),.CE(en_IF&(~Control_stall_IF)),.D(o),.Q(Q_0));

  always @(*)begin
    PC_out_IF=Q_0;
  end

endmodule