module decode_reg #(
    parameter  DATA_WIDTH = 32
) (
    input  logic                   clk,
    input  logic [2:0]             ALUctrlD,
    input  logic                   ALUSrcD,
    input  logic                   MemWriteD,
    input  logic [1:0]             ResultSrcD,
    input  logic                   BranchD,
    input  logic                   JumpD,
    input  logic                   branch_negD,
    input  logic [DATA_WIDTH-1:0]  ImmExtD,
    input  logic                   PcOpD,
    input  logic [DATA_WIDTH-1:0]  rd1D,
    input  logic [DATA_WIDTH-1:0]  rd2D,
    input  logic [DATA_WIDTH-1:0]  pcD,
    input  logic [14:12]           instr_14_12D,
    input  logic [DATA_WIDTH-1:0]  PCPlus4D,
    input  logic                   RegWriteD,
    input  logic [11:7]            RdD,
    input  logic [19:15]           rs1D,
    input  logic [24:20]           rs2D,

    //Flush
    input  logic                   FlushD,

    //Stall
    input  logic                   StallD,

    output logic [2:0]             ALUctrlE,
    output logic                   ALUSrcE,
    output logic                   MemWriteE,
    output logic [1:0]             ResultSrcE,
    output logic                   BranchE,
    output logic                   JumpE,
    output logic                   branch_negE,
    output logic [DATA_WIDTH-1:0]  ImmExtE,
    output logic                   PcOpE,
    output logic [DATA_WIDTH-1:0]  rd1E,
    output logic [DATA_WIDTH-1:0]  rd2E,
    output logic [DATA_WIDTH-1:0]  pcE,
    output logic [14:12]           instr_14_12E,
    output logic [DATA_WIDTH-1:0]  PCPlus4E,
    output logic                   RegWriteE,
    output logic [11:7]            RdE,
    output logic [19:15]           rs1E,
    output logic [24:20]           rs2E
);



    always_ff @(posedge clk) begin

        if (FlushD) begin
            ALUctrlE <= 0;
            ALUSrcE <= 0;
            MemWriteE <= 0;
            ResultSrcE <= 0;
            BranchE <= 0;
            JumpE <= 0;
            branch_negE <= 0;
            ImmExtE <= 0;
            PcOpE <= 0;
            rd1E <= 0;
            rd2E <= 0;
            pcE <= 0;
            instr_14_12E <= 0;
            PCPlus4E <= 0;
            RegWriteE <= 0;
            RdE <= 0;
            rs1E <= 0;
            rs2E <= 0;
        end
        else begin
            if (!StallD) begin
            ALUctrlE <= ALUctrlD;
            ALUSrcE <= ALUSrcD;
            MemWriteE <= MemWriteD;
            ResultSrcE <= ResultSrcD;
            BranchE <= BranchD;
            JumpE <= JumpD;
            branch_negE <= branch_negD;
            ImmExtE <= ImmExtD;
            PcOpE <= PcOpD;
            rd1E <= rd1D;
            rd2E <= rd2D;
            pcE <= pcD;
            instr_14_12E <= instr_14_12D;
            PCPlus4E <= PCPlus4D;
            RegWriteE <= RegWriteD;
            RdE <= RdD;
            rs1E <= rs1D;
            rs2E <= rs2D;
            end
        end
    end
endmodule
