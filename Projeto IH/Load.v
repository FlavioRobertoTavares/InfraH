module Load (
    input wire [31:0] RegMemo, input wire [1:0] LoadControl, output reg [31:0] saida);
    
    always @(posedge LoadControl) begin
        if (LoadControl == 1)
            saida = {2'b000000000000000000000000, RegMemo[7:0]};
        else if (LoadControl == 2)
            saida = {2'b0000000000000000 , RegMemo[15:0]};
        else if (LoadControl == 3)
            saida = RegMemo;
        else
            saida = x;
    end

endmodule