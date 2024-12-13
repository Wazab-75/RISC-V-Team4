module alu#(
    parameter   DATA_WIDTH = 32
)(
    input  logic [DATA_WIDTH-1:0]   ALUop1,
    input  logic [DATA_WIDTH-1:0]   ALUop2,
    input  logic [2:0]              ALUctrl,
    output logic [DATA_WIDTH-1:0]   ALUout,
    output logic                    branch_l
);


always_comb begin
    case(ALUctrl)
        //ADD
        3'b000:     begin 
                    ALUout = ALUop1 + ALUop2; 
                    branch_l = 0;
                    end 
        // SUB
        3'b001:     begin 
                    ALUout = ALUop1 - ALUop2; 
                    branch_l = (ALUout == 32'b0)? 1:0;
                    end
        // Less Than 
        3'b010:     begin
                    ALUout = ALUop1 < ALUop2 ? 1 : 0;
                    branch_l = ALUout[0];
                    end 
        //TODO Clash with sub ALUctrl
        /*3'b011:     begin
                    ALUout = ALUop1 < ALUop2 ? 1 : 0;
                    branch_l = ALUout[0];
                    end 
        */
        // 
        3'b100:     begin
                    ALUout = ALUop1 ^ ALUop2; 
                    branch_l = 0; 
                    end
        3'b101:     begin
                    ALUout = ALUop1 >> ALUop2;
                    branch_l = 0;
                    end 
        3'b011:     begin
                    ALUout = ALUop1 << ALUop2;
                    branch_l = 0;
                    end
        3'b110:     begin
                    ALUout = ALUop1 | ALUop2;
                    branch_l = 0;
                    end
        3'b111:     begin
                    ALUout = ALUop1 & ALUop2;
                    branch_l = 0;
                    end
        default:    ALUout = {DATA_WIDTH{1'b0}};
    endcase
end

endmodule
