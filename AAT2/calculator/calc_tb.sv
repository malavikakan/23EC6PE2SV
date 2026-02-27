`timescale 1ns/1ps
import calc_pkg::*;


module tb;

  logic [7:0] a, b;
  opcode_t op;
  logic [15:0] y;

  // DUT
  alu dut (
    .a (a),
    .b (b),
    .op (op),
    .y (y)
  );

  // Transaction
  alu_txn txn;

  // ---------------- COVERAGE ----------------
  covergroup cg_alu;
    cp_op : coverpoint op;
  endgroup

  cg_alu cg = new();

  // ---------------- WAVEFORM DUMP ----------------
  initial begin
    $dumpfile("alu_tb.vcd");
    $dumpvars(0, tb);
    $dumpvars(0, tb.dut);
  end

  // ---------------- TEST ----------------
  initial begin
    txn = new();

    repeat (100) begin
      assert(txn.randomize())
        else $fatal("Randomization failed");

      // Drive DUT
      a = txn.a;
      b = txn.b;
      op = txn.op;

      #1; // allow combinational settle
      cg.sample(); // sample coverage
    end

    $display("ALU Opcode Coverage = %0.2f%%",
              cg.get_inst_coverage());

    $finish;
  end

endmodule
