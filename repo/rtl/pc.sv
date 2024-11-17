module pc #(
    parameter ADDRESS_WIDTH = 5
)(
    input wire clk,                       
    input wire rst,                       
    input wire [ADDRESS_WIDTH-1:0] pc_next,  
    output reg [ADDRESS_WIDTH-1:0] pc     
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) 
            pc <= {ADDRESS_WIDTH{1'b0}};  
        else 
            pc <= pc_next;                /
    end

endmodule

