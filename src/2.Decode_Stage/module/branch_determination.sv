`timescale 1ns / 1ps

import defines::*;

module branch_determination (
  input logic BrEq_i,
  input logic BrLT_i,
  input logic BrLTU_i,
  input logic Branch_i,
  input logic [2:0] funct3_i,

  output logic BranchTaken_o
  );

  logic BrSel_w;

  always_comb begin
    BrSel_w = 0;

    unique case (funct3_i)
      FUNCT3_BEQ : BrSel_w = BrEq_i;
      FUNCT3_BNE : BrSel_w = ~BrEq_i;
      FUNCT3_BLT : BrSel_w = BrLT_i;
      FUNCT3_BGE : BrSel_w = ~BrLT_i;
      FUNCT3_BLTU: BrSel_w = BrLTU_i;
      FUNCT3_BGEU: BrSel_w = ~BrLTU_i;
      default : BrSel_w = 0;
    endcase
  end

  assign BranchTaken_o = (Branch_i & BrSel_w);

endmodule
