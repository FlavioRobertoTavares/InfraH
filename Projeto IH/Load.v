module Load (
    input wire [31:0] RegMemo, input wire [1:0] LoadControl, output wire [31:0] saida);
    
    assign saida = (LoadControl == 1)? {24'b0, RegMemo[7:0]} :
                   (LoadControl == 2)? {16'b0 , RegMemo[15:0]} :
                   (LoadControl == 3)? RegMemo :
                   32'hxxxxxxxx;

endmodule