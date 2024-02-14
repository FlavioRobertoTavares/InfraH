module cpu(
        input wire clk, reset
);
//----- Control wires
        wire EPC_write;
        wire MEM_write;
        wire Store_ctrl;
        wire A_write;
        wire B_write;
        wire ALUout_write;
        wire HI_write;
        wire LO_write;
        wire PC_write;
        wire Un;
        wire [1:0] PcSource;
        wire [1:0] ALU_src_A;
        wire [1:0] ALU_src_B;
        wire [1:0] Desloc_src;
        wire [1:0] DeslocAmount;
        wire [2:0] bank_write_reg;
        wire [2:0] bank_write_data;
        wire [2:0] Desloc_Control;
        wire [2:0] IorD;

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
        wire[31:0] rt;
        wire[31:0] rd;
        wire[31:0] rs;
        wire[31:0] write_reg;
        wire[4:0] N;
        wire[31:0] Desloc_mux;
        wire[31:0] Reg_desloc_out;
        wire[31:0] Hi;
        wire[31:0] Lo;
        wire[31:0] Lt;
        wire[31:0] A;
        wire[31:0] B;
        wire[31:0] write_data;
        wire[31:0] Mux_Memo;
//-----Estendedor
        wire[15:0] immediate;
        wire[31:0] immediate_resultado;
//-----Shiftleft
        wire[31:0] Address;



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
        Registrador Load(
                clk,
                reset,
                Store_ctrl
                MEM_out,
                Load_except
        );
        RegDesloc Reg_deslocamento(
                clk,
                reset,
                Desloc_Control,
                N,
                Desloc_mux;
                Reg_desloc_out;
        );
        mux_PcSource MUX_1(
                ALUout_out,
                Offset, 
                Load_except, 
                EPC_out, 
                PcSource,
                PC_Mux
        );
        mux_IorD MUX_2(
                PC_out,
                ALUout_out,
                IorD,
                Mux_Memo
        );
        mux_BancoWriteReg MUX_3(
                rt,
                rd,
                rs,
                bank_write_reg,
                write_reg
        );
        mux_BancoWriteData MUX_4(
                ALUout_out,
                Load_except,
                Reg_desloc_out,
                Hi,
                Lo,
                PC_out,
                Lt,
                bank_write_data,
                write_data
        );
        mux_ALUsrcA MUX_5(
                PC_out,
                B_out,
                A_out,
                ALU_src_A,
                A
        );
        muxALUsrcB MUX_6(
                B_out,
                Addres,
                immediate_resultado,
                ALU_src_B,
                B
        );
        mux_DeslocSrc MUX_7(
                A_out,
                B_out,
                immediate_resultado,
                Desloc_src,
                Desloc_mux

        );
        mux_DeslocAmount MUX_8(
                Shamt,
                B_out,
                Load_except,
                Desloc_Amount,
                N
        );
        Un_16_to_32bits un_16_32(
                Un,
                immediate,
                immediate_resultado
        );
        ShiftLeft2 shitleft(
                immediate_resultado,
                Address, 
        );

endmodule