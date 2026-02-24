// ============================================================
// DESIGN: 1011 Sequence Detector (Mealy FSM)
// ============================================================
module seq_detector(
    input  logic clk, rst, in,
    output logic det
);

    typedef enum logic [1:0] {S0, S1, S2, S3} state_t;
    state_t state, next;

    // State register
    always_ff @(posedge clk)
        state <= rst ? S0 : next;

    // Next-state + output logic (Mealy)
    always_comb begin
        next = S0;
        det  = 0;
        case (state)
            S0: next = in ? S1 : S0;           // got nothing, wait for 1
            S1: next = in ? S1 : S2;           // got 1
            S2: next = in ? S3 : S0;           // got 10
            S3: begin                           // got 101
                    det  = in ? 1 : 0;          // got 1011 -> detect!
                    next = in ? S1 : S2;        // overlap handling
                end
        endcase
    end

endmodule
