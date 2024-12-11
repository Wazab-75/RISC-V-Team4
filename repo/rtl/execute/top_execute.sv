`include <./execute/alu.sv>

module top_execute #(
    parameter   DATA_WIDTH = 32
)(
    input  logic [DATA_WIDTH-1:0]  pc,
    input  logic                   PcOp,
    input  logic [2:0]             ALUctrl,
    input  logic                   ALUSrc,
    input  logic [DATA_WIDTH-1:0]  ImmExt,
    input  logic [DATA_WIDTH-1:0]  rd1,
    input  logic [DATA_WIDTH-1:0]  rd2,
    input  logic                   Branch,
    input  logic                   Jump, 
    input  logic                   branch_neg,
    input  logic [1:0]             ForwardAE,
    input  logic [1:0]             ForwardBE,
    input  logic [DATA_WIDTH-1:0]  ResultW,
    input  logic [DATA_WIDTH-1:0]  ALUResultM,

    output logic [DATA_WIDTH-1:0]  ALUResult,
    output logic [DATA_WIDTH-1:0]  PCTarget,
    output logic                   PCSrc,
    output logic [DATA_WIDTH-1:0]  rd2_h
);
logic [DATA_WIDTH-1:0] ALUop2;
logic                  branch_l;
logic [DATA_WIDTH-1:0] rd1_h;



    always_comb begin
    case (ForwardAE)
            2'b00: rd1_h = rd1; 
            2'b01: rd1_h = ResultW;        
            2'b10: rd1_h = ALUResultM;     
            default: rd1_h = 32'b0;   
    endcase

    case (ForwardBE)
            2'b00: rd2_h = rd2; 
            2'b01: rd2_h = ResultW;        
            2'b10: rd2_h = ALUResultM;     
            default: rd2_h = 32'b0;   
    endcase
    end 

mux ALuSrc2Sel (
    .in0        (rd2_h),
    .in1        (ImmExt),
    .sel        (ALUSrc),
    .out        (ALUop2)
);

alu alu(
    .ALUop1     (rd1_h),
    .ALUop2     (ALUop2),
    .ALUctrl    (ALUctrl),
    .ALUout     (ALUResult),
    .branch_l   (branch_l)
);

always_comb begin
    PCTarget = PcOp ? rd1 + ImmExt : pc + ImmExt;
    PCSrc = (Branch && (branch_l ^ branch_neg)) || Jump;
end


endmodule
