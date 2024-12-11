module fetch_reg #(
    parameter   ADDRESS_WIDTH = 32
) (
    input  logic                       clk,
    input  logic [ADDRESS_WIDTH-1:0]   instrF,
    input  logic [ADDRESS_WIDTH-1:0]   pcF,
    input  logic [ADDRESS_WIDTH-1:0]   PCPlus4F,

    //Flush
    input  logic                       FlushF,

    //Stall 
    input  logic                       StallF,

    output logic [ADDRESS_WIDTH-1:0]   instrD,
    output logic [ADDRESS_WIDTH-1:0]   pcD,
    output logic [ADDRESS_WIDTH-1:0]   PCPlus4D
);


    always_ff @(posedge clk) begin
        if (!StallF) begin
            if (FlushF) begin
                instrD <= 0;
                pcD <= 0;
                PCPlus4D <= 0;
            end
            else begin 
                instrD <= instrF;
                pcD <= pcF;
                PCPlus4D <= PCPlus4F;                
            end
        end 
    end
endmodule
