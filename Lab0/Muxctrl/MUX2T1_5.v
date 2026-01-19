module MUX2T1_5 (
    input [4:0] I0,
    input [4:0] I1,
    input s,
    output [4:0] o
);
    assign o = s ? I1 : I0;

endmodule