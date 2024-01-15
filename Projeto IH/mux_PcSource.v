module mux_PcSource (
    input wire [31:0] AluOut, Offset, Load_except, EPC, input wire [1:0] PcSource, output wire [31:0] PcMux);
    
    assign PcMux =  (PcSource == 0)? AluOut :
                    (PcSource == 1)? Offset :
                    (PcSource == 2)? Load_except :
                    (PcSource == 3)? EPC :
                    x; 

endmodule