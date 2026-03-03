`timescale 1ns/1ps

module top;

  logic clk = 0;

  // Clock generation
  always #5 clk = ~clk;

  // Instantiate interface
  clock_if intf (clk);

  // Instantiate DUT
  digital_clock dut (
    .clk (clk),
    .rst (intf.rst),
    .sec (intf.sec),
    .min (intf.min)
  );

  // Instantiate Testbench
  clock_tb tb (intf);

endmodule
