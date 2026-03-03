`timescale 1ns/1ps

module clock_tb (clock_if vif);

  // ---------------- WAVEFORM ----------------
  initial begin
    $dumpfile("clock_structured.vcd");
    $dumpvars(0, clock_tb);
  end

  // ---------------- TEST ----------------
  initial begin

    // Reset
    vif.rst = 1;
    #20;
    vif.rst = 0;

    repeat (4000) begin
      @(posedge vif.clk);

      if (vif.sec == 0 && vif.min != 0) begin
        $display("Sec wrapped, Min = %0d", vif.min);
      end

      if (vif.sec == 0 && vif.min == 0) begin
        $display("Full wrap (59:59 → 00:00)");
      end
    end

    $display("Structured Test Completed");
    $finish;

  end

endmodule
