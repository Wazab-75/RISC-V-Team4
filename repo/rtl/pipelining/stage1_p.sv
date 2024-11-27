module  Stage1#(
    parameter DATA_WIDTH = 32
)(
    input logic                     clk,
    input logic                     en,
    input logic                     rst,

    //instrmem input
    input logic[DATA_WIDTH-1:0]        addr,
    //PC input
    input logic[DATA_WIDTH-1:0]        pc_next,

    //instrmem output
    output logic[DATA_WIDTH-1:0]        dout,
    //PC output
    output logic[DATA_WIDTH-1:0]        pc,

);

always_ff @(posedge clk) begin
    if (rst) begin
        //instr
        dout <= 0;
        //pc
        pc<= 0;
       
    end
    else if(en) begin
        //instr
        dout <= dout;
        //pc
        pc<= pc;
        
    end
    else begin
        //instr
        dout <= addr;
        //pc
        pc<= pc_next;
        
    end
end
    
endmodule
