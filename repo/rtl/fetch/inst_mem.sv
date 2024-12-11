module inst_mem #(
    parameter   ADDRESS_WIDTH = 32,
                DATA_WIDTH = 8
)(
    input  logic [ADDRESS_WIDTH-1:0]       addr,
    output logic [ADDRESS_WIDTH-1:0]       dout
);

logic [DATA_WIDTH-1:0] rom_array [32'hBFC00FFF : 32'hBFC00000];

initial 
begin
    $display ("Loading instructions....");
    $readmemh("program.hex",rom_array);
    $display ("Finished Loading instructions!");
end


always_comb
    dout = {rom_array[(addr + 3)- 32'hBFC00000],rom_array[(addr + 2) - 32'hBFC00000],rom_array[(addr+ 1) - 32'hBFC00000],rom_array[(addr) - 32'hBFC00000]};

endmodule
