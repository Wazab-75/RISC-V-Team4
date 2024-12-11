module execute_reg #(
    parameter  DATA_WIDTH = 32
) (
    input  logic                    clk,
    input  logic [DATA_WIDTH-1:0]   ALUResultE,
    input  logic [DATA_WIDTH-1:0]   WriteDataE,
    input  logic [11:7]             RdE,
    input  logic                    RegWriteE,
    input  logic [DATA_WIDTH-1:0]   PCPlus4E,
    input  logic                    MemWriteE,
    input  logic [1:0]              ResultSrcE,
    input  logic [14:12]            funct3E,
    output logic [DATA_WIDTH-1:0]   WriteDataM,    
    output logic [DATA_WIDTH-1:0]   ALUResultM,
    output logic [11:7]             RdM,
    output logic                    RegWriteM,
    output logic [DATA_WIDTH-1:0]   PCPlus4M,
    output logic                    MemWriteM,
    output logic [1:0]              ResultSrcM,
    output logic [14:12]            funct3M
);
    always_ff @(posedge clk) begin
            ALUResultM <= ALUResultE;
            WriteDataM <= WriteDataE;
            RdM <= RdE;
            RegWriteM <= RegWriteE;
            PCPlus4M <= PCPlus4E;
            MemWriteM <= MemWriteE;
            ResultSrcM <= ResultSrcE;
            funct3M <= funct3E;   
    end
endmodule
