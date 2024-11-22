module top_decode # (
    parameter  ADDRESS_WIDTH = 5,
               DATA_WIDTH = 32
) (
    input logic [DATA_WIDTH-1:0] instr, 
    input logic        EQ,
    input logic [1:0] ImmSrc,
    output logic       RegWrite,
    output logic [2:0] ALUctrl,
    output logic       ALUSrc,
    output logic       PCSrc,
    output logic [31:0] ImmOp,
    output logic       MemWrite,
    output logic       ResultSrc
);

    // Internal signals
    logic [2:0] funct3;
    logic [6:0]   op;
    logic         funct7_5;

    // Extract fields from instruction
    assign op        = instr[6:0];
    assign funct3    = instr[14:12];
    assign funct7_5  = instr[30];  

    // Instantiate control unit
    control_unit control_unit_inst (
        .funct3(funct3),
        .op(op),
        .funct7_5(funct7_5),
        .EQ(EQ),
        .RegWrite(RegWrite),
        .ALUctrl(ALUctrl),
        .ALUSrc(ALUSrc),
        .ImmSrc(ImmSrc),
        .PCSrc(PCSrc),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc)
    );

    // Instantiate sign extend unit
    sign_extend sign_extend_inst (
        .ImmSrc(ImmSrc),
        .Imm_up(instr[31:20]),
        .Imm_down(instr[11:7]),
        .ImmExt(ImmOp)
    );

endmodule
