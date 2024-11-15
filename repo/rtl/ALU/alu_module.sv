module alu_module #(
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
            3'b000: begin
                ALUout = ALUop1 + ALUop2; // ADD operation
                EQ = 0; 
            end

            3'b001: begin   // BNE
                if (ALUop1 == ALUop2) begin
                    ALUout = 0; 
                    EQ = 1;     // Set EQ to 1 when ALUop1 == ALUop2
                end else begin
                    ALUout = 1; 
                    EQ = 0;     // Set EQ to 0 when ALUop1 != ALUop2
                end
            end

            default: begin
                ALUout = 0; 
                EQ = 0;     
            end
        endcase
    end

endmodule
