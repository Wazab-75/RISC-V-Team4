module cache #(
    parameter DATA_WIDTH = 32,
              BLOCK_SIZE = 4,    // 4 words per block
              WAYS       = 2,    // 2-way associative
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

logic [20:0] tag;
logic [6:0]  index;
logic [1:0]  offset;      
logic [1:0]  byte_offset;

assign tag         = addr[31:11];
assign index       = addr[10:4];
assign offset      = addr[3:2];  
assign byte_offset = addr[1:0];  

// Cache arrays
logic [DATA_WIDTH-1:0] data_array[NUM_SETS-1:0][WAYS-1:0][BLOCK_SIZE-1:0];
logic [20:0]           tag_array [NUM_SETS-1:0][WAYS-1:0];
logic                  v[NUM_SETS-1:0][WAYS-1:0];
logic                  d[NUM_SETS-1:0][WAYS-1:0];

logic next_way[NUM_SETS-1:0];

// Initialization
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

// Hit detection
logic hit_found;
logic [WAYS-1:0] way_hit_vector;

logic [DATA_WIDTH:0] selected_word;
logic [DATA_WIDTH:0] fetched_word;

logic [DATA_WIDTH-1:0] miss_count;
logic [DATA_WIDTH-1:0] hit_count;

always_comb begin
    hit_found = 0;
    way_hit_vector = 2'b0;
    for (int w = 0; w < WAYS; w++) begin
        if (v[index][w] && (tag_array[index][w] == tag)) begin
            hit_found = 1;
            way_hit_vector[w] = 1;
        end
    end
end

assign hit = hit_found;

always_ff @(posedge clk) begin
    write_back_valid <= 1'b0;
    write_back_addr  <= {DATA_WIDTH{1'b0}};
    write_back_data  <= {4*DATA_WIDTH{1'b0}};

    if (wr_en || rd_en) begin
        int replace_way = next_way[index];

        if (wr_en) begin
            int hit_way_idx = 0;
            if (hit_found) begin
                hit_count <= hit_count + 1;
                // Write hit
                for (int w = 0; w < WAYS; w++)
                    if (way_hit_vector[w]) hit_way_idx = w;
                d[index][hit_way_idx] <= 1;
            end 
            else begin
                miss_count <= miss_count + 1;
                // Write miss
                if (v[index][replace_way] && d[index][replace_way]) begin
                    // Write back dirty block
                    for (int i = 0; i < BLOCK_SIZE; i++)
                        write_back_data[(i+1)*DATA_WIDTH-1 -: DATA_WIDTH] <= data_array[index][replace_way][i];

                    write_back_addr  <= {tag_array[index][replace_way], index, 4'b0000};
                    write_back_valid <= 1'b1;
                end

                // Fetch new block
                for (int i = 0; i < BLOCK_SIZE; i++)
                    data_array[index][replace_way][i] <= fetch_data[i*DATA_WIDTH +: DATA_WIDTH];

                tag_array[index][replace_way] <= tag;
                v[index][replace_way] <= 1;
                d[index][replace_way] <= 1;
                
                hit_way_idx = replace_way;
                next_way[index] <= ~next_way[index];
            end

            case (funct3)
                3'b000: data_array[index][hit_way_idx][offset][(byte_offset*8) +:8] <= WriteData[7:0];
                3'b001: data_array[index][hit_way_idx][offset][(byte_offset[1]*16) +:16] <= WriteData[15:0];
                3'b010: data_array[index][hit_way_idx][offset] <= WriteData;

                default: data_array[index][hit_way_idx][offset] <= WriteData;
            endcase

        end 
        else if (rd_en) begin
            if (!hit_found) begin
                miss_count <= miss_count + 1;
                // Read miss
                if (v[index][replace_way] && d[index][replace_way]) begin
                    // Write back dirty block
                    for (int i = 0; i < BLOCK_SIZE; i++)
                        write_back_data[(i+1)*DATA_WIDTH-1 -: DATA_WIDTH] <= data_array[index][replace_way][i];

                    write_back_addr  <= {tag_array[index][replace_way], index, 4'b0000};
                    write_back_valid <= 1'b1;
                end

                // Fetch new block
                for (int i = 0; i < BLOCK_SIZE; i++)
                    data_array[index][replace_way][i] <= fetch_data[i*DATA_WIDTH +: DATA_WIDTH];

                tag_array[index][replace_way] <= tag;
                v[index][replace_way] <= 1;
                d[index][replace_way] <= 0; 
                next_way[index] <= ~next_way[index];
            end
            else hit_count <= hit_count + 1;
        end
    end
end

// Cache Read Logic
always_comb begin
    if (!hit && fetch_enable) begin
        fetched_word = fetch_data[(offset*DATA_WIDTH) +: DATA_WIDTH]; // Generates 33 bits !!
        
        case (funct3)
            3'b000: begin
                logic [7:0] b_data = fetched_word[(byte_offset*8) +: 8];
                cache_read = {{24{b_data[7]}}, b_data};
            end
            3'b001: begin
                logic [15:0] h_data = fetched_word[(byte_offset[1]*16) +: 16];
                cache_read = {{16{h_data[15]}}, h_data};
            end
            3'b010: cache_read = fetched_word;
            
            3'b100: begin
                logic [7:0] b_data = fetched_word[(byte_offset*8) +: 8];
                cache_read = {24'b0, b_data};
            end
            3'b101: begin 
                logic [15:0] h_data = fetched_word[(byte_offset[1]*16) +:16];
                cache_read = {16'b0, h_data};
            end
            default: cache_read = fetched_word;
        endcase
    end

    else begin
        if (hit_found) begin
            int rd_way = 0;
            for (int w = 0; w < WAYS; w++)
                if (way_hit_vector[w]) rd_way = w;
            selected_word = data_array[index][rd_way][offset];
        end 

        case (funct3)
            3'b000: begin
                logic [7:0] b_data = selected_word[(byte_offset*8)+:8];
                cache_read = {{24{b_data[7]}}, b_data};
            end
            3'b001: begin
                logic [15:0] h_data = selected_word[(byte_offset[1]*16)+:16];
                cache_read = {{16{h_data[15]}}, h_data};
            end
            3'b010: cache_read = selected_word;

            3'b100: begin
                logic [7:0] b_data = selected_word[(byte_offset*8)+:8];
                cache_read = {24'b0, b_data};
            end
            3'b101: begin
                logic [15:0] h_data = selected_word[(byte_offset[1]*16)+:16];
                cache_read = {16'b0, h_data};
            end
            default: cache_read = selected_word;
        endcase
    end
end

endmodule
