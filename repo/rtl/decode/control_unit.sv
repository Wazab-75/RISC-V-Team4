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
                    3'b001: ALUctrl = `ALU_OPCODE_SLL;  //sll: Shift Left Logical
                    3'b010: ALUctrl = `ALU_OPCODE_SLT;  //slt: Set Less Than                    
                    //3'b011: ALUctrl = // TODO           //sltu: Set Less Than (U)
                    3'b100: ALUctrl = `ALU_OPCODE_XOR;  //XOR
                    3'b101: ALUctrl = {3'b100, funct7[5]}; //srl: Shift Right Logical, sra: Shift Right Arith*
                    3'b110: ALUctrl = `ALU_OPCODE_OR;  // OR
                    3'b111: ALUctrl = `ALU_OPCODE_AND;   // AND
                    default: ALUctrl = 0;
                endcase    
                    RegWrite = 1;
                    ALUSrc = 0;
                    ImmSrc = 3'bXXX;
                    Branch = 0;
                    MemWrite = 0;
                    ResultSrc= 0;
            end

        // I-type
            7'b0010011: begin   
                case(funct3)
                    3'b000: ALUctrl = `ALU_OPCODE_ADD;   // addi: ADD Immediate 
                    3'b001: ALUctrl = `ALU_OPCODE_SLL;   //slli: Shift Left Logical Imm
                    3'b010: ALUctrl = `ALU_OPCODE_SLT;   //slti: Set Less Than Imm
                    //3'b011: ALUctrl = // TODO            //sltiu: Set Less Than Imm (U)
                    3'b100: ALUctrl = `ALU_OPCODE_XOR;   //xori: XOR Immediate
                    3'b101: ALUctrl = {3'b100, funct7[5]}; //srli: Shift Right Logical Imm, srai: Shift Right Arith Imm
                    3'b110: ALUctrl = `ALU_OPCODE_OR;    // ori: OR Immediate
                    3'b111: ALUctrl = `ALU_OPCODE_AND;   // andi: AND Immediate 
                    default ALUctrl = 0;
                endcase
                        RegWrite = 1;
                        ALUSrc = 1;
                        ImmSrc = 3'b000;
                        Branch = 0;
                        MemWrite = 0;
                        ResultSrc= 0;
            end


        // I-type
            7'b0000011: begin   
                        RegWrite = 1;
                        ALUctrl = 4'b0000;
                        ALUSrc = 1;
                        ImmSrc = 3'b000;
                        Branch = 0;
                        MemWrite = 0;
                        ResultSrc= 1;
                    end
            

        // S-type
            7'b0100011: begin   
                        RegWrite = 0;
                        ALUctrl = 4'b0000;
                        ALUSrc = 1;
                        ImmSrc = 3'b001;
                        Branch = 0;
                        MemWrite = 1;
                        ResultSrc= 0;
                    end

        // B-type
            7'b1100011: begin   
                case(funct3)
                    // neg jump defined elsewhere
                    3'b000: ALUctrl = `ALU_OPCODE_SUB;    //beq: Branch ==
                    3'b001: ALUctrl = `ALU_OPCODE_SUB;    //bne: Branch !=                 
                    3'b100: ALUctrl = `ALU_OPCODE_SLT;    //blt: Branch <
                    3'b101: ALUctrl = `ALU_OPCODE_SLT;    //bge: Branch ≥
                    3'b110: ALUctrl = `ALU_OPCODE_SLT;    //bltu: Branch < (U)
                    3'b111: ALUctrl = `ALU_OPCODE_SLT;    //bgeu: Branch ≥ (U)
                    default ALUctrl = 0;
                endcase
                        RegWrite = 0;
                        ALUSrc =  0;
                        ImmSrc = 3'b010;
                        Branch = 1;
                        MemWrite = 0;
                        ResultSrc= 0;

            end

        // J-type
            7'b1101111: begin   //jal: Jump And Link
                RegWrite = 1;
                ALUctrl = 4'b0000;
                ALUSrc =  1;
                ImmSrc = 3'b100;
                Branch = 1;
                MemWrite = 0;
                ResultSrc= 2'b10;
            end

        // I-type    
            7'b1100111: begin    //jalr: Jump And Link Reg
                RegWrite = 1;
                ALUctrl = 4'b0000;
                ALUSrc =  1;
                ImmSrc = 3'b000;
                Branch = 1;
                MemWrite = 0;
                ResultSrc= 2'b10;
            end

        // U-type
            7'b0110111: begin    //lui: Load Upper Imm
                RegWrite = 1;  
                ALUctrl = `ALU_OPCODE_LUI;    
                ALUSrc = 1;       
                ImmSrc = 3'b011;
                Branch = 0;  
                MemWrite = 0;
                ResultSrc = 0;   
            end

        // U-type
            7'b0010111: begin    //auipc: Add Upper Imm to PC 
                // TODO
                RegWrite = 1;  
                ALUctrl = `ALU_OPCODE_LUI;    
                ALUSrc = 1;       
                ImmSrc = 3'b011;
                Branch = 0;  
                MemWrite = 0;
                ResultSrc = 0;   
            end

        // I-type
            7'b1110011: begin  
                case (funct7)
                    7'b0000000: begin //ecall: Environment Call 
                        // TODO
                    end

                    7'b0000001: begin //ebreak: Environment Break
                        // TODO
                    end
                    
                    default: begin
                        // TODO
                        RegWrite = 0;
                        ALUctrl = 4'b0000;
                        ALUSrc = 0;
                        ImmSrc = 3'b000;
                        Branch = 0;
                        MemWrite = 0;
                        ResultSrc= 0;
                    end
                endcase
            end

            default: begin
                RegWrite = 0;
                ALUctrl = 4'b0000;
                ALUSrc = 0;
                ImmSrc = 3'b000;
                Branch = 0;
                MemWrite = 0;
                ResultSrc= 0;
            end
        endcase

        //Unconditonal Jump operations
        if (op == 7'b1101111 || op == 7'b1100111) Jump = 1;
        else Jump = 0;

        //Check if bne, bge or bgeu
        if (funct3 == 3'b001 || funct3 == 3'b101 || funct3 == 3'b111) Branch_neg = 1;
        else Branch_neg = 0;

        //Assign PCSrc
        PCSrc = Jump || (Branch && (Branch_neg ? !Zero : Zero));

        //Select PC target for branch opperations
        if (op == 7'b1100111) PcOp = 1;
        else PcOp = 0;

    end 
endmodule 
