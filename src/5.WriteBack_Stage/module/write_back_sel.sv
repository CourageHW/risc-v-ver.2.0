`timescale 1ns / 1ps

import defines::*;

module write_back_sel (
  input wb_sel_e WBSel_i,
  input logic [DATA_WIDTH-1:0] alu_result_i,
  input logic [DATA_WIDTH-1:0] rd_data_i,
  input logic [DATA_WIDTH-1:0] pc_plus4_i,

  output logic [DATA_WIDTH-1:0] writeback_data_o
  );

  always_comb begin
    writeback_data_o = '0;

    unique case (WBSel_i)
      WB_ALU: writeback_data_o = alu_result_i;
      WB_MEM: writeback_data_o = rd_data_i;
      WB_PC4: writeback_data_o = pc_plus4_i;
      default: writeback_data_o = '0;
    endcase
  end
endmodule
