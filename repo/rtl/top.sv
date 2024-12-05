`include <mux.sv>
`include <./fetch/top_fetch.sv>
`include <./decode/top_decode.sv>
`include <./execute/top_execute.sv>
`include <./memory/top_memory.sv>
`include <./memory/inst_mem.sv>


module top #(
    parameter   DATA_WIDTH = 32
) (
    input   logic clk,
    input   logic rst,
    input   logic trigger,
    output  logic [DATA_WIDTH-1:0] a0    
);
    //TODO
    logic unused_trigger = trigger;

    logic [DATA_WIDTH-1:0]      pc;
    logic [DATA_WIDTH-1:0]      ImmExt;
    logic                       PCSrc;
    logic [DATA_WIDTH-1:0]      instr;
    logic                       Zero;
    logic [3:0]                 ALUctrl;
    logic                       RegWrite;
    logic                       ALUSrc;
    logic                       MemWrite;
    logic [1:0]                 ResultSrc;
    logic [DATA_WIDTH-1:0]      ALUResult;
    logic [DATA_WIDTH-1:0]      WriteData;
    logic [DATA_WIDTH-1:0]      Result;
    logic [4:0]                 rs1;
    logic [4:0]                 rs2;
    logic [4:0]                 rd;
    logic                       PcOp;
    logic [DATA_WIDTH-1:0]      PCTarget;
    logic [DATA_WIDTH-1:0]      PCPlus4;


    top_fetch fetch(
        .clk         (clk),
        .rst         (rst),
        .PCSrc       (PCSrc),
        .PCTarget    (PCTarget),
        .PCPlus4     (PCPlus4),
        .pc          (pc)
    );

    inst_mem inst_mem (
        .addr       (pc),
        .dout       (instr)
    );

    top_decode decode(
        .instr      (instr),
        .Zero       (Zero),
        .ALUctrl    (ALUctrl),
        .RegWrite   (RegWrite),
        .ALUSrc     (ALUSrc),
        .MemWrite   (MemWrite),
        .MemRead    (MemRead),
        .ResultSrc  (ResultSrc),
        .PCSrc      (PCSrc),
        .ImmExt     (ImmExt),
        .rs1        (rs1),
        .rs2        (rs2),
        .rd         (rd),
        .PcOp       (PcOp)
    );

    top_execute execute(
        .clk        (clk),
        .rs1        (rs1),
        .rs2        (rs2),
        .rd         (rd),
        .ALUctrl    (ALUctrl),
        .ALUSrc     (ALUSrc),
        .WE3        (RegWrite),
        .Result     (Result),
        .ImmExt     (ImmExt),
        .a0         (a0),
        .ALUResult  (ALUResult),
        .Zero       (Zero),
        .WriteData  (WriteData),
        .pc         (pc),
        .PCTarget   (PCTarget),
        .PcOp       (PcOp)
    );

    top_memory memory(
        .clk        (clk), 
        .ALUResult  (ALUResult),
        .WriteData  (WriteData),
        .ResultSrc  (ResultSrc),
        .MemWrite   (MemWrite),
        .MemRead    (MemRead),
        .Result     (Result),
        .funct3     (instr[14:12]),
        .PCPlus4    (PCPlus4)
    );


endmodule
