module cache #(
    parameter DATA_WIDTH = 32,
              BLOCK_SIZE = 4,  // 4 words per block
              NUM_BLOCKS = 2   // 2 cache lines
)(
    input  logic                               clk,
    input  logic                               rd_en,
    input  logic                               wr_en,
    input  logic [DATA_WIDTH-1:0]              addr,
    input  logic [DATA_WIDTH-1:0]              WriteData,
    input  logic [2:0]                         funct3,

    input  logic [4*DATA_WIDTH-1:0]            fetch_data,
    input  logic                               fetch_enable,

    output logic [DATA_WIDTH-1:0]              cache_read,
    output logic                               hit,
    output logic [4*DATA_WIDTH-1:0]            write_back_data,
    output logic                               write_back_valid,
    output logic [DATA_WIDTH-1:0]              write_back_addr
);

logic [DATA_WIDTH-1:0] data_array [NUM_BLOCKS-1:0][BLOCK_SIZE-1:0]; // Data storage
logic [26:0]           tag_array [NUM_BLOCKS-1:0];                  // Tags
logic                  v [NUM_BLOCKS-1:0];                          // Valid bits
logic                  d [NUM_BLOCKS-1:0];                          // Dirty bits

logic [26:0] tag;
logic        set;
logic [1:0]  offset;

assign tag = addr[31:5];
assign set = addr[4];
assign offset = addr[3:2];

// Initialization
initial begin
    for (int i = 0; i < NUM_BLOCKS; i++) begin
        v[i] = 0;
        d[i] = 0;
        for (int j = 0; j < BLOCK_SIZE; j++) begin
            data_array[i][j] = 32'h0;
        end
    end
end

// Cache Operations
always_ff @(posedge clk) begin
    if (wr_en) begin
        if (v[set] && tag_array[set] == tag) begin
            hit <= 1;
            d[set] <= 1; // Mark as dirty
        end else begin
            hit <= 0;
            if (d[set] && v[set]) begin
                for (int i = 0; i < BLOCK_SIZE; i++) begin
                    write_back_data[(i+1)*DATA_WIDTH-1 -: DATA_WIDTH] <= data_array[set][i];
                end
                write_back_addr <= {tag_array[set], set, 4'b0};
                write_back_valid <= 1;
            end else begin
                write_back_valid <= 0;
            end

            tag_array[set] <= tag;
            v[set] <= 1;
            d[set] <= 1; // Mark as dirty
        end

        case (funct3)
            3'b000: data_array[set][offset][7:0]   <= WriteData[7:0];   // Byte write (little-endian)
            3'b001: data_array[set][offset][15:0]  <= WriteData[15:0];  // Half-word write (little-endian)
            3'b010: data_array[set][offset]        <= WriteData;        // Full word write
        endcase
    end else if (rd_en) begin
        if (v[set] && tag_array[set] == tag) begin
            hit <= 1;
        end else begin
            hit <= 0;
            if (d[set] && v[set]) begin
                for (int i = 0; i < BLOCK_SIZE; i++) begin
                    write_back_data[(i+1)*DATA_WIDTH-1 -: DATA_WIDTH] <= data_array[set][i];
                end
                write_back_addr <= {tag_array[set], set, 4'b0};
                write_back_valid <= 1;
            end else begin
                write_back_valid <= 0;
            end

            for (int i = 0; i < BLOCK_SIZE; i++) begin
                data_array[set][i] <= fetch_data[(i*DATA_WIDTH) +: DATA_WIDTH];
            end

            tag_array[set] <= tag;
            v[set] <= 1;
            d[set] <= 0;
        end
    end else begin
        hit <= 0;
    end
end

always_comb begin
    if (!hit && fetch_enable) begin
        case (funct3)
            3'b000: cache_read = {{24{1'b0}}, fetch_data[(offset * DATA_WIDTH) +: 8]};  // Byte read (zero-extended)
            3'b001: cache_read = {{16{1'b0}}, fetch_data[(offset * DATA_WIDTH) +: 16]}; // Half-word read (zero-extended)
            3'b010: cache_read = fetch_data[(offset * DATA_WIDTH) +: DATA_WIDTH];       // Full word read
            3'b100: cache_read = {{24{fetch_data[(offset * DATA_WIDTH) + 7]}}, fetch_data[(offset * DATA_WIDTH) +: 8]};  // Byte read (sign-extended)
            3'b101: cache_read = {{16{fetch_data[(offset * DATA_WIDTH) + 15]}}, fetch_data[(offset * DATA_WIDTH) +: 16]}; // Half-word read (sign-extended)
            default: cache_read = 32'b0;
        endcase
    end else begin
        case (funct3)
            3'b000: cache_read = {{24{1'b0}}, data_array[set][offset][7:0]};  // Byte read (zero-extended)
            3'b001: cache_read = {{16{1'b0}}, data_array[set][offset][15:0]}; // Half-word read (zero-extended)
            3'b010: cache_read = data_array[set][offset];                     // Full word read
            3'b100: cache_read = {{24{data_array[set][offset][7]}}, data_array[set][offset][7:0]};  // Byte read (sign-extended)
            3'b101: cache_read = {{16{data_array[set][offset][15]}}, data_array[set][offset][15:0]}; // Half-word read (sign-extended)
            default: cache_read = 32'b0;
        endcase
    end
end

endmodule