`timescale 1ns/1ps

package calc_pkg;

  typedef enum logic [2:0] {
    ADD, SUB, MUL, XOR
  } opcode_t;

  class alu_txn;

    rand logic [7:0] a;
    rand logic [7:0] b;
    rand opcode_t op;

    // Distribution constraint
    constraint op_dist {
      op dist {
        ADD := 30,
        SUB := 30,
        MUL := 20,
        XOR := 20
      };
    }

  endclass

endpackage

