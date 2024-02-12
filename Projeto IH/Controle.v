module Controle (

        //Reset e borda de relogio
        input   wire reset,
                wire clk,

        //Entradas da ALU
        input   wire zero,                      //Zero flag
                wire div_zero,                  //Division by zero flag
                wire overflow,                  //Overflow flag
                wire GT,                        //Greater than flag
                wire EG,                        //
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
                    load_ctrl,                  
                    store_ctrl,                 
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

        // Macro para zerar todos os regitradores de saída. Pode ser substituido por uma Task futuramente
        `define RESET \
        {wr, ir_write, PC_write, bank_write, load_ctrl, store_ctrl, EPC_write, A_write, B_write, ALU_out_write, Lo_write, Hi_write, mem_reg_write} = {1'b0}; \
        {PC_src, ALU_src_A, ALU_src_B, sh_src, sh_amt, bank_write_reg} = {2'b00}; \
        {ALU_op, bank_write_data, iorD, sh_ctrl} = {3'b000}; \
        signedn = 0; \
        counter = 0; \
        state = FETCH

        reg [5:0]state;
        reg [3:0]counter;

        //Resetando todos os registradores
        initial begin
                `RESET;
        end

        always @(posedge clk) begin
                if (reset == 1) begin
                        `RESET;
                        state = FETCH;
                        counter = 0;
                end
                else begin
                        case(state)

                                FETCH: begin
                                        if(counter < 4) begin
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
                                        ir_write = 0;
                                        PC_write = 0;
                                        if(counter == 0) counter = 1;
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
                                                        SRAM_OP:  state = SRAM;
                                                        LB_OP:    state = LB;
                                                        LH_OP:    state = LH;
                                                        LUI_OP:   state = LUI;
                                                        LW_OP:    state = LW;
                                                        SB_OP:    state = SB;
                                                        SH_OP:    state = SH;
                                                        SLTI_OP:  state = SLTI;
                                                        //Tipo J
                                                        J_OP:     state = J;
                                                        JAL_OP:   state = JAL;
                                                        //Opcode inexistente
                                                        default:  state = OPCODE_INEXISTENTE;                   
                                                endcase
                                        end
                                end
                                OPCODE_INEXISTENTE: begin
                                        if (counter < 2) begin
                                                //PC - 4
                                                ALU_src_A = A_SRC_PC;
                                                ALU_src_B = B_SRC_4;
                                                ALU_op = ALU_SUB;

                                                //Não entendi esses sinais, seria bom conferir
                                                iorD = 3'b100;
                                                wr = MEM_READ;
                                                PC_src = PC_SRC_LOAD;
                                                counter = counter + 1;
                                        end
                                        else begin
                                                load_ctrl = 1;
                                                PC_write = 1;
                                                counter = 0;
                                        end
                                end
                                
                        endcase
                end
        end
endmodule