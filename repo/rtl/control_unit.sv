`include "def.sv"

module control_unit (   
    input logic  [6:0]  op,  
    input logic  [2:0]  funct3,
    input logic         funct7_5,  

    input logic         EQ,

    output logic        RegWrite,   
    output logic [3:0]  ALUctrl,    
    output logic        ALUSrc,     
    output logic [1:0]  ImmSrc,     
    output logic        PCSrc,       
    output logic        MemWrite,
    output logic        ResultSrc
);

    // control logic based on opcode
    always_comb begin
        // default values
        RegWrite = 0;
        ALUctrl = 4'b0000;
        ALUSrc = 0;
        PCSrc = 0;
        ImmSrc = 2'b00;
        MemWrite = 0;
        ResultSrc= 0;

        case (op) 
            7'b0010011: begin   // I-type
                if (funct3 == 3'b000) begin  //ADDI
                    RegWrite = 1;               
                    ALUctrl = `ALU_OPCODE_ADD;   
                    ALUSrc = 1;             
                end 
            end

            7'b1100011: begin   // B-type
                if (funct3 == 3'b001) begin   //BNE   
                    ALUctrl = `ALU_OPCODE_SUB;           
                    ImmSrc = 2'b10;       
                    PCSrc = ~EQ;       
                end 
            end

            7'b0110011: begin
                case(funct3)

                    3'b000: begin
                        RegWrite = 1;

                        if(funct7_5 == 0)   // ADD
                            ALUctrl = `ALU_OPCODE_ADD;
                        else if(funct7_5 == 1)   // SUB
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
                        ImmSrc = 2'b00;
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
                ImmSrc = 2'b00;
                PCSrc = 0;
                MemWrite = 0;
                ResultSrc= 0;
            end
        endcase
    end 
endmodule 
