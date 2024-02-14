module mux_DeslocSrc (
    input wire [31:0] RegA, RegB, Immediate, input wire [1:0] DeslocSrc, output wire [31:0] DeslocMux);
    
    assign DeslocMux = (DeslocSrc == 0)? RegA :
                       (DeslocSrc == 1)? RegB :
                       (DeslocSrc == 2)? Immediate :
                       32'hxxxxxxxx; 

endmodule