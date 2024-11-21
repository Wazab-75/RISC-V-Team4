module sign_extend (
    input logic [1:0]  ImmSrc,
    input       [31:7] dout,
    output      [31:0] ImmOp
);

always_comb

    case (ImmSrc)
        2'b00: ImmOp = {{20{dout[31]}}, dout[31:20]};             // I-type
        2'b10: ImmOp = {{20{dout[31]}}, dout[31], dout[7], dout[30:25], dout[11:8], 1'b0}; // B-type
        default: ImmOp = 32'b0;
    endcase

endmodule


