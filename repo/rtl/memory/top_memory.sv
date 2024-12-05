`include <./memory/data_mem.sv>

module top_memory #(
    parameter  DATA_WIDTH = 32
) (
    input  logic                   clk, 
    input  logic [DATA_WIDTH-1:0]  ALUResult,
    input  logic [DATA_WIDTH-1:0]  WriteData,
    input  logic [1:0]             ResultSrc,
    input  logic                   MemWrite,
    input  logic [2:0]             funct3,
    input  logic [DATA_WIDTH-1:0]  PCPlus4,
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

always_comb begin
    case(ResultSrc) 
        2'b00: Result = ALUResult;
        2'b01: Result = ReadData;
        2'b10: Result = PCPlus4;
        //2:b11:TODO
        default:Result = 0;
    endcase
 end


endmodule
