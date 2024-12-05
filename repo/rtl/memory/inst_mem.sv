module inst_mem (
    input logic  [31:0]   addr,  
    output logic [31:0]   dout 
);

    // ROM array: reduced to 2^8 (256 locations), each 8 bits wide
    logic [7:0] rom_array [32'hBFC00FFF : 32'hBFC00000];  

    initial begin
        $display("Loading ROM.");
        $readmemh("program.hex", rom_array);  // Load instructions into ROM
    end;

    always_comb begin
        // Concatenate 4 consecutive 8-bit blocks to form a 32-bit instruction
        dout = {rom_array[(addr + 3)- 32'hBFC00000],rom_array[(addr + 2) - 32'hBFC00000],rom_array[(addr+ 1) - 32'hBFC00000],rom_array[(addr) - 32'hBFC00000]};
    end

endmodule


