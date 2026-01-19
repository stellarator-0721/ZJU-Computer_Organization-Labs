`timescale 1ns / 1ps

module cache (
    input  wire        clk,
    input  wire        rst,

    input  wire [31:0] addr_cpu,
    input  wire [31:0] data_cpu_write,
    input  wire        rd_cpu,
    input  wire        wr_cpu,

    input  wire [31:0] data_mem_read,
    input  wire        ready_mem,

    output wire        rd_mem,
    output wire        wr_mem,
    output reg  [31:0] addr_mem,
    output reg  [31:0] data_cpu_read,
    output reg  [31:0] data_mem_write,
    output reg         cpu_ready
);

    /* ---------------- Address decode ---------------- */
    wire [22:0] tag   = addr_cpu[31:9];
    wire [6:0]  index = addr_cpu[8:2];
    wire [1:0]  woff  = addr_cpu[3:2];

    /* ---------------- RAM outputs ---------------- */
    wire [127:0] data0, data1;
    wire [25:0]  tag0, tag1;

    wire v0 = tag0[25];
    wire d0 = tag0[24];
    wire lru0 = tag0[23];
    wire [22:0] t0 = tag0[22:0];

    wire v1 = tag1[25];
    wire d1 = tag1[24];
    wire lru1 = tag1[23];
    wire [22:0] t1 = tag1[22:0];

    wire hit0 = v0 && (t0 == tag);
    wire hit1 = v1 && (t1 == tag);

    /* ---------------- Controller ---------------- */
    wire do_alloc, do_wb, hit_way, victim_way;

    cache_controller ctrl (
        .clk(clk), .rst(rst),
        .rd_cpu(rd_cpu), .wr_cpu(wr_cpu),
        .hit0(hit0), .hit1(hit1),
        .dirty0(d0), .dirty1(d1),
        .lru0(lru0),
        .ready_mem(ready_mem),
        .rd_mem(rd_mem),
        .wr_mem(wr_mem),
        .do_allocate(do_alloc),
        .do_writeback(do_wb),
        .hit_way(hit_way),
        .victim_way(victim_way)
    );

    /* ---------------- RAM instances ---------------- */
    reg data_we0, data_we1;
    reg [127:0] data_din0, data_din1;

    data_ram way0_data (.clk(clk), .en(1'b1), .we(data_we0),
        .addr(index), .din(data_din0), .dout(data0));

    data_ram way1_data (.clk(clk), .en(1'b1), .we(data_we1),
        .addr(index), .din(data_din1), .dout(data1));

    reg tag_we0, tag_we1;
    reg [25:0] tag_din0, tag_din1;

    tag_ram way0_tag (.clk(clk), .en(1'b1), .we(tag_we0),
        .addr(index), .din(tag_din0), .dout(tag0));

    tag_ram way1_tag (.clk(clk), .en(1'b1), .we(tag_we1),
        .addr(index), .din(tag_din1), .dout(tag1));

    /* ========== 关键修正 1：寄存内存数据 ========== */
    reg [31:0] mem_data_reg;

    always @(posedge clk) begin
        if (ready_mem)
            mem_data_reg <= data_mem_read;
    end

    /* ========== 关键修正 2：所有 cache 写入都放在时序逻辑 ========== */
    always @(posedge clk) begin
        if (rst) begin
            data_we0 <= 0; data_we1 <= 0;
            tag_we0  <= 0; tag_we1  <= 0;
        end else begin
            data_we0 <= 0; data_we1 <= 0;
            tag_we0  <= 0; tag_we1  <= 0;

            /* HIT write */
            if (hit0 && wr_cpu) begin
                data_we0 <= 1;
                data_din0 <= data0;
                data_din0[(woff*32)+:32] <= data_cpu_write;
                tag_we0 <= 1;
                tag_din0 <= {1'b1,1'b1,1'b1,tag};
            end

            if (hit1 && wr_cpu) begin
                data_we1 <= 1;
                data_din1 <= data1;
                data_din1[(woff*32)+:32] <= data_cpu_write;
                tag_we1 <= 1;
                tag_din1 <= {1'b1,1'b1,1'b1,tag};
            end

            /* ALLOCATE */
            if (do_alloc && ready_mem) begin
                if (!victim_way) begin
                    data_we0 <= 1;
                    data_din0 <= {4{mem_data_reg}};
                    tag_we0 <= 1;
                    tag_din0 <= {1'b1,wr_cpu,1'b1,tag};
                end else begin
                    data_we1 <= 1;
                    data_din1 <= {4{mem_data_reg}};
                    tag_we1 <= 1;
                    tag_din1 <= {1'b1,wr_cpu,1'b1,tag};
                end
            end
        end
    end

    /* ---------------- Read path ---------------- */
    always @(*) begin
        if (hit0)
            data_cpu_read = data0[(woff*32)+:32];
        else if (hit1)
            data_cpu_read = data1[(woff*32)+:32];
        else
            data_cpu_read = 32'b0;
    end

    /* ---------------- Memory interface ---------------- */
    always @(*) begin
        addr_mem = do_wb ? { victim_way ? t1 : t0, index, 2'b00 }
                         : { tag, index, 2'b00 };
    end

    always @(*) begin
        cpu_ready = ~(rd_mem | wr_mem);
    end

    always @(*) begin
        if (wr_mem)
            data_mem_write = victim_way ? data1[31:0] : data0[31:0];
        else
            data_mem_write = 32'b0;
    end

endmodule
