// For later because we don't need a memory for first steps

module ram #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 5
)(
    input  logic                   clk,
    input  logic [DATA_WIDTH-1:0]  WD,  // Data to be written
    input  logic [ADDR_WIDTH-1:0]  A,       // Address for reading and writing
    input  logic                   WE,         // Write Enable
    output logic [DATA_WIDTH-1:0]  RD    // Data read from memory
);

    // 32 registers, each 32-bits wide
    reg [DATA_WIDTH-1:0] registers [31:0];

    // Read data from the registers
    assign RD = registers[A];

    // Writing data on the rising edge of the clock
    always @(posedge clk) begin
        if (WE) begin
            registers[A] <= WD; // Write data to register at address A if WE is high
        end
    end

endmodule

