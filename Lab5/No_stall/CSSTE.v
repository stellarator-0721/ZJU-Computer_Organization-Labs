`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/12/15 20:50:14
// Design Name: 
// Module Name: CSSTE
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CSSTE(
    input clk_100mhz,
    input RSTN,
    input [3:0] BTN_y,
    input [15:0] SW,
    output [3:0] Blue,
    output [3:0] Green,
    output [3:0] Red,
    output HSYNC,
    output VSYNC,
    output [7:0] AN,
    output [7:0] segment,
    output [15:0] LED_out
);

    wire Clk_CPU;
    wire [31:0] clk_div;
    wire rst;
    wire [15:0] SW_OK;
    wire [3:0] BTN_OK;
    wire MemRW_Ex, MemRW_Mem;
    wire [31:0] PC_out;
    wire [31:0] Inst_IF;
    wire [31:0] Data_out;
    wire [31:0] Addr_out;
    wire [31:0] Data_in;
    wire [31:0] Data_out_WB;
    wire [31:0] PC_ID, PC_Ex;
    wire [31:0] inst_ID;
    wire CPU_MIO;
    wire [31:0] RAM_B_0_douta;
    wire [31:0] ram_data_in;
    wire [9:0] ram_addr;
    wire U4_data_ram_we;
    wire [15:0] led_out;
    wire [31:0] counter_out;
    wire counter0_OUT;
    wire counter1_OUT;
    wire counter2_OUT;
    wire counter_we;
    wire [1:0] counter_set;
    wire GPIOe0000000_we;
    wire GPIOf0000000_we;
    wire [31:0] Peripheral_in;
    wire [7:0] point_out;
    wire [7:0] les;
    wire [31:0] disp_num;
    wire led_clk, led_sout, led_clrn, LED_PEN;
    wire [13:0] GPIOf0;
    wire readn;
    wire [4:0] Key_x, Key_out;
    wire Key_ready;
    wire [3:0] pulse_out;
    wire CR;
    
    Pipeline_CPU U1(
        .clk(Clk_CPU),
        .rst(rst),
        .Data_in(Data_in),
        .inst_IF(Inst_IF),
        .PC_out_IF(PC_out),
        .PC_out_ID(PC_ID),
        .inst_ID(inst_ID),
        .PC_out_Ex(PC_Ex),
        .MemRW_Ex(MemRW_Ex),
        .MemRW_Mem(MemRW_Mem),
        .Addr_out(Addr_out),
        .Data_out(Data_out),
        .Data_out_WB(Data_out_WB)
    );

    ROM_0 U2(
        .a(PC_out[11:2]),
        .spo(Inst_IF)
    );

    RAM_B U3(
        .addra(ram_addr),
        .clka(~clk_100mhz),
        .dina(ram_data_in),
        .douta(RAM_B_0_douta),
        .wea(U4_data_ram_we)
    );

    MIO_BUS U4(
        .clk(clk_100mhz), 
        .rst(rst), 
        .BTN(BTN_OK), 
        .SW(SW_OK), 
        .mem_w(MemRW_Mem),
        .Cpu_data2bus(Data_out), 
        .addr_bus(Addr_out),
        .ram_data_out(RAM_B_0_douta),
        .led_out(led_out), 
        .counter_out(counter_out), 
        .counter0_out(counter0_OUT), 
        .counter1_out(counter1_OUT), 
        .counter2_out(counter2_OUT), 
        .Cpu_data4bus(Data_in), 
        .ram_data_in(ram_data_in), 
        .ram_addr(ram_addr), 
        .data_ram_we(U4_data_ram_we), 
        .GPIOf0000000_we(GPIOf0000000_we), 
        .GPIOe0000000_we(GPIOe0000000_we), 
        .counter_we(counter_we), 
        .Peripheral_in(Peripheral_in)
    );

    Multi_8CH32 U5( 
        .clk(~Clk_CPU), 
        .rst(rst), 
        .EN(GPIOe0000000_we),
        .point_in({clk_div[31:0], clk_div[31:0]}),
        .LES(64'b0),
        .Test(SW_OK[7:5]),
        .Data0(Peripheral_in),
        .data1({2'b00, PC_out[31:2]}),
        .data2(Inst_IF), 
        .data3(counter_out), 
        .data4(Addr_out), 
        .data5(Data_out),
        .data6(Data_in),
        .data7(PC_out),
        .point_out(point_out),
        .LE_out(les),
        .Disp_num(disp_num)
    );

    Seg7_Dev U6(
        .scan(clk_div[18:16]),
        .disp_num(disp_num),
        .point(point_out),
        .les(les),
        .AN(AN),
        .segment(segment)
    );

    SPIO U7(
        .clk(~Clk_CPU),
        .rst(rst), 
        .Start(clk_div[20]),
        .EN(GPIOf0000000_we),
        .P_Data(Peripheral_in), 
        .counter_set(counter_set), 
        .LED_out(led_out), 
        .led_clk(led_clk),
        .led_sout(led_sout),
        .led_clrn(led_clrn),
        .LED_PEN(LED_PEN),
        .GPIOf0(GPIOf0)
    );

    clk_div U8(
        .clk(clk_100mhz),
        .rst(rst),
        .SW2(SW_OK[2]),
        .SW8(SW_OK[8]),
        .STEP(SW_OK[10]),
        .clkdiv(clk_div),
        .Clk_CPU(Clk_CPU)
    );

    SAnti_jitter U9(
        .clk(clk_100mhz),
        .RSTN(RSTN),
        .readn(readn),
        .Key_y(BTN_y),
        .Key_x(Key_x),
        .SW(SW),
        .Key_out(Key_out),
        .Key_ready(Key_ready), 
        .pulse_out(pulse_out),
        .BTN_OK(BTN_OK),
        .SW_OK(SW_OK),
        .CR(CR),
        .rst(rst)
    );
    
    Counter_x U10(
        .clk(~Clk_CPU),
        .rst(rst),
        .clk0(clk_div[6]),
        .clk1(clk_div[9]),
        .clk2(clk_div[11]),
        .counter_we(counter_we),
        .counter_val(Peripheral_in), 
        .counter_ch(counter_set),
        .counter0_OUT(counter0_OUT),
        .counter1_OUT(counter1_OUT),
        .counter2_OUT(counter2_OUT),
        .counter_out(counter_out)
    );
    
    VGA U11(
        .clk_25m(clk_div[1]),
        .clk_100m(clk_100mhz),
        .rst(rst),
        .PC_IF(PC_out),
        .inst_IF(Inst_IF),
        .PC_ID(PC_ID),
        .inst_ID(inst_ID),
        .PC_Ex(PC_Ex),
        .MemRW_Ex(MemRW_Ex),
        .MemRW_Mem(MemRW_Mem),
        .Data_out(Data_out),
        .Addr_out(Addr_out),
        .Data_out_WB(Data_out_WB),
        .hs(HSYNC),
        .vs(VSYNC),
        .vga_r(Red),
        .vga_g(Green), 
        .vga_b(Blue)
    );

    assign LED_out = led_out;

endmodule