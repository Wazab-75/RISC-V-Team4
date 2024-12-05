module sign_extend (
    input logic [2:0]  ImmSrc,
    input       [31:7] Imm_in,
    output      [31:0] ImmExt
);

always_comb

    case (ImmSrc)
        3'b000: ImmExt = {{20{Imm_in[31]}}, Imm_in[31:20]};             // I-type
        3'b001: ImmExt = {{20{Imm_in[31]}}, Imm_in[31:25], Imm_in[11:7]};   // S-type  
        3'b010: ImmExt = {{20{Imm_in[31]}}, Imm_in[7], Imm_in[30:25], Imm_in[11:8], 1'b0};   // B-type  
        3'b011: ImmExt = {Imm_in[31:12], 12'b0};   // U-type  
        3'b100: ImmExt = {{12{Imm_in[31]}}, Imm_in[19:12], Imm_in[20], Imm_in[30:21], 1'b0};   // J-type  
        default: ImmExt = 32'b0;
        // R-type has no immediate

    endcase

endmodule


