`timescale 1ns/1ps

module tb;

    logic [3:0] in;
    logic [1:0] out;
    logic valid;

    // DUT instantiation
    priority_enc dut (
        .in(in),
        .out(out),
        .valid(valid)
    );

    //-----------------------------------------
    // Functional Coverage
    //-----------------------------------------
    covergroup cg_enc;

        cp_in : coverpoint in {
            bins b0 = {4'b0001};
            bins b1 = {4'b0010};
            bins b2 = {4'b0100};
            bins b3 = {4'b1000};
            bins others = default;
        }

        cp_valid : coverpoint valid {
            bins v0 = {0};
            bins v1 = {1};
        }

        cp_out : coverpoint out {
            bins o0 = {2'b00};
            bins o1 = {2'b01};
            bins o2 = {2'b10};
            bins o3 = {2'b11};
        }

    endgroup

    cg_enc cg = new();

    //-----------------------------------------
    // VCD Dump
    //-----------------------------------------
    initial begin
        $dumpfile("priority_enc.vcd");
        $dumpvars(0, tb);
    end

    //-----------------------------------------
    // Stimulus
    //-----------------------------------------
    initial begin
        $display("Starting Priority Encoder Simulation");

        // Apply all 16 possible combinations
        for (int i = 0; i < 16; i++) begin
            in = i;
            #5;
            cg.sample();
        end

        // Additional random testing
        repeat (20) begin
            in = $urandom_range(0,15);
            #5;
            cg.sample();
        end

        //-----------------------------------------
        // Display Functional Coverage
        //-----------------------------------------
        $display("Functional Coverage = %0.2f %%", cg.get_coverage());

        $display("Simulation Finished");
        $finish;
    end

endmodule
