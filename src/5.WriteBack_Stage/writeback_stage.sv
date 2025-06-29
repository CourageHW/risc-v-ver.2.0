`timescale 1ns / 1ps

import defines::*;

module writeback_stage (
  input wb_sel_e WB_WBSel_i,
  input logic [DATA_WIDTH-1:0] WB_alu_result_i,
  input logic [DATA_WIDTH-1:0] WB_rd_data_i,
  input logic [DATA_WIDTH-1:0] WB_pc_plus4_i,

  output logic [DATA_WIDTH-1:0] WB_writeback_data_o
  );

  write_back_sel wbsel_inst(
    .WBSel_i(WB_WBSel_i),
    .alu_result_i(WB_alu_result_i),
    .rd_data_i(WB_rd_data_i),
    .pc_plus4_i(WB_pc_plus4_i),

    .writeback_data_o(WB_writeback_data_o)
    );
endmodule 
