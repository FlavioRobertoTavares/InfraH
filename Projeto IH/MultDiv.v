module MultDiv (
    input wire [31:0] A, B, input wire [1:0] DivMultControl, input wire clk, reset, output reg [31:0] Hi, Lo, output reg DivZero);
    
    reg [5:0] i;
    reg [1:0] auxiliar;
    //para multiplicação
    reg q;
    reg [31:0] Q, Arm;
    //para divisão
    reg [63:0] div, resto;
    reg [31:0] quo;

    initial begin
        auxiliar = 0;
    end


    always @(posedge clk) begin

        auxiliar <= DivMultControl;

        if ( ((auxiliar == 0) && (DivMultControl != 0)) || (reset == 1) ) begin

            //Config inicial para mult
            Q = A;
            q = 0;
            Arm = 0; 
    
            //Config inicial para div
            quo = 0;
            if (A[31] == 1) begin
                div[63:32] = ~A + 1; //Ver se precisa por isso dentro do bloco de ação
            end

            else begin
                div[63:32] = A;
            end

            if (B[31] == 1) begin
                resto[31:0] = ~B + 1; //Ver se precisa por isso dentro do bloco de ação
            end

            else begin
                resto[31:0] = B;
            end

            //Comum      
            i = 0;
            Hi = 0;
            Lo = 0;
            DivZero = 0;
            
        end

        if (DivMultControl == 1 && reset == 0) begin
            //multiplica
            
            if (Q[0] == 0 && q == 1) begin
                Arm = Arm + B; 
            end

            else if (Q[0] == 1 && q == 0) begin
                Arm = Arm + (~B+1); //menos?
            end

            {Arm, Q, q} = {Arm, Q, q} >>> 1;
            i = i + 1;

            if (Arm[30] == 1) begin
                Arm[31] = 1;
            end

            if (i == 32) begin
                if (Arm == 4294967295) begin
                    Arm = 0;
                end

                Hi = Arm;
                Lo = Q; 
            end
        end

        else if (DivMultControl == 2 && reset == 0) begin
            //divide

            if (B == 0) begin
                DivZero = 1;
                
            end

            else begin
                      
                resto = resto - div;
                if (resto[63] == 0) begin
                    quo = quo << 1;
                    quo[0] = 1;
                end

                else begin
                    resto = resto + div;
                    quo = quo << 1;
                    quo[0] = 0;
                end

                div = div >> 1;
                i = i + 1;

                if (i == 33) begin
                    if (A[31] != B[31]) begin
                        quo = ~quo + 1;

                        if (A[31] == 1) begin
                            resto = ~resto + 1;
                        end
                    end

                    else if((A[31] == 1) && (B[31] == 1)) begin
                        resto = ~resto + 1;
                        
                    end
                
                    Lo = quo;
                    Hi = resto; //checar se pode assim
                end
            end

        end

    end

endmodule

