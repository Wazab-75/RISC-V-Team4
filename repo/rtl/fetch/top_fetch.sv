`include <./fetch/pc.sv>
`include <./fetch/inst_mem.sv>
`include <./fetch/inst_cache.sv>

module top_fetch #(
    parameter  DATA_WIDTH = 32
    
) (
    input                        clk,
    input                        rst,
    input                        PCSrc,
    input [DATA_WIDTH-1:0]       PCTarget,
    output[DATA_WIDTH-1:0]       pc,
    output[DATA_WIDTH-1:0]       PCPlus4,
    output[DATA_WIDTH-1:0]       dout
    
);  

logic [DATA_WIDTH-1:0]    pc_next;

    // Instruction memory signals
logic [4*DATA_WIDTH-1:0] inst_fetch_data;
logic                    inst_fetch_enable;
logic [DATA_WIDTH-1:0]   inst_cache_read;
logic                    inst_hit;

assign inst_fetch_enable = ~inst_hit;

assign PCPlus4 = pc + 4;

pc pc_reg(
    .clk (clk),
    .rst (rst),
    .pc  (pc),
    .pc_next (pc_next)
);

mux #(DATA_WIDTH) pc_sel (
    .in0 (PCPlus4),
    .in1 (PCTarget),
    .sel (PCSrc),
    .out (pc_next)

);

// Instruction memory instances
inst_cache inst_cache (
    .clk             (clk),
    .addr            (pc),
    .fetch_data      (inst_fetch_data),
    .fetch_enable    (inst_fetch_enable),

    .cache_read      (inst_cache_read),
    .hit             (inst_hit)
);

inst_mem inst_mem (
    .addr (pc),
    .dout (inst_fetch_data)
);

// Output logic
assign dout = inst_cache_read;

endmodule   

