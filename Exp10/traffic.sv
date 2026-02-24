module traffic_light (
    input  logic clk,
    input  logic rst,
    output logic red,
    output logic yellow,
    output logic green
);

    typedef enum logic [1:0] {
        RED    = 2'b00,
        GREEN  = 2'b01,
        YELLOW = 2'b10
    } state_t;

    state_t current_state, next_state;
    logic [3:0] counter;

    // State transition
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= RED;
            counter <= 0;
        end else begin
            if (counter == 4) begin
                current_state <= next_state;
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end

    // Next state logic
    always_comb begin
        case (current_state)
            RED:    next_state = GREEN;
            GREEN:  next_state = YELLOW;
            YELLOW: next_state = RED;
            default: next_state = RED;
        endcase
    end

    // Output logic
    assign red    = (current_state == RED);
    assign green  = (current_state == GREEN);
    assign yellow = (current_state == YELLOW);

endmodule
