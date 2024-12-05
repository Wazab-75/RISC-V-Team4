`include <./decode/control_unit.sv>
`include <./decode/sign_extend.sv>

module top_decode # (
    parameter  DATA_WIDTH = 32
) (
    input logic [DATA_WIDTH-1:0] instr, 
    input logic                  Zero,
    output logic                 RegWrite,
    output logic [3:0]           ALUctrl,
    output logic                 ALUSrc,
    output logic                 PCSrc,
    output logic [31:0]          ImmExt,
    output logic                 MemWrite,
    output logic                 MemRead,
    output logic [1:0]           ResultSrc,
    output logic [4:0]           rs1,
    output logic [4:0]           rs2,
    output logic [4:0]           rd,
    output logic                 PcOp
);


    // Internal signals
    logic [2:0]   ImmSrc;
 
    // Instantiate control unit
    control_unit control_unit_inst (
        .Instr(instr),
        .Zero(Zero),
        .RegWrite(RegWrite),
        .ALUctrl(ALUctrl),
        .ALUSrc(ALUSrc),
        .ImmSrc(ImmSrc),
        .PCSrc(PCSrc),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .ResultSrc(ResultSrc),
        .rs1        (rs1),
        .rs2        (rs2),
        .rd         (rd),
        .PcOp       (PcOp)
    );

    // Instantiate sign extend unit
    sign_extend sign_extend_inst (
        .ImmSrc(ImmSrc),
        .Imm_in(instr[31:7]),
        .ImmExt(ImmExt)
    );

endmodule
