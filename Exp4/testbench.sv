`timescale 1ns/1ps

module tb;

    logic [7:0] a, b;
    logic [7:0] y;
    opcode_e    op;

    // DUT instantiation
    alu dut (
        .a(a),
        .b(b),
        .op(op),
        .y(y)
    );

    //-----------------------------------------
    // Functional Coverage
    //-----------------------------------------
    covergroup cg_alu;

        cp_op : coverpoint op;  // Tracks ADD, SUB, AND_OP, OR_OP

        cp_y : coverpoint y {
            bins zero = {8'h00};
            bins non_zero = {[8'h01 : 8'hFF]};
        }

        // Cross coverage
        cross op, y;

    endgroup

    cg_alu cg = new();

    //-----------------------------------------
    // VCD Dump
    //-----------------------------------------
    initial begin
        $dumpfile("alu.vcd");
        $dumpvars(0, tb);
    end

    //-----------------------------------------
    // Stimulus
    //-----------------------------------------
    initial begin
        $display("Starting ALU Simulation");

        // Directed Testing (ensures all ops covered)
        a = 8'd10; b = 8'd5;

        op = ADD;    #5; cg.sample();
        op = SUB;    #5; cg.sample();
        op = AND_OP; #5; cg.sample();
        op = OR_OP;  #5; cg.sample();

        // Random Testing
        repeat (50) begin
            a = $urandom_range(0,255);
            b = $urandom_range(0,255);
            op = opcode_e'($urandom_range(0,3));
            #5;
            cg.sample();
        end

        //-----------------------------------------
        // Display Coverage
        //-----------------------------------------
        $display("Functional Coverage = %0.2f %%", cg.get_coverage());

        $display("Simulation Finished");
        $finish;
    end

endmodule
