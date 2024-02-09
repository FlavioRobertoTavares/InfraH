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
                reg[2:0] lorD,

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

        //Macro para zerar todos os regitradores. Pode ser substituido por uma Task futuramente
        `define REG_RESET \
        {PC_src, ALU_src_A, ALU_src_B, shsrc, shamt, ir_write_data, ir_write_reg, bank_write_data, bank_write_reg} = {2'b00}; \
        lorD = 0; \
        {mem_read, mem_write, reg_write, ir_write, PC_write, bank_write, load_ctrl, store_ctrl, EPC_write} = {1'b0}; \
        unsignedn = 0

        reg [5:0]state;
        reg [3:0]counter;

        initial begin
                `REG_RESET;
        end

        always @(posedge clk) begin
                if (reset == 1) begin
                        `REG_RESET;
                        state = START;
                        counter = 0;
                end
        end


        


endmodule