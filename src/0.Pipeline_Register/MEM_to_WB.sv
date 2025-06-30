`timescale 1ns / 1ps

import defines::*;

module MEM_to_WB (
  input logic clk,
  input logic rst_n,
  
  input wb_sel_e MEM_WBSel_i,
  input logic MEM_RegWrite_i,
  input logic MEM_MemWrite_i,
  
  input logic [DATA_WIDTH-1:0] MEM_alu_result_i,
  input logic [DATA_WIDTH-1:0] MEM_instruction_i,
  input logic [DATA_WIDTH-1:0] MEM_rd_data_i,
  input logic [DATA_WIDTH-1:0] MEM_pc_plus4_i,
  input logic [DATA_WIDTH-1:0] MEM_addr_i,
  input logic [DATA_WIDTH-1:0] MEM_wr_data_i,
  
  output wb_sel_e WB_WBSel_o,
  output logic WB_RegWrite_o,
  output logic WB_MemWrite_o,
  
  output logic [DATA_WIDTH-1:0] WB_alu_result_o,
  output logic [DATA_WIDTH-1:0] WB_instruction_o,
  output logic [DATA_WIDTH-1:0] WB_rd_data_o,
  output logic [DATA_WIDTH-1:0] WB_pc_plus4_o,
  output logic [DATA_WIDTH-1:0] WB_addr_o,
  output logic [DATA_WIDTH-1:0] WB_wr_data_o
  );

  always_ff @(posedge clk) begin
    if (!rst_n) begin
       WB_WBSel_o       <= WB_NONE;
       WB_RegWrite_o    <= 0;
       WB_MemWrite_o    <= 0;
       WB_alu_result_o  <= '0;
       WB_instruction_o <= '0;
       WB_rd_data_o     <= '0;
       WB_pc_plus4_o    <= '0;
       WB_addr_o        <= '0;
       WB_wr_data_o     <= '0;
     end else begin
       WB_WBSel_o       <= MEM_WBSel_i;
       WB_RegWrite_o    <= MEM_RegWrite_i;
       WB_MemWrite_o    <= MEM_MemWrite_i;
       WB_alu_result_o  <= MEM_alu_result_i;
       WB_instruction_o <= MEM_instruction_i;
       WB_rd_data_o     <= MEM_rd_data_i;
       WB_pc_plus4_o    <= MEM_pc_plus4_i;
       WB_addr_o        <= MEM_addr_i;
       WB_wr_data_o     <= MEM_wr_data_i;
    end
  end
endmodule
