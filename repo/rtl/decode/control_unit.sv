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
            7'b1101111: begin   // J-type
                // jal instruction
                RegWrite = 1;               
                ALUctrl = `ALU_OPCODE_ADD;    // ALU adds PC + imm to compute the jump target
                ALUSrc = 1;     
                ImmSrc = 3'b100;
                PCSrc = 1;
                MemWrite = 0;
                ResultSrc = 0;         
            end

            7'b0010011: begin   // I-type
                // addi instruction
                if (funct3 == 3'b000) begin 
                    RegWrite = 1;               
                    ALUctrl = `ALU_OPCODE_ADD;   
                    ALUSrc = 1; 
                    ImmSrc = 3'b000;
                    PCSrc = 0;
                    MemWrite = 0;
                    ResultSrc = 0;              
                end 
            end

            7'b0100011: begin   // S-type
                // sb instruction
                if (funct3 == 3'b000) begin 
                    RegWrite = 0;               
                    ALUctrl = `ALU_OPCODE_ADD;   
                    ALUSrc = 1; 
                    ImmSrc = 3'b001;
                    PCSrc = 0;
                    MemWrite = 1;
                    ResultSrc = 0;           
                end 
            end

            7'b1100011: begin   // B-type
                // bne instruction
                if (funct3 == 3'b001) begin 
                    RegWrite = 0;  
                    ALUctrl = `ALU_OPCODE_SUB;    
                    ALUSrc = 0;       
                    ImmSrc = 3'b010;       
                    PCSrc = ~Zero; 
                    MemWrite = 0;
                    ResultSrc = 0;    
                end 
            end

            7'b0110011: begin   // R-type
                // add instruction
                if (funct3 == 3'b000 && funct7 == 0) begin 
                    RegWrite = 1;  
                    ALUctrl = `ALU_OPCODE_ADD;    
                    ALUSrc = 0;       
                    ImmSrc = 3'bXXX;       
                    PCSrc = 0;  
                    MemWrite = 0;
                    ResultSrc = 0;   
                end 
            end

            7'b0000011: begin   // I-type
                // lbu instruction
                if (funct3 == 3'h04) begin 
                    RegWrite = 1;  
                    ALUctrl = `ALU_OPCODE_ADD;    
                    ALUSrc = 1;       
                    ImmSrc = 3'b000;       
                    PCSrc = 0;  
                    MemWrite = 0;
                    ResultSrc = 0;   
                end 
            end

            7'b1100111: begin   // I-type
                // jalr instruction
                RegWrite = 1;               
                ALUctrl = `ALU_OPCODE_ADD;  
                ALUSrc = 1;     
                ImmSrc = 3'b000;
                PCSrc = 1;
                MemWrite = 0;
                ResultSrc = 0;         
            end

            7'b0010111: begin   // U-type
                // auipc instruction
                RegWrite = 1;  
                ALUctrl = `ALU_OPCODE_ADD;    
                ALUSrc = 1;       
                ImmSrc = 3'b011;
                PCSrc = 0;  
                MemWrite = 0;
                ResultSrc = 0;   
            end

            7'b0110011: begin
                case(funct3)
                    3'b000: begin
                        RegWrite = 1;

                        if(funct7 == 0)   // ADD
                            ALUctrl = `ALU_OPCODE_ADD;
                        else if(funct7 == 1)   // SUB
                            ALUctrl = `ALU_OPCODE_SUB;
                    end

                    3'b111: begin   // AND
                        RegWrite = 1;
                        ALUctrl = `ALU_OPCODE_AND;
                    end

                    3'b110: begin   // OR
                        RegWrite = 1;
                        ALUctrl = `ALU_OPCODE_OR;
                    end

                    3'b101: begin   // SLT
                        RegWrite = 1;
                        ALUctrl = `ALU_OPCODE_SLT;
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
