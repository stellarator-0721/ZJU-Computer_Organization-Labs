module IF_reg_ID(
    input wire clk_IFID,
    input wire rst_IFID,
    input wire en_IFID,
    input wire [31:0]PC_in_IFID,
    input wire [31:0]inst_in_IFID,
    input wire NOP_IFID,
    output reg [31:0]PC_out_IFID,
    output reg [31:0]inst_out_IFID,
    output reg valid_IFID
);

    always @(posedge clk_IFID or posedge rst_IFID) begin
        if (rst_IFID) begin
            // 复位：清空流水线寄存器
            PC_out_IFID   <= 32'b0;
            inst_out_IFID <= 32'b0;
            valid_IFID    <= 1'b0;
        end
        else if (!en_IFID) begin
            // 暂停（Stall）：保持原值，不让新指令进入
            PC_out_IFID   <= PC_out_IFID;
            inst_out_IFID <= inst_out_IFID;
            valid_IFID    <= valid_IFID;
        end
        else if (NOP_IFID) begin
            // 插入 NOP（Flush 气泡）
            PC_out_IFID   <= 32'b0;
            inst_out_IFID <= 32'h00000013;  // addi x0, x0, 0
            valid_IFID    <= 1'b0;
        end
        else begin
            // 正常传递
            PC_out_IFID   <= PC_in_IFID;
            inst_out_IFID <= inst_in_IFID;
            valid_IFID    <= 1'b1;
        end
    end

endmodule
