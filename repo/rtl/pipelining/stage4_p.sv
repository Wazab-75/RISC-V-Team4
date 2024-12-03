module  Stage4#(
    parameter DATA_WIDTH = 32
)(
    input logic                     clk,

    // control input 
    input logic                        RegWriteM,
    input logic[1:0]                   ResultSrcM,
    // ALU input
    input logic[DATA_WIDTH-1:0]        ALUResultM,
    //datamem input
    input logic[DATA_WIDTH-1:0]        ReadData,
    //rd
    input logic[4:0]                   RdM,
    //PC input
    input logic[DATA_WIDTH-1:0]        PC_PlusM,
   

    // control output
    output logic                        RegWriteW,
    output logic[1:0]                   ResultSrcW,
    // ALU output
    output logic[DATA_WIDTH-1:0]        ALUResultW,
    //datamem output
    output logic[DATA_WIDTH-1:0]        ReadDataW,
    //rd
    output logic[4:0]                   RdW,
    //PC output
    output logic[DATA_WIDTH-1:0]        PC_PlusW
    

);

always_ff @(posedge clk) begin
    //control
    RegWriteW <= RegWriteM;
    ResultSrcW <= ResultSrcM;
    //alu
    ALUResultW <= ALUResultM;
    //data mem
    ReadDataW <= ReadData;
     //rd
    RdW <= RdM;
    //PC
    PC_PlusW <= PC_PlusM;
end
    
endmodule
