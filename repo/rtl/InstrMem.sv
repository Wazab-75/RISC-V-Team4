module InstrMem (
    input logic  [31:0]   addr;
    output logic [31:0]   instr;
);

    reg [31:0] memory [0:1023];  // array of instruction memory

    initial begin 
        $readmemh("Instructions.hex", memory);  // load instruction from file
    end

    always @(*) begin    // execute whenever input addr changes
        instr = memory[addr[11:2]];  
    end 
endmodule