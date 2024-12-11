`include <./fetch/pc_reg.sv>
`include <./fetch/inst_mem.sv>
`include <./fetch/inst_cache.sv>

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

// Instruction memory signals
logic [ADDRESS_WIDTH-1:0] inst_fetch_data;
logic                    inst_fetch_enable;
logic [ADDRESS_WIDTH-1:0]   inst_cache_read;
logic                    inst_hit;
logic [ADDRESS_WIDTH-1:0]   inst_fetch_addr;
logic                    inst_fetch_request;

assign inst_fetch_enable = ~inst_hit;


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

// Instruction memory instances
inst_cache inst_cache (
    .clk             (clk),
    .addr            (pc),
    .fetch_data      (inst_fetch_data),
    .fetch_enable    (inst_fetch_enable),

    .cache_read      (inst_cache_read),
    .hit             (inst_hit),
    .fetch_addr      (inst_fetch_addr),
    .fetch_request   (inst_fetch_request)
);

inst_mem inst_mem (
    .addr (inst_fetch_addr),
    .en   (inst_fetch_request),
    .dout (inst_fetch_data)
);

// Output logic
assign instr = inst_cache_read;
    
endmodule
