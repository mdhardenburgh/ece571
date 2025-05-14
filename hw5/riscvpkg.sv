`ifndef RISCV_UTIL
`define RISCV_UTIL
package riscvutil;

    typedef enum logic[6:0] 
    {
        ARITH_REG=7'b0110011,
        ARITH_IMM=7'b0010011,
        LOAD=7'b0000011,
        STORE=7'b0100011,
        BRANCH=7'b1100011,
        JAL=7'b1101111,
        JALR=7'b1100111,
        LUI=7'b0110111,
        AUIPC=7'b0010111
    } OPCODE_T;

    typedef enum logic[3:0]
    {
        ADD = 4'h0,
        XOR = 4'h4,
        OR = 4'h6,
        AND = 4'h7,
        SLL = 4'h1,
        SRLA = 4'h5,
        SLT = 4'h2,
        SLTU = 4'h3
    } ALU_FUNCT3_T;
    
    typedef enum logic[3:0]
    {
        LB = 4'h0,
        LH = 4'h1,
        LW = 4'h2,
        LBU = 4'h4,
        LHU = 4'h5
    } LOAD_FUNCT3_T;

    typedef enum logic[3:0]
    {
        SB = 4'h0,
        SH = 4'h1,
        SW = 4'h2
    } STORE_FUNCT3_T;

    typedef enum logic[3:0]
    {
        BEQ = 4'h0,
        BNE = 4'h1,
        BLT = 4'h4,
        BGE = 4'h5,
        BLTU = 4'h6,
        BGEU = 4'h7
    } BRANCH_FUNCT3_T;

    typedef enum logic[4:0] 
    {
        ZERO, // x0 zero register
        RA,   // x1 ra return addr pointer
        SP,   // x2 sp stack pointer
        GP,   // x3 gp global pointer
        TP,   // x4 tp thread pointer
        T0,   // x5 t0, RA
        T1,   // x6 t1
        T2,   // x7 t2
        FP,   // x8 s0, framepointer
        S1,   // x9 s1
        A0,   // x10 a0
        A1,   // x11 a1
        A2,   // x12
        A3,   // x13
        A4,   // x14
        A5,   // x15
        A6,   // x16
        A7,   // x17
        S2,   // x18
        S3,   // x19
        S4,   // x20
        S5,   // x21
        S6,   // x22 
        S7,   // x23
        S8,   // x24
        S9,   // x25
        S10,  // x26
        S11,  // x27
        T3,   // x28
        T4,   // x29
        T5,   // x30
        T6    // x31
    } REG_NAME_T;
    
    typedef union packed 
    {
        logic [31:0] instrType;

        struct packed 
        {
            logic [6:0]  funct7;
            logic [4:0]  rs2;
            logic [4:0]  rs1;
            logic [2:0]  funct3;
            logic [4:0]  rd;
            logic [6:0]  opcode;
        } register_t;

        struct packed 
        {
            logic [11:0]  imm;
            logic [4:0]  rs1;
            logic [2:0]  funct3;
            logic [4:0]  rd;
            logic [6:0]  opcode;
        } immediate_t;

        struct packed 
        {
            logic [19:0]  imm;
            logic [4:0]  rd;
            logic [6:0]  opcode;
        } upperImmediate_t;

        struct packed 
        {
            logic [6:0]  upperImm;
            logic [4:0]  rs2;
            logic [4:0]  rs1;
            logic [2:0]  funct3;
            logic [4:0]  lowerImm;
            logic [6:0]  opcode;
        } store_t;

        struct packed 
        {
            logic imm12;
            logic [5:0]  imm10To5;
            logic [4:0]  rs1;
            logic [4:0]  rs2;
            logic [2:0]  funct3;
            logic [3:0]  imm4to1;
            logic imm11;
            logic [6:0]  opcode;
        } branch_t;

        struct packed 
        {
            logic imm20;
            logic [9:0]  imm10To1;
            logic imm11;
            logic [7:0]  imm19to12;
            logic [4:0]  rd;
            logic [6:0]  opcode;
        } jump_t;

    } riscvinst;

    function automatic string disassemble
    (
        input riscvinst instr
    );
        string instrString = "unknown instr";
        string disassembledInstr = "unknown";
        unique0 case (instr.instrType[6:0])
            ARITH_REG:
            begin
                unique0 case(instr.register_t.funct3)
                    ADD:
                    begin
                        if(instr.register_t.funct7 == 8'h00)
                        begin
                            instrString = "add";
                        end
                        else if(instr.register_t.funct7 == 8'h20)
                        begin
                            instrString = "sub";
                        end
                    end
                    XOR: instrString = "xor";
                    OR: instrString = "or";
                    AND: instrString = "and";
                    SLL: instrString = "sll";
                    SRLA:
                    begin
                        if(instr.register_t.funct7 == 8'h00)
                        begin
                            instrString = "srl";
                        end
                        else if(instr.register_t.funct7 == 8'h20)
                        begin
                            instrString = "sra";
                        end
                    end
                    SLT: instrString = "slt";
                    SLTU: instrString = "sltu";
                endcase
                disassembledInstr = $sformatf("%s %s, %s, %s", instrString, parseRegToString(instr.register_t.rd), parseRegToString(instr.register_t.rs1), parseRegToString(instr.register_t.rs2));
            end
            ARITH_IMM:
            begin
                unique0 case(instr.immediate_t.funct3)
                    ADD:
                    begin
                        disassembledInstr = $sformatf("%s %s, %s, %0d", "addi", parseRegToString(instr.immediate_t.rd), parseRegToString(instr.immediate_t.rs1), $signed(instr.immediate_t.imm));
                    end
                    XOR:
                    begin
                        disassembledInstr = $sformatf("%s %s, %s, 0x%0h", "xori", parseRegToString(instr.immediate_t.rd), parseRegToString(instr.immediate_t.rs1), instr.immediate_t.imm);
                    end
                    OR:
                    begin
                        disassembledInstr = $sformatf("%s %s, %s, 0x%0h", "ori", parseRegToString(instr.immediate_t.rd), parseRegToString(instr.immediate_t.rs1), instr.immediate_t.imm);
                    end
                    AND:
                    begin
                        disassembledInstr = $sformatf("%s %s, %s, 0x%0h", "andi", parseRegToString(instr.immediate_t.rd), parseRegToString(instr.immediate_t.rs1), instr.immediate_t.imm);
                    end
                    SLL:
                    begin
                        if(instr.immediate_t.imm[11:5] == 8'h00)
                        begin
                            disassembledInstr = $sformatf("%s %s, %s, %0d", "slli", parseRegToString(instr.immediate_t.rd), parseRegToString(instr.immediate_t.rs1), instr.immediate_t.imm[4:0]);
                        end
                        else
                            $fatal("improper shift amount: (%0d)", $signed(instr.immediate_t.imm));
                    end
                    SRLA:
                    begin
                        if(instr.immediate_t.imm[11:5] == 8'h00)
                        begin
                            disassembledInstr = $sformatf("%s %s, %s, %0d", "srli", parseRegToString(instr.immediate_t.rd), parseRegToString(instr.immediate_t.rs1), instr.immediate_t.imm[4:0]);
                        end
                        else if(instr.immediate_t.imm[11:5] == 8'h20)
                        begin
                            disassembledInstr = $sformatf("%s %s, %s, %0d", "srai", parseRegToString(instr.immediate_t.rd), parseRegToString(instr.immediate_t.rs1), instr.immediate_t.imm[4:0]);
                        end
                        else
                            $fatal("improper shift amount: (%0d)", $signed(instr.immediate_t.imm));
                    end
                    SLT:
                    begin
                        disassembledInstr = $sformatf("%s %s, %s, %0d", "slti", parseRegToString(instr.immediate_t.rd), parseRegToString(instr.immediate_t.rs1), $signed(instr.immediate_t.imm));
                    end
                    SLTU:
                    begin
                        disassembledInstr = $sformatf("%s %s, %s, %0d", "sltiu", parseRegToString(instr.immediate_t.rd), parseRegToString(instr.immediate_t.rs1), $unsigned(instr.immediate_t.imm));
                    end
                endcase
            end
            LOAD: // the byte is unsigned
            begin
                unique0 case(instr.immediate_t.funct3)
                    LB: instrString = "lb"; 
                    LH: instrString = "lh"; 
                    LW: instrString = "lw"; 
                    LBU: instrString = "lbu"; 
                    LHU: instrString = "lhu"; 
                endcase
                disassembledInstr = $sformatf("%s %s, %0d(%s)", instrString, parseRegToString(instr.immediate_t.rd), $signed(instr.immediate_t.imm), parseRegToString(instr.immediate_t.rs1));
            end
            STORE:
            begin
                unique0 case(instr.store_t.funct3)
                    SB: instrString = "sb";
                    SH: instrString = "sh";
                    SW: instrString = "sw";
                endcase
                disassembledInstr = $sformatf("%s %s, %0d(%s)", instrString, parseRegToString(instr.store_t.rs2), $signed({instr.store_t.upperImm, instr.store_t.lowerImm}), parseRegToString(instr.store_t.rs1));
            end
            BRANCH: // the compares are unsigned
            begin
                unique0 case(instr.branch_t.funct3)
                    BEQ: instrString = "beq"; 
                    BNE: instrString = "bne"; 
                    BLT: instrString = "blt"; 
                    BGE: instrString = "bge"; 
                    BLTU: instrString = "bltu"; 
                    BGEU: instrString = "bgeu"; 
                endcase
                disassembledInstr = $sformatf("%s %s, %s, .%0d", instrString, parseRegToString(instr.branch_t.rs2), parseRegToString(instr.branch_t.rs1), $signed({instr.branch_t.imm12, instr.branch_t.imm11, instr.branch_t.imm10To5, instr.branch_t.imm4to1, 1'b0}));
            end
            JAL:
            begin
                disassembledInstr = $sformatf("%s %s, .%0d", "jal", parseRegToString(instr.jump_t.rd), $signed({instr.jump_t.imm20, instr.jump_t.imm19to12, instr.jump_t.imm11, instr.jump_t.imm10To1, 1'b0}));
            end
            JALR: 
            begin 
                disassembledInstr = $sformatf("%s %s, %s, %0d", "jalr", parseRegToString(instr.immediate_t.rd), parseRegToString(instr.immediate_t.rs1), $signed(instr.immediate_t.imm));
            end
            LUI:
            begin
                disassembledInstr = $sformatf("%s %s, %0d", "lui", parseRegToString(instr.upperImmediate_t.rd), instr.upperImmediate_t.imm);
            end
            AUIPC:
            begin
                disassembledInstr = $sformatf("%s %s, %0d", "auipc", parseRegToString(instr.upperImmediate_t.rd), instr.upperImmediate_t.imm);
            end
        endcase
        return disassembledInstr;
    endfunction

    function automatic string parseRegToString
    (
        input logic[4:0] regNum
    );
        string retVal = "default";

        unique0 case (regNum)
            ZERO: retVal = "zero";
            RA:   retVal = "ra"; 
            SP:   retVal = "sp";
            GP:   retVal = "gp";
            TP:   retVal = "tp";
            T0:   retVal = "t0";
            T1:   retVal = "t1";
            T2:   retVal = "t2";
            FP:   retVal = "fp";
            S1:   retVal = "s1";
            A0:   retVal = "a0";
            A1:   retVal = "a1";
            A2:   retVal = "a2";
            A3:   retVal = "a3";
            A4:   retVal = "a4";
            A5:   retVal = "a5";
            A6:   retVal = "a6";
            A7:   retVal = "a7";
            S2:   retVal = "s2";
            S3:   retVal = "s3";
            S4:   retVal = "s4";
            S5:   retVal = "s5";
            S6:   retVal = "s6";
            S7:   retVal = "s7";
            S8:   retVal = "s8";
            S9:   retVal = "s9";
            S10:  retVal = "s10";
            S11:  retVal = "s11";
            T3:   retVal = "t3";
            T4:   retVal = "t4";
            T5:   retVal = "t5";
            T6:   retVal = "t6";
        endcase
        return retVal;
    endfunction
endpackage
`endif