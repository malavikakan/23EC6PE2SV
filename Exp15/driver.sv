// ---------------------
// Packet Class
// ---------------------
class Packet;
    rand bit [7:0] val;
endclass


// ---------------------
// Testbench
// ---------------------
module tb;

    // Typed mailbox
    mailbox #(Packet) mbx = new();

    // ---------------------
    // Generator
    // ---------------------
    task generator();
        Packet p;
        repeat (5) begin
            p = new();
            if (!p.randomize())
                $error("Randomization failed");

            #5;   // simulate time delay

            $display("Generator sending: %0d", p.val);
            mbx.put(p);   // Put into mailbox
        end
    endtask


    // ---------------------
    // Driver
    // ---------------------
    task driver();
        Packet p;
        repeat (5) begin
            mbx.get(p);   // Blocks until data available
            $display("Driver received: %0d", p.val);
            #10;          // simulate processing time
        end
    endtask


    // ---------------------
    // Simulation Control
    // ---------------------
    initial begin

        $dumpfile("dump.vcd");
        $dumpvars(0, tb);

        fork
            generator();
            driver();
        join

        #10;
        $finish;
    end

endmodule
