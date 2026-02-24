module tb;

    logic clk;
    logic rst;
    logic red, yellow, green;

    // Instantiate DUT
    traffic_light dut (
        .clk(clk),
        .rst(rst),
        .red(red),
        .yellow(yellow),
        .green(green)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Functional Coverage
    covergroup traffic_cg @(posedge clk);
        coverpoint red;
        coverpoint yellow;
        coverpoint green;
    endgroup

    traffic_cg cg = new();

    // Test sequence
    initial begin
        $dumpfile("wave.vcd");   // For waveform
        $dumpvars(0, tb);

        rst = 1;
        #10;
        rst = 0;

        #200;   // Run long enough to hit all states

        $display("Coverage = %0.2f %%", cg.get_coverage());
        $finish;
    end

endmodule
