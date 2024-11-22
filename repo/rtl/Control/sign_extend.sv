module sign_extend (
    input logic [1:0]  ImmSrc,
    input       [31:20] Imm_up,
    input       [11:7]  Imm_down,
    output      [31:0] ImmExt
);

always_comb

    case (ImmSrc)
        2'b00: ImmExt = {{20{Imm_up[31]}}, Imm_up[31:20]};             // I-type
        2'b10: ImmExt = {{20{Imm_up[31]}}, Imm_down[7], Imm_up[30:25], Imm_down[11:8], 1'b0}; // B-type
        default: ImmExt = 32'b0;
    endcase

endmodule


