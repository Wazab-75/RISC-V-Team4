`include <./fetch/pc_reg.sv>

module top_fetch #(
    parameter   ADDRESS_WIDTH = 32
)(
    input  logic                       clk,
    input  logic                       rst,
    input  logic                       PCSrc,
    input  logic [ADDRESS_WIDTH-1:0]   ImmExt,
    input  logic [ADDRESS_WIDTH-1:0]   rs1,
    input  logic                       jalr,
    output logic [ADDRESS_WIDTH-1:0]   pc
);

logic [ADDRESS_WIDTH-1:0] pc_next;
logic [ADDRESS_WIDTH-1:0] pc_next_f;


pc_reg pc_reg(
    .clk    (clk),
    .rst    (rst),
    .pc_next(pc_next_f),
    .pc     (pc)
);

mux pc_sel
(
    .in0    (pc + 4),
    .in1    (pc + ImmExt),
    .sel    (PCSrc),
    .out    (pc_next)
);

mux jalr_sel(
    .in0    (pc_next),
    .in1    (ImmExt + rs1),
    .sel    (jalr),
    .out    (pc_next_f)
);


    
endmodule
