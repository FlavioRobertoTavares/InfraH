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
                wire[3:0] funct,

        //Sinais de selecao
        output  reg[1:0] PC_src,                //PC source
                reg[1:0] ALU_src_A,             //ALU source A
                reg[1:0] ALU_src_B,             //ALU source B
                reg[1:0] sh_src,                //Deslocamento source
                reg[1:0] div_mult_ctrl,         //Div/mult control
                reg[1:0] load_ctrl,             //Seleciona bite, half ou word
                reg[1:0] store_ctrl,            //Seleciona bite, half ou word
                reg[2:0] bank_write_reg,        
                reg[2:0] bank_write_data,       
                reg[2:0] ALU_op,                //ALU operation
                reg[2:0] iorD,                  
                reg[2:0] sh_ctrl,               //Deslocamento controle

        output  reg signedn,                    //Signed/unsigned control
        
        //Sinais de dados
        output  reg[1:0] sh_amt,                //Deslocamento amount

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
        reg [3:0]counter;

        task Compare(input [1:0]src_A, input [1:0]src_B);
                begin 
                        ALU_src_A = src_A;
                        ALU_src_B = src_B;
                        ALU_op = ALU_CMP;
                end
        endtask
        task Store(input [1:0]size);
                store_ctrl = size;
                wr = MEM_WRITE;
                state = FETCH;
        endtask
        task Load(input [1:0]size);
                load_ctrl = size;
                bank_write_reg = 'b000;
                bank_write_data = 'b001;
                bank_write = 1;
                state = FETCH;
        endtask
        task HandleException(input [2:0]excode);
                begin
                        if (counter < 2) begin
                                //PC - 4
                                ALU_src_A = A_SRC_PC;
                                ALU_src_B = B_SRC_4;
                                ALU_op = ALU_SUB;

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
        signedn = 0; \
        counter = 0; \
        state = FETCH

        //Resetando todos os registradores
        initial begin
                `RESET;
                bank_write = 1'b0;
                bank_write_data = 3'b000;
                bank_write_reg = 3'b000;
        end

        always @(posedge clk) begin
                if (reset == 1) begin
                        `RESET;
                        bank_write = 1'b1;
                        bank_write_data = 3'b101;
                        bank_write_reg = 3'b011;
                        state = FETCH;
                        counter = 0;

                end
                else begin
                        case(state)

                                FETCH: begin
                                        if(counter < 3) begin
                                                //Ler instrucao
                                                wr = MEM_READ;
                                                iorD = PC_ADDR;

                                                //PC = PC + 4
                                                ALU_src_A = A_SRC_PC;
                                                ALU_src_B = B_SRC_4;
                                                ALU_op = ALU_ADD;
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
                                                ALU_src_A = A_SRC_PC;
// DUVIDA                                       Source B não deveria ser imediato?
                                                ALU_src_B = B_SRC_ADDR;
                                                ALU_op = ALU_ADD;
                                                ALU_out_write = 1;
                                                A_write = 1;
                                                B_write = 1;
                                                counter = 1;
                                        end
                                        else begin
                                                counter = 0;
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
                                                ALU_src_A = 2'b10;
                                                ALU_src_B = 2'b00;
                                                ALU_op = 3'b001;
                                                ALU_out_write = 1'b1;
                                                counter = counter + 1;
                                        end
                                        else if(overflow == 1) begin
                                                state = OVERFLOW;
                                                counter = 0;
                                        end
                                        else if(counter == 2) begin
                                                bank_write_reg = 3'b001;
                                                bank_write_data = 3'b000;
                                                bank_write = 1'b1;
                                                counter = 0;
                                                state = FETCH;
                                        end
                                end
                                SUB: begin
                                        if(counter == 0)begin
                                                ALU_src_A = 2'b10;
                                                ALU_src_B = 2'b00;
                                                ALU_op = 3'b010;
                                                ALU_out_write = 1'b1;
                                                counter = counter + 1;
                                        end
                                        else if(overflow == 1) begin
                                                state = OVERFLOW;
                                                counter = 0;
                                        end
                                        else if(counter == 1) begin
                                                bank_write_reg = 3'b001;
                                                bank_write_data = 3'b000;
                                                bank_write = 1'b1;
                                                counter = 0;
                                                state = FETCH;
                                        end
                                end
                                AND: begin
                                        if(counter == 0)begin
                                                ALU_src_A = 2'b10;
                                                ALU_src_B = 2'b00;
                                                ALU_op = 3'b011;
                                                ALU_out_write = 1'b1;
                                                counter = counter + 1;
                                        end
                                        else if(counter == 1) begin
                                                bank_write_reg = 3'b001;
                                                bank_write_data = 3'b000;
                                                bank_write = 1'b1;
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
                                        if(counter <= 31) begin
                                                div_mult_ctrl = 2'b10;
                                                counter = counter + 1;
                                        end
                                        else if(div_zero == 1) begin
                                                state = DIVZERO;
                                                counter = 0;
                                        end
                                        else if(counter == 32) begin
                                                Hi_write = 1'b1;
                                                Lo_write = 1'b1;
                                                div_mult_ctrl = 2'b00;
                                                counter = 0;
                                                state = FETCH;
                                        end
                                end

//----------------------------- ADDs com imediato

                                ADDI: begin
                                        signedn = 1;
                                        ALU_src_A = A_SRC_A;
                                        ALU_src_B = B_SRC_IMMEDIATE;
                                        ALU_op = ALU_ADD;
                                        ALU_out_write = 1;
// DUVIDA:                              Pode checar overflow no mesmo ciclo?
                                        state = (overflow)? OVERFLOW : ADDI_WRITE;
                                end
                                ADDIU: begin
                                        signedn = 1;
                                        ALU_src_A = A_SRC_A;
                                        ALU_src_B = B_SRC_IMMEDIATE;
                                        ALU_op = ALU_ADD;
                                        ALU_out_write = 1;
                                        state = ADDI_WRITE;

                                end
                                ADDI_WRITE: begin
                                        ALU_out_write = 0;
                                        bank_write_reg = 1;
                                        bank_write_data = 0;
                                        bank_write = 1;
                                        state = FETCH;
                                end

//----------------------------- Branches

                                BEQ: begin
                                        Compare(A_SRC_A, B_SRC_B);
// DUVIDA                               //Pode checar flags de cmp no mesmo ciclo?
                                        state = (EG)? BRANCH_WRITE : FETCH;
                                end
                                BNE: begin
                                        Compare(A_SRC_A, B_SRC_B);
                                        state = (EG)? FETCH : BRANCH_WRITE;
                                end
                                BLE: begin
                                        Compare(A_SRC_A, B_SRC_B);
                                        state = (GT)? FETCH : BRANCH_WRITE;
                                end
                                BGT: begin
                                        Compare(A_SRC_A, B_SRC_B);
                                        state = (GT)? BRANCH_WRITE: FETCH;
                                end
                                BRANCH_WRITE: begin
                                        PC_src = PC_SRC_ALU_OUT;
                                        PC_write = 1;
                                        state = FETCH;
                                end

//----------------------------- Set Less Than Immediate

                                SLTI: begin
                                        if (counter == 0) begin
                                                Compare(A_SRC_A, B_SRC_IMMEDIATE);
                                                counter = 1;
                                        end
                                        else begin
                                                counter = 0;
                                                bank_write_reg = 'b000;
                                                bank_write_data = 'b111;
                                                bank_write = 1;
                                                state = FETCH;
                                        end
                                end

//----------------------------- Acesso a memoria

                                MEM: begin
                                        if(counter == 0) begin
                                                ALU_src_A = A_SRC_A;
                                                ALU_src_B = B_SRC_OFFSET;
                                                ALU_op = ALU_ADD;
                                                ALU_out_write = 1;
                                                wr = MEM_READ;
                                        end
                                        else if (counter < 3) begin
                                                iorD = ALU_ADDR;
                                                
                                        end
                                        else begin
                                                mem_reg_write = 1;
                                                case(OP)
                                                        LB_OP: state = LB;
                                                        LH_OP: state = LH;
                                                        LW_OP: state = LW;
                                                        SRAM_OP: state = SRAM;
                                                        SB_OP: state = SB;
                                                        SH_OP: state = SH;
                                                        SW_OP: state = SW;
                                                        //LUI_OP????
                                                endcase
                                        end

                                end


//----------------------------- Instrucoes de Load

                                LB: Load(BYTE);

                                LH: Load(HALF);

                                LW: Load(WORD);
                                
                                //LUI: ???? LUI ta como shift na explicacao mas na ISA do mips lui eh insrtrucao de load
                                SRAM: begin
                                        case(counter)
                                                0: begin
                                                        load_ctrl = WORD;
                                                        sh_src = SHIFT_B;
                                                        sh_amt = SHIFT_LOAD;
                                                        sh_ctrl = 'b001;
                                                        counter = 1;
                                                end
                                                1: begin
                                                        sh_ctrl = 'b100;
                                                        counter = 2;
                                                end
                                                2: begin
                                                        sh_ctrl = 'b000;
                                                        bank_write_reg = 'b000;
                                                        bank_write_data = 'b010;
                                                        counter = 0;
                                                        state = FETCH;
                                                end
                                        endcase
                                end

//----------------------------- Instrucoes de Store

                                SB: Store(BYTE);
                                
                                SH: Store(HALF);

                                SW: Store(WORD);

//----------------------------- Instrucoes do tipo j

                                JAL: begin
                                        bank_write_reg = 'b100;
                                        bank_write_data = 'b110;
                                        bank_write = 1;
                                        state = J;
                                end
                                J: begin
                                        bank_write = 0;
                                        PC_src = PC_SRC_OFFSET;
                                        PC_write = 1;
                                        state = FETCH;
                                end

//----------------------------- Break

                                BREAK: state = BREAK;

                        endcase
                end
        end
endmodule