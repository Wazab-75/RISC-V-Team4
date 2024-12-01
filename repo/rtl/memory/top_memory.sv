`include <./memory/data_mem.sv>

module top_memory #(
    parameter  DATA_WIDTH = 32
) (
    input  logic                   clk, 
    input  logic [DATA_WIDTH-1:0]  ALUResult,
    input  logic [DATA_WIDTH-1:0]  WriteData,
    input  logic                   ResultSrc,
    input  logic                   MemWrite,
    input  logic [2:0]             funct3,
    output logic [DATA_WIDTH-1:0]  Result
);

logic [DATA_WIDTH-1:0] ReadData;

data_mem data_mem(
    .clk        (clk),
    .wr_en      (MemWrite),
    .addr       (ALUResult),
    .WriteData  (WriteData),
    .ReadData   (ReadData),
    .funct3     (funct3)
);


mux ResultSlc(
    .in0        (ALUResult),
    .in1        (ReadData),
    .sel        (ResultSrc),
    .out        (Result)
);

endmodule
