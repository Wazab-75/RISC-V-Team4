module inst_cache #(
    parameter DATA_WIDTH = 32,
              BLOCK_SIZE = 4,    // 4 words per block
              WAYS       = 2,    // 2-way associative
              NUM_SETS   = 32    
)(
    input  logic                     clk,              
    input  logic [DATA_WIDTH-1:0]    addr,            
    input  logic [4*DATA_WIDTH-1:0]  fetch_data,        // Data fetched from memory
    input  logic                     fetch_enable,      // Fetch enable signal

    output logic [DATA_WIDTH-1:0]    cache_read,     
    output logic                     hit
);

// Address breakdown
logic [20:0] tag;
logic [6:0]  index;
logic [1:0]  offset;

assign tag    = addr[31:11];
assign index  = addr[10:4];
assign offset = addr[3:2];

// Cache storage
logic [DATA_WIDTH-1:0] data_array[NUM_SETS-1:0][WAYS-1:0][BLOCK_SIZE-1:0];
logic [20:0]           tag_array [NUM_SETS-1:0][WAYS-1:0];
logic                  v[NUM_SETS-1:0][WAYS-1:0];
logic                  next_way[NUM_SETS-1:0];

// Initialization
initial begin
    for (int s = 0; s < NUM_SETS; s++) begin
        next_way[s] = 0;
        for (int w = 0; w < WAYS; w++) begin
            v[s][w] = 0;
            tag_array[s][w] = '0;
            for (int j = 0; j < BLOCK_SIZE; j++)
                data_array[s][w][j] = 32'h0;
        end
    end
end

// Hit detection
logic hit_found;
logic [WAYS-1:0] way_hit_vector;

always_comb begin
    hit_found = 0;
    way_hit_vector = '0;
    for (int w = 0; w < WAYS; w++) begin
        if (v[index][w] && (tag_array[index][w] == tag)) begin
            hit_found = 1;
            way_hit_vector[w] = 1;
        end
    end
end

assign hit = hit_found;

logic [DATA_WIDTH-1:0] selected_word;

always_comb begin
    if (hit_found) begin  // Read from the cache
        int rd_way = 0;
        for (int w = 0; w < WAYS; w++) begin
            if (way_hit_vector[w]) rd_way = w;
        end

        selected_word = data_array[index][rd_way][offset];
        cache_read = selected_word;
    end 
    else if (fetch_enable) begin // read directly from fetch_data
        cache_read = fetch_data[(offset * DATA_WIDTH) +: DATA_WIDTH];
    end 
    else   cache_read = '0;
end

// Fetch handling
always_ff @(posedge clk) begin

    if (!hit_found) begin
        int replace_way = next_way[index];

        if (fetch_enable) begin
            for (int i = 0; i < BLOCK_SIZE; i++) begin
                data_array[index][replace_way][i] <= fetch_data[i*DATA_WIDTH +: DATA_WIDTH];
            end

            tag_array[index][replace_way] <= tag;
            v[index][replace_way] <= 1;

            next_way[index] <= ~next_way[index];
        end
    end
end

endmodule
