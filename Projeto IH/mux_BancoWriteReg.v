module mux_BancoWriteReg (
    input wire [4:0] rt, rd, rs, input wire [2:0] BancoWriteReg, output wire [4:0] WriteReg);
    
    assign WriteReg =  (BancoWriteReg == 0)? rt :
                    (BancoWriteReg == 1)? rd :
                    (BancoWriteReg == 2)? rs :
                    (BancoWriteReg == 3)? 29 : // SP
                    (BancoWriteReg == 4)? 31 : // JAL
                    5'bxxxxx; 

endmodule
