`timescale 1ns / 1ps

import defines::*;

module alu_control_unit (
  input alu_op_e ALUOp_i,
  input logic [2:0] alu_ctrl_funct3_i,
  input logic alu_ctrl_funct7_i,
  output alu_sel_e ALUSel_o
  );

  always_comb begin
    ALUSel_o = ALU_X;

    unique case (ALUOp_i)
      ALUOP_MEM_ADDR: ALUSel_o = ALU_ADD;    // lw, sw
      ALUOP_BRANCH  : ALUSel_o = ALU_SUB;    // beq, bne, blt, bge, bltu, bgeu
      ALUOP_LUI     : ALUSel_o = ALU_PASS_B; // lui
      ALUOP_JUMP    : ALUSel_o = ALU_ADD;    // jal, jalr
      ALUOP_RTYPE   : begin
        unique case (alu_ctrl_funct3_i)
          FUNCT3_ADD_SUB : begin
            if      (alu_ctrl_funct7_i == ALU_ADD) ALUSel_o = ALU_ADD;
            else if (alu_ctrl_funct7_i == ALU_SUB) ALUSel_o = ALU_SUB;
          end

          FUNCT3_SRL_SRA : begin
            if      (alu_ctrl_funct7_i == ALU_SRL) ALUSel_o = ALU_SRL;
            else if (alu_ctrl_funct7_i == ALU_SRA) ALUSel_o = ALU_SRA;
          end

          FUNCT3_SLL     : ALUSel_o = ALU_SLL;
          FUNCT3_SLT     : ALUSel_o = ALU_SLT;
          FUNCT3_SLTU    : ALUSel_o = ALU_SLTU;
          FUNCT3_XOR     : ALUSel_o = ALU_XOR;
          default        : ALUSel_o = ALU_X;
        endcase
      end

      ALUOP_ITYPE_ARITH  : begin
        unique case (alu_ctrl_funct3_i)
          FUNCT3_ADD_SUB : ALUSel_o = ALU_ADD;  // addi
          FUNCT3_SLL     : ALUSel_o = ALU_SLL;  // slli
          FUNCT3_SLT     : ALUSel_o = ALU_SLT;  // slti
          FUNCT3_SLTU    : ALUSel_o = ALU_SLTU; // sltiu
          FUNCT3_XOR     : ALUSel_o = ALU_XOR;  // xori
          FUNCT3_SRL_SRA : begin
            if      (alu_ctrl_funct7_i == ALU_SRL) ALUSel_o = ALU_SRL; // srli
            else if (alu_ctrl_funct7_i == ALU_SRA) ALUSel_o = ALU_SRA; // srai
          end
          default        : ALUSel_o = ALU_X;
        endcase
      end

      default : ALUSel_o = ALU_X;
    endcase
  end

endmodule
