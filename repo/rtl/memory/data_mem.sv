module data_mem #(
    parameter   ADDRESS_WIDTH = 32,
                BLOCK_WIDTH = 128
)(
    input  logic                           clk,
    input  logic                           wr_en,
    input  logic [ADDRESS_WIDTH-1:0]       addr,
    input  logic [BLOCK_WIDTH-1:0]         WriteBlockData,
    output logic [BLOCK_WIDTH-1:0]         ReadBlockData     // Full block read
);

logic [7:0] ram_array [32'h0001FFFF:0];

initial begin
    $display("Loading Sine Coefficients");
    $readmemh("../rtl/memory/sinerom.mem", ram_array);
    $display("Finished Loading Sine Coefficients");
end

always_ff @(posedge clk) begin
    if (wr_en) begin
        ram_array[addr]      <= WriteBlockData[7:0];
        ram_array[addr + 1]  <= WriteBlockData[15:8];
        ram_array[addr + 2]  <= WriteBlockData[23:16];
        ram_array[addr + 3]  <= WriteBlockData[31:24];
        
        ram_array[addr + 4]  <= WriteBlockData[39:32];
        ram_array[addr + 5]  <= WriteBlockData[47:40];
        ram_array[addr + 6]  <= WriteBlockData[55:48];
        ram_array[addr + 7]  <= WriteBlockData[63:56];
        
        ram_array[addr + 8]  <= WriteBlockData[71:64];
        ram_array[addr + 9]  <= WriteBlockData[79:72];
        ram_array[addr + 10] <= WriteBlockData[87:80];
        ram_array[addr + 11] <= WriteBlockData[95:88];
        
        ram_array[addr + 12] <= WriteBlockData[103:96];
        ram_array[addr + 13] <= WriteBlockData[111:104];
        ram_array[addr + 14] <= WriteBlockData[119:112];
        ram_array[addr + 15] <= WriteBlockData[127:120];
    end
end

always_comb begin
    ReadBlockData = {
        ram_array[addr + 15], ram_array[addr + 14], ram_array[addr + 13], ram_array[addr + 12],
        ram_array[addr + 11], ram_array[addr + 10], ram_array[addr + 9],  ram_array[addr + 8],
        ram_array[addr + 7],  ram_array[addr + 6],  ram_array[addr + 5],  ram_array[addr + 4],
        ram_array[addr + 3],  ram_array[addr + 2],  ram_array[addr + 1],  ram_array[addr]
    }; 
end

endmodule
