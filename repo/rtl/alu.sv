`include "def.sv"

module alu #(
    parameter DATA_WIDTH = 32
)(
    input  logic [DATA_WIDTH-1:0]   ALUop1,
    input  logic [DATA_WIDTH-1:0]   ALUop2,
    input  logic [2:0]              ALUctrl,

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

            `ALU_OPCODE_SLT:     ALUout = (ALUop1 < ALUop2) ? 1 : 0;    // set less than

            default:    ALUout = 0; 
        endcase

        EQ = (ALUout == 0'b0) ? 1 : 0;
    end

endmodule
