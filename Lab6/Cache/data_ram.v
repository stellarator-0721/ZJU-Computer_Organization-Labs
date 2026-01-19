module data_ram (
    input  wire        clk,
    input  wire        en,
    input  wire        we,
    input  wire [6:0]  addr,     // 128 sets
    input  wire [127:0] din,      // 4 words = 128 bits
    output reg  [127:0] dout
);
    // ===== 参数内置 =====
    localparam INDEX_WIDTH = 7;
    localparam NUM_SETS    = 128;

    // ===== 存储体 =====
    reg [127:0] mem [0:NUM_SETS-1];

    always @(posedge clk) begin
        if (en) begin
            if (we)
                mem[addr] <= din;
            dout <= mem[addr];
        end
    end
endmodule
