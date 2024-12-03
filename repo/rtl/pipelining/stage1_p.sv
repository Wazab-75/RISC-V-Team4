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

    //instrmem output
    output logic[DATA_WIDTH-1:0]        InstrD,
    //PC output
    output logic[DATA_WIDTH-1:0]        pc_next,

);

always_ff @(posedge clk) begin
    if (rst) begin
        //instr
        InstrD <= 0;
        //pc
        pc_next<= 0;
       
    end
    else if(en) begin
        //instr
        InstrD <= InstrD;
        //pc
        pc_next<= pc_next;
        
    end
    else begin
        //instr
        InstrD <=  RDi;
        //pc
        pc_next<= pc;
        
    end
end
    
endmodule
