module sign_extend #(
    parameter   DATA_WIDTH = 32
)(
    input  logic [31:7]            Imm,
    input  logic [2:0]             ImmSrc,
    output logic [DATA_WIDTH-1:0]  ImmExt        
);
    always_comb begin
    case (ImmSrc)  
        // I-type
        3'b001: ImmExt = {{20{Imm[31]}},Imm[31:20]};      
        // S-type       
        3'b010: ImmExt = {{20{Imm[31]}},Imm[31:25],Imm[11:7]};  
        //B-type
        3'b011: ImmExt = {{20{Imm[31]}},Imm[7],Imm[30:25],Imm[11:8],1'b0};
        // U-type
        3'b100: ImmExt = {Imm[31:12],12'b0};
        // J-type
        3'b101: ImmExt = {{12{Imm[31]}},Imm[19:12],Imm[20],Imm[30:21],1'b0};
        // R-type  
        default: ImmExt = 32'b0; 
    endcase
    end 
endmodule
