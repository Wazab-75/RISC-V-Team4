module top #(
    parameter   DATA_WIDTH = 32
) (
    input   logic clk,
    input   logic rst,
    output  logic [DATA_WIDTH-1:0] a0    
);
    

    logic [DATA_WIDTH-1:0]      pc;
    logic [DATA_WIDTH-1:0]      ImmExt;
    logic                       PCSrc;
    logic [DATA_WIDTH-1:0]      instr;
    logic                       EQ;
    logic [2:0]                 ALUctrl;
    logic                       RegWrite;
    logic                       ALUSrc;
    logic                       MemWrite;
    logic                       ResultSrc;
    logic [DATA_WIDTH-1:0]      ALUResult;
    logic [DATA_WIDTH-1:0]      WriteData;
    logic [DATA_WIDTH-1:0]      Result;

    top_fetch fetch(
        .clk         (clk),
        .rst         (rst),
        .PCSrc       (PCSrc),
        .ImmExt      (ImmExt),
        .pc          (pc)
    );

    inst_mem inst_mem (
        .addr       (pc),
        .dout       (instr)
    );

    top_decode decode(
        .instr      (instr),
        .EQ         (EQ),
        .ALUctrl    (ALUctrl),
        .RegWrite   (RegWrite),
        .ALUSrc     (ALUSrc),
        .MemWrite   (MemWrite),
        .ResultSrc  (ResultSrc),
        .PCSrc      (PCSrc),
        .ImmExt     (ImmExt)
    );

    top_execute execute(
        .clk        (clk),
        .instr_11_7 (instr[11:7]),
        .instr_19_15(instr[19:15]),
        .instr_24_20(instr[24:20]),
        .ALUctrl    (ALUctrl),
        .ALUSrc     (ALUSrc),
        .RegWrite   (RegWrite),
        .Result     (Result),
        .ImmExt     (ImmExt),
        .a0         (a0),
        .ALUResult  (ALUResult),
        .EQ         (EQ),
        .WriteData  (WriteData)
    );

    top_memory memory(
        .clk        (clk), 
        .ALUResult  (ALUResult),
        .WriteData  (WriteData),
        .ResultSrc  (ResultSrc),
        .MemWrite   (MemWrite),
        .Result     (Result)
    );

    //assign a0 = 32'd5;

endmodule
