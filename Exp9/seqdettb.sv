// ============================================================
// TESTBENCH: 1011 Sequence Detector
// Includes covergroup + waveform dump
// ============================================================
`timescale 1ns/1ps

module tb;

    // ---- Signals ----
    logic clk, rst, in, det;

    // ---- Clock ----
    initial clk = 0;
    always #5 clk = ~clk;

    // ---- DUT ----
    seq_detector dut (.*);

    // ---- Waveform ----
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);
    end

    // ============================================================
    // COVERGROUP
    // ============================================================
    covergroup cg_fsm @(posedge clk);

        // Whitebox: all states visited
        cp_state: coverpoint dut.state {
            bins s0 = {2'b00};
            bins s1 = {2'b01};
            bins s2 = {2'b10};
            bins s3 = {2'b11};
        }

        // Input coverage
        cp_in: coverpoint in {
            bins zero = {0};
            bins one  = {1};
        }

        // Output (detection) coverage
        cp_det: coverpoint det {
            bins no_detect = {0};
            bins detected  = {1};
        }

        // Cross: state x input (all transitions exercised)
        cx_state_in: cross cp_state, cp_in;

    endgroup

    cg_fsm cg_inst = new();

    // ============================================================
    // TASK: apply reset
    // ============================================================
    task apply_reset();
        rst = 1; in = 0;
        @(posedge clk); #1;
        @(posedge clk); #1;
        rst = 0;
    endtask

    // ============================================================
    // TASK: drive a bit sequence, print detections
    // ============================================================
    task drive_seq(input string label, input logic [0:15] seq, input int len);
        $display("\n[%s]", label);
        for (int i = 0; i < len; i++) begin
            in = seq[i];
            @(posedge clk); #1;
            $display("  bit=%b | state=%s | det=%b",
                     in, dut.state.name(), det);
        end
    endtask

    // ============================================================
    // STIMULUS
    // ============================================================
    initial begin
        $display("===========================================");
        $display("  1011 Sequence Detector Testbench");
        $display("===========================================");

        apply_reset();

        // Test 1: Exact sequence 1011
        drive_seq("TEST 1: 1011 (expect det=1 at end)",
                  16'b1011_0000_0000_0000, 4);

        // Test 2: Non-matching sequence
        drive_seq("TEST 2: 1010 (no detect)",
                  16'b1010_0000_0000_0000, 4);

        // Test 3: Overlapping 10111011
        drive_seq("TEST 3: 10111011 (two detections)",
                  16'b1011_1011_0000_0000, 8);

        // Test 4: All zeros
        drive_seq("TEST 4: 00000000 (no detect)",
                  16'b0000_0000_0000_0000, 8);

        // Test 5: All ones
        drive_seq("TEST 5: 11111111 (no detect)",
                  16'b1111_1111_0000_0000, 8);

        // Test 6: Random stimulus to boost coverage
        $display("\n[TEST 6: Random 32 bits]");
        repeat(32) begin
            in = $urandom_range(0,1);
            @(posedge clk); #1;
            if (det)
                $display("  [DETECTED] bit=%b state=%s", in, dut.state.name());
        end

        // Test 7: Reset mid-sequence
        $display("\n[TEST 7: Reset mid-sequence]");
        in = 1; @(posedge clk); #1;
        in = 0; @(posedge clk); #1;
        in = 1; @(posedge clk); #1;
        rst = 1; @(posedge clk); #1;   // reset while in S3
        rst = 0;
        $display("  After mid-reset: state=%s (expect S0)", dut.state.name());

        // ---- Coverage Report ----
        $display("\n===========================================");
        $display("  Coverage Summary");
        $display("===========================================");
        $display("  Overall        = %.2f%%", cg_inst.get_coverage());
        $display("  cp_state       = %.2f%%", cg_inst.cp_state.get_coverage());
        $display("  cp_in          = %.2f%%", cg_inst.cp_in.get_coverage());
        $display("  cp_det         = %.2f%%", cg_inst.cp_det.get_coverage());
        $display("  cx_state_in    = %.2f%%", cg_inst.cx_state_in.get_coverage());
        $display("===========================================");

        #20;
        $finish;
    end

    // ============================================================
    // SVA: detection only valid when input sequence matches
    // ============================================================
    property p_det_requires_s3_and_in;
        @(posedge clk) det |-> (dut.state == 2'b11 && in);
    endproperty
    assert property (p_det_requires_s3_and_in)
        else $error("[SVA FAIL] det asserted in wrong state/input at %0t", $time);

    // Reset always returns to S0
    property p_rst_to_s0;
        @(posedge clk) rst |=> (dut.state == 2'b00);
    endproperty
    assert property (p_rst_to_s0)
        else $error("[SVA FAIL] State not S0 after reset at %0t", $time);

endmodule
