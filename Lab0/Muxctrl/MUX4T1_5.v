module MUX4T1_5(
    input [1:0] s,
    input [4:0] I0,
    input [4:0] I1,
    input [4:0] I2,
    input [4:0] I3,
    output [4:0] o
);

    assign o = (s == 2'b00) ? I0 :
               (s == 2'b01) ? I1 :
               (s == 2'b10) ? I2 :
               (s == 2'b11) ? I3 : 5'b0;

endmodule