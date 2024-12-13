`include <./execute/alu.sv>
`include <./execute/reg_file.sv>

module top_execute #(
    parameter   DATA_WIDTH = 32
)(
    input  logic                   clk,
    input  logic [DATA_WIDTH-1:0]  pc,
    input  logic                   PcOp,
    input  logic [19:15]           instr_19_15,
    input  logic [24:20]           instr_24_20,
    input  logic [11:7]            instr_11_7,
    input  logic [2:0]             ALUctrl,
    input  logic                   ALUSrc,
    input  logic                   RegWrite,
    input  logic [DATA_WIDTH-1:0]  Result,
    input  logic [DATA_WIDTH-1:0]  ImmExt,
    output logic [DATA_WIDTH-1:0]  a0,
    output logic [DATA_WIDTH-1:0]  ALUResult,
    output logic                   branch_l,
    output logic [DATA_WIDTH-1:0]  WriteData,
    output logic [DATA_WIDTH-1:0]  rs1

);

logic [DATA_WIDTH-1:0]  ALUop2;
logic [DATA_WIDTH-1:0]  ALUop1;
logic [DATA_WIDTH-1:0]  ALUop2_f;

reg_file reg_file (
    .clk        (clk),
    .AD1        (instr_19_15),
    .AD2        (instr_24_20),
    .AD3        (instr_11_7),
    .WD3        (Result),   
    .WE3        (RegWrite),
    .RD1        (rs1),
    .RD2        (WriteData),
    .a0         (a0)
);

mux ALuSrc1Sel (
    .in0        (rs1),
    .in1        (pc),
    .sel        (PcOp),
    .out        (ALUop1)
);

mux ALuSrc2Sel (
    .in0        (WriteData),
    .in1        (ImmExt),
    .sel        (ALUSrc),
    .out        (ALUop2)
);

mux AluSrc2PcOpSel (
    .in0        (ALUop2),
    .in1        (32'd4),
    .sel        (PcOp),
    .out        (ALUop2_f)
);



alu alu(
    .ALUop1     (ALUop1),
    .ALUop2     (ALUop2_f),
    .ALUctrl    (ALUctrl),
    .ALUout     (ALUResult),
    .branch_l   (branch_l)
);

endmodule
