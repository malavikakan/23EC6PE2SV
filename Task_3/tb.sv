module tb_atm;
    logic clk = 0;
    logic rst_n;
    logic card_inserted, pin_correct, balance_ok;
    logic dispense_cash;

    // Clock generation
    always #5 clk = ~clk;

    // Instantiate Design
    atm_controller dut (.*);

    // Functional Coverage
    covergroup cg_atm @(posedge clk);
        option.per_instance = 1;
        coverpoint dut.current_state {
            bins states[] = {0, 1, 2, 3}; // IDLE, CHECK_PIN, CHECK_BAL, DISPENSE
        }
    endgroup

    cg_atm cov_inst = new();

    initial begin
        // VCD Generation
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_atm);

        // Initialize
        rst_n = 0; card_inserted = 0; pin_correct = 0; balance_ok = 0;
        #15 rst_n = 1;

        // Scenario 1: Successful Withdrawal
        @(posedge clk); card_inserted = 1;
        @(posedge clk); pin_correct = 1;
        @(posedge clk); balance_ok = 1;
        @(posedge clk); // Now in DISPENSE
        
        // Scenario 2: Reset to IDLE
        @(posedge clk); card_inserted = 0; pin_correct = 0; balance_ok = 0;

        #50;
        $display("Coverage = %.2f%%", cov_inst.get_inst_coverage());
        $finish;
    end
endmodule
