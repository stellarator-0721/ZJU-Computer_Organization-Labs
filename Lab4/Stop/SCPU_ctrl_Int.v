`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/24 20:31:38
// Design Name: 
// Module Name: SCPU_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:`timescale 1ns / 1ps
module SCPU_ctrl_Int(
    input [4:0] OPcode,
    input [2:0] Fun3,
    input Fun7,
    input MIO_ready,
    input [2:0]Fun_ecall,
    input [1:0]Fun_mret,
    output reg [2:0] ImmSel,
    output reg ALUSrc_B,
    output reg [1:0] MemtoReg,
    output reg [1:0]Jump,
    output reg Branch,
    output reg BranchN,
    output reg RegWrite,
    output reg MemRW,
    output reg [3:0] ALU_Control,
    output reg CPU_MIO,
    output reg ecall,
    output reg mret,
    output reg ill_instr
);
    reg [15:0] CPU_ctrl_signals;
    reg [1:0] ALUop;
    wire[3:0] Fun;
    assign Fun={Fun3,Fun7};
    `define CPU_ctrl_signals {ALUSrc_B,MemtoReg,RegWrite,MemRW,Branch,BranchN,Jump, ALU_Control,ImmSel}
    always @* begin
        ecall<=1'b0;
        mret<=1'b0;
        ill_instr<=1'b0;
        case(OPcode)
            5'b11100:begin
                if(Fun_ecall==3'b000) ecall<=1'b1;
                if(Fun_mret==2'b11) mret<=1'b1;
            end
            5'b00000: // I-type load
                begin
                    `CPU_ctrl_signals = {1'b1, 2'b01, 1'b1, 1'b0, 1'b0, 1'b0, 2'b00, 4'b0010, 3'b001};
                end
            5'b01100: //ALU R-type
            begin
                `CPU_ctrl_signals = {1'b0, 2'b00, 1'b1, 1'b0, 1'b0, 1'b0, 2'b00, 4'bxxxx, 3'b001};
                case(Fun)
                    4'b0000: ALU_Control = 4'b0010; // add
                    4'b1100: ALU_Control = 4'b0001; //or
                    4'b1110: ALU_Control = 4'b0000; //and
                    4'b0001: ALU_Control = 4'b0110; // sub
                    4'b0010: ALU_Control = 4'b1110; // sll
                    4'b0100: ALU_Control = 4'b0111; // slt
                    4'b1000: ALU_Control = 4'b1100; // xor
                    4'b1010: ALU_Control = 4'b1101; // srl
                    4'b0110: ALU_Control = 4'b1001; // sltu
                    4'b1011: ALU_Control = 4'b1111; // sra
                    default: ALU_Control = 4'b0010;
                endcase
            end
            5'b01000: begin `CPU_ctrl_signals ={1'b1, 2'b00, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00, 4'b0010, 3'b010}; end //store
            5'b00100:
            begin
                `CPU_ctrl_signals = {1'b1,2'b00,1'b1,1'b0,1'b0,1'b0,2'b00,4'bxxxx,3'b001};   // I-type addi
                begin
                    case(Fun3)
                    3'b000: ALU_Control=4'b0010; //add
                    3'b010: ALU_Control=4'b0111; //slt
                    3'b011: ALU_Control=4'b1001; //sltu
                    3'b100: ALU_Control=4'b1100; //xor
                    3'b110: ALU_Control=4'b0001; //or
                    3'b111: ALU_Control=4'b0000; //and
                    3'b001: ALU_Control=4'b1110; //sll
                    3'b101:
                        begin
                            case(Fun7)
                            1'b0:ALU_Control=4'b1101;//srl
                            1'b1:ALU_Control=4'b1111;//sra
                            endcase
                        end
                    default: ALU_Control=4'bxxxx;
                    endcase
                end
            end
            5'b00000: //I-type lw
            begin
                `CPU_ctrl_signals={1'b1,2'b01,1'b1,1'b0,1'b0,1'b0,2'b00,4'b0010,3'b001};
            end
            5'b11001:  //I-type jalr
            begin
                `CPU_ctrl_signals={1'b1,2'b10,1'b1,1'b0,1'b0,1'b0,2'b10,4'b0010,3'b001};
            end
            5'b11000:  //B-type beg,bne,branch
            begin
                `CPU_ctrl_signals={1'b0,2'b00,1'b0,1'b0,1'b0,1'b0,2'b00,4'b0110,3'b011};
                begin
                    case(Fun3)
                    3'b000:
                    begin
                        Branch=1;
                        BranchN=0;
                    end
                    3'b001:
                    begin
                        BranchN=1;
                        Branch=0;
                    end
                    3'b101:
                    begin
                        ill_instr<=1'b1;
                        Branch=0;
                        BranchN=0;
                    end
                    default:
                    begin
                        Branch=0;
                        BranchN=0;
                    end
                    endcase
                end
            end
            5'b11011:  //J-type jal
            begin
                `CPU_ctrl_signals={1'b1,2'b10,1'b1,1'b0,1'b0,1'b0,2'b01,4'b0010,3'b100};
            end
            5'b00101:   //u-type
            begin
                `CPU_ctrl_signals={1'bx,2'b11,1'b1,1'b0,1'b0,1'b0,2'b00,4'bxxxx,3'b000};
            end
            5'b01101: //U-type lui
            begin
                `CPU_ctrl_signals={1'b0,2'b11,1'b1,1'b0,1'b0,1'b0,2'b00,4'b0010,3'b000};
            end
            default: begin `CPU_ctrl_signals = {1'b0, 2'b00, 1'b0,1'b0,1'b0, 1'b0,2'b00, 4'bxxxx, 3'b000}; end 
        endcase
    end
endmodule


