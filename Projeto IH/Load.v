module Load (
    input wire [31:0] RegMemo, input wire [1:0] LoadControl, output reg [31:0] saida);
    
    always @(posedge LoadControl) begin
        if (LoadControl == 1) begin
            saida = {24'b0, RegMemo[7:0]}; 
        end

        else if (LoadControl == 2) begin
            saida = {16'b0 , RegMemo[15:0]}; 
        end

        else if (LoadControl == 3) begin
            saida = RegMemo; 
        end

        else begin
            saida = 32'hxxxxxxxx;
        end
        
    end

endmodule


