`timescale 1ns / 1ps

import defines::*;

module MUX_3to1 (
  input logic [DATA_WIDTH-1:0] rd_data_i,
  input logic [DATA_WIDTH-1:0] MEM_ALU_i,
  input logic [DATA_WIDTH-1:0] WB_DATA_i,
  input fw_sel_e sel,
  output logic [DATA_WIDTH-1:0] out
  );

  always_comb begin
    unique case (sel)
      FW_NONE    : out = rd_data_i;
      FW_MEM_ALU : out = MEM_ALU_i;
      FW_WB_DATA : out = WB_DATA_i;
      default: out = 'x;
    endcase
  end

endmodule
