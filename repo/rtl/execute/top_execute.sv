`include <./execute/alu.sv>
`include <./execute/reg_module.sv>

module top_execute #(
    parameter  DATA_WIDTH = 32
)(
    input   logic                       clk,
    input   logic  [19:15]              rs1,
    input   logic  [24:20]              rs2,
    input   logic  [11:7]               rd,
    input   logic  [DATA_WIDTH-1:0]     ImmExt,
    input   logic  [3:0]                ALUctrl,
    input   logic                       WE3,
    input   logic                       ALUSrc,
    input   logic [DATA_WIDTH-1:0]      Result,
    input   logic [DATA_WIDTH-1:0]      pc,
    input   logic                       PcOp,

    output  logic [DATA_WIDTH-1:0]      ALUResult,
    output  logic                       Zero,
    output  logic [DATA_WIDTH-1:0]      a0,
    output  logic [DATA_WIDTH-1:0]      WriteData,
    output  logic [DATA_WIDTH-1:0]      PCTarget
);

    logic  [DATA_WIDTH-1:0]    RD1, ALUin;

    reg_module alu_reg(
        .clk(clk),
        .AD1(rs1),
        .AD2(rs2),
        .AD3(rd),
        .WE3(WE3),
        .WD3(Result),
        .RD1(RD1),
        .RD2(WriteData),
        .a0(a0)
    );

    mux alu_mux(
        .in0(WriteData),
        .in1(ImmExt),
        .sel(ALUSrc),
        .out(ALUin)
    );

    alu alu(
        .ALUop1(RD1),
        .ALUop2(ALUin),
        .ALUctrl(ALUctrl),
        .ALUout(ALUResult),
        .branch_l(Zero)
    );

    always_comb begin
        PCTarget = PcOp ? RD1 + ImmExt : pc + ImmExt;
    end

endmodule
