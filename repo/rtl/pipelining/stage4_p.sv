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
   

    // control output
    output logic                        RegWriteW,
    output logic[1:0]                   ResultSrcW,
    // ALU output
    output logic[DATA_WIDTH-1:0]        ALUResultW,
    //datamem output
    output logic[DATA_WIDTH-1:0]        ReadDataW,
    //rd
    output logic[4:0]                   RdW,
    

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
end
    
endmodule
