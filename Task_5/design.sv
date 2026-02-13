module dual_port_ram #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input  logic clk,
    input  logic we_a,
    input  logic [ADDR_WIDTH-1:0] addr_a,
    input  logic [DATA_WIDTH-1:0] data_in_a,
    input  logic [ADDR_WIDTH-1:0] addr_b,
    output logic [DATA_WIDTH-1:0] data_out_b
);

    logic [DATA_WIDTH-1:0] ram [2**ADDR_WIDTH];

    always_ff @(posedge clk) begin
        if (we_a) ram[addr_a] <= data_in_a;
    end

    assign data_out_b = ram[addr_b];

endmodule
