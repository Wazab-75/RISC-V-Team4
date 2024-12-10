`ifndef DEF_SV
`define DEF_SV

`define ALU_OPCODE_ADD              4'b0000  // Addition
`define ALU_OPCODE_SUB              4'b0001  // Subtraction
`define ALU_OPCODE_AND              4'b0010  // Logical AND
`define ALU_OPCODE_OR               4'b0011  // Logical OR
`define ALU_OPCODE_XOR              4'b0100  // Logical XOR
`define ALU_OPCODE_SLT              4'b0101  // Set Less Than

`define ALU_OPCODE_LUI              4'b0110  // Load Upper Immediate
`define ALU_OPCODE_SLL              4'b0111  // Shift Left Logical
`define ALU_OPCODE_SRL              4'b1000  // Shift Right Logical
`define ALU_OPCODE_SRA              4'b1001  // Shift Right Arithmetic

`define ALU_OPCODE_BLTU             4'b1001  // Branch if Less Than Unsigned  

`define ALU_OPCODE_MUL       4'b1010  // Multiply
`define ALU_OPCODE_MULH      4'b1011  // Multiply High (Signed x Signed)
// `define ALU_OPCODE_MULHSU    4'b1100  // Multiply High (Signed x Unsigned)
// `define ALU_OPCODE_MULHU     4'b1101  // Multiply High (Unsigned x Unsigned)
`define ALU_OPCODE_DIV       4'b1110  // Divide (Signed)
// `define ALU_OPCODE_DIVU      4'b1111  // Divide (Unsigned)
`define ALU_OPCODE_REM       4'b0001  // Remainder (Signed)
// `define ALU_OPCODE_REMU      4'b0010  // Remainder (Unsigned)

`endif
