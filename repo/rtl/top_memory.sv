//`include <./memory/data_mem.sv>

module top_memory #(
    parameter  DATA_WIDTH = 32
) (
    input  logic                   clk, 
    input  logic [DATA_WIDTH-1:0]  ALUResult,
    input  logic [DATA_WIDTH-1:0]  WriteData,
    input  logic                   ResultSrc,
    input  logic                   MemWrite,
    input  logic                   MemRead,
    input  logic [2:0]             funct3,
    output logic [DATA_WIDTH-1:0]  Result
);

logic [4*DATA_WIDTH-1:0] fetch_data;
logic                  fetch_enable;
logic [DATA_WIDTH-1:0] Data;
logic [4*DATA_WIDTH-1:0] write_back_data;
logic [DATA_WIDTH-1:0] write_back_addr;
logic                  write_back_valid;
logic                  hit;
logic [DATA_WIDTH-1:0] ReadData_c;

logic                  mem_wr_en;
logic [4*DATA_WIDTH-1:0] ReadBlockData;

assign mem_wr_en = write_back_valid;

assign fetch_enable = ~hit;

cache data_cache (
    .clk             (clk),
    .rd_en           (MemRead),
    .ReadData_c      (ReadData_c),

    .wr_en           (MemWrite),
    .WriteData       (WriteData),
    .addr            (ALUResult),
    .funct3          (funct3),

    .hit             (hit),

    .fetch_data      (fetch_data),
    .fetch_enable    (fetch_enable),

    .write_back_data (write_back_data),
    .write_back_valid(write_back_valid),
    .write_back_addr (write_back_addr)
);

data_mem data_mem (
    .clk              (clk),
    .wr_en            (mem_wr_en),
    .addr             (write_back_addr),
    .WriteBlockData   (write_back_data),

    .ReadBlockData    (ReadBlockData)
);

assign fetch_data = ReadBlockData;

mux mem_type(
    .in0        (ReadBlockData[({ALUResult[3:2], 5'b0} + 1)*32-1 -: 32]), // Selects the word to be written to the register file
    .in1        (ReadData_c),
    .sel        (hit),
    .out        (Data)
);

mux ResultSlc(
    .in0        (ALUResult),
    .in1        (Data),
    .sel        (ResultSrc),
    .out        (Result)
);

endmodule
