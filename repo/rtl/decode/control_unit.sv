`include <./decode/alu_decoder.sv>
`include <./decode/main_decoder.sv>

module control_unit (
    input logic [6:0]     op,
    input logic [2:0]     funct3,
    input logic           funct7_5,

    output logic [2:0]    ALUctrl,
    output logic [2:0]    ImmSrc, 
    output logic          RegWrite,
    output logic          ALUSrc,
    output logic          MemWrite,
    output logic [1:0]    ResultSrc,
    output logic          Jump,
    output logic          Branch,
    output logic          branch_neg,
    output logic          PcOp
);


logic [1:0] ALUOp;

main_decoder main_decode(
    .op             (op),
    .ImmSrc         (ImmSrc),      
    .ALUOp          (ALUOp),
    .RegWrite       (RegWrite),
    .ALUSrc         (ALUSrc),
    .MemWrite       (MemWrite),
    .ResultSrc      (ResultSrc),
    .Branch         (Branch),
    .PcOp           (PcOp)
);


alu_decoder alu_decode(
    .funct3         (funct3),
    .funct7_5       (funct7_5),
    .ALUOp          (ALUOp),
    .Op_5           (op[5]),
    .ALUctrl        (ALUctrl)
);

always_comb begin
    case(funct3)
        //bne, bge, bgeu
        3'b001, 3'b101, 3'b111: branch_neg = 1;
        default: branch_neg = 0;
    endcase
    //Jump if jal or jalr
    Jump = (op == 7'b1101111 || op == 7'b1100111);
end


endmodule
