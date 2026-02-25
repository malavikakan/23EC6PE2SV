module tb;

    bit clk = 0;
    bit req = 0;
    bit gnt = 0;

    // Clock generation
    always #5 clk = ~clk;

    // --------------------------------
    // Property: If req goes high,
    // gnt must go high exactly 2 cycles later
    // --------------------------------
    property p_handshake;
        @(posedge clk)
        req |=> ##2 gnt;
    endproperty

    assert property (p_handshake)
        else $error("Protocol Fail!");

    // --------------------------------
    // Stimulus
    // --------------------------------
    initial begin

        $dumpfile("dump.vcd");
        $dumpvars(0, tb);

        // Trigger request
        @(posedge clk);
        req <= 1;

        @(posedge clk);
        req <= 0;

        // Exactly 2 cycles after req
        @(posedge clk);
        @(posedge clk);
        gnt <= 1;   // PASS case

        #20;
        $finish;
    end

endmodule
