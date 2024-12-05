`include "def.sv"

module control_unit (   
    input logic [31:0]  Instr,
    input logic         Zero,

    output logic        RegWrite,   
    output logic [3:0]  ALUctrl,    
    output logic        ALUSrc,     
    output logic [2:0]  ImmSrc,     
    output logic        PCSrc,       
    output logic        MemWrite,
    output logic        MemRead,
    output logic [1:0]  ResultSrc,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [4:0]  rd,
    output logic        PcOp
);

logic         Branch_neg; //Check if bne, bge or bgeu
logic         Branch;
logic         Jump;
logic  [6:0]  op;
logic  [2:0]  funct3;
logic  [6:0]  funct7;

    //Assign decoded signals
    assign rs1 = Instr[19:15];
    assign rs2 = Instr[24:20];
    assign rd  = Instr[11:7];  
    assign op = Instr[6:0];
    assign funct3 = Instr[14:12];
    assign funct7 = Instr[31:25];

    always_comb begin
    
        case (op) 
            // R-type
            7'b0110011: begin
                case(funct3)
                    3'b000: ALUctrl = {3'b000, funct7[5]};   // ADD, SUB
                    3'b001: ALUctrl = `ALU_OPCODE_SLL;       // SLL: Shift Left Logical
                    3'b010: ALUctrl = `ALU_OPCODE_SLT;       // SLT: Set Less Than                    
                    3'b100: ALUctrl = `ALU_OPCODE_XOR;       // XOR
                    3'b101: ALUctrl = {3'b100, funct7[5]};   // SRL: Shift Right Logical, SRA: Shift Right Arithmetic
                    3'b110: ALUctrl = `ALU_OPCODE_OR;        // OR
                    3'b111: ALUctrl = `ALU_OPCODE_AND;       // AND
                    default: ALUctrl = 0;
                endcase    
                RegWrite = 1;
                ALUSrc = 0;
                ImmSrc = 3'bXXX;
                Branch = 0;
                MemWrite = 0;
                MemRead = 0;
                ResultSrc = 0;
            end

            // I-type Arithmetic
            7'b0010011: begin   
                case(funct3)
                    3'b000: ALUctrl = `ALU_OPCODE_ADD;       // ADDI: ADD Immediate 
                    3'b001: ALUctrl = `ALU_OPCODE_SLL;       // SLLI: Shift Left Logical Imm
                    3'b010: ALUctrl = `ALU_OPCODE_SLT;       // SLTI: Set Less Than Imm
                    3'b100: ALUctrl = `ALU_OPCODE_XOR;       // XORI: XOR Immediate
                    3'b101: ALUctrl = {3'b100, funct7[5]};   // SRLI/SRAI: Shift Right Logical/Arithmetic Imm
                    3'b110: ALUctrl = `ALU_OPCODE_OR;        // ORI: OR Immediate
                    3'b111: ALUctrl = `ALU_OPCODE_AND;       // ANDI: AND Immediate 
                    default: ALUctrl = 0;
                endcase
                RegWrite = 1;
                ALUSrc = 1;
                ImmSrc = 3'b000;
                Branch = 0;
                MemWrite = 0;
                MemRead = 0;
                ResultSrc = 0;
            end

            // I-type Load
            7'b0000011: begin   
                RegWrite = 1;
                ALUctrl = 4'b0000;
                ALUSrc = 1;
                ImmSrc = 3'b000;
                Branch = 0;
                MemWrite = 0;
                MemRead = 1;  // Enable memory read for load instructions
                ResultSrc = 1;
            end

            // S-type Store
            7'b0100011: begin   
                RegWrite = 0;
                ALUctrl = 4'b0000;
                ALUSrc = 1;
                ImmSrc = 3'b001;
                Branch = 0;
                MemWrite = 1;
                MemRead = 0;
                ResultSrc = 0;
            end

            // B-type Branch
            7'b1100011: begin   
                case(funct3)
                    3'b000: ALUctrl = `ALU_OPCODE_SUB;    // BEQ: Branch ==
                    3'b001: ALUctrl = `ALU_OPCODE_SUB;    // BNE: Branch !=                 
                    3'b100: ALUctrl = `ALU_OPCODE_SLT;    // BLT: Branch <
                    3'b101: ALUctrl = `ALU_OPCODE_SLT;    // BGE: Branch ≥
                    3'b110: ALUctrl = `ALU_OPCODE_SLT;    // BLTU: Branch < (U)
                    3'b111: ALUctrl = `ALU_OPCODE_SLT;    // BGEU: Branch ≥ (U)
                    default: ALUctrl = 0;
                endcase
                RegWrite = 0;
                ALUSrc = 0;
                ImmSrc = 3'b010;
                Branch = 1;
                MemWrite = 0;
                MemRead = 0;
                ResultSrc = 0;
            end

            // J-type Jump
            7'b1101111: begin   // JAL: Jump And Link
                RegWrite = 1;
                ALUctrl = 4'b0000;
                ALUSrc = 1;
                ImmSrc = 3'b100;
                Branch = 1;
                MemWrite = 0;
                MemRead = 0;
                ResultSrc = 2'b10;
            end

            // Default case
            default: begin
                RegWrite = 0;
                ALUctrl = 4'b0000;
                ALUSrc = 0;
                ImmSrc = 3'b000;
                Branch = 0;
                MemWrite = 0;
                MemRead = 0;
                ResultSrc = 0;
            end
        endcase

        // Unconditional Jump operations
        if (op == 7'b1101111 || op == 7'b1100111) Jump = 1;
        else Jump = 0;

        // Check if BNE, BGE, or BGEU
        if (funct3 == 3'b001 || funct3 == 3'b101 || funct3 == 3'b111) Branch_neg = 1;
        else Branch_neg = 0;

        // Assign PCSrc
        PCSrc = Jump || (Branch && (Branch_neg ? !Zero : Zero));

        // Select PC target for branch operations
        if (op == 7'b1100111) PcOp = 1;
        else PcOp = 0;

    end 

endmodule 
