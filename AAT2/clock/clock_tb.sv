`timescale 1ns/1ps

module tb;

  // Clock
  logic clk = 0;
  always #5 clk = ~clk;

  // Reset
  logic rst;

  // DUT outputs
  logic [5:0] sec;
  logic [5:0] min;

  // DUT
  digital_clock dut (
    .clk (clk),
    .rst (rst),
    .sec (sec),
    .min (min)
  );

  // ---------------- WAVEFORM ----------------
  initial begin
    $dumpfile("clock_simple.vcd");
    $dumpvars(0, tb);
  end

  // ---------------- TEST ----------------
  initial begin

    // Reset
    rst = 1;
    #20;
    rst = 0;

    // Run for enough time (4000 cycles ≈ 1 min wrap)
    repeat (4000) begin
      @(posedge clk);

      // Check rollover
      if (sec == 0 && min != 0) begin
        $display("Sec wrapped, Min = %0d", min);
      end

      // Check full wrap
      if (sec == 0 && min == 0) begin
        $display("Full wrap (59:59 → 00:00)");
      end
    end

    $display("Simple Test Completed");
    $finish;

  end

endmodule

