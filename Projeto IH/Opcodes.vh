// Códigos das instruções
// Tipo R
localparam  TypeR_op    = 6'h0,
            ADD_funct   = 6'h20,
            AND_funct   = 6'h24,
            DIV_funct   = 6'h1a,
            MULT_funct  = 6'h18,
            JR_funct    = 6'h8,
            MFHI_funct  = 6'h10,
            MFLO_funct  = 6'h12,
            SLL_funct   = 6'h0,
            SLLV_funct  = 6'h4,
            SLT_funct   = 6'h2a,
            SRA_funct   = 6'h3,
            SRAV_funct  = 6'h7,
            SRL_funct   = 6'h2,
            SUB_funct   = 6'h22,
            BREAK_funct = 6'hd,
            RTE_funtc   = 6'h13,
            XCHG_funct  = 6'h5;


//Tipo I
localparam  ADDI_op     = 6'h8,
            ADDIU_op    = 6'h9,
            BEQ_op      = 6'h4,
            BNE_op      = 6'h5,
            BLE_op      = 6'h6,
            BGT_op      = 6'h7,
            SRAM_op     = 6'h1,
            LB_op       = 6'h20,
            LH_op       = 6'h21,
            LUI_op      = 6'hf,
            LW_op       = 6'h23,
            SB_op       = 6'h28,
            SH_op       = 6'h29,
            SLTI_op     = 6'ha,
            SW_op       = 6'h2b;


//Tipo J
localparam  J_op        = 6'h2,
            JAL_op      = 6'h3;