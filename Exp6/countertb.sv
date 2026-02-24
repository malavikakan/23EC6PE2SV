`timescale 1ns/1ps

module tb;

    logic clk = 0;
    logic rst;
    logic [3:0] count;

    // DUT Instantiation
    counter dut (
        .clk(clk),
        .rst(rst),
        .count(count)
    );

    //-----------------------------------------
    // Clock Generation
    //-----------------------------------------
    always #5 clk = ~clk;

    //-----------------------------------------
    // Functional Coverage
    //-----------------------------------------
    covergroup cg_count @(posedge clk);

        cp_val : coverpoint count {

            bins zero = {4'd0};
            bins max  = {4'd15};

            // Transition bin: rollover check
            bins roll = (4'd15 => 4'd0);
        }

    endgroup

    cg_count cg = new();

    //-----------------------------------------
    // VCD Dump
    //-----------------------------------------
    initial begin
        $dumpfile("counter.vcd");
        $dumpvars(0, tb);
    end

    //-----------------------------------------
    // Stimulus
    //-----------------------------------------
    initial begin
        $display("Starting 4-bit Counter Simulation");

        // Apply reset
        rst = 1;
        repeat (3) @(posedge clk);
        rst = 0;

        // Run enough cycles to see rollover multiple times
        repeat (40) @(posedge clk);

        //-----------------------------------------
        // Display Coverage
        //-----------------------------------------
        $display("Overall Functional Coverage = %0.2f %%", cg.get_coverage());
        $display("Rollover Coverage Hit = %0.2f %%", cg.cp_val.get_coverage());

        $display("Simulation Finished");
        $finish;
    end

endmodule
