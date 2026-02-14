// AND Gate Design
//-------------------------------
module and_gate (
    input  logic a,
    input  logic b,
    output logic y
);

    // AND operation
    assign y = a & b;

endmodule
