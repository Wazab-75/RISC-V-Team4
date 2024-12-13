`include <./memory/data_mem.sv>
`include <./memory/cache.sv>

module top_memory #(
    parameter  DATA_WIDTH = 32
) (
    input  logic                   clk, 
    input  logic [DATA_WIDTH-1:0]  ALUResult,
    input  logic [DATA_WIDTH-1:0]  WriteData,
    input  logic                   MemWrite,
    input  logic                   MemRead,
    input  logic [2:0]             funct3,
    output logic [DATA_WIDTH-1:0]  ReadData
);

logic                    fetch_enable;
logic [4*DATA_WIDTH-1:0] write_back_data;
logic [DATA_WIDTH-1:0]   write_back_addr;
logic                    write_back_valid;
logic                    hit;
logic [DATA_WIDTH-1:0]   cache_read;
logic                    mem_wr_en;
logic [4*DATA_WIDTH-1:0] ReadBlockData;

assign mem_wr_en = write_back_valid;
assign fetch_enable = ~hit;

cache data_cache (
    .clk             (clk),
    .wr_en           (MemWrite),
    .rd_en           (MemRead),
    .WriteData       (WriteData),
    .addr            (ALUResult),
    .funct3          (funct3),
    .fetch_data      (ReadBlockData),
    .fetch_enable    (fetch_enable),

    .cache_read      (cache_read),
    .hit             (hit),
    .write_back_data (write_back_data),
    .write_back_valid(write_back_valid),
    .write_back_addr (write_back_addr)
);

data_mem data_mem (
    .clk              (clk),
    .wr_en            (mem_wr_en),
    .addr             (write_back_addr),
    .WriteBlockData   (write_back_data),
    .mem_read_addr    (ALUResult),
    .ReadBlockData    (ReadBlockData)
);

assign ReadData = cache_read;

endmodule
