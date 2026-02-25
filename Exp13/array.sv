module tb;

    // Associative array (Sparse Memory)
    int mem[int];   
    int addr;
    int read_data;

    // -----------------------------
    // Coverage
    // -----------------------------
    covergroup cg_mem;
        coverpoint addr {
            bins low_addr  = {[0:1000]};
            bins mid_addr  = {[1001:50000]};
            bins high_addr = {[50001:100000]};
        }
    endgroup

    cg_mem cg = new();

    // -----------------------------
    // Test
    // -----------------------------
    initial begin

        $dumpfile("assoc_wave.vcd");
        $dumpvars(0, tb);

        $display("---- Writing Random Sparse Addresses ----");

        // Random writes
        repeat (10) begin
            addr = $urandom_range(0,100000);
            mem[addr] = $urandom();
            cg.sample();

            $display("Write: Addr=%0d Data=%0h", addr, mem[addr]);
        end

        $display("\n---- Reading All Stored Locations ----");

        // Iterate only existing locations
        foreach (mem[idx]) begin
            read_data = mem[idx];
            $display("Read: Addr=%0d Data=%0h", idx, read_data);
        end

        // Check existence
        addr = 500;

        if (mem.exists(addr))
            $display("\nAddress %0d exists with data %0h", addr, mem[addr]);
        else
            $display("\nAddress %0d does NOT exist in memory", addr);

        // Delete example
        if (mem.num() > 0) begin
            mem.delete();
            $display("\nMemory cleared. Entries now = %0d", mem.num());
        end

        $display("\nCoverage = %0.2f %%", cg.get_coverage());

        $finish;
    end

endmodule
