module mux_BancoWriteData (
    input wire [31:0] AluOut, Load, RegDeslocamento, Hi, Lo, PC, LT input wire [2:0] BancoWriteData, output wire [31:0] WriteData);
    
    assign WriteData = (BancoWriteData == 0)? AluOut :
                       (BancoWriteData == 1)? Load :
                       (BancoWriteData == 2)? RegDeslocamento : 
                       (BancoWriteData == 3)? Hi : 
                       (BancoWriteData == 4)? Lo :
                       (BancoWriteData == 5)? 227 : // Começo da pilha
                       (BancoWriteData == 6)? PC :
                       (BancoWriteData == 7)? LT : //ver se é 1 bit
                       x; 

endmodule