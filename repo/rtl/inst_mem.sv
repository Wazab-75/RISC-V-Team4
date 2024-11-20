module InstrMem (
    input logic  [31:0]   addr,
    output logic [31:0]   instr
);

    // set datawidth = 8 as 32 bit instruction is split into 4 parts, each part with width = 8
    // theoretically we have 4*(2**32) address, but it's too large so we reduce ROM array size to 2**8 - 1, enough for lab4
    logic [7:0] rom_array [2**8-1:0];  // array of instruction memory 

initial begin
    $display("Loading rom.");
    $readmemh("Instructions.hex", rom_array);  // load instruction from file
end;

always_comb    // asynchronous: execute whenever input addr changes
    // instruction = 4 blocks of memory, with incremented address
    // we use last 8 bits of address, corresponding to the size of datawidths
    instr = {rom_array[addr[7:0]+3], rom_array[addr[7:0]+2], rom_array[addr[7:0]+1], rom_array[addr[7:0]]};
    
endmodule

