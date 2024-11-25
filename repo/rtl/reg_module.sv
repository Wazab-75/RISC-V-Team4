module reg_module #(
    parameter DATA_WIDTH = 32
)(
    input   logic                       clk,
    input   logic   [4:0]               AD1,
    input   logic   [4:0]               AD2,
    input   logic   [4:0]               AD3,
    input   logic                       WE3,
    input   logic   [DATA_WIDTH-1:0]    WD3,
    output  logic   [DATA_WIDTH-1:0]    RD1,
    output  logic   [DATA_WIDTH-1:0]    RD2,
    output  logic   [DATA_WIDTH-1:0]    a0
);

    // 32 registers, each 32-bits wide
    reg [31:0] registers [31:0];

    assign a0 = registers[10];

    // Read data from the registers
    assign RD1 = registers[AD1];
    assign RD2 = registers[AD2];

    // Writing data on the rising edge of the clock
    always @(posedge clk) begin
        if (WE3) begin
            registers[AD3] <= WD3; // Write data to register at address AD3 if WE3 is high
        end
    end


endmodule
