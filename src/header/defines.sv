`timescale 1ns / 1ps
package defines;

  localparam DATA_WIDTH = 32;

  // For R-type / I-type Arithmetic for ALU Control Unit
  parameter FUNCT7_ADD     = 1'b0;
  parameter FUNCT7_SUB     = 1'b1;
  parameter FUNCT7_SRL     = 1'b0;
  parameter FUNCT7_SRA     = 1'b1;
  parameter FUNCT7_SRLI    = 1'b0;
  parameter FUNCT7_SRAI    = 1'b1;

  // For R-type / I-type Arithmetic
  parameter FUNCT3_ADD_SUB = 3'b000;
  parameter FUNCT3_SLL     = 3'b001;
  parameter FUNCT3_SLT     = 3'b010;
  parameter FUNCT3_SLTU    = 3'b011;
  parameter FUNCT3_XOR     = 3'b100;
  parameter FUNCT3_SRL_SRA = 3'b101;

  // For Load/Store
  parameter FUNCT3_OR      = 3'b110;
  parameter FUNCT3_AND     = 3'b111;
  parameter FUNCT3_SB      = 3'b000;
  parameter FUNCT3_SH      = 3'b001;
  parameter FUNCT3_SW      = 3'b010;
  parameter FUNCT3_LB      = 3'b000;
  parameter FUNCT3_LH      = 3'b001;
  parameter FUNCT3_LW      = 3'b010;
  parameter FUNCT3_LBU     = 3'b100;
  parameter FUNCT3_LHU     = 3'b101;
  parameter FUNCT3_LWU     = 3'b110;

  // For Branch
  parameter FUNCT3_BEQ     = 3'b000;
  parameter FUNCT3_BNE     = 3'b001;
  parameter FUNCT3_BLT     = 3'b100;
  parameter FUNCT3_BGE     = 3'b101;
  parameter FUNCT3_BLTU    = 3'b110;

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
