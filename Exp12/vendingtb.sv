module tb;

    logic clk;
    logic rst;
    logic [4:0] coin;
    logic dispense;

    vending dut (
        .clk(clk),
        .rst(rst),
        .coin(coin),
        .dispense(dispense)
    );

    // Clock
    initial clk = 0;
    always #5 clk = ~clk;

    // -------------------------
    // COVERAGE
    // -------------------------
    covergroup cg_vend @(posedge clk);

        // State coverage
        cp_state: coverpoint dut.state;

        // Transition coverage
        cp_transition: coverpoint dut.state {
            bins idle_to_5   = (0 => 1);
            bins five_to_10  = (1 => 2);
            bins ten_to_idle = (2 => 0);
        }

        // Coin coverage
        cp_coin: coverpoint coin {
            bins five  = {5};
            bins ten   = {10};
        }

    endgroup

    cg_vend cg = new();

    // -------------------------
    // TEST
    // -------------------------
    initial begin

        $dumpfile("vend_wave.vcd");
        $dumpvars(0, tb);

        rst = 1;
        coin = 0;
        #15;
        rst = 0;

        // Random coin insertion
        repeat (20) begin
            @(posedge clk);
            if ($urandom_range(0,1))
                coin = 5;
            else
                coin = 10;
        end

        #20;

        $display("Coverage = %0.2f %%", cg.get_coverage());
        $finish;
    end

endmodule
