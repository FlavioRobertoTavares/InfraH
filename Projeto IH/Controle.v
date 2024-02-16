module Controle (

        //Reset e borda de relogio
        input   wire reset,
                wire clk,

        //Entradas da ALU
        input   wire zero,                      //Zero flag
                wire div_zero,                  //Division by zero flag
                wire overflow,                  //Overflow flag
                wire GT,                        //Greater than flag
                wire EG,                        //Equal flag
                wire LT,                        //Less than flag

        //Entradas de Intrucoes
        input   wire[5:0] OP,
                wire[5:0] funct,

        //Sinais de selecao
        output  reg[1:0] PC_src,                //PC source
                reg[1:0] ALU_src_A,             //ALU source A
                reg[1:0] ALU_src_B,             //ALU source B
                reg[1:0] sh_src,                //Deslocamento source
                reg[1:0] sh_amt,                //Deslocamento amount
                reg[1:0] div_mult_ctrl,         //Div/mult control
                reg[1:0] load_ctrl,             //Seleciona bite, half ou word
                reg[1:0] store_ctrl,            //Seleciona bite, half ou word
                reg[2:0] bank_write_reg,        
                reg[2:0] bank_write_data,       
                reg[2:0] ALU_op,                //ALU operation
                reg[2:0] iorD,                  
                reg[2:0] sh_ctrl,               //Deslocamento controle

        output  reg signedn,                    //Signed/unsigned control

        //Sinais de leitura/escrita
        output  reg wr,                         //Memory read/write
                    ir_write,                   //Instruction register write signal
                    PC_write,                   
                    bank_write,                                 
                    EPC_write,                  //Exception PC register write signal
                    A_write,                    //A operand register write signal
                    B_write,                    //B operand register write signal
                    ALU_out_write,              //ALU result register write signal
                    Lo_write,                   //Lo register wirte signal
                    Hi_write,                   //Hi register write signal
                    mem_reg_write               //
        
);
        `include "Estados.vh"
        `include "Opcodes.vh"
        `include "Param_Muxes.vh"

        reg [5:0]state;
        reg [5:0]counter;

        task Bank_Write(input[2:0] bank_reg, data); begin
                bank_write_reg = bank_reg;
                bank_write_data = data;
                bank_write = 1;
        end
        endtask
        task ALU_Operation(input[1:0] op, src_A, src_B); begin
                ALU_op = op;
                ALU_src_A = src_A;
                ALU_src_B = src_B;
        end
        endtask
        task ALU_Forward(input[1:0] src); begin
                ALU_op = 0;
                ALU_src_A = src;
                ALU_out_write = 1;
        end
        endtask
        task Add(input[1:0] src_A, src_B); begin 
                ALU_Operation(ALU_ADD, src_A, src_B);
                ALU_out_write = 1;
        end
        endtask
        task Set_Less_Than(input[1:0] dest, src); begin
                if (counter == 0) ALU_Operation(ALU_CMP, A_SRC_A, src);
                else begin
                        Bank_Write(dest, BANK_LT);
                        state = FETCH;
                end
                counter = (counter < 1)? counter + 1 : 0;
        end
        endtask
        task Shift(input[2:0] op, dest, input[1:0]src, amt); begin
                case(counter)
                        0: begin
                                sh_ctrl = SH_REG_WRITE;
                                sh_src = src;
                                sh_amt = amt;
                        end
                        1:      sh_ctrl = op;
                        2: begin
                                sh_ctrl = SH_REG_RESET;
                                Bank_Write(dest, BANK_SHIFT);
                                state = FETCH;
                        end
                endcase
                counter = (counter < 2)? counter + 1 : 0;
        end
        endtask
        task Shift_R(input[2:0]op, input[1:0]src, amt); Shift(op, BANK_RD, src, amt); endtask
        task Shift_I(input[2:0]op, input[1:0]src, amt); Shift(op, BANK_RT, src, amt); endtask
        task Branch(input condition); begin 
                if (counter == 0) ALU_Operation(ALU_CMP, A_SRC_A, B_SRC_B);
                else begin
                        if(condition) begin
                                PC_write = 1;
                                PC_src = PC_SRC_ALU_OUT;
                        end
                        state = FETCH;
                end
                counter = (counter < 1)? counter + 1 : 0;
        end
        endtask
        task Store(input [1:0]size); begin
                store_ctrl = size;
                wr = MEM_WRITE;
                counter = 0;
                state = FETCH;
        end
        endtask
        task Load(input [1:0]size); begin
                load_ctrl = size;
                Bank_Write(BANK_RT, BANK_LOAD);
                counter = 0;
                state = FETCH;
        end
        endtask
        task HandleException(input [2:0]excode); begin
                if (counter < 3) begin
                        ALU_Operation(ALU_SUB, A_SRC_PC, B_SRC_4); // PC = PC - 4
                        EPC_write = 1;
                        iorD = excode;
                        wr = MEM_READ;
                        mem_reg_write = 1;
                        PC_src = PC_SRC_LOAD;
                        counter = counter + 1;
                end
                else begin
                        load_ctrl = BYTE;
                        PC_write = 1;
                        counter = 0;
                        state = FETCH;
                end
        end
        endtask

        // Macro para zerar todos os regitradores de saída. Pode ser substituido por uma Task futuramente
        `define RESET \
        {wr, ir_write, PC_write, load_ctrl, store_ctrl, EPC_write, A_write, B_write, ALU_out_write, Lo_write, Hi_write, mem_reg_write} = {1'b0}; \
        {PC_src, ALU_src_A, ALU_src_B, sh_src, sh_amt} = {2'b00}; \
        {ALU_op, iorD, sh_ctrl} = {3'b000}; \
        bank_write = 1'b1; \
        bank_write_data = 3'b101; \
        bank_write_reg = 3'b011; \
        signedn = 0; \
        counter = 0; \
        state = FETCH
        
        //Zera todos os sinais de escrita
        `define RESET_WRITE \
        bank_write = 0;\
        Hi_write = 0;\
        Lo_write = 0;\
        ALU_out_write = 0;\
        PC_write = 0;\
        A_write = 0;\
        B_write = 0;\
        EPC_write = 0;\
        div_mult_ctrl = 2'b00;\
        wr = MEM_READ;\
        mem_reg_write = 0;\
        ir_write = 0

        //Resetando todos os registradores
        initial begin
                `RESET;
        end

        always @(posedge clk) begin
                if (reset == 1) begin
                        `RESET;
                end
                else begin
                        case(state)

                                FETCH: begin

                                        if(counter < 3) begin
                                                //Ler instrucao
                                                iorD = PC_ADDR;
                                                `RESET_WRITE;

                                                //PC = PC + 4
                                                ALU_Operation(ALU_ADD, A_SRC_PC, B_SRC_4);
                                                ALU_out_write = 1;
                                                PC_src = PC_SRC_ALU_OUT;

                                                counter = counter + 1;
                                        end
                                        else begin
                                                ir_write = 1;
                                                PC_write = 1;
                                                counter = 0;
                                                state = DECODE;
                                        end
                                end
                                DECODE: begin
                                        
                                        if(counter == 0) begin
                                                //Zerando sinais de escrita do estado anterior
                                                ir_write = 0;
                                                PC_write = 0;
                                                //Calculo adiantado do Branch
                                                ALU_Operation(ALU_ADD, A_SRC_PC, B_SRC_ADDR);
                                                A_write = 1;
                                                B_write = 1;
                                                counter = 1;
                                        end
                                        else begin
                                                ALU_out_write = 0;
                                                counter = 0;
                                                `RESET_WRITE;
                                                case(OP)
                                                        TYPE_R_OP: begin
                                                                case(funct)
                                                                        ADD_FUNCT:   state = ADD;
                                                                        AND_FUNCT:   state = AND;
                                                                        DIV_FUNCT:   state = DIV;
                                                                        MULT_FUNCT:  state = MULT;
                                                                        JR_FUNCT:    state = JR;
                                                                        MFHI_FUNCT:  state = MFHI;
                                                                        MFLO_FUNCT:  state = MFLO;
                                                                        SLL_FUNCT:   state = SLL;
                                                                        SLLV_FUNCT:  state = SLLV;
                                                                        SLT_FUNCT:   state = SLT;
                                                                        SRA_FUNCT:   state = SRA;
                                                                        SRAV_FUNCT:  state = SRAV;
                                                                        SRL_FUNCT:   state = SRL;
                                                                        SUB_FUNCT:   state = SUB;
                                                                        BREAK_FUNCT: state = BREAK;
                                                                        RTE_FUNCT:   state = RTE;
                                                                        XCHG_FUNCT:  state = XCHG;
                                                                        default:     state = OPCODE_INEXISTENTE;
                                                                endcase
                                                        end
                                                        //Tipo I
                                                        ADDI_OP:  state = ADDI;
                                                        ADDIU_OP: state = ADDIU;
                                                        BEQ_OP:   state = BEQ;
                                                        BNE_OP:   state = BNE;
                                                        BLE_OP:   state = BLE;
                                                        BGT_OP:   state = BGT;
                                                        SRAM_OP:  state = MEM;
                                                        LB_OP:    state = MEM;
                                                        LH_OP:    state = MEM;
                                                        LW_OP:    state = MEM;
                                                        LUI_OP:   state = LUI;
                                                        SB_OP:    state = MEM;
                                                        SH_OP:    state = MEM;
                                                        SW_OP:    state = MEM;
                                                        SLTI_OP:  state = SLTI;
                                                        //Tipo J
                                                        J_OP:     state = J;
                                                        JAL_OP:   state = JAL;
                                                        //Opcode inexistente
                                                        default:  state = OPCODE_INEXISTENTE;                   
                                                endcase
                                        end
                                end

//----------------------------- Excecoes

                                OPCODE_INEXISTENTE: HandleException(EX_OP_INEX);

                                OVERFLOW: HandleException(EX_OVERFLOW);

                                DIVZERO: HandleException(EX_DIVZERO);

//----------------------------- Aritmeticas e Logicas

                                ADD: begin
                                        if(counter == 0)begin
                                                ALU_Operation(ALU_ADD, A_SRC_A, B_SRC_B);
                                                ALU_out_write = 1'b1;
                                                counter = counter + 1;
                                        end
                                        else if(overflow == 1) begin
                                                state = OVERFLOW;
                                                counter = 0;
                                        end
                                        else if(counter == 1) begin
                                                Bank_Write(BANK_RD, BANK_ALU);
                                                counter = 0;
                                                state = FETCH;
                                        end
                                end
                                SUB: begin
                                        if(counter == 0)begin
                                                ALU_Operation(ALU_SUB, A_SRC_A, B_SRC_B);
                                                ALU_out_write = 1'b1;
                                                counter = counter + 1;
                                        end
                                        else if(overflow == 1) begin
                                                state = OVERFLOW;
                                                counter = 0;
                                        end
                                        else if(counter == 1) begin
                                                Bank_Write(BANK_RD, BANK_ALU);
                                                counter = 0;
                                                state = FETCH;
                                        end
                                end
                                AND: begin
                                        if(counter == 0)begin
                                                ALU_Operation(A_SRC_A, B_SRC_B, ALU_AND);
                                                ALU_out_write = 1'b1;
                                                counter = counter + 1;
                                        end
                                        else if(counter == 1) begin
                                                Bank_Write(BANK_RD, BANK_ALU);
                                                counter = 0;
                                                state = FETCH;
                                        end
                                end
                                MULT: begin 
                                        if(counter <= 31) begin
                                                div_mult_ctrl = 2'b01;
                                                counter = counter + 1;
                                        end
                                        else if(counter == 32) begin
                                                Hi_write = 1'b1;
                                                Lo_write = 1'b1;
                                                div_mult_ctrl = 2'b00;
                                                counter = 0;
                                                state = FETCH;
                                        end

                                end
                                DIV: begin
                                        if(counter <= 32) begin
                                                div_mult_ctrl = 2'b10;
                                                counter = counter + 1;
                                                if(div_zero == 1) begin
                                                        state = DIVZERO;
                                                        counter = 0;
                                                end
                                        end
                                        else if(counter == 33) begin
                                                Hi_write = 1'b1;
                                                Lo_write = 1'b1;
                                                div_mult_ctrl = 2'b00;
                                                counter = 0;
                                                state = FETCH;
                                        end
                                end
                                
//-----------------------------Desvio incondicional

                                JR: begin
                                        if (counter == 0) begin 
                                                ALU_Forward(A_SRC_A);
                                                counter = counter + 1;
                                        end
                                        else if(counter == 1) begin
                                                PC_src = 2'b00;
                                                PC_write = 1'b1;
                                                counter = 0;
                                                state = FETCH;
                                        end
                                end

                                RTE: begin
                                        if(counter == 0) begin
                                                PC_src = PC_SRC_EPC;
                                                PC_write = 1'b1;
                                                counter = 0;
                                                state = FETCH;
                                        end
                                end

//----------------------------- Escrever na memoria
                                
                                MFHI: begin 
                                        Bank_Write(BANK_RD, BANK_HI);
                                        state = FETCH;
                                end
                                MFLO: begin
                                        Bank_Write(BANK_RD, BANK_LO);
                                        state = FETCH;
                                end

//----------------------------- Instrucoes de deslocamento

                                SLL: Shift_R(SH_OP_LEFT, SHIFT_B, SHAMT);

                                SLLV: Shift_R(SH_OP_LEFT, SHIFT_A, SHIFT_B);

                                SRA: Shift_R(SH_OP_RA, SHIFT_B, SHAMT);

                                SRAV: Shift_R(SH_OP_RA, SHIFT_A, SHIFT_B);

                                SRL: Shift_R(SH_OP_RL, SHIFT_B, SHAMT);

//----------------------------- Break

                                BREAK: state = BREAK;

//----------------------------- Exchange

                                XCHG: begin // testar pipeline futuramente
                                        case(counter)
                                                0:      ALU_Forward(A_SRC_A);
                                                1: begin
                                                        Bank_Write(BANK_RT, BANK_ALU);
                                                        ALU_Forward(A_SRC_B);
                                                end
                                                2: begin
                                                        Bank_Write(BANK_RS, BANK_ALU);
                                                        state = FETCH;
                                                end
                                        endcase
                                        counter = (counter < 4)? counter + 1 : 0;

                                end

//----------------------------- ADDs com imediato

                                ADDI: begin
                                        signedn = 0;
                                        ALU_Operation(ALU_ADD, A_SRC_A, B_SRC_IMMEDIATE);
                                        ALU_out_write = 1;
                                        state = ADDI_WRITE;
                                end
                                ADDIU: begin
                                        signedn = 1;
                                        ALU_Operation(ALU_ADD, A_SRC_A, B_SRC_IMMEDIATE);
                                        ALU_out_write = 1;
                                        state = ADDI_WRITE;
                                end
                                ADDI_WRITE: begin
                                        ALU_out_write = 0;
                                        signedn = 0;
                                        if (state == ADDI && overflow) state = OVERFLOW;
                                        else begin
                                                Bank_Write(BANK_RT, BANK_ALU);
                                                state = FETCH;
                                        end
                                end

//----------------------------- Branches

                                BEQ: Branch(EG);

                                BNE: Branch(!EG);

                                BGT: Branch(GT);

                                BLE: Branch(!GT);

//----------------------------- Set Less Than 

                                SLT: Set_Less_Than(BANK_RD, B_SRC_B);

                                SLTI: Set_Less_Than(BANK_RT, B_SRC_IMMEDIATE);

//----------------------------- Acesso a memoria

                                MEM: begin

                                        case(counter)
                                                0: begin
                                                        ALU_src_A = A_SRC_A;
                                                        ALU_src_B = B_SRC_OFFSET;
                                                        ALU_op = ALU_ADD;
                                                        ALU_out_write = 1;
                                                        iorD = ALU_ADDR;
                                                        wr = MEM_READ;
                                                end
                                                2: mem_reg_write = 1;
                                                3: begin
                                                        case(OP)
                                                                LB_OP: state = LB;
                                                                LH_OP: state = LH;
                                                                LW_OP: state = LW;
                                                                SRAM_OP: state = SRAM;
                                                                SB_OP: state = SB;
                                                                SH_OP: state = SH;
                                                                SW_OP: state = SW;
                                                        endcase
                                                end
                                        endcase
                                        counter = (counter < 3)? counter + 1 : 0;
                                end

//----------------------------- LUI

                                LUI: Shift_I(SH_OP_LEFT, SHIFT_IMMEDIATE, SHIFT_16);

//----------------------------- Instrucoes de Load

                                LB: Load(BYTE);

                                LH: Load(HALF);

                                LW: Load(WORD);

                                SRAM: begin
                                        Shift_I(SH_OP_RA, SHIFT_B, SHIFT_LOAD);
                                        load_ctrl = WORD;
                                end

//----------------------------- Instrucoes de Store

                                SB: Store(BYTE);
                                
                                SH: Store(HALF);

                                SW: Store(WORD);

//----------------------------- Instrucoes do tipo j

                                JAL: begin
                                        case(counter)
                                                0: begin
                                                        Bank_Write(BANK_RA, BANK_PC);
                                                        PC_write = 1;
                                                        PC_src = PC_SRC_OFFSET;
                                                end
                                                1: begin
                                                        PC_write = 0;
                                                        bank_write = 0;
                                                        state = FETCH;
                                                end
                                        endcase
                                        counter = (counter < 1)? counter + 1 : 0;
                                end
                                J: begin
                                        case(counter)
                                                0: begin
                                                        PC_src = PC_SRC_OFFSET;
                                                        PC_write = 1;
                                                end
                                                1: begin
                                                        PC_write = 0;
                                                        state = FETCH;
                                                end
                                        endcase
                                        counter = (counter < 1)? counter + 1 : 0;
                                end

                        endcase
                end
        end
endmodule
