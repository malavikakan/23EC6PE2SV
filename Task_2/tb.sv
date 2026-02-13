// =======================
// testbench.sv
// DIGITAL CLOCK TESTBENCH
// =======================

module tb;

    logic clk;
    logic rst;

    logic [5:0] sec;
    logic [5:0] min;

    // DUT Instantiation
    digital_clock dut (
        .clk(clk),
        .rst(rst),
        .sec(sec),
        .min(min)
    );


    // =======================
    // CLOCK GENERATION
    // =======================
    initial begin
        clk = 0;
        forever #5 clk = ~clk;   // 10ns period
    end


    // =======================
    // MAIN TEST
    // =======================
    initial begin
		$dumpfile("clock.vcd");
	    $dumpvars(0, tb);
        // Apply Reset
        rst = 1;
        #20;
        rst = 0;

        $display("Starting Digital Clock Simulation\n");

        // Run for 200 cycles
        repeat (200) begin
            @(posedge clk);

            $display("TIME = %02d:%02d", min, sec);
        end

        $display("\nSimulation Finished");
        $finish;

    end

endmodule
