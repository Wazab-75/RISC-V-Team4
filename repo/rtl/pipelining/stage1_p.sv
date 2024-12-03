module  Stage1#(
    parameter DATA_WIDTH = 32
)(
    input logic                     clk,
    input logic                     en,
    input logic                     rst,

    //instrmem input
    input logic[DATA_WIDTH-1:0]         RDi,
    //PC input
    input logic[DATA_WIDTH-1:0]        pc,
    input logic[DATA_WIDTH-1:0]        PC_PlusF,

    //instrmem output
    output logic[DATA_WIDTH-1:0]        InstrD,
    //PC output
    output logic[DATA_WIDTH-1:0]        pc_next,
    output logic[DATA_WIDTH-1:0]        PC_PlusD

);

always_ff @(posedge clk) begin
    if (rst) begin
        //instr
        InstrD <= 0;
        //pc
        pc_next<= 0;
        PC_PlusD <= 0; 
       
    end
    else if(en) begin
        //instr
        InstrD <= InstrD;
        //pc
        pc_next<= pc_next;
        PC_PlusD <= PC_PlusD; 
        
    end
    else begin
        //instr
        InstrD <=  RDi;
        //pc
        pc_next<= pc;
        PC_PlusD <= PC_PlusF; 
        
    end
end
    
endmodule
