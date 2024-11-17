module pc_plus_offset #(
    parameter ADDRESS_WIDTH = 5
)(
    input  [ADDRESS_WIDTH-1:0] pc,
    input  [ADDRESS_WIDTH-1:0] offset,
    output [ADDRESS_WIDTH-1:0] pc_next
);

    assign pc_next = pc + offset;

endmodule


