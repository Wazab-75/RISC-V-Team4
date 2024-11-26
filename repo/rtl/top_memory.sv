// First version of the cache implementation
// For now when there is a miss, we just write the data back to the memory
// We will implement the write-back policy later

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

logic [DATA_WIDTH-1:0] ReadData;
logic [DATA_WIDTH-1:0] Data;
logic [DATA_WIDTH-1:0] write_back_data;
logic                  write_back_valid;
logic                  hit;
logic [DATA_WIDTH-1:0] ReadData_c;

logic                  final__wr_en;
logic [DATA_WIDTH-1:0] final_wr_data;
logic [DATA_WIDTH-1:0] final_wr_addr;

assign final_wr_en = MemWrite | write_back_valid; 
assign final_wr_data = write_back_valid ? write_back_data : WriteData; 
assign final_wr_addr = write_back_valid ? ALUResult : ALUResult; 

cache data_cache(
    .clk        (clk),
    .rd_en      (MemRead),
    .wr_en      (MemWrite),
    .addr       (ALUResult),
    .WriteData  (WriteData),
    .ReadData_c (ReadData_c),
    .hit        (hit),
    .write_back_data (write_back_data),
    .write_back_valid (write_back_valid)
);

data_mem data_mem(
    .clk        (clk),
    .wr_en      (final__wr_en),
    .addr       (final_wr_addr),
    .WriteData  (final_wr_data),
    .ReadData   (ReadData)
    .funct3     (funct3)
);

mux mem_type(
    .in0        (ReadData),
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
