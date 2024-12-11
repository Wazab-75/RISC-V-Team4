module hazard_unit (
    //forwarding
    input logic[4:0]            Rs1E,
    input logic[4:0]            Rs2E,
    input logic[4:0]            RdM,
    input logic[4:0]            RdW,

    input logic                 RegWriteM,
    input logic                 RegWriteW,

    output logic[1:0]           ForwardAE,
    output logic[1:0]           ForwardBE,

    //stall
    input logic[4:0]             Rs1D,
    input logic[4:0]             Rs2D,
    input logic[4:0]             RdE,
    input logic[1:0]             ResultSrcE,

    output logic                 StallF,
    output logic                 StallD,
    output logic                 FlushF,
    
    //flush
    input logic                  PCSrcE,
    output logic                 FlushD
);

    //stall
    logic      ResultSrcE0;
    assign     ResultSrcE0 = (ResultSrcE == 2'b01);

    //flush
    logic      lwStall;

    // forwarding
    always_comb begin
        if (((Rs1E == RdM) & RegWriteM) & (Rs1E != 0)) ForwardAE = 2'b10;       // Forward from Memory stage 
        else if (((Rs1E == RdW) & RegWriteW) & (Rs1E != 0)) ForwardAE = 2'b01;  // Forward from Writeback stage 
        else ForwardAE = 2'b00;                                                 // No forwarding 

        if (((Rs2E == RdM) & RegWriteM) & (Rs2E != 0)) ForwardBE = 2'b10;       // Forward from Memory stage 
        else if (((Rs2E == RdW) & RegWriteW) & (Rs2E != 0)) ForwardBE = 2'b01;  // Forward from Writeback stage 
        else ForwardBE = 2'b00;                                                 // No forwarding 

    end

    // stall
    assign lwStall = ResultSrcE0 & ((Rs1D == RdE)|(Rs2D == RdE)); 
    assign StallF = lwStall;
    assign StallD = lwStall;

    //flush
    assign FlushF = PCSrcE;
    //assign FlushE = lwStall | PCSrcE;
    assign FlushD = lwStall || PCSrcE;

endmodule
