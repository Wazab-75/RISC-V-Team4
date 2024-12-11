module memory_reg #(
    parameter  DATA_WIDTH = 32
) (
    input  logic                    clk,
    input  logic [DATA_WIDTH-1:0]   ALUResultM,
    input  logic [DATA_WIDTH-1:0]   PCPlus4M,
    input  logic [11:7]             RdM,
    input  logic                    RegWriteM,
    input  logic [1:0]              ResultSrcM,
    input  logic [DATA_WIDTH-1:0]   ReadDataM,

    output logic [DATA_WIDTH-1:0]   ALUResultW,
    output logic [DATA_WIDTH-1:0]   PCPlus4W,
    output logic [11:7]             RdW,
    output logic                    RegWriteW,
    output logic [1:0]              ResultSrcW,
    output logic [DATA_WIDTH-1:0]   ReadDataW
);
    always_ff @(posedge clk) begin
        ALUResultW <= ALUResultM;
        PCPlus4W <= PCPlus4M;
        RdW <= RdM;
        RegWriteW <= RegWriteM;
        ResultSrcW <= ResultSrcM;
        ReadDataW <= ReadDataM;
    end
endmodule
