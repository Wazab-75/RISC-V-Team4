module Stage3#(
    parameter DATA_WIDTH = 32
)(
    input logic                     clk,
 

    // control input 
    input logic                        RegWriteE,
    input logic[1:0]                   ResultSrcE,
    input logic                        MemWriteE,
    // ALU input
    input logic[DATA_WIDTH-1:0]        ALUResult,
    //regfile input
    input logic[DATA_WIDTH-1:0]        WriteDataE,
    //rd
    input logic[4:0]                   RdE,
    //PC input
    input logic[DATA_WIDTH-1:0]        PC_PlusE,
    
   

    // control output 
    output logic                        RegWriteM,
    output logic[1:0]                   ResultSrcM,
    output logic                        MemWriteM,
    // ALU output
    output logic[DATA_WIDTH-1:0]        ALUResultM,
    //regfile output
    output logic[DATA_WIDTH-1:0]        WriteDataM,
     //rd
    output logic[4:0]                   RdM,
    //PC output
    output logic[DATA_WIDTH-1:0]        PC_PlusM
   
    

);

always_ff @(posedge clk) begin
        //control
        RegWriteM <= RegWriteE;
        ResultSrcM <= ResultSrcE;
        MemWriteM <= MemWriteE;
        //alu
        ALUResultM <= ALUResult;
        //regfile
        WriteDataM <= WriteDataE;
        //rd
        RdM <= RdE;
        //PC
        PC_PlusM <= PC_PlusE;
       
       
    end
// end
    
endmodule
