module cpu(
        input wire clk, reset
);
//----- Control wires
        wire EPC_write;
        wire MEM_write;
        wire A_write;
        wire B_write;
        wire ALUout_write;
        wire HI_write;
        wire LO_write;
        wire PC_write;
        wire [1:0] PcSource

//-----Data wires
        wire [31:0] EPC_in; 
        wire [31:0] EPC_out;
        wire [31:0] MEM_in; 
        wire [31:0] MEM_out;
        wire [31:0] A_in;
        wire [31:0] A_out; 
        wire [31:0] B_in;
        wire [31:0] B_out;
        wire [31:0] ALUout_in;
        wire [31:0] ALUout_out;
        wire [31:0] HI_in;
        wire [31:0] HI_out;
        wire [31:0] LO_in;
        wire [31:0] LO_out;
        wire [31:0] PC_Mux;
        wire [31:0] PC_out;
//-----MUXs
        wire[31:0] Offset;
        wire[31:0] Load_except;


        Registrador EPC(
                clk,
                reset,
                EPC_write,
                PC_in,
                EPC_out
        );
        Registrador PC(
                clk,
                reset,
                PC_write,
                PC_Mux,
                PC_out
        );
        Registrador MEM(
                clk,
                reset,
                MEM_write,
                MEM_in,
                MEM_out
        );
        Registrador A(
                clk,
                reset,
                A_write,
                A_in,
                A_out
        );
        Registrador B(
                clk,
                reset,
                B_write,
                B_in,
                B_out
        );
        Registrador ALUout(
                clk,
                reset,
                ALUout_write,
                ALUout_in,
                ALUout_out
        );
        Registrador HI(
                clk,
                reset,
                HI_write,
                HI_in,
                HI_out
        );
        Registrador LO(
                clk,
                reset,
                LO_write,
                LO_in,
                LO_out
        );
        mux_PcSource MUX_PcSource(
                ALUout_out,
                Offset, 
                Load_except, 
                EPC_out, 
                PcSource,
                PC_Mux
        );


endmodule