`timescale 1ns/1ps
import calc_pkg::*;

module alu (
  input logic [7:0] a,
  input logic [7:0] b,
  input opcode_t op,
  output logic [15:0] y
);

  always_comb begin
    case (op)
      ADD: y = a + b;
      SUB: y = a - b;
      MUL: y = a * b;
      XOR: y = a ^ b;
      default: y = '0;
    endcase
  end

endmodule


