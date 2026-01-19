`timescale 1ns / 1ps

module Pipeline_IF( 
    input  wire        clk_IF,
    input  wire        rst_IF,
    input  wire        en_IF,
    input  wire [31:0] PC_in_IF,
    input  wire        PCSrc,
    output wire [31:0] PC_out_IF
); 

  wire [31:0] Q_0;              // current PC
  wire [31:0] PC_plus4;         // PC + 4
  wire [31:0] PC_next;          // mux output

  assign PC_plus4 = Q_0 + 32'd4;

  // MUX: choose next PC
  assign PC_next = (PCSrc == 1'b1) ? PC_in_IF : PC_plus4;

  // PC register
  PC PC_0(
      .clk(clk_IF),
      .rst(rst_IF),
      .CE(en_IF),
      .D(PC_next),
      .Q(Q_0)
  );

  assign PC_out_IF = Q_0;

endmodule
