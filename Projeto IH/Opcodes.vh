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