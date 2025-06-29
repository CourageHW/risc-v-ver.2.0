`timescale 1ns / 1ps
package defines;

  localparam DATA_WIDTH = 32;

  localparam REG_COUNT  = 32;
  localparam ADDR_WIDTH = $clog2(REG_COUNT);

  localparam DATA_MEM_DEPTH = 1024;
  localparam DATA_MEM_ADDR_WIDTH = $clog2(DATA_MEM_DEPTH);

  // Main Opcodes
  localparam OPCODE_LOAD    = 7'b0000011;  // I-type: lb, lh, lw, ld, lbu, lhu, lwu
  localparam OPCODE_ITYPE   = 7'b0010011;  // I-type: addi, slti, sltiu, xori, ori, andi, slli, srli, srai
  localparam OPCODE_AUIPC   = 7'b0010111;  // U-type: auipc
  localparam OPCODE_STORE   = 7'b0100011;  // S-type: sb, sh, sw, sd
  localparam OPCODE_RTYPE   = 7'b0110011;  // R-type: add, sub, sll, slt, sltu, xor, srl, sra, or, and
  localparam OPCODE_LUI     = 7'b0110111;  // U-type: lui
  localparam OPCODE_BRANCH  = 7'b1100011;  // SB-type: beq, bne, blt, bge, bltu, bgeu
  localparam OPCODE_JALR    = 7'b1100111;  // I-type: jalr
  localparam OPCODE_JAL     = 7'b1101111;  // UJ-type: jal
  
  // For R-type / I-type Arithmetic for ALU Control Unit
  localparam FUNCT7_ADD     = 1'b0;
  localparam FUNCT7_SUB     = 1'b1;
  localparam FUNCT7_SRL     = 1'b0;
  localparam FUNCT7_SRA     = 1'b1;
  localparam FUNCT7_SRLI    = 1'b0;
  localparam FUNCT7_SRAI    = 1'b1;

  // For R-type / I-type Arithmetic
  localparam FUNCT3_ADD_SUB = 3'b000;
  localparam FUNCT3_SLL     = 3'b001;
  localparam FUNCT3_SLT     = 3'b010;
  localparam FUNCT3_SLTU    = 3'b011;
  localparam FUNCT3_XOR     = 3'b100;
  localparam FUNCT3_SRL_SRA = 3'b101;

  // For Load/Store
  localparam FUNCT3_OR      = 3'b110;
  localparam FUNCT3_AND     = 3'b111;
  localparam FUNCT3_SB      = 3'b000;
  localparam FUNCT3_SH      = 3'b001;
  localparam FUNCT3_SW      = 3'b010;
  localparam FUNCT3_LB      = 3'b000;
  localparam FUNCT3_LH      = 3'b001;
  localparam FUNCT3_LW      = 3'b010;
  localparam FUNCT3_LBU     = 3'b100;
  localparam FUNCT3_LHU     = 3'b101;
  localparam FUNCT3_LWU     = 3'b110;

  // For Branch
  localparam FUNCT3_BEQ     = 3'b000;
  localparam FUNCT3_BNE     = 3'b001;
  localparam FUNCT3_BLT     = 3'b100;
  localparam FUNCT3_BGE     = 3'b101;
  localparam FUNCT3_BLTU    = 3'b110;

  typedef enum logic [1:0] {
    FW_NONE,    // no forwarding
    FW_MEM_ALU, // forwarding Mem Stage ALU Result
    FW_WB_DATA  // forwarding WB Stage Data
  } fw_sel_e;

  // Write Back
  typedef enum logic [1:0] {
    WB_ALU,
    WB_MEM,
    WB_PC4,
    WB_NONE
  } wb_sel_e;

  // ALU Sel
  typedef enum logic [3:0] {
    ALU_ADD,    // add, addi, lw, sw, jal, jalr
    ALU_SUB,    // sub, beq, bne, blt, bge, bltu, bgeu
    ALU_AND,    // and, andi
    ALU_XOR,    // xor, xori
    ALU_OR,     // or, ori
    ALU_SLL,    // sll, slli
    ALU_SRL,    // srl, srli
    ALU_SRA,    // sra, srai
    ALU_SLT,    // slt, slti
    ALU_SLTU,   // sltu, sltiu
    ALU_PASS_B, // lut
    ALU_X       // default
  } alu_sel_e;

  // Imm Sel
  typedef enum logic [2:0] {
    IMM_TYPE_I,
    IMM_TYPE_S,
    IMM_TYPE_B,
    IMM_TYPE_U,
    IMM_TYPE_J,
    IMM_TYPE_R
  } imm_sel_e;

  // ALUOp
  typedef enum logic [2:0] {
      ALUOP_RTYPE,         // R-type instructions
      ALUOP_ITYPE_ARITH,   // I-type arithmetic instructions (e.g., addi, slti)
      ALUOP_MEM_ADDR,      // Memory address calculations (e.g., lw, sw)
      ALUOP_BRANCH,        // Branch instructions (e.g., beq, bne)
      ALUOP_LUI,           // Load Upper Immediate
      ALUOP_JUMP,          // Jump instructions (e.g., jal, jalr)
      ALUOP_NONE
  } alu_op_e;
    
endpackage
