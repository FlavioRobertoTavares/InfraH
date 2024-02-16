module Store (
    input wire [31:0] RegMemo, RegB, input wire [1:0] StoreControl, output wire [31:0] saida);
    
    assign  saida = (StoreControl == 1)? {RegMemo[31:8], RegB[7:0]} :
                    (StoreControl == 2)? {RegMemo[31:16], RegB[15:0]} :
                    (StoreControl == 3)? RegB :
                    32'hxxxxxxxx;

endmodule