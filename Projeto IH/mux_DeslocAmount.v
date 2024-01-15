module mux_DeslocAmount (
    input wire [31:0] Shamt, RegB, Load, input wire [1:0] DeslocAmount, output wire [31:0] N);
    
    assign N =  (DeslocAmount == 0)? Shamt :
                (DeslocAmount == 1)? RegB :
                (DeslocAmount == 2)? 16 : //Imeddiate
                (DeslocAmount == 3)? Load :
                x; 

endmodule