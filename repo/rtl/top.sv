`include <mux.sv>
`include <./fetch/top_fetch.sv>
`include <./decode/top_decode.sv>
`include <./execute/top_execute.sv>
`include <./memory/top_memory.sv>
`include <./pipeline/fetch_reg.sv>
`include <./pipeline/decode_reg.sv>
`include <./pipeline/execute_reg.sv>
`include <./pipeline/memory_reg.sv>
`include <./pipeline/hazard_unit.sv>

module top #(
    parameter   DATA_WIDTH = 32
) (
    input   logic clk,
    input   logic rst,
    input   logic trigger,
    output  logic [DATA_WIDTH-1:0] a0    
);


    logic [DATA_WIDTH-1:0]      pc;
    logic [DATA_WIDTH-1:0]      ImmExt;
    logic                       PCSrc;
    logic [DATA_WIDTH-1:0]      instr;
    logic [2:0]                 ALUctrl;
    logic                       ALUSrc;
    logic                       MemWrite;
    logic [1:0]                 ResultSrc;
    logic [DATA_WIDTH-1:0]      ALUResult;
    logic [DATA_WIDTH-1:0]      Result;
    logic                       PcOp;
    logic [DATA_WIDTH-1:0]      rd1;
    logic [DATA_WIDTH-1:0]      rd2;
    logic [DATA_WIDTH-1:0]      PCPlus4;
    logic [DATA_WIDTH-1:0]      PCTarget;
    logic                       Branch;
    logic                       Jump;
    logic                       branch_neg;
    logic                       RegWriteD;
    logic [DATA_WIDTH-1:0]      ReadData;



//--------------------------------
//------------FETCH---------------
//--------------------------------

    top_fetch fetch(
        .clk         (clk),
        .rst         (rst),
        .PCSrc       (PCSrc),
        .pc          (pc),
        .instr       (instr),
        .PCPlus4     (PCPlus4),
        .PCTarget    (PCTarget),

        //Stall
        .StallF      (StallF)
    );

//--------------------------------
//-------Pipeline Fetch-----------
//--------------------------------

    logic [DATA_WIDTH-1:0]      instrD;
    logic [DATA_WIDTH-1:0]      pcD;
    logic [DATA_WIDTH-1:0]      PCPlus4D;

    fetch_reg pipeline_fetch(
        .clk        (clk),
        .instrF     (instr),
        .pcF        (pc),
        .PCPlus4F   (PCPlus4),

        .FlushF      (FlushF),
        .StallF      (StallF),

        .instrD     (instrD),
        .pcD        (pcD),
        .PCPlus4D   (PCPlus4D)
    );


//--------------------------------
//------------DECODE--------------
//--------------------------------

    top_decode decode(
        .clk        (clk),
        .trigger    (trigger),
        .instr      (instrD),
        .ALUctrl    (ALUctrl),
        .ALUSrc     (ALUSrc),
        .MemWrite   (MemWrite),
        .ResultSrc  (ResultSrc),
        .Branch     (Branch),
        .Jump       (Jump),
        .branch_neg (branch_neg),
        .ImmExt     (ImmExt),
        .PcOp       (PcOp),
        .Result     (Result),
        .rd1        (rd1),
        .rd2        (rd2),
        .RegWrite   (RegWriteW),
        .RegWriteD  (RegWriteD),
        .Rd         (RdW),
        .a0         (a0)
    );

//--------------------------------
//-------Pipeline Decode----------
//--------------------------------

    logic [2:0]             ALUctrlE;
    logic                   ALUSrcE;
    logic                   MemWriteE;
    logic [1:0]             ResultSrcE;
    logic                   BranchE;
    logic                   JumpE;
    logic                   branch_negE;
    logic [DATA_WIDTH-1:0]  ImmExtE;
    logic                   PcOpE;
    logic [DATA_WIDTH-1:0]  rd1E;
    logic [DATA_WIDTH-1:0]  rd2E;
    logic [DATA_WIDTH-1:0]  pcE;
    logic [14:12]           instr_14_12E;
    logic [DATA_WIDTH-1:0]  PCPlus4E;
    logic                   RegWriteE;
    logic [11:7]            RdE;
    logic [19:15]           rs1E;
    logic [24:20]           rs2E;    


    decode_reg pipeline_decode(
        .clk         (clk),
        .ALUctrlD    (ALUctrl),
        .ALUSrcD     (ALUSrc),
        .MemWriteD   (MemWrite),
        .ResultSrcD  (ResultSrc),
        .BranchD     (Branch),
        .JumpD       (Jump),
        .branch_negD (branch_neg),
        .ImmExtD     (ImmExt),
        .PcOpD       (PcOp),
        .rd1D        (rd1),
        .rd2D        (rd2),
        .pcD         (pcD),
        .instr_14_12D(instrD[14:12]),
        .PCPlus4D    (PCPlus4D),
        .RegWriteD   (RegWriteD),
        .RdD         (instrD[11:7]),
        .rs1D        (instrD[19:15]),
        .rs2D        (instrD[24:20]),

        .FlushD      (FlushD),
        .StallD      (StallD),

        .ALUctrlE    (ALUctrlE),
        .ALUSrcE     (ALUSrcE),
        .MemWriteE   (MemWriteE),
        .ResultSrcE  (ResultSrcE),
        .BranchE     (BranchE),
        .JumpE       (JumpE),
        .branch_negE (branch_negE),
        .ImmExtE     (ImmExtE),
        .PcOpE       (PcOpE),
        .rd1E        (rd1E),
        .rd2E        (rd2E),
        .pcE         (pcE),
        .instr_14_12E(instr_14_12E),
        .PCPlus4E    (PCPlus4E),
        .RegWriteE   (RegWriteE),
        .RdE         (RdE),
        .rs1E        (rs1E),
        .rs2E        (rs2E)
    );

//--------------------------------
//-----------EXECUTE--------------
//--------------------------------

    logic [DATA_WIDTH-1:0]  rd2_h;

    top_execute execute(
        .ALUctrl    (ALUctrlE),
        .ALUSrc     (ALUSrcE),
        .ImmExt     (ImmExtE),
        .ALUResult  (ALUResult),
        .PcOp       (PcOpE),
        .pc         (pcE),
        .rd1        (rd1E),
        .rd2        (rd2E),
        .PCTarget   (PCTarget),
        .Jump       (JumpE),
        .Branch     (BranchE),
        .branch_neg (branch_negE),
        .PCSrc      (PCSrc),
        .ForwardAE  (ForwardAE),
        .ForwardBE  (ForwardBE),
        .ResultW    (Result),
        .ALUResultM (ALUResultM),
        .rd2_h      (rd2_h)
    );

//--------------------------------
//-------Pipeline Execute---------
//--------------------------------

    logic [DATA_WIDTH-1:0]   WriteDataM;
    logic [DATA_WIDTH-1:0]   ALUResultM;
    logic [11:7]             RdM;
    logic                    RegWriteM;
    logic [DATA_WIDTH-1:0]   PCPlus4M;
    logic                    MemWriteM;
    logic [1:0]              ResultSrcM;
    logic [14:12]            funct3M;

    execute_reg pipeline_execute(
        .clk         (clk),
        .MemWriteE   (MemWriteE),
        .ResultSrcE  (ResultSrcE),
        .PCPlus4E    (PCPlus4E),
        .RegWriteE   (RegWriteE),
        .RdE         (RdE),
        .ALUResultE  (ALUResult),
        .WriteDataE  (rd2_h),
        .funct3E     (instr_14_12E),
        .MemWriteM   (MemWriteM),
        .ResultSrcM  (ResultSrcM),
        .PCPlus4M    (PCPlus4M),
        .RegWriteM   (RegWriteM),
        .RdM         (RdM),
        .ALUResultM  (ALUResultM),
        .WriteDataM  (WriteDataM),
        .funct3M     (funct3M)
    );


//--------------------------------
//------------MEMORY--------------
//--------------------------------

    top_memory memory(
        .clk        (clk), 
        .ALUResult  (ALUResultM),
        .WriteData  (WriteDataM),
        .MemWrite   (MemWriteM),
        .ReadData   (ReadData),
        .funct3     (funct3M)
    );

//--------------------------------
//-------Pipeline Memory---------
//--------------------------------

    logic [DATA_WIDTH-1:0]   ALUResultW;
    logic [DATA_WIDTH-1:0]   PCPlus4W;
    logic [11:7]             RdW;
    logic                    RegWriteW;
    logic [1:0]              ResultSrcW;
    logic [DATA_WIDTH-1:0]   ReadDataW;

    memory_reg pipeline_memory (
        .clk        (clk),
        .ALUResultM (ALUResultM),
        .PCPlus4M   (PCPlus4M),
        .RdM        (RdM),
        .RegWriteM  (RegWriteM),
        .ResultSrcM (ResultSrcM),
        .ReadDataM  (ReadData),

        .ALUResultW (ALUResultW),
        .PCPlus4W   (PCPlus4W),
        .RdW        (RdW),
        .RegWriteW  (RegWriteW),
        .ResultSrcW (ResultSrcW),
        .ReadDataW  (ReadDataW)
    );


//--------------------------------
//-----------Write Back-----------
//--------------------------------

always_comb begin
    case (ResultSrcW) 
        2'b00: Result = ALUResultW;
        2'b01: Result = ReadDataW;
        2'b10: Result = PCPlus4W;
        //TODO
        2'b11: Result = PCTarget;
    endcase
end
    
//--------------------------------
//----------HAZARD UNIT-----------
//--------------------------------

    logic[1:0] ForwardAE;
    logic[1:0] ForwardBE;
    logic      FlushD;
    logic      FlushF;
    logic      StallF;
    logic      StallD;

    hazard_unit pipeline_hazard (
        .Rs1E           (rs1E),
        .Rs2E           (rs2E),
        .RdM            (RdM),
        .RdW            (RdW),
        .RegWriteM      (RegWriteM),
        .RegWriteW      (RegWriteW),
        .ForwardAE      (ForwardAE),
        .ForwardBE      (ForwardBE),
        .Rs1D           (instrD[19:15]),
        .Rs2D           (instrD[24:20]),
        .RdE            (RdE),
        .ResultSrcE     (ResultSrcE),
        .StallF         (StallF),
        .StallD         (StallD),
        .FlushF         (FlushF),
        .PCSrcE         (PCSrc),
        .FlushD         (FlushD)
    );


endmodule
