//Operacoes ALU
localparam  ALU_ADD     = 1,
            ALU_SUB     = 2,
            ALU_AND     = 3,
            ALU_INC     = 4,
            ALU_NOT     = 5,
            ALU_XOR     = 6,
            ALU_CMP     = 7;

//Fontes da ALU
localparam  A_SRC_PC        = 0,
            A_SRC_B         = 1,
            A_SRC_A         = 2,
            B_SRC_B         = 0,  
            B_SRC_4         = 1,
            B_SRC_ADDR      = 2,
            B_SRC_OFFSET    = 3,
            B_SRC_IMMEDIATE = 3;

//Fontes do PC
localparam  PC_SRC_ALU_OUT  = 0,
            PC_SRC_OFFSET   = 1,
            PC_SRC_LOAD     = 2,
            PC_SRC_EPC      = 3;

//Fontes do Shift
localparam  SHIFT_A         = 0,
            SHAMT           = 0,
            SHIFT_B         = 1,
            SHIFT_IMMEDIATE = 2,
            SHIFT_16        = 2,
            SHIFT_LOAD      = 3;

//Operações de Shift
localparam  SH_REG_RESET    = 0,
            SH_REG_WRITE    = 1,
            SH_OP_LEFT      = 2,
            SH_OP_RL        = 3,
            SH_OP_RA        = 4;

//Bank Data MUXes
localparam  BANK_ALU        = 0,
            BANK_LOAD       = 1,
            BANK_SHIFT      = 2,
            BANK_HI         = 3,
            BANK_LO         = 4,
            BANK_STACK      = 5,
            BANK_PC         = 6,
            BANK_LT         = 7;

//Bank Reg MUXes
localparam  BANK_RT = 0,
            BANK_RD = 1,
            BANK_RS = 2,
            BANK_SP = 3,
            BANK_RA = 4;

//Memoria
localparam  MEM_READ    = 0,
            MEM_WRITE   = 1,
            PC_ADDR     = 0,
            ALU_ADDR    = 1,
            BYTE        = 1,
            HALF        = 2,
            WORD        = 3;

//Codigos de excecao
localparam  EX_OP_INEX  = 'b100,
            EX_OVERFLOW = 'b011,
            EX_DIVZERO  = 'b010;