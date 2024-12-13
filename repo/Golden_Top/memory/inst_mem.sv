module inst_mem #(
    parameter   ADDRESS_WIDTH = 32,
                DATA_WIDTH = 32
)(
    input  logic                           clk,
    input  logic [ADDRESS_WIDTH-1:0]       addr,
    output logic [ADDRESS_WIDTH-1:0]       dout
);

/*
logic [ADDRESS_WIDTH-1:0]       addr_w;
assign addr_w = addr >> 2;

	rom_inst inst_rom (
		.clock		(clk),
		.address		(addr_w[12:0]),
		.q				(dout)
	);
*/

logic [DATA_WIDTH-1:0] rom_array [32'hFF : 32'h0];

initial 
begin
    $display ("Loading instructions....");
    $readmemh("program_test.hex",rom_array);
    $display ("Finished Loading instructions!");
end


always_ff @(posedge clk)
    dout <= rom_array[addr >> 2];


endmodule
