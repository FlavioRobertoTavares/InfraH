module mux_ALUsrcB (
    input wire [31:0] RegB, Addres, Off_immedi, input wire [1:0] ALUsrcB, output wire [31:0] B);
    
    assign B =  (ALUsrcB == 0)? RegB :
                (ALUsrcB == 1)? 4 : // Quatro
                (ALUsrcB == 2)? Addres :
                (ALUsrcB == 3)? Off_immedi :
                32'hxxxxxxxx; 

endmodule