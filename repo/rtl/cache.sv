module cache#(
    parameter DATA_WIDTH = 32,
              BLOCK_SIZE = 4,  // 4 words per block
              NUM_BLOCKS = 2  // Number of cache lines
)(
    input  logic                               clk,
    input  logic                               rd_en,
    input  logic                               wr_en,
    input  logic [DATA_WIDTH-1:0]              addr,
    input  logic [DATA_WIDTH-1:0]              WriteData,
    input  logic [2:0]                         funct3,

    input  logic [4*DATA_WIDTH-1:0]            fetch_data,
    input  logic                               fetch_enable,

    output logic [DATA_WIDTH-1:0]              ReadData_c,
    output logic                               hit,
    output logic [4*DATA_WIDTH-1:0]            write_back_data,
    output logic                               write_back_valid,
    output logic [DATA_WIDTH-1:0]              write_back_addr
);

logic [DATA_WIDTH-1:0] data_array [NUM_BLOCKS-1:0][BLOCK_SIZE-1:0];   // Data storage (2 sets, 4 words per set)
logic [26:0] tag_array [NUM_BLOCKS-1:0];         // Tags
logic        v [NUM_BLOCKS-1:0];                 // Valid bits
logic        d [NUM_BLOCKS-1:0];                 // Dirty bits

logic [26:0] tag;
logic        set;
logic [1:0]  offset;

assign tag = addr[31:5];
assign set = addr[4];
assign offset = addr[3:2];

initial begin
    for (int i = 0; i < 2; i++) begin
        v[i] = 0;
        d[i] = 0;
        for (int j = 0; j < 4; j++) begin
            data_array[i][j] = 32'h0;
        end
    end
end

always_ff @(posedge clk) begin
    if (fetch_enable) begin
        for (int i = 0; i < 4; i++) begin
            data_array[set][i] <= fetch_data[(i+1)*32-1 -: 32];
        end
        tag_array[set] <= tag;
        v[set] <= 1;
        d[set] <= wr_en ? 1 : 0;
    end 
    else if (rd_en || wr_en) begin
        if (v[set] && tag_array[set] == tag) begin
            hit <= 1;

            if (rd_en) begin
                case (funct3)
                    3'b000: ReadData_c = {{24{data_array[set][offset][7]}}, data_array[set][offset][7:0]};
                    3'b001: ReadData_c = {{16{data_array[set][offset][15]}}, data_array[set][offset][15:8], data_array[set][offset][7:0]};
                    3'b010: ReadData_c = data_array[set][offset];
                    3'b100: ReadData_c = {24'b0, data_array[set][offset][7:0]};
                    3'b101: ReadData_c = {16'b0, data_array[set][offset][15:8], data_array[set][offset][7:0]};
                    default: ReadData_c = data_array[set][offset];
                endcase
            end
            else if (wr_en) begin
                case (funct3)
                    3'b000: data_array[set][offset][7:0]   <= WriteData[7:0];
                    3'b001: begin
                        data_array[set][offset][15:8]  <= WriteData[15:8];
                        data_array[set][offset][7:0]   <= WriteData[7:0];
                    end
                    3'b010: begin
                        data_array[set][offset][31:24] <= WriteData[31:24];
                        data_array[set][offset][23:16] <= WriteData[23:16];
                        data_array[set][offset][15:8]  <= WriteData[15:8];
                        data_array[set][offset][7:0]   <= WriteData[7:0];
                    end
                    default: begin
                        data_array[set][offset][31:24] <= WriteData[31:24];
                        data_array[set][offset][23:16] <= WriteData[23:16];
                        data_array[set][offset][15:8]  <= WriteData[15:8];
                        data_array[set][offset][7:0]   <= WriteData[7:0];
                    end
                endcase
                d[set] <= 1; // Mark the block as dirty
            end
        end
        
        else begin
            hit <= 0;
            if (d[set]) begin
                for (int i = 0; i < 4; i++) begin
                    write_back_data[(i+1)*32-1 -: 32] <= data_array[set][i];
                end
                write_back_addr <= {tag_array[set], set, 5'b0};
                write_back_valid <= 1;
            end else begin
                write_back_valid <= 0;
            end
        end
    end
end

endmodule
