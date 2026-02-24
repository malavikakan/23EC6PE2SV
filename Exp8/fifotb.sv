// ============================================================
// FIFO Testbench — Fixed version
// Fixes: VCP7285 $past() now uses explicit @(posedge clk)
// ============================================================
`timescale 1ns/1ps

module tb_fifo;

    parameter DATA_WIDTH = 8;
    parameter DEPTH      = 16;

    logic clk   = 0;
    logic rst_n = 0;

    always #5 clk = ~clk;

    // ---- Interface ----
    fifo_if #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) fif (.clk(clk), .rst_n(rst_n));

    // ---- DUT ----
    fifo #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) dut (.fif(fif));

    // ============================================================
    // COVERGROUP
    // ============================================================
    covergroup cg_fifo @(posedge clk);

        cp_wr_en: coverpoint fif.wr_en {
            bins no_write = {0};
            bins write    = {1};
        }
        cp_rd_en: coverpoint fif.rd_en {
            bins no_read = {0};
            bins read    = {1};
        }
        cp_full: coverpoint fif.full {
            bins not_full = {0};
            bins full     = {1};
        }
        cp_empty: coverpoint fif.empty {
            bins not_empty = {0};
            bins empty     = {1};
        }
        cp_almost_full: coverpoint fif.almost_full {
            bins not_af = {0};
            bins af     = {1};
        }
        cp_almost_empty: coverpoint fif.almost_empty {
            bins not_ae = {0};
            bins ae     = {1};
        }
        cp_fill_count: coverpoint fif.fill_count {
            bins empty = {0};
            bins low   = {[1:4]};
            bins mid   = {[5:11]};
            bins high  = {[12:15]};
            bins full  = {DEPTH};
        }
        cp_wr_data: coverpoint fif.wr_data {
            bins zeros     = {8'h00};
            bins ones      = {8'hFF};
            bins low_vals  = {[8'h01:8'h7F]};
            bins high_vals = {[8'h80:8'hFE]};
        }
        cp_rw_concurrent: coverpoint {fif.wr_en, fif.rd_en} {
            bins idle       = {2'b00};
            bins write_only = {2'b10};
            bins read_only  = {2'b01};
            bins read_write = {2'b11};
        }
        cp_write_full:  coverpoint (fif.wr_en & fif.full)  { bins hit = {1}; bins miss = {0}; }
        cp_read_empty:  coverpoint (fif.rd_en & fif.empty) { bins hit = {1}; bins miss = {0}; }

        cx_rw_fill: cross cp_rw_concurrent, cp_fill_count;

    endgroup

    cg_fifo cg_inst = new();

    // ============================================================
    // SCOREBOARD
    // ============================================================
    logic [DATA_WIDTH-1:0] ref_queue [$];

    // ============================================================
    // TASKS
    // ============================================================
    task apply_reset();
        fif.wr_en = 0; fif.wr_data = 0; fif.rd_en = 0;
        rst_n = 0;
        repeat(3) @(posedge clk); #1;
        rst_n = 1;
        ref_queue = {};
        @(posedge clk); #1;
        $display("[%0t] Reset done. empty=%b full=%b fill=%0d",
                 $time, fif.empty, fif.full, fif.fill_count);
    endtask

    task write_data(input logic [DATA_WIDTH-1:0] data);
        if (fif.full) begin
            $display("[%0t] WARN: Write on full FIFO skipped.", $time);
            // Still drive signals to hit coverage bin
            fif.wr_en = 1; fif.wr_data = data;
            @(posedge clk); #1;
            fif.wr_en = 0;
            return;
        end
        fif.wr_en   = 1;
        fif.wr_data = data;
        ref_queue.push_back(data);
        @(posedge clk); #1;
        fif.wr_en = 0;
        $display("[%0t] WRITE 0x%0h | fill=%0d | full=%b | af=%b",
                 $time, data, fif.fill_count, fif.full, fif.almost_full);
    endtask

    task read_data();
        logic [DATA_WIDTH-1:0] expected;
        if (fif.empty) begin
            $display("[%0t] WARN: Read on empty FIFO skipped.", $time);
            // Still drive to hit coverage bin
            fif.rd_en = 1;
            @(posedge clk); #1;
            fif.rd_en = 0;
            return;
        end
        expected  = ref_queue.pop_front();
        fif.rd_en = 1;
        @(posedge clk); #1;
        fif.rd_en = 0;
        if (fif.rd_data === expected)
            $display("[%0t] READ  0x%0h [PASS] | fill=%0d | empty=%b | ae=%b",
                     $time, fif.rd_data, fif.fill_count, fif.empty, fif.almost_empty);
        else
            $error("[%0t] READ MISMATCH: got=0x%0h expected=0x%0h",
                   $time, fif.rd_data, expected);
    endtask

    task burst_write(input int n);
        $display("[%0t] -- Burst Write %0d --", $time, n);
        repeat(n) write_data($urandom_range(1, 254));
    endtask

    task burst_read(input int n);
        $display("[%0t] -- Burst Read %0d --", $time, n);
        repeat(n) read_data();
    endtask

    task sim_rw(input logic [DATA_WIDTH-1:0] data);
        logic [DATA_WIDTH-1:0] expected;
        fif.wr_en   = 1;
        fif.wr_data = data;
        fif.rd_en   = 1;
        if (!fif.full)  ref_queue.push_back(data);
        if (!fif.empty) expected = ref_queue.pop_front();
        @(posedge clk); #1;
        fif.wr_en = 0; fif.rd_en = 0;
        $display("[%0t] SIM_RW: wrote=0x%0h read=0x%0h fill=%0d",
                 $time, data, fif.rd_data, fif.fill_count);
    endtask

    // ============================================================
    // SVA ASSERTIONS
    // FIX: $past() replaced with registered signals to avoid VCP7285
    // ============================================================

    // Latch previous values in registers — no $past() needed
    logic prev_full, prev_empty;
    logic [DATA_WIDTH-1:0] prev_wr_data;
    logic prev_wr_en, prev_rd_en;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prev_full    <= 0;
            prev_empty   <= 1;
            prev_wr_data <= '0;
            prev_wr_en   <= 0;
            prev_rd_en   <= 0;
        end else begin
            prev_full    <= fif.full;
            prev_empty   <= fif.empty;
            prev_wr_data <= fif.wr_data;
            prev_wr_en   <= fif.wr_en;
            prev_rd_en   <= fif.rd_en;
        end
    end

    // Assert: reset clears FIFO state
    property p_reset_clears;
        @(posedge clk) (!rst_n) |=> (fif.empty && !fif.full && fif.fill_count == 0);
    endproperty
    assert property (p_reset_clears)
        else $error("[SVA FAIL] Not empty after reset at %0t", $t
