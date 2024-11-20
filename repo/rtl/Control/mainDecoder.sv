module mainDecode (
    input  logic [6:0]  opcode,
    output logic        PCSrc,
    output logic        ResultSrc,
    output logic        MemWrite,
    output logic        ALUSrc,
    output logic [1:0]  ImmSrc,
    output logic        RegWrite,
    output logic [1:0]  ALUOp,
);

    always_comb
    begin
        // default values
        PCsrc = 0;
        ResultSrc = 0;
        MemWrite = 0;
        ALUsrc = 0;
        Immsrc = 2'b00;
        RegWrite = 0;
        ALUOp = 2'b00; 

        case opcode == 7'b0010011: // ADDI
                ADDI: begin
                RegWrite = 1;       // write to regfile
                ALUctrl = 3'b000;   // ALU performs addition
                ALUsrc = 1;         // use immediate as second operand
                ImmSrc = 0; 
                PCsrc = 0;          // no branching
            end