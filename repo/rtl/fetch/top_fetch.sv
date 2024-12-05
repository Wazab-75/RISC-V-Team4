`include <./fetch/pc.sv>
//`include <./fetch/inst_mem.sv>

module top_fetch #(
    parameter  DATA_WIDTH = 32
    
) (
    input                        clk,
    input                        rst,
    input                        PCSrc,
    input [DATA_WIDTH-1:0]       PCTarget,
    output[DATA_WIDTH-1:0]       pc,
    output[DATA_WIDTH-1:0]      PCPlus4
    
);  

    logic [DATA_WIDTH-1:0]    pc_next;

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


endmodule   

