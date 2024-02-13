module MultDiv (
    input wire [31:0] A, B, input wire [1:0] DivMultControl, input wire clk, reset, output reg [31:0] Hi, Lo, output reg DivZero);
    
    reg [5:0] i;
    //para multiplicação
    reg q;
    reg [31:0] Q, Arm;
    //para divisão
    reg [63:0] div, resto;
    reg [31:0] quo;

    initial begin
        
        if (DivMultControl == 1) begin
            //Config inicial para mult
            Q = A;
            q = 0;
            Arm = 0; 
        end

        else if (DivMultControl == 2) begin
            //Config inicial para div
            if (A[31] == 1) begin
                div[63:32] = ~A + 1;
            end

            else begin
                div[63:32] = A;
            end

            if (B[31] == 1) begin
                resto[31:0] = ~B + 1;
            end

            else begin
                resto[31:0] = B;
            end

            quo = 0;

        end

        i = 0;
        Hi = 0;
        Lo = 0;
        DivZero = 0;

    end

    always @(posedge clk) begin

        if (reset == 1) begin
            //resetar

            Hi = 0;
            Lo = 0;
            DivZero = 0;
            i = 0;
            q = 0;
            Q = 0;
            Arm = 0;
            div = 0;
            resto = 0;
            quo = 0;

        end

        else if (DivMultControl == 1) begin
            //multiplica
            
            if (Q[0] == 0 && q = 1) begin
                Arm = Arm + B; 
            end

            else if (Q[0] == 1 && q == 0) begin
                Arm = Arm + (~B+1); //menos?
            end

            {Arm, Q, q} = {Arm, Q, q} >> 1;
            i = i + 1;

            if (i == 32) begin
                Hi = Arm;
                Lo = Q; 
            end
        end

        else if (DivMultControl == 2) begin
            //divide

            if (B == 0) begin
                DivZero = 1;
                
            end

            else begin
                      
                resto = div - resto;
                if (resto >= 0) begin
                    quo = quo << 1;
                    quo[0] = 1;
                end

                else begin
                    resto = div + resto;
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
                
                    Lo = quo;
                    Hi = resto; //checar se pode assim
                end
            end

        end

    end

endmodule

