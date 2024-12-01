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
    
   

    // control output 
    output logic                        RegWriteM,
    output logic[1:0]                   ResultSrcM,
    output logic                        MemWriteM,
    // ALU output
    output logic[DATA_WIDTH-1:0]        ALUResultM,
    //regfile output
    output logic[DATA_WIDTH-1:0]        WriteDataM,
   
    

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
       
       
    end
// end
    
endmodule
