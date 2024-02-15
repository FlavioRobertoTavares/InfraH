module cpu(
        input wire clk, reset
);
//----- Control wires
        wire EPC_write;
        wire MEM_write;
        wire bank_write;
        wire negativo;
        wire DivZero;
        wire Signedn;
        wire wr;
        wire ir_write;
        wire mem_reg_write;
        wire zero;
        wire A_write;
        wire B_write;
        wire ALUout_write;
        wire HI_write;
        wire LO_write;
        wire PC_write;
        wire LT;
        wire GT;
        wire EG;
        wire [1:0] Store_ctrl;
        wire [1:0] Load_ctrl;
        wire [1:0] PcSource;
        wire [1:0] ALU_src_A;
        wire [1:0] ALU_src_B;
        wire [1:0] Desloc_src;
        wire [1:0] DeslocAmount;
        wire [1:0] DivMultControl;
        wire [2:0] bank_write_reg;
        wire [2:0] bank_write_data;
        wire [2:0] Desloc_Control;
        wire [2:0] IorD;
        wire [2:0] ALU_op;



//-----Data wires
        wire [31:0] result; 
        wire [25:0] offset;
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
        wire [5:0]  OP;
        wire [5:0]  Funct;
//-----MUXs
        wire [4:0] rt;
        wire [4:0] rd;
        wire [4:0] rs;
        wire [31:0] offset_resultado;
        wire [31:0] Load_except;
        wire [4:0]  Shamt;
        wire [4:0] write_reg;
        wire [4:0]  N;
        wire [31:0] Desloc_mux;
        wire [31:0] Reg_desloc_out;
        wire [31:0] LT_MUX;
        wire [31:0] A;
        wire [31:0] B;
        wire [31:0] write_data;
        wire [31:0] Mux_Memo;
//-----Estendedor
        wire [15:0] immediate;
        wire [31:0] immediate_resultado;
//-----Shiftleft
        wire [31:0] Address;
//-----Store
        wire [31:0] write;
//------Unidade de controle

        Controle unidade_controle(
                .reset(reset),
                .clk(clk),
                .zero(zero),
                .div_zero(DivZero),
                .overflow(overflow),
                .GT(GT),
                .EG(EG),
                .LT(LT),
                .OP(OP),
                .funct(Funct),
                .PC_src(PcSource),
                .ALU_src_A(ALU_src_A),
                .ALU_src_B(ALU_src_B),
                .sh_src(Desloc_src),
                .div_mult_ctrl(DivMultControl),
                .load_ctrl(Load_ctrl),
                .store_ctrl(Store_ctrl),
                .bank_write_reg(bank_write_reg),
                .bank_write_data(bank_write_data),
                .ALU_op(ALU_op),
                .iorD(IorD),
                .sh_ctrl(Desloc_Control),
                .signedn(Signedn),
                .sh_amt(DeslocAmount),
                .wr(wr),
                .ir_write(ir_write),
                .PC_write(PC_write),
                .bank_write(bank_write),
                .EPC_write(EPC_write),
                .A_write(A_write),
                .B_write(B_write),
                .ALU_out_write(ALUout_write),
                .Lo_write(LO_write),
                .Hi_write(HI_write),
                .mem_reg_write(mem_reg_write)
        );
//------ULA
        ula32 ULA(
                A,
                B,
                ALU_op,
                result,
                overflow,
                negativo,
                zero,
                EG,
                GT,
                LT
        );
//------Registradores
        Registrador EPC(
                clk,
                reset,
                EPC_write,
                result,
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
        Registrador RegA(
                clk,
                reset,
                A_write,
                A_in,
                A_out
        );
        Registrador RegB(
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
                result,
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
        RegDesloc Reg_deslocamento(
                clk,
                reset,
                Desloc_Control,
                N,
                Desloc_mux,
                Reg_desloc_out
        );
//------Estruturas relacionadas a memoria e armazenamento
        Memoria memoria(
                Mux_Memo,
                clk,
                wr,
                write,
                MEM_in
        );
        Load load(
                MEM_out,
                Load_ctrl,
                Load_except
        );
        Store store(
                MEM_out,
                B_out,
                Store_ctrl,
                write
        );
        Instr_Reg IR(
                clk,
                reset,
                ir_write,
                MEM_in,
                OP,
                rs,
                rt,
                immediate        
        );
        assign  rd = immediate[15:11],
                Shamt = immediate[10:6],
                Funct = immediate[5:0],
                offset = {rs, rt, immediate};
        
        Banco_reg Regbank(
                clk,
                reset,
                bank_write,
                rs,
                rt,
                write_reg,
                write_data,
                A_in,
                B_in

        );
//------MUXES
        mux_PcSource MUX_1(
                ALUout_out,
                offset_resultado, 
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
                HI_out,
                LO_out,
                PC_out,
                LT_MUX,
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
        mux_ALUsrcB MUX_6(
                B_out,
                Address,
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
                {27'b0, Shamt},
                B_out,
                Load_except,
                DeslocAmount,
                N
        );

//------Divisor e multiplicador
        MultDiv Mult_Div(
                A_out,
                B_out,
                DivMultControl,
                clk,
                reset,
                HI_in,
                LO_in,
                DivZero
        );

//------Estendedor e Shifter
        LT_extender extender1_32(
                LT,
                LT_MUX
        );
        PC_and_offset_concatenator extender26_28(
                offset,
                PC_out,
                offset_resultado
        );
        Un_16_to_32bits un_16_32(
                Signedn,
                immediate,
                immediate_resultado
        );
        ShiftLeft2 shitleft(
                immediate_resultado,
                Address
        );

endmodule
