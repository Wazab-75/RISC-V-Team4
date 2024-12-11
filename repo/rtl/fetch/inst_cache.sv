module inst_cache #(
    parameter DATA_WIDTH = 32,
              BLOCK_SIZE = 4,
              WAYS       = 2,
              NUM_SETS   = 32
)(
    input  logic                     clk,               
    input  logic [DATA_WIDTH-1:0]    addr,              // Address for cache access
    input  logic [4*DATA_WIDTH-1:0]  fetch_data,        // Data fetched from memory
    input  logic                     fetch_enable,      // Fetch enable signal

    output logic [DATA_WIDTH-1:0]    cache_read,        // Data read from cache
    output logic                     hit,               // Cache hit indicator
    output logic [DATA_WIDTH-1:0]    fetch_addr,        // Address to fetch data from memory
    output logic                     fetch_request      // Fetch request signal
);

// Address decoding
logic [20:0] tag;
logic [6:0]  index;
logic [1:0]  offset;

assign tag         = addr[31:11];
assign index       = addr[10:4];
assign offset      = addr[3:2];

logic [DATA_WIDTH-1:0] data_array[NUM_SETS-1:0][WAYS-1:0][BLOCK_SIZE-1:0];
logic [20:0]           tag_array [NUM_SETS-1:0][WAYS-1:0];
logic                  v[NUM_SETS-1:0][WAYS-1:0];
logic                  next_way[NUM_SETS-1:0];

// Cache initialization
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

logic hit_found;
logic [WAYS-1:0] way_hit_vector;

// Hit detection
always_comb begin
    hit_found = 0;
    way_hit_vector = 0;
    for (int w = 0; w < WAYS; w++) begin
        if (v[index][w] && (tag_array[index][w] == tag)) begin
            hit_found = 1;
            way_hit_vector[w] = 1;
        end
    end
end

assign hit = hit_found;

logic [DATA_WIDTH-1:0] selected_word;

// Cache read
always_comb begin
    if (hit_found) begin
        int rd_way = 0;
        for (int w = 0; w < WAYS; w++)
            if (way_hit_vector[w]) rd_way = w;
        selected_word = data_array[index][rd_way][offset];
    end else begin
        selected_word = 0;
    end
    cache_read = selected_word;
end

// Cache write back
always_ff @(posedge clk) begin
    fetch_request <= 0;
    fetch_addr <= {DATA_WIDTH{1'b0}};

    if (!hit_found) begin
        int replace_way = next_way[index];

        fetch_addr <= {tag, index, 4'b0000};
        fetch_request <= 1;

        if (fetch_enable) begin
            for (int i = 0; i < BLOCK_SIZE; i++)
                data_array[index][replace_way][i] <= fetch_data[i*DATA_WIDTH +: DATA_WIDTH];

            tag_array[index][replace_way] <= tag;
            v[index][replace_way] <= 1;
            next_way[index] <= ~next_way[index];
        end
    end
end

endmodule
