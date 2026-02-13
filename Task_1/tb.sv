// Code your testbench here
// or browse Examples
// =======================
// testbench.sv
// TESTBENCH
// =======================


// OPCODE ENUM
typedef enum logic [1:0] {
    ADD = 2'b00,
    SUB = 2'b01,
    MUL = 2'b10,
    XOR = 2'b11
} opcode_t;


// =======================
// TRANSACTION CLASS
// =======================
class alu_trans;

    rand logic [7:0] a;
    rand logic [7:0] b;
    rand opcode_t opcode;

    // Constraint: MUL at least 20%
    constraint mul_weight {
        opcode dist {
            ADD := 25,
            SUB := 25,
            MUL := 20,
            XOR := 30
        };
    }

    function void display();
        $display("A=%0d B=%0d OPCODE=%s",
                 a, b, opcode.name());
    endfunction

endclass

function string opcode_to_string(opcode_t op);

    case (op)
        ADD: opcode_to_string = "ADD";
        SUB: opcode_to_string = "SUB";
        MUL: opcode_to_string = "MUL";
        XOR: opcode_to_string = "XOR";
        default: opcode_to_string = "UNKNOWN";
    endcase

endfunction


// =======================
// TESTBENCH MODULE
// =======================
module tb;

    logic [7:0]  a, b;
    opcode_t  opcode;
    logic [15:0] result;

    // DUT Instantiation
    alu dut (
        .a(a),
        .b(b),
        .opcode(opcode),
        .result(result)
    );


    alu_trans tr;


    // COVERAGE
    covergroup alu_cg;

        coverpoint opcode {
            bins add = {ADD};
            bins sub = {SUB};
            bins mul = {MUL};
            bins xor_op = {XOR};
        }

    endgroup

    alu_cg cg;


    // MAIN TEST
    initial begin

        tr = new();
        cg = new();

        $display("Starting ALU Test...\n");

        repeat (100) begin

            if (!tr.randomize())
                $fatal("Randomization Failed");

            // Drive DUT
            a      = tr.a;
            b      = tr.b;
            opcode = tr.opcode;

            #1;

            // Sample coverage
            cg.sample();

            // Display
            $display("A=%0d B=%0d OP=%s RESULT=%0d",
                     a, b, opcode_to_string(opcode), result);

        end

        $display("\nCoverage = %0.2f %%", cg.get_coverage());

        $finish;

    end

endmodule
