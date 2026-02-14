//-----------------------------------------
// Opcode Definition
//-----------------------------------------
typedef enum bit [1:0] {
    ADD,
    SUB,
    AND_OP,
    OR_OP
} opcode_e;


//-----------------------------------------
// 8-bit ALU Design
//-----------------------------------------
module alu (
    input  logic [7:0] a,
    input  logic [7:0] b,
    input  opcode_e    op,
    output logic [7:0] y
);

    always_comb begin
        case (op)
            ADD    : y = a + b;
            SUB    : y = a - b;
            AND_OP : y = a & b;
            OR_OP  : y = a | b;
            default: y = 8'h00;
        endcase
    end

endmodule
