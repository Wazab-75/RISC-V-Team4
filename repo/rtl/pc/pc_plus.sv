module pc_plus (
    input  logic [31:0] pc,           // current pc
    output logic [31:0] pc_plus_4     // address (PC + 4)
);

    assign pc_plus_4 = pc + 4;        // PC + 4

endmodule
