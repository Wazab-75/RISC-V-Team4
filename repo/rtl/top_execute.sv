module top_execute #(
    parameter  DATA_WIDTH = 32
)(
    input   logic                       clk,
    input   logic  [19:15]              instr_19_15,
    input   logic  [24:20]              instr_24_20,
    input   logic  [11:7]               instr_11_7,
    input   logic  [DATA_WIDTH-1:0]     ImmExt,
    input   logic  [2:0]                ALUctrl,
    input   logic                       WE3,
    input   logic                       ALUSrc,

    output  logic [DATA_WIDTH-1:0]      ALUResult,
    output  logic                       EQ,
    output  logic   [DATA_WIDTH-1:0]    a0
);

    logic  [DATA_WIDTH-1:0]    RD1, RD2, ALUin;

    reg_module alu_reg(
        .clk(clk),
        .AD1(instr_19_15),
        .AD2(instr_24_20),
        .AD3(instr_11_7),
        .WE3(WE3),
        .WD3(ALUResult),
        .RD1(RD1),
        .RD2(RD2),
        .a0(a0)
    );

    mux alu_mux(
        .in0(RD2),
        .in1(ImmExt),
        .sel(ALUSrc),
        .out(ALUin)
    );

    alu alu(
        .ALUop1(RD1),
        .ALUop2(ALUin),
        .ALUctrl(ALUctrl),
        .ALUout(ALUResult),
        .EQ(EQ)
    );

endmodule
