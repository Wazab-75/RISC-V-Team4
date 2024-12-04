`include "def.sv"

module alu #(
    parameter DATA_WIDTH = 32
)(
    input  logic [DATA_WIDTH-1:0]   ALUop1,
    input  logic [DATA_WIDTH-1:0]   ALUop2,
    input  logic [3:0]              ALUctrl,

    output logic [DATA_WIDTH-1:0]   ALUout,
    output logic                    branch_l
);

    always_comb begin

        case (ALUctrl)
            `ALU_OPCODE_ADD:     ALUout = ALUop1 + ALUop2;

            `ALU_OPCODE_SUB:     ALUout = ALUop1 - ALUop2;

            `ALU_OPCODE_AND:     ALUout = ALUop1 & ALUop2;

            `ALU_OPCODE_OR:      ALUout = ALUop1 | ALUop2;

            `ALU_OPCODE_XOR:     ALUout = ALUop1 ^ ALUop2;

            `ALU_OPCODE_SLT:     ALUout = ($signed(ALUop1) < $signed(ALUop2)) ? 1 : 0;

            // Shift operations:
            `ALU_OPCODE_LUI:     ALUout = ALUop2 << 12;

            `ALU_OPCODE_SLL:     ALUout = ALUop1 << ALUop2;

            `ALU_OPCODE_SRL:     ALUout = ALUop1 >> ALUop2;

            `ALU_OPCODE_SRA:     ALUout = ALUop1 >>> ALUop2;

            // Branch instructions:

            `ALU_OPCODE_BLTU: branch_l = (ALUop1 < ALUop2);

            default: begin
                ALUout = 0;
                branch_l = 0;
            end
        endcase

        branch_l = (ALUout == 0) ? 1 : 0;
    end

endmodule
