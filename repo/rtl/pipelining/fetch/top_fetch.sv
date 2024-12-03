`include <./fetch/pc.sv>
`include <./fetch/inst_mem.sv>

module top_fetch #(
    parameter   ADDRESS_WIDTH = 32
)(
    input  logic                       clk,
    input  logic                       rst,
    input  logic                       PCSrc,
    input  logic [ADDRESS_WIDTH-1:0]   PCTarget,
    output logic [ADDRESS_WIDTH-1:0]   instr,
    output logic [ADDRESS_WIDTH-1:0]   pc,
    output logic [ADDRESS_WIDTH-1:0]   PCPlus4
);

logic [ADDRESS_WIDTH-1:0] pc_next;


assign PCPlus4 = pc + 4;

pc_reg pc_reg(
    .clk    (clk),
    .rst    (rst),
    .pc_next(pc_next),
    .pc     (pc)
);

mux pc_sel
(
    .in0    (PCPlus4),
    .in1    (PCTarget),
    .sel    (PCSrc),
    .out    (pc_next)
);

inst_mem inst_mem
(
    .addr       (pc),
    .dout       (instr)
);


    
endmodule