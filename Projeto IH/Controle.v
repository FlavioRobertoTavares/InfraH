module Controle (

        //Reset e borda de relogio
        input   wire reset,
                wire clk,

        //Entradas da ALU
        input   wire zero,
                wire div_zero,
                wire overflow,
                wire GT,
                wire EG,
                wire LT,

        //Entradas de Intrucoes
        input   wire[5:0] OP,
                wire[3:0] func,

        //Sinais de selecao (MUX)
        output  reg[1:0] PC_src,
                reg[1:0] ALU_src_A,
                reg[1:0] ALU_src_B,
                reg[1:0] shsrc,
                reg[1:0] shamt,
                reg[1:0] ir_write_data,
                reg[1:0] ir_write_reg,
                reg[1:0] bank_write_data,
                reg[1:0] bank_write_reg,
                reg[2:0] iorD,

        //Sinais de leitura/escrita
        output  reg mem_read,
                    mem_write,
                    reg_write,
                    ir_write,
                    PC_write,
                    bank_write,
                    load_ctrl,
                    store_ctrl,
                    EPC_write,

        
        output reg unsignedn
);
        `include "Estados.vh"

        // Macro para zerar todos os regitradores. Pode ser substituido por uma Task futuramente
        `define REG_RESET \
        {PC_src, ALU_src_A, ALU_src_B, shsrc, shamt, ir_write_data, ir_write_reg, bank_write_data, bank_write_reg} = {2'b00}; \
        lorD = 0; \
        {mem_read, mem_write, reg_write, ir_write, PC_write, bank_write, load_ctrl, store_ctrl, EPC_write} = {1'b0}; \
        unsignedn = 0

        reg [5:0]state;
        reg [3:0]counter;

                // Códigos das instruções
        // Tipo R
        parameter TypeR_op = 6'h0x0;
        parameter ADD_funct = 6'h0x20;
        parameter AND_funct = 6'h0x24;
        parameter DIV_funct = 6'h0x1a;
        parameter MULT_funct = 6'h0x18;
        parameter JR_funct = 6'h0x8;
        parameter MFHI_funct = 6'h0x10;
        parameter MFLO_funct = 6'h0x12;
        parameter SLL_funct = 6'h0x0;
        parameter SLLV_funct = 6'h0x4;
        parameter SLT_funct = 6'h0x2a;
        parameter SRA_funct = 6'h0x3;
        parameter SRAV_funct = 6'h0x7;
        parameter SRL_funct = 6'h0x2;
        parameter SUB_funct = 6'h0x22;
        parameter BREAK_funct = 6'h0xd;
        parameter RTE_funtc = 6'h0x13;
        parameter XCHG_funct = 6'h0x5;


        //Tipo I
        parameter ADDI_op = 6'h0x8;
        parameter ADDIU_op = 6'h0x9;
        parameter BEQ_op = 6'h0x4;
        parameter BNE_op = 6'h0x5;
        parameter BLE_op = 6'h0x6;
        parameter BGT_op = 6'h0x7;
        parameter SRAM_op = 6'h0x1;
        parameter LB_op = 6'h0x20;
        parameter LH_op = 6'h0x21;
        parameter LUI_op = 6'h0xf;
        parameter LW_op = 6'h0x23;
        parameter SB_op = 6'h0x28;
        parameter SH_op = 6'h0x29;
        parameter SLTI_op = 6'h0xa;
        parameter SW_op = 6'h0x2b;


        //Tipo J
        parameter J_op = 6'h0x2;
        parameter JAL_op = 6'h0x3;

        //Resetando todos os registradores
        initial begin
                `REG_RESET;
        end

        always @(posedge clk) begin
                if (reset == 1) begin
                        `REG_RESET;
                        state = START;
                        counter = 0;
                end
                else begin
                        case(state)

                                START: begin
                                        if(counter <= 4'd1) begin
                                                iorD = 3'd0;
                                                mem_read = 1'd1;
                                                ALU_src_A = 2'd0;
                                                ALU_src_B = 2'd1;
                                                //ALU_op = 3'd1;
                                                PC_src = 2'd0;
                                                counter = counter + 1'd1;
                                        end
                                        else if (counter == 2)begin
                                                ir_write = 1'd1;
                                                PC_write = 1'd1;
                                                counter = counter + 1'd1;
                                        end
                                        else begin
                                                
                                        end
                                end
                        endcase
                end
        end


        


endmodule