module vending (
    input  logic       clk,
    input  logic       rst,
    input  logic [4:0] coin,     // 5 or 10
    output logic       dispense
);

    typedef enum logic [1:0] {
        IDLE,      // 0 cents
        HAS_5,     // 5 cents
        HAS_10     // 10 cents
    } state_t;

    state_t state, next_state;

    // State register
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Next state logic
    always_comb begin
        next_state = state;
        dispense   = 0;

        case (state)

            IDLE: begin
                if (coin == 5)       next_state = HAS_5;
                else if (coin == 10) next_state = HAS_10;
            end

            HAS_5: begin
                if (coin == 5)       next_state = HAS_10;
                else if (coin == 10) begin
                    next_state = IDLE;
                    dispense   = 1;   // 5 + 10 = 15
                end
            end

            HAS_10: begin
                if (coin == 5) begin
                    next_state = IDLE;
                    dispense   = 1;   // 10 + 5 = 15
                end
                else if (coin == 10) begin
                    next_state = IDLE;
                    dispense   = 1;   // 10 + 10 = 20 (extra ignored)
                end
            end

        endcase
    end

endmodule
