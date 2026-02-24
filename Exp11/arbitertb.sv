module tb;

    logic clk;
    logic rst;
    logic [3:0] req;
    logic [3:0] gnt;

    // Instantiate DUT
    arbiter dut (
        .clk(clk),
        .rst(rst),
        .req(req),
        .gnt(gnt)
    );

    // Clock
    initial clk = 0;
    always #5 clk = ~clk;

    // -------------------------
    // ASSERTION
    // -------------------------
    // At every clock, grant must be one-hot or zero
    property one_hot_grant;
        @(posedge clk) disable iff (rst)
        $onehot0(gnt);
    endproperty

    assert property (one_hot_grant)
        else $error("Protocol Violation: Multiple Grants!");

    // -------------------------
    // COVERAGE
    // -------------------------
    covergroup arbiter_cg @(posedge clk);
        coverpoint req;
        coverpoint gnt;
    endgroup

    arbiter_cg cg = new();

    // -------------------------
    // TEST
    // -------------------------
    initial begin
        $dumpfile("arbiter_wave.vcd");
        $dumpvars(0, tb);

        rst = 1;
        req = 0;
        #15;
        rst = 0;

        // Random requests
        repeat (20) begin
            @(posedge clk);
            req = $urandom_range(0,15);
        end

        #20;

        $display("Coverage = %0.2f %%", cg.get_coverage());
        $finish;
    end

endmodule
