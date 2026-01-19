
module Water_LED_tb;
    reg CLK_i;
    reg RSTn_i;
    wire [3:0] LED_o;

    Water_LED Water_LED_U (
        .CLK_i(CLK_i),
        .RSTn_i(RSTn_i),
        .LED_o(LED_o)
    );

    always #1 CLK_i = ~CLK_i; // 10 time units clock period

    initial begin
        CLK_i = 0;
        RSTn_i = 0;

        #100 RSTn_i = 1; // Release reset after 100 time units
    end

endmodule