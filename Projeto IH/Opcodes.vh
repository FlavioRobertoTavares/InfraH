// Códigos das instruções
// Tipo R
localparam  TYPE_R_OP   = 6'h0,
            ADD_FUNCT   = 6'h20,
            AND_FUNCT   = 6'h24,
            DIV_FUNCT   = 6'h1a,
            MULT_FUNCT  = 6'h18,
            JR_FUNCT    = 6'h8,
            MFHI_FUNCT  = 6'h10,
            MFLO_FUNCT  = 6'h12,
            SLL_FUNCT   = 6'h0,
            SLLV_FUNCT  = 6'h4,
            SLT_FUNCT   = 6'h2a,
            SRA_FUNCT   = 6'h3,
            SRAV_FUNCT  = 6'h7,
            SRL_FUNCT   = 6'h2,
            SUB_FUNCT   = 6'h22,
            BREAK_FUNCT = 6'hd,
            RTE_FUNCT   = 6'h13,
            XCHG_FUNCT  = 6'h5;


//Tipo I
localparam  SRAM_OP     = 6'h1,
            BEQ_OP      = 6'h4,
            BNE_OP      = 6'h5,
            BLE_OP      = 6'h6,
            BGT_OP      = 6'h7,
            ADDI_OP     = 6'h8,
            ADDIU_OP    = 6'h9,
            SLTI_OP     = 6'ha,
            LUI_OP      = 6'hf,
            LB_OP       = 6'h20,
            LH_OP       = 6'h21,
            LW_OP       = 6'h23,
            SB_OP       = 6'h28,
            SH_OP       = 6'h29,
            SW_OP       = 6'h2b;

//Tipo J
localparam  J_OP        = 6'h2,
            JAL_OP      = 6'h3;

//OPerações ALU
localparam  ALU_ADD     = 1,
            ALU_SUB     = 2,
            ALU_AND     = 3,
            ALU_INC     = 4,
            ALU_NOT     = 5,
            ALU_XOR     = 6,
            ALU_CMP     = 7;

//Fontes do PC
localparam  PC_SRC_ALU_OUT  = 0,
            PC_SRC_OFFSET   = 1,
            PC_SRC_LOAD     = 2,
            PC_SRC_EPC      = 3;

//Fontes da ALU
localparam  A_SRC_PC        = 0,
            A_SRC_B         = 1,
            A_SRC_A         = 2,
            B_SRC_A         = 0,  
            B_SRC_4         = 1,
            B_SRC_ADDR      = 2,
            B_SRC_OFFSET    = 3,
            B_SRC_IMMEDIATE = 3;

//Memoria
localparam  MEM_READ    = 0,
            MEM_WRITE   = 1,
            PC_ADDR     = 0,
            ALU_ADDR    = 1;