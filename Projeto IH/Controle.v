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

        //Sinais de selecao
        output  reg[1:0] PC_src,                //PC source
                reg[1:0] ALU_src_A,             //ALU source A
                reg[1:0] ALU_src_B,             //ALU source B
                reg[1:0] sh_src,                //Deslocamento source
                reg[1:0] div_mult_ctrl,         //Div/Mult control
                reg[2:0] bank_write_reg,        //Bank write reg
                reg[2:0] bank_write_data,       //Bank write data
                reg[2:0] ALU_op,                //ALU operation
                reg[2:0] iorD,                  //iorD
                reg[2:0] sh_ctrl,               //Deslocamento controle

        output  reg unsignedn,                  //Signed/Unsigned control
        
        //Sinais de dados
        output  reg[1:0] sh_amt,                //Deslocamento amount

        //Sinais de leitura/escrita
        output  reg mem_read,                   //Memory read
                    mem_write,                  //Memory write
                    ir_write,                   //Instruction register write
                    PC_write,                   //PC write
                    bank_write,                 //Bank write
                    load_ctrl,                  //Load control
                    store_ctrl,                 //Store control
                    EPC_write                   //EPC write

        
);
        `include "Estados.vh"
        `include "Opcodes.vh"

        // Macro para zerar todos os regitradores. Pode ser substituido por uma Task futuramente
        `define REG_RESET \
        {mem_read, mem_write, ir_write, PC_write, bank_write, load_ctrl, store_ctrl, EPC_write} = {1'b0}; \
        {PC_src, ALU_src_A, ALU_src_B, sh_src, sh_amt, bank_write_reg} = {2'b00}; \
        {ALU_op, bank_write_data, iorD, sh_ctrl} = {3'b000}; \
        unsignedn = 0

        reg [5:0]state;
        reg [3:0]counter;

        

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