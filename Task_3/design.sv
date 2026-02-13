module atm_controller (
    input logic clk,
    input logic rst_n,
    input logic card_inserted,
    input logic pin_correct,
    input logic balance_ok,
    output logic dispense_cash
);

    typedef enum logic [1:0] {
        IDLE      = 2'b00,
        CHECK_PIN = 2'b01,
        CHECK_BAL = 2'b10,
        DISPENSE  = 2'b11
    } state_t;

    state_t current_state, next_state;

    // State Transition Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) current_state <= IDLE;
        else        current_state <= next_state;
    end

    // Next State Logic
    always_comb begin
        next_state = current_state;
        dispense_cash = 1'b0;

        case (current_state)
            IDLE: begin
                if (card_inserted) next_state = CHECK_PIN;
            end
            CHECK_PIN: begin
                if (pin_correct)    next_state = CHECK_BAL;
                else if (!card_inserted) next_state = IDLE; // Simplified exit
            end
            CHECK_BAL: begin
                if (balance_ok)     next_state = DISPENSE;
                else if (!card_inserted) next_state = IDLE;
            end
            DISPENSE: begin
                dispense_cash = 1'b1;
                next_state = IDLE; // Returns to IDLE after dispensing
            end
        endcase
    end

    // --- Assertions ---
    
    // 1. Cash is dispensed ONLY if pin_correct AND balance_ok occurred
    // We check that if we are in DISPENSE, we must have passed the checks.
    property p_valid_dispense;
        @(posedge clk) (current_state == DISPENSE) |-> dispense_cash;
    endproperty
    assert_valid_dispense: assert property (p_valid_dispense);

    // 2. Machine returns to IDLE after dispensing
    property p_return_idle;
        @(posedge clk) (current_state == DISPENSE) |=> (current_state == IDLE);
    endproperty
    assert_return_idle: assert property (p_return_idle);

endmodule
