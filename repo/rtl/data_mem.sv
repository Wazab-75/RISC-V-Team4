module data_mem #(
    parameter   ADDRESS_WIDTH = 32,
                DATA_WIDTH = 32
)(
    input  logic                           clk,
    input  logic                           wr_en,
    input  logic [ADDRESS_WIDTH-1:0]       addr,
    input  logic [DATA_WIDTH-1:0]          WriteData,
    output logic [DATA_WIDTH-1:0]          ReadData
);

logic [DATA_WIDTH-1:0] ram_array [2**ADDRESS_WIDTH-1:0];



always_ff @(posedge clk)
    if (wr_en) ram_array[addr] <= WriteData;
    

always_comb
    ReadData = ram_array[addr];


endmodule
