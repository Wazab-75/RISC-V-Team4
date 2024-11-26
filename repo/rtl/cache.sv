module cache#(
    parameter DATA_WIDTH = 32,
              BLOCK_SIZE = 4,  // 4 words per block
              NUM_BLOCKS = 2  // Number of cache lines
)(
    input  logic                     clk,
    
    input  logic                     rd_en,
    input  logic                     wr_en,
    input  logic [DATA_WIDTH-1:0]    addr,
    input  logic [DATA_WIDTH-1:0]    WriteData,

    output logic [DATA_WIDTH-1:0]    ReadData_c,
    output logic                     hit,
    output logic [DATA_WIDTH-1:0]    write_back_data,
    output logic                     write_back_valid
)

// Cache storage
logic [31:0] data_array [NUM_BLOCKS-1:0][BLOCK_SIZE-1:0];
logic [26:0] tag_array [NUM_BLOCKS-1:0];
logic        v [NUM_BLOCKS-1:0];
logic        d [NUM_BLOCKS-1:0];

// Address parameter

logic [26:0] tag;
logic        set;
logic [1:0]  offset;

assign tag = addr[31:5];
assign set = addr[4];
assign offset = addr[3:2];

// Internal variables
logic [31:0] block_data; // Holds data for the selected block


// Initialize arrays
initial begin
    for (int i = 0; i < NUM_BLOCKS; i++) begin
        v[i] = 0;
        d[i] = 0;
        for (int j = 0; j < BLOCK_SIZE; j++) begin
            data_array[i][j] = 32'h0; // Initialize data with zero
        end
    end
end


always_ff @(posedge clk) begin

    if (rd_en || wr_en) begin
        // Check for hit
        if (v[set] && tag_array[set] == tag) begin
            hit <= 1;
            if (rd_en) begin
                ReadData_c <= data_array[set][offset];
            end
            if (wr_en) begin
                data_array[set][offset] <= WriteData;
                d[set] <= 1; // Mark block as dirty
            end
        end 
        
        else begin
            // Cache miss
            hit <= 0;

            if (d[set]) begin
                // Write back dirty block to memory
                write_back_data <= data_array[set][offset];
                write_back_valid <= 1;
            end else begin
                write_back_valid <= 0;
            end

            // Fetch new block (for now, assume memory fetch logic outside)
            tag_array[set] <= tag;
            v[set] <= 1;
            d[set] <= 0;

            // Placeholder for memory load
            data_array[set][0] <= 32'hDEADBEEF; // Example data
            data_array[set][1] <= 32'hCAFEBABE; 
            data_array[set][2] <= 32'h12345678; 
            data_array[set][3] <= 32'h87654321; 
        end
    end
end

endmodule
