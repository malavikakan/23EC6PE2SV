// ----------------------
// CLASS DEFINITIONS FIRST
// ----------------------

class Packet;
    rand bit [7:0] data;

    virtual function void print();
        $display("Normal Packet: %0h", data);
    endfunction
endclass


class BadPacket extends Packet;

    virtual function void print();
        $display("ERROR Packet: %0h", data);
    endfunction
endclass


// ----------------------
// TESTBENCH MODULE
// ----------------------

module tb;

    Packet p;          // class handle
    BadPacket bad;     // class handle

    initial begin

        $dumpfile("dump.vcd");
        $dumpvars(0, tb);

        bad = new();
        p   = bad;

        if (!p.randomize())
            $error("Randomization failed");

        p.print();

        #10;
        $finish;
    end

endmodule
