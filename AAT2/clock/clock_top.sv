`timescale 1ns/1ps

package clock_pkg;

  class clock_txn;

    rand int cycles;

    // Run long enough to see wrap
    constraint c1 {
      cycles inside {[200:500]};
    }

  endclass

endpackage

