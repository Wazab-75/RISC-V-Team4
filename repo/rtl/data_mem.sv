module data_mem #(
    parameter   ADDRESS_WIDTH = 32,
                DATA_WIDTH = 32
)(
    input  logic                           clk,
    input  logic                           wr_en,
    input  logic [ADDRESS_WIDTH-1:0]       addr,
    input  logic [DATA_WIDTH-1:0]          WriteData,
    input  logic [2:0]                     funct3,                     
    output logic [DATA_WIDTH-1:0]          ReadData
);


logic [7:0] ram_array [32'h0001FFFF:0];


//---- Load sine coeff (Lab 4 extension) ----

initial begin
        $display("Loading Sine Coefficients");
        $readmemh("../rtl/memory/sinerom.mem", ram_array);  // Load into data mem
        $display("Finished Loading Sine Coefficients");
end;



always_ff @(posedge clk)
    if (wr_en) begin 
        case (funct3)
            3'b000: begin
                ram_array[addr]     <= WriteData [7:0];
            end
            3'b001: begin
                ram_array[addr + 1] <= WriteData [7:0];
                ram_array[addr]     <= WriteData [15:8];
            end
            3'b010: begin
                ram_array[addr + 3] <= WriteData [7:0];
                ram_array[addr + 2] <= WriteData [15:8];
                ram_array[addr + 1] <= WriteData [23:16];
                ram_array[addr]     <= WriteData [31:24];
            end
            default:begin
                ram_array[addr + 3] <= WriteData [7:0];
                ram_array[addr + 2] <= WriteData [15:8];
                ram_array[addr + 1] <= WriteData [23:16];
                ram_array[addr]     <= WriteData [31:24];
            end
        endcase
    end
    

always_comb

    case (funct3) //Check if right order TODO
        3'b000: ReadData = {{24{ram_array[addr][7]}}, ram_array[addr]};
        3'b001: ReadData = {{16{ram_array[addr+1][7]}}, ram_array[addr+ 1], ram_array[addr]};
        3'b010: ReadData = {ram_array[addr + 3], ram_array[addr + 2], ram_array[addr+ 1], ram_array[addr]};
        3'b100: ReadData = {24'b0, ram_array[addr]};
        3'b101: ReadData = {16'b0, ram_array[addr+ 1], ram_array[addr]};
        default: ReadData = {ram_array[addr + 3], ram_array[addr + 2], ram_array[addr+ 1], ram_array[addr]};
    endcase
    
endmodule
