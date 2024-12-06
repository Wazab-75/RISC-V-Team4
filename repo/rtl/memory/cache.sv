module cache #(
    parameter DATA_WIDTH = 32,
              BLOCK_SIZE = 4,    // 4 words per block (16 bytes)
              WAYS       = 2,
              NUM_SETS   = 128   
)(
    input  logic                     clk,
    input  logic                     rd_en,
    input  logic                     wr_en,
    input  logic [DATA_WIDTH-1:0]    addr,
    input  logic [DATA_WIDTH-1:0]    WriteData,
    input  logic [2:0]               funct3,

    input  logic [4*DATA_WIDTH-1:0]  fetch_data,
    input  logic                     fetch_enable,

    output logic [DATA_WIDTH-1:0]    cache_read,
    output logic                     hit,
    output logic [4*DATA_WIDTH-1:0]  write_back_data,
    output logic                     write_back_valid,
    output logic [DATA_WIDTH-1:0]    write_back_addr
);

// Address breakdown
logic set;  
logic [1:0] offset; 
logic [26:0] tag;

assign tag    = addr[31:5];   // Top 27 bits as tag
assign set    = addr[4];      // 1 bit for set
assign offset = addr[1:0];    // 2 bits for word in block (4 words)

logic [DATA_WIDTH-1:0] hit_data; // Data from hit block

// Arrays now 2D for ways
logic [DATA_WIDTH-1:0] data_array [NUM_SETS-1:0][WAYS-1:0][BLOCK_SIZE-1:0]; 
logic [26:0]           tag_array  [NUM_SETS-1:0][WAYS-1:0];                 
logic                  v          [NUM_SETS-1:0][WAYS-1:0];                 
logic                  d          [NUM_SETS-1:0][WAYS-1:0];

// Replacement bit per set
logic next_way[NUM_SETS-1:0];

initial begin
    for (int s = 0; s < NUM_SETS; s++) begin
        next_way[s] = 0;
        for (int w = 0; w < WAYS; w++) begin
            v[s][w] = 0;
            d[s][w] = 0;
            tag_array[s][w] = '0;
            for (int j = 0; j < BLOCK_SIZE; j++)
                data_array[s][w][j] = 32'h0;
        end
    end
end

logic hit_found;
logic [WAYS-1:0] way_hit_vector;

always_comb begin
    hit_found = 0;
    way_hit_vector = '0;
    for (int w = 0; w < WAYS; w++) begin
        if (v[set][w] && (tag_array[set][w] == tag)) begin
            hit_found = 1;
            way_hit_vector[w] = 1;
        end
    end
end

assign hit = hit_found;

// Default assigns
assign write_back_data = '0;
assign write_back_addr = '0;
assign write_back_valid = 0;

always_ff @(posedge clk) begin
    // Local vars
    reg replace_way;
    reg hit_way_idx;

    if (wr_en) begin
        if (hit_found) begin
            // Write hit
            hit_way_idx = 0;
            for (int w = 0; w < WAYS; w++)
                if (way_hit_vector[w]) hit_way_idx = w;

            d[set][hit_way_idx] <= 1;
            case (funct3)
                3'b000: data_array[set][hit_way_idx][offset][7:0]   <= WriteData[7:0];   
                3'b001: data_array[set][hit_way_idx][offset][15:0]  <= WriteData[15:0];  
                3'b010: data_array[set][hit_way_idx][offset]        <= WriteData;        
                default: data_array[set][hit_way_idx][offset]       <= WriteData;
            endcase
        end else begin
            // Write miss
            replace_way = next_way[set];

            if (v[set][replace_way] && d[set][replace_way]) begin
                // Write back dirty block
                for (int i = 0; i < BLOCK_SIZE; i++)
                    write_back_data[(i+1)*DATA_WIDTH-1 -: DATA_WIDTH] <= data_array[set][replace_way][i];
                // Construct proper byte-aligned block address:
                // tag(27 bits), set(1 bit), and 4 bits of 0 => total 32 bits
                write_back_addr <= {tag_array[set][replace_way], set, 4'b0000}; 
                write_back_valid <= 1;
            end else begin
                write_back_valid <= 0;
            end

            for (int i = 0; i < BLOCK_SIZE; i++)
                data_array[set][replace_way][i] <= fetch_data[i*DATA_WIDTH +: DATA_WIDTH];

            tag_array[set][replace_way] <= tag;
            v[set][replace_way] <= 1;
            d[set][replace_way] <= 1;

            // Perform write now
            case (funct3)
                3'b000: data_array[set][replace_way][offset][7:0]   <= WriteData[7:0];   
                3'b001: data_array[set][replace_way][offset][15:0]  <= WriteData[15:0];  
                3'b010: data_array[set][replace_way][offset]        <= WriteData;        
                default: data_array[set][replace_way][offset]       <= WriteData;
            endcase

            next_way[set] <= ~next_way[set];
        end
    end else if (rd_en) begin
        if (hit_found) begin
            // Read hit: no extra action
        end else begin
            // Read miss
            replace_way = next_way[set];

            if (v[set][replace_way] && d[set][replace_way]) begin
                // Write back if dirty
                for (int i = 0; i < BLOCK_SIZE; i++)
                    write_back_data[(i+1)*DATA_WIDTH-1 -: DATA_WIDTH] <= data_array[set][replace_way][i];
                write_back_addr <= {tag_array[set][replace_way], set, 4'b0000}; 
                write_back_valid <= 1;
            end else begin
                write_back_valid <= 0;
            end

            // Fetch block
            for (int i = 0; i < BLOCK_SIZE; i++)
                data_array[set][replace_way][i] <= fetch_data[i*DATA_WIDTH +: DATA_WIDTH];

            tag_array[set][replace_way] <= tag;
            v[set][replace_way] <= 1;
            d[set][replace_way] <= 0;

            next_way[set] <= ~next_way[set];
        end
    end else begin
        // No read/write this cycle
    end
end

// Read logic
always_comb begin
    logic [DATA_WIDTH-1:0] selected_data = '0;
    if (!hit && fetch_enable) begin
        // On miss, reading from fetch_data
        case (funct3)
            3'b000: selected_data = {{24{fetch_data[(offset*8)+7]}}, fetch_data[(offset*8)+:8]};
            3'b001: selected_data = {{16{fetch_data[(offset*16)+15]}}, fetch_data[(offset*16)+:16]};
            3'b010: selected_data = fetch_data[(offset*DATA_WIDTH)+:DATA_WIDTH];
            3'b100: selected_data = {24'b0, fetch_data[(offset*8)+:8]};
            3'b101: selected_data = {16'b0, fetch_data[(offset*16)+:16]};
            default: selected_data = fetch_data[(offset*DATA_WIDTH)+:DATA_WIDTH];
        endcase
        cache_read = selected_data;
    end else begin
        // On hit or not fetching
        logic rd_way = 0;
        for (int w = 0; w < WAYS; w++)
            if (way_hit_vector[w]) rd_way = w;

        hit_data = data_array[set][rd_way][offset];
        case (funct3)
            3'b000: cache_read = {{24{hit_data[7]}}, hit_data[7:0]};
            3'b001: cache_read = {{16{hit_data[15]}}, hit_data[15:0]};
            3'b010: cache_read = hit_data;
            3'b100: cache_read = {24'b0, hit_data[7:0]};
            3'b101: cache_read = {16'b0, hit_data[15:0]};
            default: cache_read = hit_data;
        endcase
    end
end

endmodule
