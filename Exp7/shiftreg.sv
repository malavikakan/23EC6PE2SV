// ============================================================
// Shift Register Design - SystemVerilog
// 8-bit Serial-In Parallel-Out (SIPO) Shift Register
// with parallel load, reset, and shift enable
// ============================================================

module shift_register #(
    parameter WIDTH = 8
)(
    input  logic             clk,
    input  logic             rst_n,      // Active-low async reset
    input  logic             shift_en,   // Shift enable
    input  logic             load,       // Parallel load enable
    input  logic             serial_in,  // Serial input (MSB first)
    input  logic [WIDTH-1:0] parallel_in,// Parallel load data
    output logic [WIDTH-1:0] parallel_out,// Parallel output
    output logic             serial_out   // Serial output (LSB)
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            parallel_out <= '0;
        else if (load)
            parallel_out <= parallel_in;
        else if (shift_en)
            parallel_out <= {serial_in, parallel_out[WIDTH-1:1]};
        // else: hold
    end

    assign serial_out = parallel_out[0];

endmodule
