// =======================
// design.sv
// DIGITAL CLOCK DESIGN
// =======================

module digital_clock (
    input  logic clk,
    input  logic rst,
    output logic [5:0] sec,
    output logic [5:0] min
  
);

    // Seconds Counter
    always_ff @(posedge clk or posedge rst) begin

        if (rst) begin
            sec  <= 0;
            min  <= 0;
        
        end
        else begin

            // Increment seconds
            if (sec == 59) begin
                sec <= 0;

                // Increment minutes
                if (min == 59) begin
                    min <= 0;                 

                end
                else
                    min <= min + 1;

            end
            else
                sec <= sec + 1;

        end

    end

endmodule
