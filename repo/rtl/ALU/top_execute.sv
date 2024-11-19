module top_execute #(
    parameter  ADDRESS_WIDTH = 5,
               DATA_WIDTH = 32
)(
    input   logic       clk,
    input   logic  [DATA_WIDTH-1:0]     instr,
    input   logic  [DATA_WIDTH-1:0]     ImmExt,
    input   logic  [2:0]                ALUctrl,
    input   logic                       WE3,
    input   logic                       ALUSrc,

    output  logic [DATA_WIDTH-1:0]      ALUout,
    output  logic                       EQ,
    output  logic   [DATA_WIDTH-1:0]    a0
);

    logic  [DATA_WIDTH-1:0]    RD1, RD2, ALUin;

    reg_module alu_reg(
        .clk(clk),
        .AD1(instr[19:15]),
        .AD2(instr[24:20]),
        .AD3(instr[11:7]),
        .WE3(WE3),
        .WD3(ALUout),
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

    ALU alu(
        .ALUop1(RD1),
        .ALUop2(ALUin),
        .ALUctrl(ALUctrl),
        .ALUout(ALUout),
        .EQ(EQ)
    );

endmodule
