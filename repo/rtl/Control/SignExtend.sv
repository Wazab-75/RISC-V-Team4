module SignExtend (
    input logic [1:0]  ImmSrc,
    input       [31:7]  instr,
    output      [31:0] imm_out
);

always_comb

    case (ImmSrc)
        2'b00: imm_out = {{20{instr[31]}}, instr[31:20]};             // I-type
        2'b10: imm_out = {{20{instr[31]}}, instr[31], instr[7], instr[30:25],instr[11:8], 1'b0}; // B-type
        default: imm_out = 32'b0;
    endcase

endmodule


