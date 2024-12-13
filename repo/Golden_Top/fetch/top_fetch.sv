

module top_fetch #(
    parameter   ADDRESS_WIDTH = 32
)(
    input  logic                       clk,
    input  logic                       rst,
    input  logic                       PCSrc,
    input  logic [ADDRESS_WIDTH-1:0]   ImmExt,
    input  logic [ADDRESS_WIDTH-1:0]   rs1,
    input  logic                       jalr,
    output logic [ADDRESS_WIDTH-1:0]   pc,
    output logic [ADDRESS_WIDTH-1:0]   pc_cur
);

logic [ADDRESS_WIDTH-1:0] pc_next;

always_comb begin
    if (jalr) pc = rs1 + ImmExt;
    else begin 
    if (PCSrc) pc = pc_cur + ImmExt - 4;
    else pc = pc_cur;
    end
    pc_next = pc + 4;
end



pc_reg pc_reg(
    .clk    (clk),
    .rst    (rst),
    .pc_next(pc_next),
    .pc     (pc_cur)
);

    
endmodule
