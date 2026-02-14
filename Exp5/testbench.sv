`timescale 1ns/1ps

//-----------------------------------------
// Transaction Class
//-----------------------------------------
class packet;

    rand bit d;
    rand bit rst;

    // Reset distribution: mostly 0
    constraint c1 {
        rst dist {0 := 90, 1 := 10};
    }

endclass


//-----------------------------------------
// Testbench
//-----------------------------------------
module tb;

    logic clk = 0;
    logic rst;
    logic d;
    logic q;

    // DUT instantiation
    dff dut (
        .clk(clk),
        .rst(rst),
        .d(d),
        .q(q)
    );

    //-----------------------------------------
    // Clock Generation
    //-----------------------------------------
    always #5 clk = ~clk;

    //-----------------------------------------
    // Functional Coverage
    //-----------------------------------------
    covergroup cg @(posedge clk);

        cp_rst : coverpoint rst;
        cp_d   : coverpoint d;
        cp_q   : coverpoint q;

        cross rst, d;

    endgroup

    cg cinst = new();
    packet pkt = new();

    //-----------------------------------------
    // VCD Dump
    //-----------------------------------------
    initial begin
        $dumpfile("dff.vcd");
        $dumpvars(0, tb);
    end

    //-----------------------------------------
    // Stimulus
    //-----------------------------------------
    initial begin
        $display("Starting DFF Simulation");

        repeat (100) begin
            pkt.randomize();

            rst <= pkt.rst;
            d   <= pkt.d;

            @(posedge clk);  // sample on clock edge
        end

        //-----------------------------------------
        // Display Coverage
        //-----------------------------------------
        $display("Functional Coverage = %0.2f %%", cinst.get_coverage());

        $display("Simulation Finished");
        $finish;
    end

endmodule
