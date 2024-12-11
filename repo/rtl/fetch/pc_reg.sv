module pc_reg #(
    parameter   ADDRESS_WIDTH = 32
)(
    input  logic                       clk,
    input  logic                       rst,
    input  logic [ADDRESS_WIDTH-1:0]   pc_next,
    output logic [ADDRESS_WIDTH-1:0]   pc
);

always_ff @(posedge clk)
    if (rst) pc <= {ADDRESS_WIDTH{1'b0}};
    else pc <= pc_next;
endmodule
