module alu (
    input  logic [7:0] a,
    input  logic [7:0] b,
    input  logic [1:0] opcode,
    output logic [15:0] result
);

    always_comb begin
        case(opcode)
            2'b00: result = a + b;   // ADD
            2'b01: result = a - b;   // SUB
            2'b10: result = a * b;   // MUL
            2'b11: result = a ^ b;   // XOR
            default: result = 0;
        endcase
    end

endmodule
