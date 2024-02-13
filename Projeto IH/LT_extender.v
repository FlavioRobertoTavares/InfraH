module LT_extender (
    input wire LT, output wire [31:0] LT_resultado);

    assign LT_resultado = {31'b0, LT};
    
endmodule