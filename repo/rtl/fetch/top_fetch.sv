`include <./fetch/pc_reg.sv>
`include <./fetch/inst_mem.sv>

module top_fetch #(
    parameter   ADDRESS_WIDTH = 32
)(
    input  logic                       clk,
    input  logic                       rst,
    input  logic                       PCSrc,
    input  logic [ADDRESS_WIDTH-1:0]   PCTarget,

    //Stall
    input  logic                       StallF,

    output logic [ADDRESS_WIDTH-1:0]   instr,
    output logic [ADDRESS_WIDTH-1:0]   pc,
    output logic [ADDRESS_WIDTH-1:0]   PCPlus4
);

logic [ADDRESS_WIDTH-1:0] pc_next;
logic [ADDRESS_WIDTH-1:0] pc_next_pp;


assign PCPlus4 = pc + 4;

pc_reg pc_reg(
    .clk    (clk),
    .rst    (rst),
    .pc_next(pc_next_pp), 
    .pc     (pc)
);

mux pc_sel
(
    .in0    (PCPlus4),
    .in1    (PCTarget),
    .sel    (PCSrc),
    .out    (pc_next)
);

assign pc_next_pp = StallF ? pc : pc_next;

    inst_mem inst_mem (
        .addr       (pc),
        .dout       (instr)
    );


    
endmodule
