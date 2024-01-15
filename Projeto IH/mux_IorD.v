module mux_IorD (
    input wire [31:0] PC, AluOut, input wire [2:0] IorD, output wire [31:0] MuxMemo);
    
    assign MuxMemo = (IorD == 0)? PC :
                     (IorD == 1)? AluOut :
                     (IorD == 2)? 255 : // Div0
                     (IorD == 3)? 254 : // Overflow
                     (IorD == 4)? 253 : // OpInex
                     x; 

endmodule