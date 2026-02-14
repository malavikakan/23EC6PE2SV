`timescale 1ns/1ps

module and_gate_tb;

    // Testbench signals
    logic a;
    logic b;
    logic y;

    // Instantiate DUT
    and_gate dut (
        .a(a),
        .b(b),
        .y(y)
    );

    //---------------------------
    // Functional Coverage
    //---------------------------
    covergroup and_cov;
        coverpoint a;
        coverpoint b;
        coverpoint y;

        // Cross coverage
        cross a, b;
    endgroup

    and_cov cov = new();

    //---------------------------
    // Stimulus
    //---------------------------
    initial begin
        $display("Starting AND Gate Simulation");

        // Apply all input combinations
        repeat (4) begin
            {a,b} = $random;
            #10;
            cov.sample();   // Sample coverage
        end

        // Explicit combinations (guaranteed 100% coverage)
        a=0; b=0; #10; cov.sample();
        a=0; b=1; #10; cov.sample();
        a=1; b=0; #10; cov.sample();
        a=1; b=1; #10; cov.sample();

        $display("Simulation Finished");
        $finish;
    end

endmodule
