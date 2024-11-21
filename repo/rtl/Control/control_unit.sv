module control_unit (
    input logic  [14:12] funct3,   
    input logic  [6:0]   op,  
    input logic          funct7_5,    
    input logic          EQ,
    output logic         RegWrite,   // controls signal to write to regfile
    output logic [2:0]   ALUctrl,    // ALU control signal
    output logic         ALUSrc,     // selects ALU source (register or immediate)
    output logic [1:0]   ImmSrc,     // type of immediate extension
    output logic         PCSrc,       // if PC branches    
    output logic         MemWrite,
    output logic         ResultSrc
);



    // control logic based on opcode
    always_comb begin
        // default values
        RegWrite = 0;
        ALUctrl = 3'b000;
        ALUSrc = 0;
        PCSrc = 0;
        ImmSrc = 2'b00;
        MemWrite = 0;
        ResultSrc= 0;

        case (op) 
            7'b0010011: begin   // I-type
                RegWrite = 1;       // write to regfile
                ALUSrc = 1;         // use immediate as second operand
                ImmSrc = 2'b00;     // I-type immediate
                PCSrc = 0;          // no branching
                MemWrite = 0;
                ResultSrc = 0;
                ALUctrl = funct3;
            end

            7'b1100011: begin   // B-type
                RegWrite = 0;       // no register write
                ALUSrc = 0;         // use registers as operands
                ImmSrc = 2'b10;         // B-type immediate
                PCSrc = ~EQ;        // branch if not equal
                ResultSrc= 1;
                MemWrite = 0;
                ALUctrl = funct3;
            end

            default: begin
                RegWrite = 0;
                ALUctrl = 3'b000;   
                ALUSrc = 0;
                PCSrc = 0;
                ImmSrc = 2'b00;
                MemWrite = 0;
                ResultSrc= 0;
            end
        endcase
    end 
endmodule 

