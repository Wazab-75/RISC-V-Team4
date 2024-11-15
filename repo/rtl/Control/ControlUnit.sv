module ControlUnit (
    input logic  [6:0]  opcode,        // opcode from instruction
    output logic        RegWrite,   // controls signal to write to regfile
    output logic [2:0]  ALUctrl,    // ALU control signal
    output logic        ALUsrc,     // selects ALU source (register or immediate)
    output logic        ImmSrc,     // type of immediate extension
    output logic        PCsrc       // if PC branches
);

    // opcode values corresponding to each instruction
    localparam ADDI     = 7'b0010011;
    localparam BNE      = 7'b1100011;

    // control logic based on opcode
    always_comb begin
        // default values
        RegWrite = 0;
        ALUctrl = 3'b000;
        ALUsrc = 0;
        PCsrc = 0;
        Immsrc = 0;

        case (opcode)
            ADDI: begin
                RegWrite = 1;       // write to regfile
                ALUctrl = 3'b000;   // ALU performs addition
                ALUsrc = 1;         // use immediate as second operand
                ImmSrc = 0; 
                PCsrc = 0;          // no branching
            end

            BNE: begin
                RegWrite = 0;       // no register write
                ALUctrl = 3'b001;      // ALU performs subtraction
                ALUsrc = 0;         // use registers as operands
                ImmSrc = 1;
                PCsrc = 1;          // branch if not equal
            end

            default: begin
                RegWrite = 0;
                ALUctrl = 3'b000;   
                ALUsrc = 0;
                PCsrc = 0;
            end
        endcase
    end 
endmodule 