`include "def.sv"
`include "./decode/alu_decoder.sv"
`include "./decode/main_decoder.sv"

module control_unit (   
    input logic [31:0]  Instr,

    input logic         Zero,

    output logic        RegWrite,   
    output logic [3:0]  ALUctrl,    
    output logic        ALUSrc,     
    output logic [2:0]  ImmSrc,     
    output logic        PCSrc,       
    output logic        MemWrite,
    output logic        ResultSrc
);
logic  [6:0]  op;
logic  [2:0]  funct3;
logic  [6:0]  funct7;

assign op = Instr[6:0];
assign funct3 = Instr[14:12];
assign funct7 = Instr[31:25];

    always_comb begin
        // default values
        RegWrite = 0;
        ALUctrl = 4'b0000;
        ALUSrc = 0;
        ImmSrc = 3'b000;
        PCSrc = 0;
        MemWrite = 0;
        ResultSrc= 0;

        case (op) 

        // R-type
            7'b0110011: begin
                case(funct3)
                    3'b000: begin
                        if (funct7 == 0)   // ADD
                            ALUctrl = `ALU_OPCODE_ADD;
                        else if (funct7 == 7'b0100000)   // SUB
                            ALUctrl = `ALU_OPCODE_SUB;
                    end

                    3'b001: begin    //sll: Shift Left Logical
                        ALUctrl = `ALU_OPCODE_SLL;
                    end

                    3'b010: begin   //slt: Set Less Than
                        ALUctrl = `ALU_OPCODE_SLT;
                    end
                    
                    3'b011: begin   //sltu: Set Less Than (U)
                        ALUctrl = // TODO
                    end

                    3'b100: begin   //XOR
                        ALUctrl = `ALU_OPCODE_XOR;
                    end

                    3'b101: begin   
                        if (funct7 == 0)   //srl: Shift Right Logical
                            ALUctrl = `ALU_OPCODE_SRL;
                        else if (funct7 == 7'b0100000)   //sra: Shift Right Arith*
                            ALUctrl = `ALU_OPCODE_SRA;
                    end

                    3'b110: begin   // OR
                        ALUctrl = `ALU_OPCODE_OR;
                    end

                    3'b111: begin   // AND
                        ALUctrl = `ALU_OPCODE_AND;
                    end

                    default: begin
                        RegWrite = 1;
                        ALUctrl = 4'b0000;
                        ALUSrc = 0;
                        ImmSrc = 3'bXXX;
                        PCSrc = 0;
                        MemWrite = 0;
                        ResultSrc= 0;
                    end
                endcase


        // I-type
            7'b0010011: begin   
                case(funct3)
                    3'b000: begin     // addi: ADD Immediate 
                        ALUctrl = `ALU_OPCODE_ADD;           
                    end 

                    3'b001: begin    //slli: Shift Left Logical Imm
                        ALUctrl = `ALU_OPCODE_SLL;
                    end

                    3'b010: begin   //slti: Set Less Than Imm
                        ALUctrl = `ALU_OPCODE_SLT;
                    end
                    
                    3'b011: begin   //sltiu: Set Less Than Imm (U)
                        ALUctrl = // TODO
                    end

                    3'b100: begin   //xori: XOR Immediate
                        ALUctrl = `ALU_OPCODE_XOR;
                    end

                    3'b101: begin   
                        if (funct7 == 0)   //srli: Shift Right Logical Imm 
                            ALUctrl = `ALU_OPCODE_SRL;
                        else if (funct7 == 7'b0100000)   //srai: Shift Right Arith Imm
                            ALUctrl = `ALU_OPCODE_SRA;
                    end

                    3'b110: begin   // ori: OR Immediate
                        ALUctrl = `ALU_OPCODE_OR;
                    end

                    3'b111: begin   // andi: AND Immediate 
                        ALUctrl = `ALU_OPCODE_AND;
                    end

                    default: begin
                        RegWrite = 1;
                        ALUctrl = 4'b0000;
                        ALUSrc = 1;
                        ImmSrc = 3'b000;
                        PCSrc = 0;
                        MemWrite = 0;
                        ResultSrc= 0;
                    end
                endcase
            end


        // I-type
            7'b0000011: begin   
                case(funct3)
                    3'b000: begin     //lb: Load Byte 
                        // TODO
                    end

                    3'b001: begin    //lh: Load Half
                        // TODO
                    end

                    3'b010: begin   //lw: Load Word
                        // TODO
                    end
                    
                    3'b100: begin   //lbu: Load Byte (U)
                        // TODO
                    end

                    3'b101: begin   //lhu: Load Half (U)
                        // TODO
                    end

                    default: begin
                        RegWrite = 1;
                        ALUctrl = 4'b0000;
                        ALUSrc = 1;
                        ImmSrc = 3'b000;
                        PCSrc = 0;
                        MemWrite = 0;
                        ResultSrc= 1;
                    end
                endcase


        // S-type
            7'b0100011: begin   
                case(funct3)
                    3'b000: begin     //sb: Store Byte 
                        // TODO
                    end

                    3'b001: begin    //sh: Store Half
                        // TODO
                    end

                    3'b010: begin   //sw: Store Word
                        // TODO
                    end

                    default: begin
                        RegWrite = 0;
                        ALUctrl = 4'b0000;
                        ALUSrc = 1;
                        ImmSrc = 3'b001;
                        PCSrc = 0;
                        MemWrite = 1;
                        ResultSrc= 0;
                    end
                endcase


        // B-type
            7'b1100011: begin   
                case(funct3)
                    3'b000: begin     //beq: Branch ==
                        // TODO
                    end

                    3'b001: begin    //bne: Branch !=
                        // TODO
                    end
                    
                    3'b100: begin   //blt: Branch <
                        // TODO
                    end

                    3'b101: begin   //bge: Branch ≥
                        // TODO
                    end

                    3'b110: begin   //bltu: Branch < (U)
                        // TODO
                    end

                    3'b111: begin   //bgeu: Branch ≥ (U) 
                        // TODO
                    end

                    default: begin
                        RegWrite = 0;
                        ALUctrl = 4'b0000;
                        ALUSrc = = 0;
                        ImmSrc = 3'b010;
                        PCSrc = 0;
                        MemWrite = 0;
                        ResultSrc= 0;
                    end
                endcase


        // J-type
            7'b1101111: begin   //jal: Jump And Link
                // TODO
            end

        // I-type    
            7'b1100111: begin    //jalr: Jump And Link Reg
                // TODO
            end

        // U-type
            7'b0110111: begin    //lui: Load Upper Imm
                // TODO
            end

        // U-type
            7'b0010111: begin    //auipc: Add Upper Imm to PC 
                // TODO
                RegWrite = 1;  
                ALUctrl = `ALU_OPCODE_ADD;    
                ALUSrc = 1;       
                ImmSrc = 3'b011;
                PCSrc = 0;  
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
                        PCSrc = 0;
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
                PCSrc = 0;
                MemWrite = 0;
                ResultSrc= 0;
            end
        endcase
    end 
endmodule 
