module data_mem #(
    parameter   ADDRESS_WIDTH = 32,
                DATA_WIDTH = 32
)(
    input  logic                           clk,
    input  logic                           wr_en,
    input  logic [ADDRESS_WIDTH-1:0]       addr,
    input  logic [DATA_WIDTH-1:0]          WriteData,
    output logic [DATA_WIDTH-1:0]          ReadData
);

logic [7:0] ram_array [32'h0001FFFF:0];


//---- Load sine coeff (Lab 4 extension) ----
/*
initial begin
        $display("Loading Sine Coefficients");
        $readmemh("../rtl/sinerom.mem", ram_array);  // Load into data mem
end;
*/


always_ff @(posedge clk)
    if (wr_en) begin 
        ram_array[addr + 3] <= WriteData [7:0];
        ram_array[addr + 2] <= WriteData [15:8];
        ram_array[addr + 1] <= WriteData [23:16];
        ram_array[addr]     <= WriteData [31:24];
    end
    

always_comb
    ReadData = {ram_array[addr + 3],ram_array[addr + 2],ram_array[addr+ 1],ram_array[addr]};


endmodule
