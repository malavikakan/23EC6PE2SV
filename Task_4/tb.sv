module tb_packet_challenge;
    initial begin
        // Create an instance of the class
        EthPacket pkt = new();

        $display("Starting Randomization Test...\n");

        // Task 5: Randomize and print 5 packets
        for (int i = 1; i <= 5; i++) begin
            if (pkt.randomize()) begin
                pkt.display(i);
            end else begin
                $error("Randomization failed for packet %0d", i);
            end
        end
    end
    
    // VCD Generation (standard for EDA Playground visibility)
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_packet_challenge);
    end
endmodule
