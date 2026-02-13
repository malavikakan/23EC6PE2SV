module tb_dual_port_ram;
    parameter ADDR_WIDTH = 4;
    parameter DATA_WIDTH = 8;

    logic clk = 0;
    logic we_a;
    logic [ADDR_WIDTH-1:0] addr_a, addr_b;
    logic [DATA_WIDTH-1:0] data_in_a, data_out_b;

    // Reference Model
    logic [DATA_WIDTH-1:0] ref_model [logic [ADDR_WIDTH-1:0]];

    // --- Functional Coverage ---
    covergroup ram_cg @(posedge clk);
        option.per_instance = 1;
        
        // Track which addresses were written to
        cp_addr_a: coverpoint addr_a {
            bins low    = {[0:7]};
            bins high   = {[8:15]};
        }
        
        // Track the write enable signal
        cp_we: coverpoint we_a;
        
        // Ensure we wrote to both low and high address ranges
        cross_write: cross cp_addr_a, cp_we {
            ignore_bins no_write = binsof(cp_we) intersect {0};
        }
    endgroup

    ram_cg cg_inst = new();
    always #5 clk = ~clk;

    dual_port_ram #(ADDR_WIDTH, DATA_WIDTH) dut (.*);

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_dual_port_ram);

        we_a = 0; 
        repeat(2) @(posedge clk);

        // Task 3: Write random data
        repeat(20) begin
            @(posedge clk);
            we_a = 1;
            addr_a = $urandom_range(0, 15);
            data_in_a = $urandom();
            ref_model[addr_a] = data_in_a;
            @(posedge clk);
            we_a = 0;
        end

        // Task 4 & 5: Read and Compare
        foreach (ref_model[curr_addr]) begin
            addr_b = curr_addr;
            #1; 
            if (data_out_b === ref_model[curr_addr])
                $display("[PASS] Addr: %0h | Data: %0h", curr_addr, data_out_b);
            else
                $display("[FAIL] Addr: %0h", curr_addr);
        end

        // Display Final Coverage Result
        $display("Final Functional Coverage: %.2f%%", cg_inst.get_inst_coverage());
        $finish;
    end
endmodule
