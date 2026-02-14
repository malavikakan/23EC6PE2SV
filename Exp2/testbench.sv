`timescale 1ns/1ps

module mux2to1_tb;

    logic a;
    logic b;
    logic sel;
    logic y;

    // DUT Instantiation
    mux2to1 dut (
        .a(a),
        .b(b),
        .sel(sel),
        .y(y)
    );

    //---------------------------------
    // Functional Coverage
    //---------------------------------
    covergroup mux_cov;

        coverpoint a {
            bins a0 = {0};
            bins a1 = {1};
        }

        coverpoint b {
            bins b0 = {0};
            bins b1 = {1};
        }

        coverpoint sel {
            bins s0 = {0};
            bins s1 = {1};
        }

        coverpoint y {
            bins y0 = {0};
            bins y1 = {1};
        }

        // Cross coverage
        cross a, b, sel;

    endgroup

    mux_cov cov = new();

    //---------------------------------
    // VCD Dump
    //---------------------------------
    initial begin
        $dumpfile("mux2to1.vcd");
        $dumpvars(0, mux2to1_tb);
    end

    //---------------------------------
    // Stimulus
    //---------------------------------
    initial begin
        $display("Starting 2:1 MUX Simulation");

        // Apply all combinations (8 total)
        for (int i = 0; i < 8; i++) begin
            {a,b,sel} = i;
            #10;
            cov.sample();
        end

        //---------------------------------
        // Display Coverage
        //---------------------------------
        $display("Functional Coverage = %0.2f %%", cov.get_coverage());

        $display("Simulation Finished");
        $finish;
    end

endmodule
