module Store (
    input wire [31:0] RegMemo, RegB, input wire [1:0] StoreControl, output reg [31:0] saida);
    
    always @(posedge StoreControl) begin
        if (StoreControl == 1)
            saida = {RegMemo[31:8], RegB[7:0]};
        else if (StoreControl == 2)
            saida = {RegMemo[31:16], RegB[15:0]};
        else if (StoreControl == 3)
            saida = RegB;
        else
            saida = x;
    end

endmodule