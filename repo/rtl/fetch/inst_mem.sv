module inst_mem #(
    parameter   ADDRESS_WIDTH = 32,
                DATA_WIDTH = 8,
                MEM_START = 32'hBFC00000,
                MEM_END = 32'hBFC00FFF
)(
    input  logic                       en,    // Enable signal
    input  logic [ADDRESS_WIDTH-1:0]   addr,  // Address input
    output logic [ADDRESS_WIDTH-1:0]   dout   // Data output
);

logic [DATA_WIDTH-1:0] rom_array [MEM_END : MEM_START];

initial begin
    $display ("Loading instructions....");
    $readmemh("program.hex", rom_array);
    $display ("Finished Loading instructions!");
end

always_comb begin
    if (en) begin
        if (addr[1:0] != 2'b00) begin
            $fatal("Instruction address not word-aligned: %h", addr);
        end
        dout = {rom_array[(addr + 3) - MEM_START],
                rom_array[(addr + 2) - MEM_START],
                rom_array[(addr + 1) - MEM_START],
                rom_array[(addr + 0) - MEM_START]};
    end else begin
        dout = '0; // Default value when disabled
    end
end

endmodule
