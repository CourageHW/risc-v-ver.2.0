`timescale 1ns / 1ps

import defines::*;

module ID_to_EX (
  input logic clk,
  input logic rst_n,
  input logic flush_i,

  input wb_sel_e ID_WBSel_i,
  input fw_sel_e ID_forwardA_i,
  input fw_sel_e ID_forwardB_i,
  input logic ID_MemRead_i,
  input logic ID_MemWrite_i,
  input logic ID_RegWrite_i,
  input alu_op_e ID_ALUOp_i,
  input logic ID_ALUOpSrc1_i,
  input logic ID_ALUOpSrc2_i,

  input logic [DATA_WIDTH-1:0] ID_instruction_i,
  input logic [DATA_WIDTH-1:0] ID_rd_data1_i,
  input logic [DATA_WIDTH-1:0] ID_rd_data2_i,
  input logic [DATA_WIDTH-1:0] ID_imm_i,
  input logic [DATA_WIDTH-1:0] ID_pc_i,
  input logic [DATA_WIDTH-1:0] ID_pc_plus4_i,

  output wb_sel_e EX_WBSel_o,
  output fw_sel_e EX_forwardA_o,
  output fw_sel_e EX_forwardB_o,
  output logic EX_MemRead_o,
  output logic EX_MemWrite_o,
  output logic EX_RegWrite_o,
  output alu_op_e EX_ALUOp_o,
  output logic EX_ALUOpSrc1_o,
  output logic EX_ALUOpSrc2_o,

  output logic [DATA_WIDTH-1:0] EX_instruction_o,
  output logic [DATA_WIDTH-1:0] EX_rd_data1_o,
  output logic [DATA_WIDTH-1:0] EX_rd_data2_o,
  output logic [DATA_WIDTH-1:0] EX_imm_o,
  output logic [DATA_WIDTH-1:0] EX_pc_o,
  output logic [DATA_WIDTH-1:0] EX_pc_plus4_o
  );

  always_ff @(posedge clk) begin
    if (!rst_n || flush_i) begin
      EX_WBSel_o     <= WB_NONE;
      EX_forwardA_o  <= FW_NONE;
      EX_forwardB_o  <= FW_NONE;
      EX_MemRead_o   <= 0;
      EX_MemWrite_o  <= 0;
      EX_RegWrite_o  <= 0;
      EX_ALUOp_o     <= ALUOP_NONE;
      EX_ALUOpSrc1_o <= 0;
      EX_ALUOpSrc2_o <= 0;

      EX_instruction_o <= '0;
      EX_rd_data1_o    <= '0;
      EX_rd_data2_o    <= '0;
      EX_imm_o         <= '0;
      EX_pc_o          <= '0;
      EX_pc_plus4_o    <= '0;
    end else begin
      EX_WBSel_o     <= ID_WBSel_i;
      EX_forwardA_o  <= ID_forwardA_i;
      EX_forwardB_o  <= ID_forwardB_i;
      EX_MemRead_o   <= ID_MemRead_i;
      EX_MemWrite_o  <= ID_MemWrite_i;
      EX_RegWrite_o  <= ID_RegWrite_i;
      EX_ALUOp_o     <= ID_ALUOp_i;
      EX_ALUOpSrc1_o <= ID_ALUOpSrc1_i;
      EX_ALUOpSrc2_o <= ID_ALUOpSrc2_i;

      EX_instruction_o <= ID_instruction_i;
      EX_rd_data1_o    <= ID_rd_data1_i;
      EX_rd_data2_o    <= ID_rd_data2_i;
      EX_imm_o         <= ID_imm_i;
      EX_pc_o          <= ID_pc_i;
      EX_pc_plus4_o    <= ID_pc_plus4_i;
    end
  end

endmodule
