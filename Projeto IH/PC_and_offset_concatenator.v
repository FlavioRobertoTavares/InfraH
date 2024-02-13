module PC_and_offset_concatenator (
    input wire [25:0] offset, input wire [31:0] PC, output wire [31:0] offset_resultado);

    assign offset = {offset, 2'b00};
    assign offset_resultado = {PC[31:28], offset};

endmodule