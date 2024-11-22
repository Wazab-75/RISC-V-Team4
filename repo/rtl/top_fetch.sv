module top_fetch #(
    parameter  ADDRESS_WIDTH = 5,
               DATA_WIDTH = 32
    
) (
    input                        clk,
    input                        rst,
    input                        PCSrc,
    input[DATA_WIDTH-1:0]        ImmExt,
    output[ADDRESS_WIDTH-1:0]    pc
    
);
     
    logic [ADDRESS_WIDTH-1:0]    pc_next;

    pc pc_reg(
        .clk (clk),
        .rst (rst),
        .pc  (pc),
        .pc_next (pc_next)
    );

    mux pc_sel(
        .in0 (pc + 4),
        .in1 (pc + ImmExt[ADDRESS_WIDTH-1:0]),
        .sel (PCSrc),
        .out (pc_next)

    );


endmodule   

