module reg_file #(
    parameter ADDRESS_WIDTH = 5,
    parameter DATA_WIDTH = 32
) (
    input  logic                           clk,
    input  logic [ADDRESS_WIDTH-1:0]       AD1,
    input  logic [ADDRESS_WIDTH-1:0]       AD2,
    input  logic [ADDRESS_WIDTH-1:0]       AD3,
    input  logic [DATA_WIDTH-1:0]          WD3,
    input  logic                           WE3,
    output logic [DATA_WIDTH-1:0]          RD1,
    output logic [DATA_WIDTH-1:0]          RD2,
    output logic [DATA_WIDTH-1:0]          a0
);

logic [DATA_WIDTH-1:0] registers [2**ADDRESS_WIDTH-1:0];

always_ff @(negedge clk)
    begin
        if (WE3 && (AD3 != 0)) registers[AD3] <= WD3;
    end

always_comb begin
     RD1 = registers[AD1];
     RD2 = registers[AD2];
end

assign a0 = registers[10];


endmodule
