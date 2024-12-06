module cache #(
    parameter DATA_WIDTH = 32,
              BLOCK_SIZE = 4,  // 4 words per block
              NUM_SETS   = 2   // Number of sets (2-set associative)
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

logic set;  
logic [1:0] offset; 
logic [26:0] tag;

assign tag    = addr[31:5];   // Tag is still from upper address bits
assign set    = addr[4];      // Set index is now a single bit from addr[4]
assign offset = addr[1:0];    // Word offset within a block

logic [DATA_WIDTH-1:0] data_array [NUM_SETS-1:0][BLOCK_SIZE-1:0]; 
logic [26:0]           tag_array  [NUM_SETS-1:0];                 
logic                  v          [NUM_SETS-1:0];                 
logic                  d          [NUM_SETS-1:0];                 

// Initialization
initial begin
    for (int i = 0; i < NUM_SETS; i++) begin
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
                // Write-back logic
                for (int i = 0; i < BLOCK_SIZE; i++) begin
                    write_back_data[(i+1)*DATA_WIDTH-1 -: DATA_WIDTH] <= data_array[set][i];
                end
                // Constructing write_back_addr:
                // tag_array[set] (27 bits) + set (1 bit) + BLOCK_SIZE zeros (4 bits) = 32 bits total
                write_back_addr <= {tag_array[set], set, {BLOCK_SIZE{1'b0}}};
                write_back_valid <= 1;
            end else begin
                write_back_valid <= 0;
            end

            // Update tag and mark as valid and dirty
            tag_array[set] <= tag;
            v[set] <= 1;
            d[set] <= 1;
        end

        // Write logic based on funct3
        case (funct3)
            3'b000: data_array[set][offset][7:0]   <= WriteData[7:0];   // Byte write
            3'b001: data_array[set][offset][15:0]  <= WriteData[15:0];  // Half-word write
            3'b010: data_array[set][offset]        <= WriteData;        // Full word write
            default: data_array[set][offset]       <= WriteData;       
        endcase
    end else if (rd_en) begin
        if (v[set] && tag_array[set] == tag) begin
            hit <= 1;
        end else begin
            hit <= 0;
            if (d[set] && v[set]) begin
                // Write-back logic
                for (int i = 0; i < BLOCK_SIZE; i++) begin
                    write_back_data[(i+1)*DATA_WIDTH-1 -: DATA_WIDTH] <= data_array[set][i];
                end
                write_back_addr <= {tag_array[set], set, {BLOCK_SIZE{1'b0}}};
                write_back_valid <= 1;
            end else begin
                write_back_valid <= 0;
            end

            // Fetch data from memory and update cache
            for (int i = 0; i < BLOCK_SIZE; i++) begin
                data_array[set][i] <= fetch_data[(i*DATA_WIDTH) +: DATA_WIDTH];
            end

            // Update tag and valid bit
            tag_array[set] <= tag;
            v[set] <= 1;
            d[set] <= 0;
        end
    end else begin
        hit <= 0;
    end
end

// Cache Read Logic
always_comb begin
    if (!hit && fetch_enable) begin
        case (funct3)
            3'b000: cache_read = {{24{fetch_data[(offset * 8) + 7]}}, fetch_data[(offset * 8) +: 8]};
            3'b001: cache_read = {{16{fetch_data[(offset * 16) + 15]}}, fetch_data[(offset * 16) +:16]};
            3'b010: cache_read = fetch_data[(offset * DATA_WIDTH) +: DATA_WIDTH];
            3'b100: cache_read = {24'b0, fetch_data[(offset * 8) +: 8]};
            3'b101: cache_read = {16'b0, fetch_data[(offset * 16) +:16]};
            default: cache_read = fetch_data[(offset * DATA_WIDTH) +: DATA_WIDTH];
        endcase
    end else begin
        case (funct3)
            3'b000: cache_read = {{24{data_array[set][offset][7]}}, data_array[set][offset][7:0]};
            3'b001: cache_read = {{16{data_array[set][offset][15]}}, data_array[set][offset][15:0]};
            3'b010: cache_read = data_array[set][offset];
            3'b100: cache_read = {24'b0, data_array[set][offset][7:0]};
            3'b101: cache_read = {16'b0, data_array[set][offset][15:0]};
            default: cache_read = data_array[set][offset];
        endcase
    end
end

endmodule
