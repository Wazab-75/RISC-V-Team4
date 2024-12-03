module Stage2#(
    parameter DATA_WIDTH = 32
)(
    input logic                     clk,
    input logic                     rst,
    // control input
    input logic                     RegWrite,
    input logic[1:0]                ResultSrc,
    input logic                     MemWrite,
    input logic [3:0]                    ALUctrl,

    input logic                     ALUSrc,
 
    // regfile input 
    input logic[DATA_WIDTH-1:0]     RD1,
    input logic[DATA_WIDTH-1:0]     RD2,
    //
    input logic[4:0]                RdD,
    //
    input logic[4:0]                ReadData,
    // extend input
    input logic[DATA_WIDTH-1:0]     ImmExt,
    //PC input
    input logic[DATA_WIDTH-1:0]     pc,
    input logic[DATA_WIDTH-1:0]     PC_PlusD,
     // forward
    input logic[4:0]                Rs1D,
    input logic[4:0]                Rs2D,
    
    
    // control output 
    output logic                    RegWriteE,
    output logic[1:0]               ResultSrcE,
    output logic                    MemWriteE,
    output logic [3:0]                   ALUctrlE,
    output logic                    ALUSrcE,
    // regfile output 
    output logic[DATA_WIDTH-1:0]     RD1E,
    output logic[DATA_WIDTH-1:0]     RD2E,
    //rd
    output logic[4:0]                RdE,
    output logic[4:0]                ReadDataE,
    // extend output
    output logic[DATA_WIDTH-1:0]     ImmExtE,
    //PC output
    output logic[DATA_WIDTH-1:0]     pce,
    output logic[DATA_WIDTH-1:0]     PC_PlusE,
    //output
    output logic[4:0]                Rs1E,
    output logic[4:0]                Rs2E

    

    //function3
    input logic[2:0]                funct3,
    output logic[2:0]               funct3E,

  

);

always_ff @(posedge clk) begin
    if (rst) begin
        // Clear all registers when rst is active
        RegWriteE <= 0;
        ResultSrcE <= 0;
        MemWriteE <= 0;
        ALUctrlE <= 0;
        ALUSrcE <= 0;
        RD1E <= 0;
        RD2E <= 0;
        RdE <= 0;
        ReadDataE <= 0;
        ImmExtE <= 0;
        pce <= 0;
        PC_PlusE <= 0;
        Rs1E <= 0;
        Rs2E <= 0;
        funct3E<=0;
    end 
    else begin
        //control
        RegWriteE <= RegWrite;
        ResultSrcE <= ResultSrc;
        MemWriteE <= MemWrite;
        ALUctrlE <= ALUctrl;
        ALUSrcE <= ALUSrc;
        //regfile
        RD1E <= RD1;
        RD2E <= RD2;
        //rd
        RdE <= RdD;
        //rd
        ReadDataE <= ReadData;
        //extend
        ImmExtE <= ImmExt;
        //PC
        pce <= pc;
        PC_PlusE <= PC_PlusD;

        funct3E<=funct3;
    end

end
    
endmodule
