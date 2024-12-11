`include <./decode/control_unit.sv>
`include <./decode/sign_extend.sv>
`include <./decode/reg_file.sv>

module top_decode #(
    parameter DATA_WIDTH = 32
) (
    input  logic                   clk,
    input  logic                   trigger,
    input  logic [DATA_WIDTH-1:0]  instr,
    input  logic [DATA_WIDTH-1:0]  Result,
    input  logic [11:7]            Rd,
    input  logic                   RegWrite,
    output logic [2:0]             ALUctrl,
    output logic                   ALUSrc,
    output logic                   MemWrite,
    output logic [1:0]             ResultSrc,
    output logic                   Branch,
    output logic                   Jump,
    output logic                   branch_neg,
    output logic [DATA_WIDTH-1:0]  ImmExt,
    output logic                   PcOp,
    output logic [DATA_WIDTH-1:0]  rd1,
    output logic [DATA_WIDTH-1:0]  rd2,
    output logic                   RegWriteD,
    output logic [DATA_WIDTH-1:0]  a0
); 

logic [2:0] ImmSrc;

control_unit control_unit (
    .op         (instr[6:0]),
    .funct3     (instr[14:12]),
    .funct7_5   (instr[30]),
    .ALUctrl    (ALUctrl),
    .ImmSrc     (ImmSrc), 
    .RegWrite   (RegWriteD),
    .ALUSrc     (ALUSrc),
    .MemWrite   (MemWrite),
    .ResultSrc  (ResultSrc),
    .PcOp       (PcOp),
    .Branch     (Branch),
    .Jump       (Jump),
    .branch_neg (branch_neg)
);

sign_extend sign_extend(
    .Imm        (instr[31:7]),
    .ImmSrc     (ImmSrc),
    .ImmExt     (ImmExt)     
);

reg_file reg_file (
    .clk        (clk),
    .trigger    (trigger),
    .AD1        (instr[19:15]),
    .AD2        (instr[24:20]),
    .AD3        (Rd),
    .WD3        (Result),   
    .WE3        (RegWrite),
    .RD1        (rd1),
    .RD2        (rd2),
    .a0         (a0)
);

    
endmodule
