module inst_mem #(
    parameter   ADDRESS_WIDTH = 32,
                DATA_WIDTH = 8,
                MEM_START = 32'hBFC00000,
                MEM_END = 32'hBFC00FFF
)(
    input  logic [ADDRESS_WIDTH-1:0]   addr,
    output logic [4*ADDRESS_WIDTH-1:0]   dout 
);

// rom array initialization
logic [DATA_WIDTH-1:0] rom_array [MEM_END : MEM_START];

// Align the address to 16 bytes
logic [ADDRESS_WIDTH-1:0] aligned_addr;
assign aligned_addr = addr & 32'hFFFFFFF0;

initial begin
    $display ("Loading instructions....");
    $readmemh("program.hex", rom_array);
    $display ("Finished Loading instructions!");
end

always_comb begin
    dout = {
        rom_array[(aligned_addr + 15) - MEM_START],
        rom_array[(aligned_addr + 14) - MEM_START],
        rom_array[(aligned_addr + 13) - MEM_START],
        rom_array[(aligned_addr + 12) - MEM_START],
        rom_array[(aligned_addr + 11) - MEM_START],
        rom_array[(aligned_addr + 10) - MEM_START],
        rom_array[(aligned_addr + 9) - MEM_START],
        rom_array[(aligned_addr + 8) - MEM_START],
        rom_array[(aligned_addr + 7) - MEM_START],
        rom_array[(aligned_addr + 6) - MEM_START],
        rom_array[(aligned_addr + 5) - MEM_START],
        rom_array[(aligned_addr + 4) - MEM_START],
        rom_array[(aligned_addr + 3) - MEM_START],
        rom_array[(aligned_addr + 2) - MEM_START],
        rom_array[(aligned_addr + 1) - MEM_START],
        rom_array[(aligned_addr + 0) - MEM_START]};
end

endmodule
