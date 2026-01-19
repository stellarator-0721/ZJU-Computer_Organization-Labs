module cache_controller (
    input  wire clk,
    input  wire rst,

    input  wire rd_cpu,
    input  wire wr_cpu,
    input  wire hit0,
    input  wire hit1,
    input  wire dirty0,
    input  wire dirty1,
    input  wire lru0,
    input  wire ready_mem,

    output reg  rd_mem,
    output reg  wr_mem,
    output reg  do_allocate,
    output reg  do_writeback,
    output reg  hit_way,
    output reg  victim_way
);
    localparam IDLE      = 2'd0;
    localparam COMPARE   = 2'd1;
    localparam WRITEBACK = 2'd2;
    localparam ALLOCATE  = 2'd3;

    reg [1:0] state, next;

    always @(posedge clk or posedge rst)
        if (rst) state <= IDLE;
        else     state <= next;

    always @(*) begin
        rd_mem       = 0;
        wr_mem       = 0;
        do_allocate  = 0;
        do_writeback = 0;
        hit_way      = hit1;
        victim_way   = lru0 ? 1'b1 : 1'b0;
        next         = state;

        case (state)
        IDLE:
            if (rd_cpu || wr_cpu)
                next = COMPARE;

        COMPARE: begin
            if (hit0 || hit1) begin
                next = IDLE;
            end else if ((dirty0 && !lru0) || (dirty1 && lru0)) begin
                do_writeback = 1;
                wr_mem = 1;
                next = WRITEBACK;
            end else begin
                rd_mem = 1;
                do_allocate = 1;
                next = ALLOCATE;
            end
        end

        WRITEBACK: begin
            wr_mem = 1;
            if (ready_mem) begin
                rd_mem = 1;
                do_allocate = 1;
                next = ALLOCATE;
            end
        end

        ALLOCATE: begin
            rd_mem = 1;
            do_allocate = 1;
            if (ready_mem)
                next = COMPARE;
        end
        endcase
    end
endmodule
