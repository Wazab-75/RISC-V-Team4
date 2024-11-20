module ControlUnit (
    input logic  [31:0] instr,     
    input logic         EQ,
    output logic        RegWrite,   // controls signal to write to regfile
    output logic [2:0]  ALUctrl,    // ALU control signal
    output logic        ALUsrc,     // selects ALU source (register or immediate)
    output logic [1:0]  Immsrc,     // type of immediate extension
    output logic        PCsrc       // if PC branches
);

    logic [6:0] opcode;
    logic [2:0] funct3;
    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];

    // control logic based on opcode
    always_comb begin
        // default values
        RegWrite = 0;
        ALUctrl = 3'b000;
        ALUsrc = 0;
        PCsrc = 0;
        Immsrc = 2'b00;

        case (opcode) 
            7'b0010011: begin   // I-type
                if (funct3 == 3'b000) begin  //ADDI
                    RegWrite = 1;       // write to regfile
                    ALUctrl = 3'b000;   // ALU performs addition
                    ALUsrc = 1;         // use immediate as second operand
                    Immsrc = 2'b00;     // I-type immediate
                    PCsrc = 0;          // no branching
                end 
            end

            7'b1100011: begin   // B-type
                if (funct3 == 3'b001) begin   //BNE
                    RegWrite = 0;       // no register write
                    ALUctrl = 3'b001;   // ALU performs subtraction
                    ALUsrc = 0;         // use registers as operands
                    Immsrc = 2'b10;         // B-type immediate
                    PCsrc = ~EQ;        // branch if not equal
                end 
            end

            default: begin
                RegWrite = 0;
                ALUctrl = 3'b000;   
                ALUsrc = 0;
                PCsrc = 0;
                Immsrc = 2'b00;
            end
        endcase
    end 
endmodule 

