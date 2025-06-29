`timescale 1ns / 1ps

import defines::*;

module EX_to_MEM (
  input logic clk,
  input logic rst_n,


  input logic EX_alu_zeroFlag_i,
  input wb_sel_e EX_WBSel_i,
  input logic EX_MemRead_i,
  input logic EX_MemWrite_i,
  input logic EX_RegWrite_i,
  
  input logic [DATA_WIDTH-1:0] EX_alu_result_i,
  input logic [DATA_WIDTH-1:0] EX_instruction_i,
  input logic [DATA_WIDTH-1:0] EX_wr_data_i,
  input logic [DATA_WIDTH-1:0] EX_pc_plus4_i,

  output logic MEM_alu_zeroFlag_o,
  output wb_sel_e MEM_WBSel_o,
  output logic MEM_MemRead_o,
  output logic MEM_MemWrite_o,
  output logic MEM_RegWrite_o,
  
  output logic [DATA_WIDTH-1:0] MEM_alu_result_o,
  output logic [DATA_WIDTH-1:0] MEM_instruction_o,
  output logic [DATA_WIDTH-1:0] MEM_wr_data_o,
  output logic [DATA_WIDTH-1:0] MEM_pc_plus4_o
  );

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      MEM_alu_zeroFlag_o <= 0;
      MEM_WBSel_o        <= WB_NONE;
      MEM_MemRead_o      <= 0;
      MEM_MemWrite_o     <= 0;
      MEM_RegWrite_o     <= 0;
      
      MEM_alu_result_o  <= '0;
      MEM_instruction_o <= '0;
      MEM_wr_data_o     <= '0;
      MEM_pc_plus4_o    <= '0;
    end else begin
      MEM_alu_zeroFlag_o <= EX_alu_zeroFlag_i;
      MEM_WBSel_o        <= EX_WBSel_i       ;
      MEM_MemRead_o      <= EX_MemRead_i     ;
      MEM_MemWrite_o     <= EX_MemWrite_i    ;
      MEM_RegWrite_o     <= EX_RegWrite_i    ;
                           
      MEM_alu_result_o  <= EX_alu_result_i  ;
      MEM_instruction_o <= EX_instruction_i ;
      MEM_wr_data_o     <= EX_wr_data_i     ;
      MEM_pc_plus4_o    <= EX_pc_plus4_i    ;
      
    end
  end

endmodule
