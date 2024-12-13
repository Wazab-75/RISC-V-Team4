`include <./decode/control_unit.sv>
`include <./decode/sign_extend.sv>

module top_decode #(
    parameter DATA_WIDTH = 32
) (
    input  logic [DATA_WIDTH-1:0]  instr,
    input  logic                   branch_l,
    output logic [2:0]             ALUctrl,
    output logic                   RegWrite,
    output logic                   ALUSrc,
    output logic                   MemWrite,
    output logic                   ResultSrc,
    output logic                   PCSrc,
    output logic [DATA_WIDTH-1:0]  ImmExt,
    output logic                   PcOp,
    output logic                   jalr
);

logic [2:0] ImmSrc;

control_unit control_unit (
    .op         (instr[6:0]),
    .funct3     (instr[14:12]),
    .funct7_5   (instr[30]),
    .branch_l   (branch_l),  
    .ALUctrl    (ALUctrl),
    .ImmSrc     (ImmSrc), 
    .RegWrite   (RegWrite),
    .ALUSrc     (ALUSrc),
    .MemWrite   (MemWrite),
    .ResultSrc  (ResultSrc),
    .PCSrc      (PCSrc),
    .PcOp       (PcOp),
    .jalr       (jalr)
);

sign_extend sign_extend(
    .Imm        (instr[31:7]),
    .ImmSrc     (ImmSrc),
    .ImmExt     (ImmExt)     
);

    
endmodule
