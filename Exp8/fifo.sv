// ============================================================
// fifo_if Interface
// ============================================================
interface fifo_if #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 16
)(
    input logic clk,
    input logic rst_n
);
    logic                   wr_en;
    logic [DATA_WIDTH-1:0]  wr_data;
    logic                   full;
    logic                   almost_full;
    logic                   rd_en;
    logic [DATA_WIDTH-1:0]  rd_data;
    logic                   empty;
    logic                   almost_empty;
    logic [$clog2(DEPTH):0] fill_count;

    modport producer (input clk, rst_n, output wr_en, wr_data, input full, almost_full, fill_count);
    modport consumer (input clk, rst_n, output rd_en, input rd_data, empty, almost_empty, fill_count);
    modport dut      (input clk, rst_n, input wr_en, wr_data, output full, almost_full,
                      input rd_en, output rd_data, empty, almost_empty, output fill_count);
    modport monitor  (input clk, rst_n, input wr_en, wr_data, full, almost_full,
                      input rd_en, rd_data, empty, almost_empty, input fill_count);
endinterface

// ============================================================
// FIFO Design
// ============================================================
module fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 16
)(
    fifo_if.dut fif
);
    localparam PTR_W = $clog2(DEPTH);

    logic [DATA_WIDTH-1:0]  mem [0:DEPTH-1];
    logic [PTR_W:0]         wr_ptr;
    logic [PTR_W:0]         rd_ptr;
    wire  [PTR_W:0]         count = wr_ptr - rd_ptr;

    assign fif.full         = (count == DEPTH);
    assign fif.empty        = (count == 0);
    assign fif.almost_full  = (count == DEPTH - 1);
    assign fif.almost_empty = (count == 1);
    assign fif.fill_count   = count;
    assign fif.rd_data      = mem[rd_ptr[PTR_W-1:0]];

    always_ff @(posedge fif.clk or negedge fif.rst_n) begin
        if (!fif.rst_n) begin
            wr_ptr <= '0;
        end else if (fif.wr_en && !fif.full) begin
            mem[wr_ptr[PTR_W-1:0]] <= fif.wr_data;
            wr_ptr <= wr_ptr + 1;
        end
    end

    always_ff @(posedge fif.clk or negedge fif.rst_n) begin
        if (!fif.rst_n)
            rd_ptr <= '0;
        else if (fif.rd_en && !fif.empty)
            rd_ptr <= rd_ptr + 1;
    end

endmodule
