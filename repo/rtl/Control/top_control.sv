module top_control # (
    parameter  ADDRESS_WIDTH = 5,
               DATA_WIDTH = 32
) (
    input [ADDRESS_WIDTH-1:0]    pc,
    input logic        EQ,
    input logic [1:0] ImmSrc,
    output logic       RegWrite,
    output logic [2:0] ALUctrl,
    output logic       ALUSrc,
    output logic       PCSrc,
    output logic [31:0] ImmOp,
    output logic [DATA_WIDTH-1:0] instr
    // not sure if needed:
    // output logic       MemWrite,
    // output logic       ResultSrc,
);

    // Internal signals
    logic [31:0] instr;      // Instruction fetched from instruction memory
    logic [2:0] funct3;
    logic [6:0]   op;
    // logic         funct7_5;

    // Instantiate instruction memory
    inst_mem inst_mem_inst (
        .addr(pc),
        .dout(instr)
    );

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
        // .MemWrite(MemWrite),
        // .ResultSrc(ResultSrc)
    );

    // Instantiate sign extend unit
    sign_extend sign_extend_inst (
        .ImmSrc(ImmSrc),
        .dout(instr[31:7]),
        .immOp(immOp)
    );

endmodule
