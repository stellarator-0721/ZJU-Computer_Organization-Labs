`timescale 1ns / 1ps

module cache_tb;

    // ===============================
    // CPU <-> Cache
    // ===============================
    reg         clk;
    reg         rst;
    reg         wr_cpu;
    reg         rd_cpu;
    reg  [31:0] addr_out;
    reg  [31:0] data_cpu_write;
    wire [31:0] data_cpu_read;
    wire        cpu_ready;   // 保留，不使用（与你原 TB 一致）

    // ===============================
    // Cache <-> Memory
    // ===============================
    reg         ready_mem;
    reg  [31:0] data_mem_read;
    wire        wr_mem;
    wire        rd_mem;
    wire [31:0] mem_reg_addr;
    wire [31:0] data_mem_write;

    // ===============================
    // Clock
    // ===============================
    always #5 clk = ~clk;

    // ===============================
    // Test sequence（保持你原逻辑）
    // ===============================
    initial begin
        clk            = 1'b0;
        rst            = 1'b1;
        rd_cpu         = 1'b0;
        wr_cpu         = 1'b0;
        addr_out       = 32'b0;
        data_cpu_write = 32'b0;
        ready_mem      = 1'b0;
        data_mem_read  = 128'b0;

        #40;
        rst = 1'b0;

        // -------------------------------
        // Read miss
        // -------------------------------
        rd_cpu   = 1'b1;
        addr_out = 32'h0000_0207;
        #160;

        ready_mem     = 1'b1;
        data_mem_read = 128'd32;
        #60;
        ready_mem = 1'b0;
        rd_cpu    = 1'b0;

        #200;

        // -------------------------------
        // Write hit
        // -------------------------------
        wr_cpu         = 1'b1;
        addr_out       = 32'h0000_0207;
        data_cpu_write = 32'd16;
        #60;
        wr_cpu = 1'b0;

        #90;

        // -------------------------------
        // Read hit
        // -------------------------------
        rd_cpu   = 1'b1;
        addr_out = 32'h0000_0207;
        #80;
        rd_cpu = 1'b0;

        #100;

        // -------------------------------
        // Write miss
        // -------------------------------
        wr_cpu         = 1'b1;
        addr_out       = 32'h0000_0407;
        data_cpu_write = 32'd18;
        #100;

        ready_mem     = 1'b1;
        data_mem_read = 128'd20;
        #100;
        ready_mem = 1'b0;

        #60;
        wr_cpu = 1'b0;

        #200;

        // -------------------------------
        // Read miss (LRU replace)
        // -------------------------------
        rd_cpu   = 1'b1;
        addr_out = 32'h0000_0807;
        #160;

        ready_mem     = 1'b1;
        data_mem_read = 32'd31;
        #100;
        ready_mem = 1'b0;
        rd_cpu    = 1'b0;

        #400;
        $stop;
    end

    // ===============================
    // DUT
    // ===============================
    cache cache_u (
        .clk(clk),
        .rst(rst),

        .addr_cpu(addr_out),
        .data_cpu_write(data_cpu_write),
        .wr_cpu(wr_cpu),
        .rd_cpu(rd_cpu),

        .data_cpu_read(data_cpu_read),
        .cpu_ready(cpu_ready),

        .ready_mem(ready_mem),
        .data_mem_read(data_mem_read),
        .wr_mem(wr_mem),
        .rd_mem(rd_mem),
        .addr_mem(mem_reg_addr),
        .data_mem_write(data_mem_write)
    );

endmodule
