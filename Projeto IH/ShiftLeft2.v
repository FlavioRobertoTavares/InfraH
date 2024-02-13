module ShiftLeft2 (
    input wire [31:0] immediate, output wire [31:0] immediate_resultado);

    assign immediate_resultado = immediate << 2;
    
endmodule