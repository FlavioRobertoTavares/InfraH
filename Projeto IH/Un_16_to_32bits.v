module Un_16_to_32bits (
    input wire Un, input wire [15:0] immediate, output wire [31:0] immediate_resultado);

    assign immediate_resultado = ( (Un == 0) && (immediate[15] == 0) )? {16'h0000, immediate} :
                                 ( (Un == 0) && (immediate[15] == 1) )? {16'hffff, immediate} :
                                 {16'h0000, immediate};

endmodule
