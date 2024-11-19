module SignExtend (
    input logic   ImmSrc,
    input [31:7]  instr,
    output [31:0] imm_out
);

always_comb() begin
    case (ImmSrc) 
        1'b0: imm_out = {{20{instr[31]}},instr[31:20]};             // I-type
        1'b1: imm_out = {{20{instr[31]}},instr[31:25],instr[11:7]};  // S-type
        default: imm_out = 32'b0;
    endcase
end 

endmodule

