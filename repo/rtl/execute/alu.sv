`include "def.sv"

module alu #(
    parameter DATA_WIDTH = 32
)(
    input  logic [DATA_WIDTH-1:0]   ALUop1,
    input  logic [DATA_WIDTH-1:0]   ALUop2,
    input  logic [3:0]              ALUctrl,

    output logic [DATA_WIDTH-1:0]   ALUout,
    output logic                    EQ
);

    // ALU operations
    always_comb begin
        
        case (ALUctrl)
            `ALU_OPCODE_ADD:     ALUout = ALUop1 + ALUop2;              // ADD operation

            `ALU_OPCODE_SUB:     ALUout = ALUop1 - ALUop2;              // SUB operation

            `ALU_OPCODE_AND:     ALUout = ALUop1 & ALUop2;              // AND operation

            `ALU_OPCODE_OR:      ALUout = ALUop1 | ALUop2;               // OR operation

            `ALU_OPCODE_XOR:     ALUout = ALUop1 ^ ALUop2;              // XOR operation

            `ALU_OPCODE_SLT:     ALUout = (ALUop1 < ALUop2) ? 1 : 0;    // set less than
            
            // shift op:

            `ALU_OPCODE_LUI:     ALUout = ALUop2 << 12;

            `ALU_OPCODE_SLL:     ALUout = ALUop1 << ALUop2;

            `ALU_OPCODE_SRL:     ALUout = ALUop1 >> ALUop2;

            `ALU_OPCODE_SRA:     ALUout = ALUop1 >>> ALUop2;

            default:begin 
                ALUout = 0;
                EQ = 0;
            end

        endcase

        EQ = (ALUout == 0'b0) ? 1 : 0;
    end

endmodule
