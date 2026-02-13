// Challenge Exercise: Exercise 4: The 8-byte Packet
class EthPacket;
    // Task 1: Dynamic array payload
    rand byte payload[];

    // Task 2: Variable len (length)
    rand int len;

    // Task 3: Constraint: payload.size() must equal len
    constraint c_payload_size {
        payload.size() == len;
    }

    // Task 4: Constraint: len must be between 4 and 8
    constraint c_len_range {
        len inside {[4:8]};
    }

    // Helper function to display packet details
    function void display(int index);
        $display("Packet %0d: len = %0d, payload size = %0d", index, len, payload.size());
        $write("Payload content: ");
        foreach (payload[i]) $write("%h ", payload[i]);
        $display("\n-----------------------------------------");
    endfunction
endclass
