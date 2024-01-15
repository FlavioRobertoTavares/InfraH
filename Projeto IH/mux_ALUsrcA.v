module mux_ALUsrcA (
    input wire [31:0] PC, RegB, RegA, input wire [1:0] ALUsrcA, output wire [31:0] A);
    
    assign A =  (ALUsrcA == 0)? PC :
                (ALUsrcA == 1)? RegB :
                (ALUsrcA == 2)? RegA :
                x; 

endmodule