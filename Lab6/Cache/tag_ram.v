module tag_ram (
    input  wire        clk,
    input  wire        en,
    input  wire        we,
    input  wire [6:0]  addr,     // set index
    input  wire [25:0] din,      // {V,D,U,TAG[22:0]}
    output reg  [25:0] dout
);
    // ===== 参数内置 =====
    localparam TAG_WIDTH = 23;
    localparam NUM_SETS  = 128;

    // ===== 存储体 =====
    reg [25:0] mem [0:NUM_SETS-1];

    always @(posedge clk) begin
        if (en) begin
            if (we)
                mem[addr] <= din;
            dout <= mem[addr];
        end
    end
endmodule
