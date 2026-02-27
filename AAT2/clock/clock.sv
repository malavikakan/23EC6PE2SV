`timescale 1ns/1ps
import clock_pkg::*;

module digital_clock (

  input  logic clk,
  input  logic rst,

  output logic [5:0] sec,   // 0–59
  output logic [5:0] min    // 0–59
);

  always_ff @(posedge clk or posedge rst) begin

    if (rst) begin
      sec <= 0;
      min <= 0;
    end

    else begin

      // Seconds
      if (sec == 59) begin
        sec <= 0;

        // Minutes
        if (min == 59)
          min <= 0;
        else
          min <= min + 1;

      end
      else begin
        sec <= sec + 1;
      end

    end

  end

endmodule

